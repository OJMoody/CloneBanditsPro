//-----------------------------------------------------------
// Created by Demiurge Studios
//-----------------------------------------------------------

class ClonesGame extends xTeamGame;

var private array<int> TeamCloneCounts;	// number of clones each team possesses. ONLY FOR ClonesGame TO TOUCH!!!

// These two scale the number of clones by the specified number
// The number of clones when these two are 1.0 is equal to whatever is specified in the map
var() config float BlueCloneMultiplier; 
var() config float RedCloneMultiplier; 

var array<ClonePump>		ClonePumps;		// list of all clone pumps in the game
var array<CloneJarBase>		CloneJarBases;  // list of all clone jar bases in the game
var	array<CloneJar>			CloneJarArray;	// list of all clone jars loose in the level

var float ClonePumpCounter; // Seconds counter to pump the clone pumps

var string MapMenuClass;	//This menu is displayed to players when they die - it should contain the map for choosing where to respawn at

var		config	int				ReinforcementsFreq;			// Reinforcement frequency (seconds, 0 = no reinforcements)
var				int				ReinforcementsCount;

var int NoClonesEndGameCountDown[2];
var int NoClonesStage[2];
var NoClonesTimer NoClonesTimers[2];
var TeamInfo NoCloneTimerRanOutTeam;
var int AllDeadIndex;

var(LoadingHints) private localized array<string> ClonesHints;

replication
{
	reliable if(Role == ROLE_Authority)
		TeamCloneCounts;
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	// TODO_CL replace these sounds with our own custom sounds
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('NewRoundIn');
	}
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

    // Since we're a mod, we never show parent game's hints

    for(i = 0; i < default.ClonesHints.Length; i++)
    {
        Hints[i] = default.ClonesHints[i];
    }

	return Hints;
}

simulated function int GetTeamCloneCount(int Team)
{
	return TeamCloneCounts[Team];
}

function AddGameSpecificInventory(Pawn p)
{
	local Inventory Inv;

	Super.AddGameSpecificInventory(p);

	p.CreateInventory("XWeapons.LinkGun");
	p.CreateInventory("Onslaught.ONSAVRiL");
	p.CreateInventory("XWeapons.RocketLauncher");
	p.CreateInventory("Onslaught.ONSGrenadeLauncher");
	p.CreateInventory("XWeapons.FlakCannon");
	p.CreateInventory("XWeapons.Minigun");
	p.CreateInventory("UTClassic.ClassicSniperRifle");

	For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Weapon(Inv) != None )
			Weapon(Inv).MaxOutAmmo();
	}

}

function PostBeginPlay()
{
	local LinkAmmoPickup A;

	Super.PostBeginPlay();

	TeamCloneCounts[0] *= RedCloneMultiplier;
	TeamCloneCounts[1] *= BlueCloneMultiplier;

	// Dump to the ini file
	SaveConfig();

	// Link Ammo is very important in Clones
	ForEach DynamicActors(class'LinkAmmoPickup', A)
		A.MaxDesireability *= 2;

	// removing this breaks stuff
	SetTeamJars(); //CTF stuff

	UpdateCloneJars();
}

function SetInitialState()
{
    Super.SetInitialState();

    UpdateLinks();
}

function Reset()
{
	NoCloneTimerRanOutTeam = NONE;
	AllDeadIndex = -1;
	Super.Reset();
}

simulated event Tick(float DeltaTime)
{
	local int i;
	local int total;
	local int NumClonesTaken;

	super.Tick(DeltaTime);

	if(Role == ROLE_Authority)
	{
		ClonePumpCounter += DeltaTime;
		if(ClonePumpCounter > 1.0)
		{
			// Pump Clones and update each pump's clone count displays as well
			for(i = 0; i < ClonePumps.Length; i++)
			{
				total += ClonePumps[i].Pump();
				ClonePumps[i].Machine.RedCount = GameReplicationInfo.Teams[0].Score;
				ClonePumps[i].Machine.BlueCount = GameReplicationInfo.Teams[1].Score;
			}

			ClonePumpCounter = 0;

			NumClonesTaken = abs(total);
			// If we can steal clones
			if(total > 0)
			{
				NumClonesTaken = TakeClones(0, NumClonesTaken); // try to take desired amount
				AddClones(1, NumClonesTaken); // give however many were taken to the team controlling this pump
			}
			else if(total < 0)
			{
				NumClonesTaken = TakeClones(1, NumClonesTaken); // try to take desired amount
				AddClones(0, NumClonesTaken); // give however many were taken to the team controlling this pump
			}
		}

		for(i = 0; i < 2; i++)
			GameReplicationInfo.Teams[i].Score = TeamCloneCounts[i];
	}
}

