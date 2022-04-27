//-----------------------------------------------------------
// ClonesVehicleFactory - Created on 1/26/04  Demiurge Studios
//-----------------------------------------------------------
// Much functionality copied directly from the ONSVehicleFactory
// class.

class ClonesVehicleFactory extends SVehicleFactory
    abstract
	placeable;


var()   float   RespawnTime;	// time between vehicles respawning from this factory
var()   int     TeamNum;		// id of team this factory belongs to
var     Vehicle LastSpawnedVehicle; // ref to last vehicle created
var		bool	bUnusedVehicle; // true if a spawned vehicle is still untouched
								// used to prevent stacked spawns



// copied from ONSVehicleFactory
function PostNetBeginPlay()
{
    bHidden = True;
	Super.PostNetBeginPlay();
	SpawnVehicle();
}



// When a player enters a previously unused vehicle (at the factory), set a timer
// to spawn a new vehicle after the respawn time has elapsed (not looped)
event VehiclePossessed( Vehicle V )
{	
	// if a player is entering the last created vehicle for the first time
	// start count to spawn a new one.
	if (bUnusedVehicle && V == LastSpawnedVehicle)
	{
		//Log("ClonesVehicleFactory.VehiclePossessed: Info. Started spawn countdown");
		SetTimer(RespawnTime, false);     // start a spawn countdown
		bUnusedVehicle = false;			  // last created vehicle was touched
	}
}



// Called when a vehicle produced at this factory is destroyed
event VehicleDestroyed(Vehicle V)
{
	// Call parent class code
	Super.VehicleDestroyed(V);

	// If an untouched vehicle is destroyed, start a count to spawn
	// a new one.
	if (bUnusedVehicle && V == LastSpawnedVehicle)
	{
		//Log("ClonesVehicleFactory.VehicleDestroyed: Info. Untouched vehicle destroyed. Starting spawn countdown");
		SetTimer(RespawnTime, false);     // start a spawn countdown
	}
	else if(!bUnusedVehicle && TimerRate == 0.0f)
	{
		// if there is no vehicle at the spawn point (only when MaxVehicleCount is reached)
		// and a spawn countdown isn't in progress, start a spawn countdown
		//Log("ClonesVehicleFactory.VehicleDestroyed: Info. No vehicle at factory. Starting spawn countdown");
		SetTimer(RespawnTime, false);     // start a spawn countdown
	}
}



// copied from ONSVehicleFactory
function SpawnVehicle()
{
	local Vehicle CreatedVehicle;
	local Pawn P;
	local bool bBlocked;

	// don't even try to spawn if...
	// 1. level doesn't allow vehicles
	// 2. maximum vehicle count already reached
	if (Level.Game.bAllowVehicles && VehicleCount < MaxVehicleCount)
	{
		foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.25)
		{
			bBlocked = true;
			// if a player is doing the blocking, send them a message
			if (PlayerController(P.Controller) != None)
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 11);
		}

	    if (bBlocked)
	    {
	     	SetTimer(1, false); // try again 1 second later, and continue trying until 
	       						// factory can spawn a vehicle
	    }
	    else
	    {
			// attempt to create the actual vehicle
			CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
			
			// see if creation worked (assuming all vehicles are sub-objects of ONSVehicle)
			if ( ONSVehicle(CreatedVehicle) != None )
			{
				VehicleCount++;
				CreatedVehicle.SetTeamNum(TeamNum);
				CreatedVehicle.Event = Tag;
				CreatedVehicle.ParentFactory = Self;
				
				// save ref to vehicle
				LastSpawnedVehicle = CreatedVehicle;
				// set flag that a new vehicle is available
				bUnusedVehicle = true;
			}
			else
			{
				log("Could not spawn vehicle for some reason.");
				SetTimer(1, false); // try again 1 second later, and continue trying until 
	       							// factory can spawn a vehicle
			}
		}
	}
}



// attempt to spawn a vehicle whenever the respawn timer runs out
function Timer()
{
	SpawnVehicle();
}



// Clones doesn't use the trigger system
event Trigger( Actor Other, Pawn EventInstigator )
{
}

defaultproperties
{
     RespawnTime=15.000000
     MaxVehicleCount=3
     DrawType=DT_Mesh
     bHidden=False
     bNoDelete=False
}
