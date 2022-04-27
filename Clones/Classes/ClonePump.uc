//---------------------------------------------------------------
// Pumps that steal clones for whichever team controls the node
// from the other team.
// This file was originally modeled heavily off of the ONSPowerCore
// class, so some functionality within that class has been copied
// to this one, but left commented out, for reference.
//---------------------------------------------------------------
class ClonePump extends DestroyableObjective
	hidecategories(DestroyableObjective); // do not show DestroyableObjective properties in UnrealEd

var() int NumClonesToTake;		// number of clones this pump will steal every SecondsPerClone seconds
var() float SecondsPerClone;    // determines rate that clones are taken from one team and given to another
var int SecondsCounter;
var localized string NeutralString, ConstructingString;

var()   float               ConstructingTime; // time to go from neutral state to active state (in seconds)
var()   sound               DestroyedSound; // sound played when pump set to neutral state
var()	sound				ConstructedSound; // sound played when Constructing complete and entering active state
var()	sound				StartConstructingSound; // sound played when constructing from neutral state
var()   sound               ActiveSound;  // ambient sound played when in active state
var()   sound               NeutralSound; // ambient sound played when in neutral state
var()   sound               HealingSound; // ambient sound played while healing
var()   sound               HealedSound;  // sound played when fully healed
var()   bool                bStartNeutral;// start in neutral state
var()   bool                bPowered;     // currently not used
var     bool                bUnderAttack; // tracks when pump is under attack
var     bool                bOldUnderAttack;

// Internal
var array<Material> RedSkins; // special textures when controlled by red team
var array<Material> BlueSkins; // special textures when controlled by blue team
var byte            PumpStage;
var byte            LastPumpStage;
var float           ConstructingTimeElapsed;
var float           LastAttackTime;
var float           LastAttackExpirationTime;
var float           LastAttackAnnouncementTime;
var float           LastAttackMessageTime;
var float           HealingTime;
var array<Actor>    CloseActors;
var string DestroyedEvent[4];
var string ConstructedEvent[2];
var Controller Constructor; //player who touched me to start Constructing
var Controller LastHealedBy;
//var ONSNodeHealEffect NodeHealEffect; // Update this with our own heal visual effect
//var Emitter ExplosionEffect; // don't use this now?

var PlayerReplicationInfo LastDamagedBy;
var ClonePumpMachine Machine;	// ref to ClonePumpMachine, which handles animated mesh
var ClonePumpCollisionMesh CollMesh; // ref to static mesh that handles collision for the machine
var ClonePump NextPump;

var byte LastDefenderTeamIndex;
var(HUD) vector HUDLocation;

// Breakdown of ClonePump's PumpStage values
// -----------------------------|-------------------------------------------------------
// PumpStage | Meaning          | Description
// -----------------------------|-------------------------------------------------------
// 0         | Active           | Controlled by a team and taking clones from the other
//           |                  | team. Can be healed or shot.
// 1         | Destroyed        | Blown up. Play appropriate visual and audio effects.
// 2         | Constructing     | Building towards the active state. Can be healed or shot
// 3         | Reset            | Reset to default values
// 4         | Neutral          | Ready to be "activated" by a player for his/her team.
// 254       | Static (custom)  | An power source for factories, turrets, etc.
//           |                  | Transparent to the player.
// 255       | Disabled         | ?
// -----------------------------|-------------------------------------------------------

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		PumpStage, bUnderAttack, CollMesh, Machine;
}

simulated function UpdatePrecacheMaterials()
{
	local int i;

	for ( i=0; i<BlueSkins.Length; i++ )
		Level.AddPrecacheMaterial(BlueSkins[i]);

	for ( i=0; i<RedSkins.Length; i++ )
		Level.AddPrecacheMaterial(RedSkins[i]);

    Super.UpdatePrecacheMaterials();
}





simulated event PostBeginPlay()
{
	local rotator MeshRotation;

    Super.PostBeginPlay();
    SetCollision(false, false, false);

	if(Role == ROLE_Authority)
	{
		Machine = spawn(class'ClonePumpMachine', self);

		// turn static mesh 90 to the left so it matches animated mesh
		MeshRotation = Rotation;
		//MeshRotation.Yaw -= 16384; // 90 degrees Commented out because it was fixed in art
		CollMesh = spawn(class'ClonePumpCollisionMesh', self,,,MeshRotation);
	}
}


simulated event PostNetBeginPlay()
{
    FindCloseActors();
}