event InitGame(string Options, out string Error)
{
	local string MapName;
	local int y;
	local NavigationPoint N;
	local ClonePump Pump;

	Super.InitGame(Options, Error);

	y = 0;

	// create lists of clone pumps and clone jar bases
	for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		if (N.IsA('CloneJarBase'))
		{
//			Log("CloneJarBase found in the naviation list",'ClonesGame');
			CloneJarBases[y] = CloneJarBase(N);
			y++;
		}
	}

	foreach AllActors(class'ClonePump', Pump)
	{
//		Log("ClonesGame::InitGame. ClonePump found in the naviation list");
		ClonePumps[ClonePumps.Length] = Pump;
	}

	if (ClonePumps.Length == 0)
	{
//		Log("ClonesGame::InitGame. Level doesn't have any ClonePumps!",'Error');
		return;
	}
	else
	{
		// make ClonePumps on the level form a looped linked list
		// between each other
		SetupClonePumpLinkedList();
	}

	MapName = Left(string(Level), InStr(string(Level), "."));

	// TODO Al: add this option to the UI
	ReinforcementsFreq	= 10; // Max(0, GetIntOption( Options, "ReinforcementsFreq", ReinforcementsFreq ));
}

function BeginRound()
{
	ReinforcementsCount = ReinforcementsFreq;	// Start reinforcements right away

}

function StartMatch()
{
	Super.StartMatch();
	BeginRound();
}



// Creates a looped linked list between
// all the ClonePumps on the level by setting
// their NextPump member
// Modelled off of ONSOnslaughtGame.ResetPowerLinks
// The ClonePumps array must be initialized BEFORE this
// function is called.
function SetupClonePumpLinkedList()
{
	local int x;

//	Log("ClonesGame::SetupClonePumpLinkedList");

	for (x = 0; x < ClonePumps.length; x++)
		ClonePumps[x].UpdatePumpList();


	//for (x = 0; x < ClonePumps.length; x++)
	//	Log(ClonePumps[x].Name@"'s NextPump ="$ClonePumps[x].NextPump.Name);
}



// tests if players touch ClonePumps
function UpdateLinks()
{
	local int i;

    if (!bScriptInitialized)	//ClonePumps haven't done PostBeginPlay() yet
        return;

    for (i=0; i<ClonePumps.Length; i++)
    {
		// if the clone pump is neutral, check for players powering it up for their team
		if (ClonePumps[i].PumpStage == 4)
		{
			ClonePumps[i].CheckTouching();	// check if someone is touching it
		}
    }
}



simulated function UpdateCloneJars()
{
	local CloneJar jar;

	CloneJarArray.Length = 0;
	foreach AllActors(class'CloneJar', jar)
	{
		if(!jar.bPendingDelete)
			CloneJarArray[CloneJarArray.Length] = jar;
	}
}



event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
	local PlayerController PC;

	PC = Super.Login( Portal, Options, Error );

	return PC;
}

