//=============================================================================
// CloneJarBase
//=============================================================================
class CloneJarBase extends GameObjective
	abstract;

var() Sound TakenSound;
var CloneJar myJar;
var class<CloneJar> JarType;
var GameReplicationInfo GRI;
var ClonesGame MyGame;
var() float TimeForCloneRespawn;
var() float FracOfClonesToTake;
var() int MinClonesToTake;
var() int MaxClonesInJar;



simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
}	



function BeginPlay()
{
	Super.BeginPlay();

	MyGame = ClonesGame(Level.Game);

	//Start up clone jar production
	MakeNewJar();
	SetTimer(TimeForCloneRespawn, true);  
}



function PostBeginPlay()
{
	local UnrealScriptedSequence W;

	Super.PostBeginPlay();

	// TODO_CL: play custom clones animation
    //if ( Level.NetMode != NM_DedicatedServer )
    //    LoopAnim('flag',0.8);
    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);

	//calculate distance from this base to all nodes - store in BaseDist[DefenderTeamIndex] for each node
	SetBaseDistance(DefenderTeamIndex);

	// calculate visibility to base and defensepoints, for all paths
	SetBaseVisibility(DefenderTeamIndex);
	for ( W=DefenseScripts; W!=None; W=W.NextScript )
		if ( W.myMarker != None )
			W.myMarker.SetBaseVisibility(DefenderTeamIndex);
}



function PlayAlarm()
{
	PlaySound(TakenSound); // play alarm sound
}



function Timer()
{
	MakeNewJar();
}



// Returns true if successful
function bool MakeNewJar()
{
	local Pawn P;
	local bool bTempBlocked;
	bTempBlocked = false;

	// if this team actually has some clones to steal
	if(myGame.GetTeamCloneCount(DefenderTeamIndex) > 0 && myJar == NONE)
	{
		// check if there is anything in the way
		foreach CollidingActors(class'Pawn', P, JarType.default.CollisionRadius * 7.0)
		{
			bTempBlocked = true;
			// if a player is doing the blocking, send them a message
			if (PlayerController(P.Controller) != None)
			{
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'CLNMessage', 23);
			}
		}

		if(bTempBlocked)
		{
			SetTimer(1.0, true); // keep trying every second
		}
		else
		{
			// spawn the jar
			myJar = Spawn(JarType, self); // create a clone jar
			if (myJar==None)
			{
				warn(Self$" could not spawn Jar of type '"$JarType$"' at "$location);
				return false;
			}
			else
			{   // set default properties for new clone jar
				myJar.HomeBase = self;
				myJar.TeamNum = DefenderTeamIndex;
				MyGame.SetTeamJars();
				return true;
			}
			// reset Timer to loop
			SetTimer(TimeForCloneRespawn, true);
		}
	}
	return false;
}



function int GetClonesToTake()
{
	local int Difference;

	Difference = MyGame.GetTeamCloneCount(0) - MyGame.GetTeamCloneCount(1);
	if(DefenderTeamIndex == 1)
		Difference *= -1;
	
	if(Difference < 0)
		Difference = 0;

	return max(MinClonesToTake, min(MaxClonesInJar, Difference * FracOfClonesToTake));
}



// called when a clone jar is taken from this base
function NotifyTakeJar()
{ 
	// set no Jar here
	myJar = None;

	PlayAlarm();
}


event touch(Actor Other)
{
	local CloneJar Jar;
	local array<Controller> ControllersToConsider;
	local Controller C;
	local ONSVehicle V;
	local int i;

	if(Pawn(Other) == NONE)
		return;

	V = ONSVehicle(Other);
	if(V != NONE)
	{
		if( V.Controller != NONE )
			ControllersToConsider[ControllersToConsider.length] = V.Controller;

		for (i=0; i<V.WeaponPawns.length; i++)
			if ( V.WeaponPawns[i].Controller != NONE )
				ControllersToConsider[ControllersToConsider.length] = V.WeaponPawns[i].Controller;
	}
	else
        ControllersToConsider[ControllersToConsider.length] = Pawn(Other).Controller;

	for(i = 0; i < ControllersToConsider.length; i++)
	{
		C = ControllersToConsider[i];
		// if its a valid player and he/she has a clone jar
		if(C != NONE && C.PlayerReplicationInfo.HasFlag != None)
		{
			// temp assignment for readability
			Jar = CloneJar(C.PlayerReplicationInfo.HasFlag);
			// if the player touched this base with an opposing clone jar
			if(Jar.TeamNum != DefenderTeamIndex)
			{
				ClonesGame(Level.Game).ScoreJar(C, Jar); // add clones in jar to capturing team's repository
				TriggerEvent(Event,self,C.Pawn); // used for level design triggers
				//if (Bot(C) != None)
				//    Bot(C).Squad.SetAlternatePath(true);
				BroadcastLocalizedMessage( class'CLNMessage', 16 + DefenderTeamIndex, C.PlayerReplicationInfo, None, Jar );
				Jar.Score(); // destroy Jar object

				// Reset AI Flags
				if(ClonesBot(C) != None)
				{
					ClonesBot(C).bClonesFinalStretch = false;
				}
			}
		}
	}
}

defaultproperties
{
     TakenSound=Sound'GameSounds.CTFAlarm'
     TimeForCloneRespawn=10.000000
     FracOfClonesToTake=0.250000
     MinClonesToTake=4
     MaxClonesInJar=8
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CS_CloneItems_S.CloneJar.CloneJar'
     bStatic=False
     bAlwaysRelevant=True
     NetUpdateFrequency=8.000000
     SoundRadius=255.000000
     CollisionRadius=60.000000
     CollisionHeight=80.000000
     bCollideActors=True
     bUseCylinderCollision=True
     bNetNotify=True
}