simulated function ClonePump ClosestTo(Actor A)
{
    local float Distance, BestDistance;
    local ClonePump C, Best;

	BestDistance = VSize(A.Location - Location);
	Best = Self;

	for ( C = NextPump; C != Self && C != None; C = C.NextPump )
	{
		Distance = VSize(A.Location - C.Location);
		if ( Distance < BestDistance )
		{
			BestDistance = Distance;
			Best = C;
		}
	}

	return Best;
}


// Create a list of all the relevant actors to this clone pump (player spawn locations, manned turrets, etc)
simulated function FindCloseActors()
{
	local Actor A;

	CloseActors.Length = 0;

	if (Role == ROLE_Authority)
	{
		foreach AllActors(class 'Actor', A)
			if ( (A.IsA('PlayerStart') || A.IsA('ClonesVehicleFactory') || A.IsA('BerthaPawn') || A.IsA('xTeamBanner') )
			     && ClosestTo(A) == self )
			{
				CloseActors[CloseActors.Length] = A;
			}
	}
	else
	{
		foreach AllActors(class'Actor', A)
			if (A.IsA('xTeamBanner') && ClosestTo(A) == self)
			{
				CloseActors[CloseActors.Length] = A;
			}
	}
}


// Makes this clone pump enter a linked list with the rest
// of the clone pumps on the level via its NextPump member.
simulated function UpdatePumpList()
{
    local ClonePump PC;
    local NavigationPoint N;

//	log(Name@"UpdatePumpList()");
    for ( N = Level.NavigationPointList; N != None; N = N.nextNavigationPoint )
    {
		// only link to another clone pump
    	PC = ClonePump(N);
    	if ( PC != None )
    	{	// ignore if NextPump is already set
    		if ( NextPump == None )
    		{
				if ( PC.NextPump == None )
					NextPump = PC;
				else
					NextPump = PC.NextPump;
				PC.NextPump = Self;
			}
		}
	}
}


function Reset()
{
	Health = DamageCapacity;
	ClonePumpReset();
}


simulated function UpdateTeamBanners()
{
	local int i;

	for (i = 0; i < CloseActors.length; i++)
        	if (xTeamBanner(CloseActors[i]) != None)
        	{
        		if (PumpStage == 0)
	        		xTeamBanner(CloseActors[i]).Team = DefenderTeamIndex;
	        	else
	        		xTeamBanner(CloseActors[i]).Team = 255;
        		xTeamBanner(CloseActors[i]).UpdateForTeam();
        	}
}


simulated event PostNetReceive()
{
    if (PumpStage != LastPumpStage)
    {
//    	log(Name@"PumpStage changed from "$LastPumpStage@"to"@PumpStage);
	   LastPumpStage = PumpStage;
       switch(PumpStage)
        {
            case 0:
                ClonePumpActive();
                break;
            case 1:
                ClonePumpDestroyed();
                break;
            case 2:
                ClonePumpConstructing();
                break;
            case 3:
                ClonePumpReset();
                break;
            case 4:
                ClonePumpNeutral();
                break;
//            case 254:
//				ClonePumpStatic();
//				break;
            case 255:
            	ClonePumpDisabled();
            	break;
        }
    }

    if ( DefenderTeamIndex != LastDefenderTeamIndex )
    {
//    	log(Name@"DefenderTeamIndex changed from "$LastDefenderTeamIndex@"to"@DefenderTeamIndex);
    	LastDefenderTeamIndex = DefenderTeamIndex;
    }
}


// Based on parameter values, set this pump as static,
// neutral, or active (already owned by a team)
event SetInitialState()
{
	if (bStartNeutral)
    {
        PumpStage = 4; // set as neutral
        ClonePumpNeutral();
        if (Role == ROLE_Authority)
            GotoState('NeutralPump'); // set pump in neutral state
    }
    else
    {
		PumpStage = 0; // set as active
        ClonePumpActive();
        if (Role == ROLE_Authority)
            GotoState('');			 // set pump to null state (only non-state functions are called)
    }
}


//
// Returns the number of clones to pump. Positive numbers go to TeamIndex 1, negative numbers go to TeamIndex 0
//
function int Pump()
{
	SecondsCounter++;
		// if clones pump is active (fact that log above ran all the time means we need to check this)
	if(SecondsCounter >= SecondsPerClone)
	{
		SecondsCounter = 0;

		if(PumpStage == 0)
		{
			// Update if we support more than 2 teams
			if(DefenderTeamIndex == 0)
				return -NumClonesToTake;
			else
				return NumClonesToTake;
		}
	}
	return 0;
}