State MatchInProgress
{
	function Timer()
	{
        local Controller C;
		local Bot B;
        local TranslocatorBeacon Trans;
        local Vehicle V;
        local array<Vehicle> KillVehicles;
		local Inventory Inv;
		local int i, TeamNodes[2], TotalNodes;
		local PlayerController PC;

		// for all the ClonePumps in the game
        for(i=0;i<ClonePumps.Length;i++)
        {
			// update a ConePump's under attack status based on how much time has elapsed since it was last attacked
            ClonePumps[i].bUnderAttack = (Level.TimeSeconds - ClonePumps[i].LastAttackTime < ClonePumps[i].LastAttackExpirationTime);

			// if the clone pump is not disabled
            if (ClonePumps[i].PumpStage != 255)
			{
				// if the clone pump is active and on a valid team (0=red, 1=blue)
	    		if (ClonePumps[i].PumpStage == 0 && ClonePumps[i].DefenderTeamIndex < 2)
					// update number of clone pumps this team has
	           		TeamNodes[ClonePumps[i].DefenderTeamIndex]++;
				TotalNodes++; // update total number of active ClonePumps
			}
        }

        Super.Timer(); // Need this!!!

		// If a game reset is in progress
        if (ResetCountDown > 0)
        {
            ResetCountDown--;
            if ( ResetCountDown < 3 )
            {
				// blow up all redeemer guided warheads
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
					if ( (C.Pawn != None) && C.Pawn.IsA('RedeemerWarhead') )
						C.Pawn.Fire(1);

			}
            if ( ResetCountDown == 8 )
            {
				// put up semi-permanent "New Round In" message to all players
                for ( C = Level.ControllerList; C != None; C = C.NextController )
                    if ( PlayerController(C) != None )
						PlayerController(C).PlayStatusAnnouncement('NewRoundIn',1,true);
			}
	        else if ( (ResetCountDown > 1) && (ResetCountDown < 7) )
				// add "...x" to end of "New Round In" message, updating x
				BroadcastLocalizedMessage(class'TimerMessage', ResetCountDown-1);
            else if (ResetCountDown == 1)
            {
                // Kick players out of vehicles
                foreach DynamicActors(class'Vehicle', V)
                {
                    if (V.Driver != none)
                        V.KDriverLeave(True);

					if (V.ParentFactory != None)
	        			KillVehicles[KillVehicles.length] = V;
                }

                //destroy all vehicles with a parent factory (the factories will respawn those near ClonePumps later)
                for (i = 0; i < KillVehicles.length; i++)
                	if (KillVehicles[i] != None)
	                	KillVehicles[i].Destroy();

                // reset the ClonePumps
                for(i=0;i<ClonePumps.Length;i++)
                {
                    ClonePumps[i].GotoState(''); // set to active state
                    ClonePumps[i].DestructionMessage = ClonePumps[i].default.DestructionMessage;
                    ClonePumps[i].Health = ClonePumps[i].DamageCapacity; // restore health
                    ClonePumps[i].PumpStage = 0; // set to active state
                    ClonePumps[i].ClonePumpReset(); // reset for new game
                }

//                Log("Reset Clones.");

				// reset all bot enemies
				Teams[0].AI.ClearEnemies();
				Teams[1].AI.ClearEnemies();

                // reset all players position and rotation on the field for the next round
                for ( C = Level.ControllerList; C != None; C = C.NextController )
					if ( (C.PlayerReplicationInfo != None) && !C.PlayerReplicationInfo.bOnlySpectator )
    				{
						log("TEMP-AR 4");
   						C.StartSpot = FindPlayerStart(C, C.PlayerReplicationInfo.Team.TeamIndex);
    					if ( C.StartSpot != None )
    					{
							C.SetLocation(C.StartSpot.Location);
							C.SetRotation(C.StartSpot.Rotation);
						}
						if ( C.Pawn != None )
						{
							if ( xPawn(C.Pawn) != None )
							{
								if (xPawn(C.Pawn).CurrentCombo != None)
								{
									C.Adrenaline = 0;
									xPawn(C.Pawn).CurrentCombo.Destroy();
								}
								if ( xPawn(C.Pawn).UDamageTimer != None )
								{
									xPawn(C.Pawn).UDamageTimer.Destroy();
									xPawn(C.Pawn).DisableUDamage();
								}
							}
							C.Pawn.Health = Max(C.Pawn.Health,C.Pawn.HealthMax);
							SetPlayerDefaults(C.Pawn);
							C.Pawn.SetLocation(C.StartSpot.Location);
							C.Pawn.SetRotation(C.StartSpot.Rotation);
							C.Pawn.Velocity = vect(0,0,0);
							C.Pawn.PlayTeleportEffect(false, true);
							for ( Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
								if ( Inv.IsA('TransLauncher') )
									Weapon(Inv).GiveAmmo(0, None, false);
						}
    					if ( C.StartSpot != None )
							C.ClientSetLocation(C.StartSpot.Location,C.StartSpot.Rotation);
     				}

				UpdateLinks();

				// destroy translocator beacons
				foreach DynamicActors( class'TranslocatorBeacon', Trans )
					Trans.Destroy();

				ResetCountDown = 0; // indicate reset is complete
           }
        }

		// Stolen from ASGameInfo - we take from all game types equally :-)

		if ( ResetCountDown == 0 && ReinforcementsFreq > 0 )
		{
			ReinforcementsCount++;
			if ( ReinforcementsCount > ReinforcementsFreq)
			{
				ReinforcementsCount = 0;
				ClonesGameReplicationInfo(GameReplicationInfo).ReinforcementCountDown = ReinforcementsFreq;
			}
			else if ( ReinforcementsCount >= ReinforcementsFreq )
			{
				ClonesGameReplicationInfo(GameReplicationInfo).ReinforcementCountDown = 0;

				// Auto respawn "ready" players
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
				{
					PC = PlayerController(C);
					if ( PC != None && PC.IsDead()
						&& PC.PlayerReplicationInfo != NONE
						&& ClonesPlayerReplicationInfo(PC.PlayerReplicationInfo) != NONE
						)
					{
						RestartPlayer( PC );
					}
					B = Bot(C);
					if( B != None && (B.IsInState('Dead') || B.IsInState('xBot')) )
					{
						RestartPlayer(B);
					}
				}
			}
		}
    }

	// Player Can be restarted ?
  	function bool PlayerCanRestart( PlayerController aPlayer )
  	{
  		if ( GameReplicationInfo.bMatchHasBegun && ResetCountDown == 0  )
  		{
  			if ( ReinforcementsCount < ReinforcementsFreq )
  				return false;
  			else
  				return true;
  		}
  		else
  			return true;
  	}
}


// Stolen and changed from ASGameInfo
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint	N, BestStart;
	local byte				Team, T;
	local float				BestRating, NewRating;

	// Fix for InTeam not working correctly in GameInfo
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.Team != None )
	{
		Team = Player.PlayerReplicationInfo.Team.TeamIndex;
	}
    else
	{
        Team = InTeam;
	}

	if ( Player != None )
		Player.StartSpot = None;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        NewRating = RatePlayerStart(N, Team, Player);
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if ( PlayerStart(BestStart) == None )
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
		log(" Player:" @ Player.GetHumanReadableName() @ "Team:" @ Team @ "Player.Event:" @ Player.Event);
		BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )	// consider all playerstarts...
        {
			if ( PlayerStart(N) != None )
				T = PlayerStart(N).TeamNumber;
			else
				T = Team;
            NewRating = RatePlayerStart(N, T, Player);
            if ( InventorySpot(N) != None )
				NewRating -= 50;
			NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
		//Assert(true);
    }

	// Ugly Hack to force player to use a specific Spawning area
	if ( Player != None )
		Player.Event = '';

	return BestStart;
}

