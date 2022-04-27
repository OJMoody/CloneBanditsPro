class CloneJar extends GameObject;

var byte 			TeamNum;    	
var UnrealTeamInfo 	Team;
var UnrealPawn 		OldHolder;
var GameReplicationInfo GRI;
var Emitter FlagEffect;

var int ClonesInJar;

var() Sound TakeFlagSound;
var() Sound ReturnFlagSound;
var() Sound DropFlagSound;

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority )
		ClonesInJar, Team;
}



simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
}	



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);

	if(Level.GetLocalPlayerController() != NONE)
		ClonesHUD(Level.GetLocalPlayerController().myHUD).UpdateCloneJars();
	
	if(Role == ROLE_Authority)
		ClonesGame(Level.Game).UpdateCloneJars();
}



simulated event Destroyed()
{
	if(Level.GetLocalPlayerController() != NONE)
		ClonesHUD(Level.GetLocalPlayerController().myHUD).UpdateCloneJars();

	if(Role == ROLE_Authority)
		ClonesGame(Level.Game).UpdateCloneJars();
}



function Score()
{
	Destroy();
}



// State transitions
function SetHolder(Controller C)
{
	Holder = UnrealPawn(C.Pawn);
	if(Holder.PlayerReplicationInfo.HasFlag != NONE)
	{
//		log("Allready Holding Jar!  Not doing anything!");
		return;
	}

	//Play Sound for flag taker
	if(PlayerController(C) != NONE)
		PlayerController(C).ClientPlaySound(TakeFlagSound);

	//TODO_CL - consider doing some AI stuff here
	//local CTFSquadAI S;
	//
	//// AI Related
	//if ( Bot(C) != None )
	//	S = CTFSquadAI(Bot(C).Squad);
	//else if ( PlayerController(C) != None )
	//	S = CTFSquadAI(UnrealTeamInfo(C.PlayerReplicationInfo.Team).AI.FindHumanSquad());
	//if ( S != None )
	//	S.EnemyFlagTakenBy(C);

	Super.SetHolder(C);
	
    //C.SendMessage(None, 'OTHER', C.GetMessageIndex('GOTENEMYFLAG'), 10, 'TEAM');	// don't want "flag" messages
}



function Drop(vector newVel)
{
    OldHolder = Holder;

	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));

    Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	if ( PhysicsVolume.bWaterVolume )
		Velocity *= 0.5;

    Super.Drop(Velocity);
}



// called when the jar leaves play
// bReturnClones controls if the clones in this jar are returned
// to the controlling team or not
function MySendHome(bool bReturnClones)
{
	if(bReturnClones)
	{
		ClonesGame(Level.Game).AddClones(Team.TeamIndex, ClonesInJar);
	}
	else
	{	
//		Log(ClonesInJar@"clones lost when clone jar expired");	
		// broadcast message to all players that this team just lost some clones
		BroadcastLocalizedMessage(class'CLNMessage', 12 + Team.TeamIndex, , , self);
	}
	Destroy();
}


// Helper funcs
function bool SameTeam(Controller c)
{
    if (c == None || c.PlayerReplicationInfo.Team != Team)
        return false;

    return true;
}

function bool ValidHolder(Actor Other)
{
    local Controller c;

//	log("Debugging: ValidHolder  Self="$Self$" Other="$Other$" GetStateName="$GetStateName()); //DO NOT REMOVE - this is to test the not capping clone jar problem that I could not reproduce in testing

    if (!Super.ValidHolder(Other))
        return false;

    c = Pawn(Other).Controller;
	if (SameTeam(c))
	{
        SameTeamTouch(c);
        return false;
	}

    return true;
}

function SameTeamTouch(Controller c)
{
}

// Events
function Landed(vector HitNormal)
{
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	Super.Landed(HitNormal);
}

// Logging
function LogReturned();

function LogDropped()
{
	if ( bLastSecondSave )
		BroadcastLocalizedMessage( class'LastSecondMessage', 0, Holder.PlayerReplicationInfo, None, Team );
	else
		//BroadcastLocalizedMessage( MessageClass, 2, Holder.PlayerReplicationInfo, None, Team );
		BroadcastLocalizedMessage( class'CLNMessage', 20 + Team.TeamIndex, Holder.PlayerReplicationInfo , None, self );
	bLastSecondSave = false;
	UnrealMPGameInfo(Level.Game).GameEvent("flag_dropped",""$Team.TeamIndex, Holder.PlayerReplicationInfo);

	//Play Sound for flag taker
	if(PlayerController(Holder.Controller) != NONE)
		PlayerController(Holder.Controller).ClientPlaySound(DropFlagSound);
}

function CheckPain(); // stub

event FellOutOfWorld(eKillZType KillType)
{
	BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
    MySendHome(true); // return clones in this jar to its team
}