// display proper broadcast message to all players regarding a
// shut down clone pump
function DisableObjective(Pawn Instigator)
{
	local PlayerReplicationInfo	PRI;


	if ( Instigator != None )
		PRI = Instigator.PlayerReplicationInfo;
	else if ( DelayedDamageInstigatorController != None )
		PRI = DelayedDamageInstigatorController.PlayerReplicationInfo;

	// tell everyone that a clone pump was shut down
	BroadcastLocalizedMessage(class'CLNMessage', 6 + DefenderTeamIndex, PRI);

	// no longer awarding points for destroying clone pumps
	//if ( bAccruePoints )
	//	Level.Game.ScoreObjective( PRI, 0 );
	//else
	//{
	//	if (PumpStage == 0)
	//	{
	//		ShareScore(Score, DestroyedEvent[DefenderTeamIndex]);
	//	}
	//	else
	//	{
	//		ShareScore(Score, DestroyedEvent[2+DefenderTeamIndex]);
	//	}
	//}

	// set as destroyed state
	PumpStage = 1;
	ClonePumpDestroyed();

	TeamGame(Level.Game).ObjectiveDisabled(Self);
	TeamGame(Level.Game).FindNewObjectives(Self);
	TriggerEvent(Event, self, Instigator);
}


// ignore any damage dealt to the static mesh.
// we'll see if this is a really bad idea.
// maybe send a text message to whomever hit it
// telling them they need to hit the machinery, not
// the external static mesh.
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{

}


// Controls what happens when this pump take a hit.
// This isn't in TakeDamage because we want the clone pump to
// ignore damage to the static mesh and care only about damage
// to the ClonePumpMachine, which calls HandleDamage.
function HandleDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local Controller InstigatorController;

	// Team index not set correctly yet - don't handle damage
	if(DefenderTeamIndex == 255)
	{
		log("Warning: Team index not set correctly for clone pump.");  // TEMP_CL
		return;
	}

//	Log("HandleDamage Called!",'ClonePump');

	// ignore damage in the neutral and destroyed states or insignificant damage
	if (PumpStage == 4 || PumpStage == 1 || (Damage <= 0))
	{
//		Log(Damage@"damage passed to HandleDamage",'ClonePump');
		return;
	}

	if (damageType == None || !damageType.default.bDelayedDamage)
	{
		DelayedDamageInstigatorController = None;
	}

	if (instigatedBy != None && instigatedBy.Controller != None)
	{
		InstigatorController = instigatedBy.Controller; // keep track of who hit this pump
	}
	else
	{
		InstigatorController = DelayedDamageInstigatorController; // assume it was delayed damage from some effect
	}

	if (InstigatorController == None && damageType != None) // if no controller and no damage type, do nothing
	{
		return;
	}

	if (damageType != None)
	{
		Damage *= damageType.default.VehicleDamageScaling; // use vehicle scaling for specific damage types
	}

    if (instigatedBy != None) // if someone hit the pump
    {
    	if (instigatedBy.HasUDamage()) // check for damage power up and damage scaling
		{
			Damage *= 2;
		}

		Damage *= instigatedBy.DamageScaling;
    }

    // if an member of an opposing team hit this clonepump or its random damage (?)
    if ( InstigatorController == None || (InstigatorController.GetTeamNum() != DefenderTeamIndex) )
    {
		NetUpdateTime = Level.TimeSeconds - 1;
    	AccumulatedDamage += Damage;

    	if ((DamageEventThreshold > 0) && (AccumulatedDamage >= DamageEventThreshold))
    	{
    		TriggerEvent(TakeDamageEvent,self, InstigatedBy); // TODO_CL: will this break stuff as all damage handled through HandleDamage?
    		AccumulatedDamage = 0;
    	}

		if (InstigatorController != None) // if an opposing team member hit us
		{
			LastDamagedBy = InstigatorController.PlayerReplicationInfo;
			// no longer awarding points for destroying clone pumps
			//AddScorer(InstigatorController, FMin(Health, Damage) / DamageCapacity);
		}

    	Health -= Damage; // apply damage

    	if ( Health < 0 ) // if health dropped below 0, disable it (does some bookkeeping, then goes to destoryed state)
		{
    		DisableObjective(instigatedBy);
		}
		else if (damageType != None) // if still alive, send out messages to players
		{
			//attack notification
			if (LastAttackMessageTime + 1 < Level.TimeSeconds) // only yell about being attacked once a second
			{
				// broadcast to all the players that this clone pump is under attack
				BroadcastLocalizedMessage(class'CLNMessage', 4 + DefenderTeamIndex,,, self);
				UnrealTeamInfo(Level.GRI.Teams[DefenderTeamIndex]).AI.CriticalObjectiveWarning(self, instigatedBy);
				LastAttackMessageTime = Level.TimeSeconds; // update attack time
			}
			LastAttackTime = Level.TimeSeconds; // update attack time
		}

		if (InstigatorController != None)
		{
			LastDamagedBy = InstigatorController.PlayerReplicationInfo;
		}
    }
    else if (PlayerController(InstigatorController) != None && InstigatorController.GetTeamNum() != DefenderTeamIndex)
	{
        PlayerController(InstigatorController).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 5);
	}
}