function bool AllDeadOnTeamAndNoClones(int TeamIndex)
{
	local int PRIIndex;
	local bool AllDead;
	local PlayerReplicationInfo PRI;


	if(TeamCloneCounts[TeamIndex] <= 0)
	{
		AllDead = true;
		for(PRIIndex = 0; PRIIndex < GameReplicationInfo.PRIArray.length; PRIIndex++)
		{
			PRI = GameReplicationInfo.PRIArray[PRIIndex];
			if(PRI.Team.TeamIndex == TeamIndex)
			{
				if( PRI.PlayerVolume != None || PRI.PlayerZone != None )
					AllDead = false;
			}
		}
		if(AllDead)
			return true;
	}
	return false;
}



// is this player important, gameplay-wise
function bool CriticalPlayer(Controller Other)
{
	local int x;

	if (Other.Pawn == None || Other.PlayerReplicationInfo == None)
		return Super.CriticalPlayer(Other);

	// if this player is damaging an active/constructing pump, he's important
	for (x = 0; x < ClonePumps.length; x++)
		if ( (ClonePumps[x].PumpStage == 0 || ClonePumps[x].PumpStage == 2) && ClonePumps[x].DefenderTeamIndex != Other.GetTeamNum()
		     && ((ClonePumps[x].bUnderAttack && Other.PlayerReplicationInfo == ClonePumps[x].LastDamagedBy) || VSize(Other.Pawn.Location - ClonePumps[x].Location) < 2000) )
			return true;

	return Super.CriticalPlayer(Other);
}



function int AddClones(int TeamIndex, int NumClones)
{
	TeamCloneCounts[TeamIndex] += NumClones; // add to the clone total for the team

	//Stop EndGame Timer
	if(TeamCloneCounts[TeamIndex] > 0 && NoClonesEndGameCountDown[TeamIndex]!=0)
	{
		NoClonesEndGameCountDown[TeamIndex] = 0; //false
		NoClonesTimers[TeamIndex].Destroy();
	}

	return NumClones; // return number added (this might be modified later if a cap is implemented, so leave
	                  // the return code convention intact)
}