// States
auto state Home
{
	ignores SendHome, Score, Drop;

	function SameTeamTouch(Controller c)
	{
    }
        
    function LogTaken(Controller c)
    {
		local int clonesForJar;
		local CloneJarBase jarBase;

        UnrealMPGameInfo(Level.Game).GameEvent("flag_taken",""$Team.TeamIndex,C.PlayerReplicationInfo);
		
		// get a handle to the base of this clone jar
		jarBase = CloneJarBase(HomeBase);

		if(jarBase != None)
		{
			// Notify the base that the Jar is taken
			jarBase.NotifyTakeJar();

			// determine how many should go in the Jar
			clonesForJar = jarBase.GetClonesToTake();
			// see how many we can get from the repository
			clonesForJar = jarBase.MyGame.TakeClones(Team.TeamIndex, clonesForJar);
			// if none to take, flag error
			if(clonesForJar == 0)
			{
//				Log("Attempting to take a clone jar when there are no clones to take",'Warning');
			}
			else // put clones in the jar
			{
//				Log("Put "$clonesForJar$" clones in "$self$".",'CloneJar');	
				ClonesInJar = clonesForJar;
				if(self == None)
				{
					// temp debug. this never executes
//					Log("self == None in State Home LogTaken",'CloneJar');

					// TODO_CL: so self is valid right now, but when CLNMessage tries to use it, it
					// is set to None. The same call works later in this class when LogTaken is called
					// in the Dropped state. What gives?
				}
				BroadcastLocalizedMessage( class'CLNMessage', 14 + Team.TeamIndex, C.PlayerReplicationInfo, None, self );
			}			
		}
		else
		{
//			Log("Clone Jar has invalid HomeBase. Cannot assign clones.", 'Warning');
		}
     }

	function BeginState()
	{
        Super.BeginState();
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Home;
		HomeBase.AmbientSound = None; //CTL
		HomeBase.NetUpdateTime = Level.TimeSeconds - 1;
	}

	function EndState()
	{
		Super.EndState();
		HomeBase.NetUpdateTime = Level.TimeSeconds - 1;
	}
}



state Held
{
    ignores SetHolder;

	function Timer()
	{
		if (Holder == None)
        {
//            log(self$" Held.Timer: had to sendhome", 'Error');
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			MySendHome(true); // return jar to owning team (also returns any clones to the team's repository)
        }
	}

	function BeginState()
	{
		//local Rotator rot;

        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_HeldEnemy;
        Super.BeginState();
		SetTimer(10.0, true); // start timer to check for no holder every 10 seconds

		// TEMP_CL
		//rot.Pitch = -16384;
		//FlagEffect = spawn(class'FX_NewIonCore', self,, Holder.location, rot); // spawn visual effect on jar carrier
		//FlagEffect.SetBase(Holder);
	}

	function EndState()
	{
		Super.EndState();
		// TEMP_CL
		//FlagEffect.Kill();
		//FlagEffect = NONE;
	}
}



state Dropped
{
   ignores Drop;

   function SameTeamTouch(Controller c)
	{
		// returned Jar
		BroadcastLocalizedMessage( class'CLNMessage', 18 + Team.TeamIndex, C.PlayerReplicationInfo, None, self );
		//BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
		ClonesGame(Level.Game).ScoreJar(C, self);
		MySendHome(true); // return jar to owning team (also returns any clones to the team's repository)

		//Play Sound for flag taker
		if(PlayerController(C) != NONE)
			PlayerController(C).ClientPlaySound(ReturnFlagSound);
	}

    function LogTaken(Controller c)
    {
        UnrealMPGameInfo(Level.Game).GameEvent("flag_pickup",""$Team.TeamIndex,C.PlayerReplicationInfo);
        //BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
        BroadcastLocalizedMessage( class'CLNMessage', 14 + Team.TeamIndex, C.PlayerReplicationInfo, None, self );
    }

    function CheckFit()
    {
	    local vector X,Y,Z;

	    GetAxes(OldHolder.Rotation, X,Y,Z);
	    SetRotation(rotator(-1 * X));
	    if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5)) 
		    && !SetLocation(OldHolder.Location) )
	    {
		    SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
		    if ( !SetLocation(OldHolder.Location) )
		    {
//                log(self$" Drop sent Jar home", 'Error');
				UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
				BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			    MySendHome(true); // return jar to owning team (also returns any clones to the team's repository)
			    return;
		    }
	    }
    }

	function BeginState()
	{
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Down;
        Super.BeginState();
	    bCollideWorld = true;
	    SetCollisionSize(0.5 * default.CollisionRadius, CollisionHeight);
        SetCollision(true, false, false);
        CheckFit();
        //CheckPain();
        //BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
		SetTimer(MaxDropTime, false);
	}
    
    function EndState()
    {
        Super.EndState();
		bCollideWorld = false;
		SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
    }
	
	function Timer()
	{
		UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
		MySendHome(false); // do not return clones to this jar's team
	}
}

defaultproperties
{
     TakeFlagSound=Sound'PickupSounds.AdrenelinPickup'
     ReturnFlagSound=Sound'WeaponSounds.Misc.item_respawn'
     DropFlagSound=Sound'2K4MenuSounds.Generic.msfxDrag'
     bHome=True
     MaxDropTime=45.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CS_CloneItems_S.CloneJar.CloneJar'
     bStatic=False
     bStasis=False
     bAlwaysRelevant=True
     Physics=PHYS_Rotating
     NetPriority=3.000000
     DrawScale=0.600000
     PrePivot=(X=2.000000,Z=0.500000)
     Style=STY_Masked
     bUnlit=True
     CollisionRadius=48.000000
     CollisionHeight=30.000000
     bCollideActors=True
     bCollideWorld=True
     bFixedRotationDir=True
     Mass=30.000000
     Buoyancy=20.000000
     RotationRate=(Yaw=20000)
     MessageClass=Class'UnrealGame.CTFMessage'
}