// ignore any healing done to the static mesh.
// we'll see if this is a really bad idea.
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if (PumpStage == 4 || PumpStage == 1 || Health <= 0 || Amount <= 0 || Healer == None || !TeamLink(Healer.GetTeamNum()))
		return false;

	if (Health >= DamageCapacity)
	{
        if (Level.TimeSeconds - HealingTime < 0.5)
            PlaySound(HealedSound, SLOT_Misc, 5.0);

        return false;
    }

	Amount = Min(Amount * LinkHealMult, DamageCapacity - Health);
	Health += Amount;

	NetUpdateTime = Level.TimeSeconds - 1;
    HealingTime = Level.TimeSeconds;
    LastHealedBy = Healer;

// Update this with our own heal visual effect
  //  if (NodeHealEffect == None)
  //  {
  //      NodeHealEffect = Spawn(class'ONSNodeHealEffect', self,, Location + vect(0,0,363));
  //      NodeHealEffect.AmbientSound = HealingSound;
  //  }

  //  Enable('Tick');

    return true;
}


// Controls what happens when this pump is healed.
// This isn't in HealDamage because we want the clone pump to
// ignore healing to the static mesh and care only about damage
// to the ClonePumpMachine, which calls HandleHealing.
function bool HandleHealing(int Amount, Controller Healer, class<DamageType> DamageType)
{

//	Log("HandleHealing Called!",'ClonePump');

	if (PumpStage == 4 || PumpStage == 1 || Health <= 0 || Amount <= 0 || Healer == None || !TeamLink(Healer.GetTeamNum()))
		return false;

	if (Health >= DamageCapacity)
	{
        if (Level.TimeSeconds - HealingTime < 0.5)
            PlaySound(HealedSound, SLOT_Misc, 5.0);

        return false;
    }

	Amount = Min(Amount * LinkHealMult, DamageCapacity - Health);
	Health += Amount;

	NetUpdateTime = Level.TimeSeconds - 1;
    HealingTime = Level.TimeSeconds;
    LastHealedBy = Healer;

// Update this with our own heal visual effect
  //  if (NodeHealEffect == None)
  //  {
  //      NodeHealEffect = Spawn(class'ONSNodeHealEffect', self,, Location + vect(0,0,363));
  //      NodeHealEffect.AmbientSound = HealingSound;
  //  }

  //  Enable('Tick');

    return true;
}


// Update this with our own heal visual effect
//simulated event Tick(float DT)
//{
//    if (Level.TimeSeconds - HealingTime > 0.5)
//    {
//        if (NodeHealEffect != None)
//            NodeHealEffect.Destroy();
//
//	Disable('Tick');
//    }
//}


function UpdateCloseActors()
{
    local int i;
    local Actor A;
    local ONSVehicle V;

    for (i = 0; i < CloseActors.Length; i++)
    {
        A = CloseActors[i];

        //// Disable any vehicle factories in the power radius
        //if (A.IsA('ClonesVehicleFactory'))
        //    ClonesVehicleFactory(A).Deactivate();

        // Disable any turrets in the power radius
		// all clones turrets are derived from BerthaPawn
        if (A.IsA('BerthaPawn'))
        {
			// only disable if it is not a static turret (always same team, always powered)
			if(BerthaPawn(A).bStaticTeam == false)
			{
				BerthaPawn(A).bPowered = False;
				BerthaPawn(A).KDriverLeave(True);
				BerthaPawn(A).Team = 255;
			}
        }
    }
	// all clones vehicles are derived from ONSVehicle
    foreach DynamicActors(class'ONSVehicle', V)
        if (V.bTeamLocked && V.Health > 0 && ClosestTo(V) == self)
            V.Destroy();
}