// Attempt to remove NumClones clones from the specified
// team's clone reservoir. Update the team scores in the
// replication info. If JarBase is a valid value, it means
// clones are being taken because a clone jar was stolen
// from that base. Otherwise, it means clones are being
// taken because a player is spawning.
function int TakeClones(int TeamIndex, int NumClones)
{
	local int x;

	// if the number to be taken would make the repository value negative...
	if(TeamCloneCounts[TeamIndex] - NumClones < 0)
	{
		NumClones = TeamCloneCounts[TeamIndex]; // just take all that remains, no more
	}

	TeamCloneCounts[TeamIndex] -= NumClones; // subtract from the clone total for the team

	// set clone jar bases to no jars mode if we just used the last clone
	if(TeamCloneCounts[TeamIndex] <= 0 && NumClones != 0)
	{
		// go through all the clone jar bases on the map
		for (x = 0; x < CloneJarBases.length; x++)
		{
			// only apply to clone jar bases on the same team
			if(CloneJarBases[x].DefenderTeamIndex == TeamIndex && CloneJarBases[x].myJar != NONE)
			{
				CloneJarBases[x].myJar.Destroy(); // this will not destroy the clone jar just taken
			}
		}
	}

	//StartGameEndTimer
	if(TeamCloneCounts[TeamIndex] <= 0 && NoClonesEndGameCountDown[TeamIndex]==0)
	{
		NoClonesEndGameCountDown[TeamIndex] = 1; //true
		NoClonesStage[TeamIndex] = 20;
		NoClonesTimers[TeamIndex] = spawn(class'NoClonesTimer',self);
		NoClonesTimers[TeamIndex].TeamIndex = TeamIndex;
		NoClonesTimers[TeamIndex].SetTimer(5, true);
	}

	return NumClones; // return number taken (as a positive value)
}



function NoClonesTimerCallBack(int TeamIndex)
{
	if(NoClonesEndGameCountDown[TeamIndex]==0 || bGameEnded)
		return;

	NoClonesStage[TeamIndex]--;
	BroadcastLocalizedMessage(class'TimerMessage', NoClonesStage[TeamIndex]);

	if(	NoClonesStage[TeamIndex] <= 0)
	{
		NoClonesTimers[TeamIndex].Destroy();

		NoCloneTimerRanOutTeam = Teams[TeamIndex];
		EndGame(NONE,"triggered");
	}
}





//
// Restart a player only if there enough clones
//
function RestartPlayer( Controller aPlayer )
{
	local int TeamIndex, clone;

	if( Bot(aPlayer) != NONE && ReinforcementsCount < ReinforcementsFreq)
		return;

	TeamIndex = -1;
	// don't bother unless player is on a team
    if ( (aPlayer.PlayerReplicationInfo != None) && (aPlayer.PlayerReplicationInfo.Team != None) )
	{
		// set team number
		TeamIndex = aPlayer.PlayerReplicationInfo.Team.TeamIndex;
		// attempt to take a clone from the clone reservoir for this respawn
		clone = TakeClones(TeamIndex, 1); // this call updates the clone reservoir
        if(clone == 0)
		{
			//log(" Can't spawn player because there are NO CLONES!");
			if(AllDeadOnTeamAndNoClones(TeamIndex))
			{
				AllDeadIndex = TeamIndex;
				EndGame(NONE, "triggered");
			}
			return;
		}
		else // "else" unecessary due to above return statement, but clarifies intent
		{
			// respawn the player
			Super.RestartPlayer(aPlayer);
		}
	}
}

function TEMP_ARRestartPlayer( Controller aPlayer )
{
    local NavigationPoint startSpot;
    local int TeamNum;
    local class<Pawn> DefaultPlayerClass;
	local Vehicle V, Best;
	local vector ViewDir;
	local float BestDist, Dist;

    if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        return;

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    startSpot = FindPlayerStart(aPlayer, TeamNum);
    if( startSpot == None )
    {
        log(" Player start not found!!!");
        return;
    }

    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
        BaseMutator.PlayerChangedClass(aPlayer);

    if ( aPlayer.PawnClass != None )
	{
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);
	}

    if( aPlayer.Pawn==None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
    }
    if ( aPlayer.Pawn == None )
    {
        log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$StartSpot);
        aPlayer.GotoState('Dead');
        if ( PlayerController(aPlayer) != None )
			PlayerController(aPlayer).ClientGotoState('Dead','Begin');
        return;
    }
    if ( PlayerController(aPlayer) != None )
		PlayerController(aPlayer).TimeMargin = -0.1;
    aPlayer.Pawn.Anchor = startSpot;
	aPlayer.Pawn.LastStartSpot = PlayerStart(startSpot);
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);
    TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);

    if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(aPlayer) != None) )
    {
		// tell bots not to get into nearby vehicles for a little while
		BestDist = 2000;
		ViewDir = vector(aPlayer.Pawn.Rotation);
		for ( V=VehicleList; V!=None; V=V.NextVehicle )
			if ( V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team) )
			{
				Dist = VSize(V.Location - aPlayer.Pawn.Location);
				if ( (ViewDir Dot (V.Location - aPlayer.Pawn.Location)) < 0 )
					Dist *= 2;
				if ( Dist < BestDist )
				{
					Best = V;
					BestDist = Dist;
				}
			}

		if ( Best != None )
			Best.PlayerStartTime = Level.TimeSeconds + 8;
	}
}