// Check if an actor is touching the pump and
// call the bump function for each one.
function CheckTouching()
{
    	local Pawn P;

    	foreach CollMesh.BasedActors(class'Pawn', P)
    	{
    		Bump(P);
    		return;
    	}
}


// called when someone touches the pump via the CheckTouching function
// whenever a player touches a pump in active mode, inform the player
// how many clones are left in the reservoir. Keeping this around
// as we might need its functionality later.
simulated function Bump(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);

	// ignore bump if its not a pawn, its not a player, or its a vehicle
	if ( P == None || !P.IsPlayerPawn() || Vehicle(Other) != None )
		return;

	// ignore the bump if we're not in the active state
	// (redundant, as we could ignore bump in other states, but minimizes
	// changes to the onslaught code)
	if ( PumpStage != 0 )
		return;

	//NetUpdateTime = Level.TimeSeconds - 1;
}


simulated function string GetHumanReadableName()
{
	// if its active return which team it belongs to
	if (PumpStage == 0)
		return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]$ObjectiveStringSuffix;
	// if its constructing return which team it belongs to
	else if (PumpStage == 2)
		return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]@ConstructingString;
	// otherwise its neutral, don't worry about including team information
	else
		return NeutralString;
}





// Controls when the health bar should be shown.
simulated function bool HasHealthBar()
{
	// show health bar in active and constructing stages
	return PumpStage == 0 || PumpStage == 2;
}


simulated singular function UpdateHUDLocation( float ScreenX, float ScreenY, float RadarWidth, float Range, vector Center, optional bool bIgnoreRange )
{
	local vector ScreenLocation;
	local float Dist;

    ScreenLocation = Location - Center;
    ScreenLocation.Z = 0;
	Dist = VSize(ScreenLocation);
	if ( bIgnoreRange || (Dist < (Range * 0.95)) )
	{
        HUDLocation.X = ScreenX + ScreenLocation.X * (RadarWidth/Range);
        HUDLocation.Y = ScreenY + ScreenLocation.Y * (RadarWidth/Range);
    }

    if ( NextPump != None )
    	NextPump.UpdateHUDLocation(ScreenX, ScreenY, RadarWidth, Range, Center, bIgnoreRange);
}


function SetTeam(byte TeamIndex)
{
	Super.SetTeam(TeamIndex);

	if (PumpStage == 0)
		ClonePumpActive();
}


// Prep to enter the active state
simulated function ClonePumpActive()
{
	local Actor A;
    local int i;

    AmbientSound = ActiveSound;

//	log(Name@"ClonePumpActive");
    // Update Visuals
    if (Level.NetMode != NM_DedicatedServer)
    {
		// TODO_CL: remove any visual effects from Constructing

		// set static mesh skins for owning team
		if (DefenderTeamIndex == 0)
		{
            // reassign only specific skins
			Skins[0] = RedSkins[0]; // give all the green metal a red hue
            Skins[2] = RedSkins[1]; // sign outline and stars
			Skins[3] = RedSkins[2]; // "now serving" sign
		}
        else
		{
            // reassign only specific skins
			Skins[0] = BlueSkins[0]; // give all the green metal a blue hue
            Skins[2] = BlueSkins[1]; // sign outline and stars
			Skins[3] = BlueSkins[2]; // "now serving" sign
		}

		// have machine do what it needs to do when active
		Machine.SetActive(DefenderTeamIndex);

        UpdateTeamBanners();

		PlaySound(ConstructedSound, SLOT_Misc, 5.0);
    }

    if (Role == ROLE_Authority)
    {
	    Scorers.length = 0; // reset list of people who should get points for destorying the clone pump

        // Update Nearby Powered Actors
        for (i = 0; i < CloseActors.Length; i++)
        {
            A = CloseActors[i];

            // Enable any turrets in the power radius
            If (A.IsA('BerthaPawn'))
            {
				// only enable if it is not a static turret (always same team, always powered)
				if(BerthaPawn(A).bStaticTeam == false)
				{
					BerthaPawn(A).bPowered = True;
					BerthaPawn(A).SetTeamNum(DefenderTeamIndex);
					BerthaPawn(A).PrevTeam = DefenderTeamIndex;
				}
			}
        }

		// TODO_CL - test reassing objects like this...
		TeamGame(Level.Game).FindNewObjectives(Self);
    }

	SetTimer(SecondsPerClone, true); // enable timer for clone pumping
}


// Reset the clone pump
simulated function ClonePumpReset()
{
//	log(Name@"ClonePumpReset");

	if (Role == ROLE_Authority)
	{
		UpdateCloseActors();
		NetUpdateTime = Level.TimeSeconds - 1;
		// reset team index only if its not a main base node
		DefenderTeamIndex = default.DefenderTeamIndex;
			// this will work fine if the ClonePump class was subclassed
			// into red and blue versions to the default value could be
			// set appropriately
//		Log(Name@"team set to"@DefenderTeamIndex);

		if ( bScriptInitialized )
			SetInitialState();
	}
}


// Set the clone pump in the neutral state, where the
// internal machinery is ghosted (or not shown) and
// any player can start constructing for their team
// by touching the internal machinery (for now)
simulated function ClonePumpNeutral()
{
	AmbientSound = NeutralSound;

//	log(Name@"ClonePumpNeutral");
    Health = 0;
    bPowered = False;
    DefenderTeamIndex = 2; // null team
	NetUpdateTime = Level.TimeSeconds - 1;

	// eye and ear-candy stuff
    if (Level.NetMode != NM_DedicatedServer)
	{
        UpdateTeamBanners(); // update HUD?
	}

    if (Role == ROLE_Authority)
    {
    	NetUpdateTime = Level.TimeSeconds - 1;
	}

}


// In this state, the pump is waiting for a player to touch it and start
// the Constructing process. Neutral pumps can't be used or damaged.
state NeutralPump
{
	ignores UsedBy, HandleDamage; // ignore damage to the internal machinery when neutral, can't use neutral pumps

	// called when someone touches the pump via the CheckTouching function
	function Bump(Actor Other)
	{
		// ignore bump if its not a pawn, its not a player, or its a vehicle
		if ( (Pawn(Other) == None) || !Pawn(Other).IsPlayerPawn() || Vehicle(Other) != None )
			return;

		NetUpdateTime = Level.TimeSeconds - 1;
		DefenderTeamIndex = Pawn(Other).GetTeamNum();	// set pump on team of player who touched it
		Constructor = Pawn(Other).Controller;			// record who touched it
		GotoState('Constructing');					// enter constructing state
    }

	// check for being touched by stuff when pump is neutral
	event BeginState()
	{
		CheckTouching(); // essentially calls Bump for each actor "based" on the pump
	}
}


// The pump is a static, invisible pump whose sole purpose is to power the
// vehicle factories, turrets, and other actors at a team's main base.
state Static
{
	ignores Bump, UsedBy;
}


simulated function ClonePumpConstructing()
{
	AmbientSound = HealingSound;

	// ear and eye-candy stuff
	if (Level.NetMode != NM_DedicatedServer)
    {
		// set animated mesh skins for the constructing team
		Machine.SetConstructing(DefenderTeamIndex);

        UpdateTeamBanners();
    }

	// broadcast message to all players that a clone pump is being constructed
    if (Role == ROLE_Authority)
    	BroadcastLocalizedMessage(class'CLNMessage', 8 + DefenderTeamIndex);
}


// The pump is gaining health at a fixed rate. When it reaches full health, it will
// begin transferring clones from its reservoir to the owning team. A pump in this
// state can be healed and take damage normally. If its health reaches zero, it will
// revert back to the neutral state after temporarilly going to the destroyed state
// for visual effects
state Constructing
{

	ignores Bump, UsedBy;

	function BeginState() // called before Begin:
	{
		Scorers.length = 0;
		PlaySound(StartConstructingSound, SLOT_Misc, 5.0);	// play Constructing sound
		PumpStage = 2; // constructing state
	}

    event Timer()
    {
		// don't progress with Constructing if we've just been attacked
    	if (Level.TimeSeconds < LastAttackTime + 1.0)
    		return;

		NetUpdateTime = Level.TimeSeconds - 1;

        ConstructingTimeElapsed += 1.0;		// update construction time
        Health += (1.0 / ConstructingTime) * DamageCapacity; // add sliver of health

		// if the pump is fully constructed
        if (Health > DamageCapacity)
        {
            SetTimer(0.0, False);		// stop constructing
            Health = DamageCapacity;	// cap health to max health
            PumpStage = 0;				// set pump as active
            ClonePumpActive();			// do active stuff

            // broadcast message that team X has finished powering up
            BroadcastLocalizedMessage( class'CLNMessage', 0 + DefenderTeamIndex);

            // give score points to the player who constructed this pump
            if (Constructor != None && Constructor.PlayerReplicationInfo != None)
            {
				// points scored is based on number of clones this pump steals per cycle (doesn't take SecondsPerClone into account)
				Level.Game.ScoreObjective(Constructor.PlayerReplicationInfo, NumClonesToTake * 2.0 + 2); // update player's score
        	    Level.Game.ScoreEvent(Constructor.PlayerReplicationInfo, NumClonesToTake * 2.0 + 2, ConstructedEvent[DefenderTeamIndex]); // logs stats
            }
            TeamGame(Level.Game).FindNewObjectives(self);
            GotoState(''); // enter null state (only non-state functions are called) as the pump is now active
        }
    }

Begin:
    sleep(0.5);											// wait 1/2 secs (call only be called in Begin, as its a latent function)
	ClonePumpConstructing();							// Do fancy visual stuff. This call is in both PostNetRecieve and here so it works in single + multiplayer
    ConstructingTimeElapsed = 0.0;						// reset Constructing timer count
    SetTimer(1.0, True);								// Call Timer() once a second (looping)

}