// CTF elements
function Logout(Controller Exiting)
{
	if ( Exiting.PlayerReplicationInfo.HasFlag != None )
	{
//		log("ClonesGame::Logout. Info. Trying to DROP Jar!!");
		CloneJar(Exiting.PlayerReplicationInfo.HasFlag).Drop(vect(0,0,0));
	}
	Super.Logout(Exiting);
}


function DiscardInventory( Pawn Other )
{
	if ( (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.HasFlag != None) )
	{
		//log("ClonesGame::DiscardInventory. Info. Trying to DROP Jar!!");
		CloneJar(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);
	}
	Super.DiscardInventory(Other);
}



function SetTeamJars()
{
	local CloneJar F;

	// associate clone jars with teams
	ForEach AllActors(Class'CloneJar',F)
	{
		if(Teams[F.TeamNum] != NONE)
		{
			F.Team = Teams[F.TeamNum]; // set team according to TeamNum
			F.Team.HomeBase = F.HomeBase; // set homebase for team according to home base of clone jar
										  // this logic is from Capture the Flag where each team has
										  // only one home base
		}
	}
}

function ScoreJar(Controller Scorer, CloneJar theJar)
{
	local float Dist,oppDist;
	local vector JarLoc;

//	log("ClonesGame:ScoreJar");

	// if the player recovered a Jar (ie the Jar and player are on the same team)
	if ( Scorer.PlayerReplicationInfo.Team == theJar.Team )
	{
		JarLoc = TheJar.Position().Location;  // get location of the Jar
		Dist = vsize(JarLoc - TheJar.HomeBase.Location); // determine distance from Jar to its home base

		// determine distance to enemy home base
		if (TheJar.TeamNum==0)
			oppDist = vsize(JarLoc - Teams[1].HomeBase.Location);
		else
  			oppDist = vsize(JarLoc - Teams[0].HomeBase.Location);

		GameEvent("jar_returned",""$theJar.Team.TeamIndex,Scorer.PlayerReplicationInfo); // send event (does some stats bookkeeping)

		// award points to the player according to where the Jar was,
		// but only if the Jar was more than 1024 away from its home base
		if (Dist>1024)
		{
			if (Dist<=oppDist)	// in friendly territory
			{	
				Scorer.PlayerReplicationInfo.Score += float(TheJar.ClonesInJar) / 3.0; // award small fraction of clones in jar
				//ScoreEvent(Scorer.PlayerReplicationInfo,3,"flag_ret_friendly");
			}
			else // in enemy territory
			{
				Scorer.PlayerReplicationInfo.Score += float(TheJar.ClonesInJar) / 1.5; // award larger fraction of clones in jar
				//ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_ret_enemy");
			}
		}
		return;
	} // end if same team recovery
	else // enemy Jar was captured
	{
		//// Figure out Team based scoring.
		//if (TheJar.FirstTouch!=None)	// Original Player to Touch it gets half the number of clones in the jar
		//{
		//	//ScoreEvent(TheJar.FirstTouch.PlayerReplicationInfo,5,"flag_cap_1st_touch"); // log events
		//	TheJar.FirstTouch.PlayerReplicationInfo.Score += float(TheJar.ClonesInJar) / 2.0;
		//	TheJar.FirstTouch.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		//}

		// Guy who caps gets all the clones in the jar
		Scorer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Scorer.PlayerReplicationInfo.Score += TheJar.ClonesInJar;
		IncrementGoalsScored(Scorer.PlayerReplicationInfo);
		

		//// Each player gets 20/x but it's guarenteed to be at least 1 point but no more than 5 points
		//numtouch=0;
		//for (i=0;i<TheJar.Assists.length;i++)
		//{
		//	if (TheJar.Assists[i]!=None)
		//		numtouch = numtouch + 1.0;
		//}

		//ppp = FClamp(20/numtouch,1,5);

		//for (i=0;i<TheJar.Assists.length;i++)
		//{
		//	if (TheJar.Assists[i]!=None)
		//	{
		//		ScoreEvent(TheJar.Assists[i].PlayerReplicationInfo,ppp,"flag_cap_assist");
		//		TheJar.Assists[i].PlayerReplicationInfo.Score += int(ppp);
		//	}
		//}


		// add clones in the Jar to the capturer's team
		AddClones(Scorer.PlayerReplicationInfo.Team.TeamIndex, theJar.ClonesInJar);


		// broadcast message to all players that a Jar was captured
		AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex); // announce score (sounds n stuff)
		CheckScore(Scorer.PlayerReplicationInfo); // check if this capture should end the match

		// end the game if a clone pump was captured in overtime (legacy code, not sure if we still want this) TODO_CL
		if ( bOverTime )
		{
			EndGame(Scorer.PlayerReplicationInfo,"timelimit");
		}
	} // end else enemy Jar was captured
}