// Called when a clone pump runs out of clones
// destroy the clone pump and stop showing it
simulated function ClonePumpDisabled()
{
	// hide and set as unpowered
    bHidden = True;
	Machine.bHidden = True;
    bPowered = False;

	// stop ambient sound
	AmbientSound = None;

	Machine.SetDestroyed();

//	Log("ClonePumpDisabled called", 'ClonePump');

    // broadcast message that this pump is empty only if it meant to pump
    // in the first place
    if(SecondsPerClone > 0.0)
    {
		//Log("ClonePump.ClonePumpDisabled: Info. Clone pump ran dry. Disabling pump.");
		BroadcastLocalizedMessage(class'CLNMessage', 10 + DefenderTeamIndex);

		// play some crazy explosion effect (BOOM)
		if (Level.NetMode != NM_DedicatedServer)
		{
			// TODO_CL: add a more fitting explosion effect and better sound (too quiet right now)
			//spawn(class'ONSSmallVehicleExplosionEffect',self,, Location + vect(0,0,200));
			spawn(class'RedeemerExplosion',self,, Location + vect(0,0,200));
			PlaySound(sound'WeaponSounds.redeemer_explosionsound');
		}
    }
}


// enter this state when the clone pump runs dry and needs to disappear
state DisabledPump
{
	event BeginState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		SetCollision(false, false); // stop collision
		bDisabled = true;
		SetTimer(0, false);
		NetUpdateFrequency = 0.1;
	}

	event EndState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		SetCollision(default.bCollideActors, default.bBlockActors);
		bDisabled = false;
		NetUpdateFrequency = default.NetUpdateFrequency;
		UnrealMPGameInfo(Level.Game).FindNewObjectives(self);
	}

}


simulated function ClonePumpDestroyed()
{
    Health = 0; // clear health

	AmbientSound = None;

	// Play visual and audio destruction effects
    if (Level.NetMode != NM_DedicatedServer)
	{
        spawn(class'PumpExplosion',self,, Location + vect(0,0,200));
		PlaySound(sound'WeaponSounds.BExplosion3');

		// set static mesh skins for owning team
		if (DefenderTeamIndex == 0)
		{
            // reassign only specific skins
			Skins[0] = default.Skins[0];
            Skins[2] = default.Skins[2];
			Skins[3] = default.Skins[3];
		}
        else
		{
            // reassign only specific skins
			Skins[0] = default.Skins[0];
            Skins[2] = default.Skins[2];
			Skins[3] = default.Skins[3];
		}

		// set visual effects for the machine
		Machine.SetDestroyed();
	}

    if (Role == ROLE_Authority)
    {
		NetUpdateTime = Level.TimeSeconds - 1;
		Scorers.length = 0;
        UpdateCloseActors();

		DefenderTeamIndex = 2; // set team to null
        GotoState('DestroyedPump'); // set state as destroyed
    }
}


// clone pump was just destroyed, transition to neutral state
state DestroyedPump
{
Begin:
    sleep(2.0);

	// go to neutral state
	PumpStage = 4;
	ClonePumpNeutral();
	GotoState('NeutralPump');
}




//////////////////////////////////////////////////
// Bot Stuff

simulated function bool OwnedBy(byte Team)
{
    return Team == DefenderTeamIndex;
}



function bool TellBotHowToHeal(Bot B)
{
	//log("ClonePump::TellBotHowToHeal");
	return Super.TellBotHowToHeal(B);
}



function bool TellBotHowToDisable(Bot B)
{
	//log("ClonePump::TellBotHowToDisable");

	if (PumpStage == 4 || PumpStage == 1)
		return B.Squad.FindPathToObjective(B, self);

	if(OwnedBy(B.Squad.Team.TeamIndex) && !TellBotHowToHeal(B))
	{
		return false;
	}
	return Super.TellBotHowToDisable(B);
}



function bool KillEnemyFirst(Bot B)
{
	if ( !bUnderAttack || Health < DamageCapacity * 0.25
	     || (Vehicle(B.Pawn) != None && Vehicle(B.Pawn).IndependentVehicle() && Vehicle(B.Pawn).HasOccupiedTurret()) )
		return false;

	if (B.Enemy != None && B.Enemy.Controller != None && B.Enemy.CanAttack(B.Pawn))
	{
		if (B.Aggressiveness > 0.4)
			return true;

		return (B.LastUnderFire > Level.TimeSeconds - 1);
	}

	if (Level.TimeSeconds - HealingTime < 0.5 && LastHealedBy != None && LastHealedBy.Pawn != None && LastHealedBy.Pawn.Health > 0)
	{
		//attack enemy healing me
		B.Enemy = LastHealedBy.Pawn;
		B.EnemyChanged(true);
		return true;
	}

	return false;
}



function bool NearObjective(Pawn P)
{
	if (P.CanAttack(GetShootTarget()))
		return true;

	return (VSize(Location - P.Location) < BaseRadius && P.LineOfSightTo(self));
}

defaultproperties
{
     NumClonesToTake=1
     SecondsPerClone=10.000000
     NeutralString="Neutral Clone Pump"
     ConstructingString=" Team Activating Clone Pump"
     ConstructingTime=30.000000
     DestroyedSound=Sound'ONSVehicleSounds-S.PowerCore.PowerCoreExplosion01'
     ConstructedSound=Sound'ONSVehicleSounds-S.PowerNode.whooshthunk'
     StartConstructingSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeBuild02'
     ActiveSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeActive01'
     NeutralSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeNOTActive01'
     HealingSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeStartBuild03'
     HealedSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeBuilt01'
     bStartNeutral=True
     bPowered=True
     RedSkins(0)=Combiner'CS_CloneItems_T.ClonePump.PumpRedCombo'
     RedSkins(1)=MaterialSequence'CS_CloneItems_T.ClonePump.EdgeFlashRed'
     RedSkins(2)=Texture'CS_CloneItems_T.ClonePump.ScreenTeamRed'
     BlueSkins(0)=Combiner'CS_CloneItems_T.ClonePump.PumpBlueCombo'
     BlueSkins(1)=MaterialSequence'CS_CloneItems_T.ClonePump.EdgeFlashBlue'
     BlueSkins(2)=Texture'CS_CloneItems_T.ClonePump.ScreenTeamBlue'
     PumpStage=4
     LastPumpStage=250
     LastAttackExpirationTime=5.000000
     DestroyedEvent(0)="red_clonepump_destroyed"
     DestroyedEvent(1)="blue_clonepump_destroyed"
     DestroyedEvent(2)="red_constructing_clonepump_destroyed"
     DestroyedEvent(3)="blue_constructing_clonepump_destroyed"
     ConstructedEvent(0)="red_clonepump_constructed"
     ConstructedEvent(1)="blue_clonepump_constructed"
     LastDefenderTeamIndex=2
     DamageCapacity=1000
     LinkHealMult=1.000000
     AIShootOffset=(Z=400.000000)
     DefenderTeamIndex=255
     DefensePriority=1
     Score=0
     DestructionMessage=""
     ObjectiveStringSuffix=" Team Clone Pump"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CS_CloneItems_S.ClonePump.ClonePumpScaffolding'
     bHidden=False
     DrawScale=2.000000
     Skins(0)=Combiner'CS_CloneItems_T.ClonePump.PumpNeutralCombo'
     Skins(1)=Texture'CS_CloneItems_T.ClonePump.Concrete'
     Skins(2)=Shader'CS_CloneItems_T.ClonePump.EdgeGlowShader'
     Skins(3)=Texture'CS_CloneItems_T.ClonePump.OutOfOrder'
     Skins(4)=Shader'CS_CloneItems_T.ClonePump.NowServingShader'
     SoundVolume=200
     SoundRadius=255.000000
     CollisionRadius=220.000000
     CollisionHeight=250.000000
     bCollideActors=False
     bProjTarget=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bNetNotify=True
}