// Removed Hat-Trick announcer sound
function IncrementGoalsScored(PlayerReplicationInfo PRI)
{
	PRI.GoalsScored += 1;
}



static function Texture GetRandomTeamSymbol(int base)
{
	return Texture(DynamicLoadObject("AR_ClonesHud_T.Generic.Jar", class'Texture'));
}

function InitTeamSymbols()
{
    // default team textures (for banners, etc.)
	GameReplicationInfo.TeamSymbols[0] = GetRandomTeamSymbol(0);
   	GameReplicationInfo.TeamSymbols[1] = GetRandomTeamSymbol(1);
	GameReplicationInfo.TeamSymbolNotify();
}




////////////////////////////////////
// End of Game Stuff

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;
	local PlayerController player;
	local int i;
	local Actor a;

	if(Winner != NONE)
	{
		for(i = 0; i < CloneJarArray.length; i++)
		{
			if(CloneJarArray[i].TeamNum == Winner.Team.TeamIndex)
			{
				EndGameFocus = CloneJarArray[i];
				break;
			}
		}
	}
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	// Remove all AutoTurret stuff because they muck up the ControllerList
	foreach DynamicActors(class'Actor', a)
	{
		if(ClonesAutoTurret(a) != NONE)
			a.destroy();
		if(ClonesAutoTurretFactory(a) != NONE)
			a.destroy();
	}

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			player.ClientSetBehindView(true);
			if ( EndGameFocus != None )
            {
				Player.ClientSetViewTarget(EndGameFocus);
                Player.SetViewTarget(EndGameFocus);
            }
			player.ClientGameEnded();
			if ( CurrentGameProfile != None )
				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
		P.GameHasEnded();
	}
}



function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local bool ReadyToEnd;

	if ( bOverTime )
	{
		if ( Numbots + NumPlayers == 0 )
			return true;
	}

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;


	ReadyToEnd = false;

	if(NoCloneTimerRanOutTeam != NONE)
	{
		GameReplicationInfo.Winner = Teams[1 - NoCloneTimerRanOutTeam.TeamIndex]; //TODO_CL only works for 2 teams
		ReadyToEnd = true;
	}
	if( AllDeadIndex >= 0 )
	{
		GameReplicationInfo.Winner = Teams[1 - AllDeadIndex]; //TODO_CL only works for 2 teams
		ReadyToEnd = true;
	}
	if ( bOverTime )
	{
		if(Teams[0].Score > Teams[1].Score)
		{
			GameReplicationInfo.Winner = Teams[0];
			ReadyToEnd = true;
		}
		else if(Teams[1].Score > Teams[0].Score)
		{
			GameReplicationInfo.Winner = Teams[1];
			ReadyToEnd = true;
		}
	}

	if(ReadyToEnd)
	{
		if ( Winner == None )
		{
			for ( P=Level.ControllerList; P!=None; P=P.nextController )
				if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
					&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)) )
				{
					Winner = P.PlayerReplicationInfo;
				}
		}

		EndTime = Level.TimeSeconds + EndTimeDelay;

		SetEndGameFocus(Winner);
		return true;
	}

	return false;
}



// overwrite TeamGame version so that 
// we never play the "humiliating defeat" and
// "flawless victory" messages. Just play
// the "X team wins" and "Y team loses" messages
function PlayEndOfMatchMessage()
{
	local controller C;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if ( C.IsA('PlayerController') )
		{
			if (Teams[0].Score > Teams[1].Score)
				PlayerController(C).PlayStatusAnnouncement(EndGameSoundName[0],1,true);
			else
				PlayerController(C).PlayStatusAnnouncement(EndGameSoundName[1],1,true);
		}
	}
}

// Ripped from clones game because ControllerClass in ClonesPawn didn't work at all.
// here's why...UGH. 
function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = GetBotTeam();
    Chosen = BotTeam.ChooseBotClass(botName);

    if (Chosen.PawnClass == None)
        Chosen.Init(); //amb

	NewBot = Spawn(class'Clones.ClonesBot');


    if ( NewBot != None )
        InitializeBot(NewBot,BotTeam,Chosen);
    return NewBot;
}

defaultproperties
{
     TeamCloneCounts(0)=60
     TeamCloneCounts(1)=60
     BlueCloneMultiplier=1.000000
     RedCloneMultiplier=1.000000
     AllDeadIndex=-1
     ClonesHints(0)="Every time a player respawns, it uses a CLONE from the team reserve."
     ClonesHints(1)="Capture and defend CLONE PUMPS to steal CLONES from your enemy's reserves and add to your own."
     ClonesHints(2)="Shoot an enemy CLONE PUMP to destroy it; capture it for your team by touching the wreckage."
     ClonesHints(3)="Some CLONE JARS contain more CLONES than others."
     ClonesHints(4)="If you control the CLONE PUMPS you control the game."
     ClonesHints(5)="Alt-Fire in the LOUNGE TANK to drop anti-vehicle FLAMINGO MINES."
     ClonesHints(6)="Use the link gun alternate-fire to heal friendly CLONE PUMPS and speed the capture process."
     ClonesHints(7)="This mod was created by Demiurge Studios."
     ClonesHints(8)="You cannot carry a CLONE JAR while riding the MOSCOWBOY."
     ClonesHints(9)="Do flips and spins while airborne in the BARRACUDA to gain extra NITROUS."
     ClonesHints(10)="Alt-Fire while driving the Barracuda for a NITROUS speed boost."
     ClonesHints(11)="The BARRACUDA will slowly recharge NITROUS boost if it has none."
     ClonesHints(12)="Press Fire in the MOSCOWBOY to become an anti-vehicle missle; don't forget to jump off before impact."
     ClonesHints(13)="The BARRACUDA's driver gun has a limited firing arc; the roof-mounted passenger gun can fire in all 360 degrees."
     ClonesHints(14)="You can steal CLONES directly by grabbing a CLONE JAR at the enemy base and returning it to a friendly CLONE JAR spawn point."
     ClonesHints(15)="CLONE JARS dropped on the map will eventually expire, destroying any CLONES it had."
     ClonesHints(16)="Steer the MOSCOWBOY with the mouse; just look where you want to go."
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     FriendlyFireScale=1.000000
     TeamAIType(0)=Class'Clones.ClonesTeamAI'
     TeamAIType(1)=Class'Clones.ClonesTeamAI'
     NetWait=10
     RestartWait=15
     DefaultEnemyRosterClass="XGame.xTeamRoster"
     LoginMenuClass="Clones.UT2K4ClonesLoginMenu"
     bAllowVehicles=True
     DefaultPlayerClassName="Clones.ClonesPawn"
     ScoreBoardType="Clones.ScoreBoardClones"
     GameUMenuType="Clones.UT2K4ClonesLoginMenu"
     HUDType="Clones.ClonesHUD"
     MapListType="Clones.CLNMapListClones"
     MapPrefix="CLN"
     BeaconName="CLN"
     ResetTimeDelay=11
     GoalScore=999
     TimeLimit=30
     MutatorClass="Clones.ClonesDefaultMut"
     PlayerControllerClassName="Clones.ClonesPlayer"
     GameReplicationInfoClass=Class'Clones.ClonesGameReplicationInfo'
     GameName="Clone Bandits"
     Description="Clone Bandits by Demiurge Studios, Inc||Capture the Clone Pumps to siphon clones from your enemy's supply or boldly invade their compound, grab Clone Jars, and hightail it back to your own base. Drop 'em off at your own Jar Points to complete the transaction. Trafficking in human flesh was never so easy or fun!"
     ScreenShotName="JY_CarMod_T.Misc.CB-GameType"
     DecoTextName="Clones.ClonesGame"
     Acronym="CLN"
}
