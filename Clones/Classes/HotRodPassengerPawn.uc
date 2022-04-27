//-----------------------------------------------------------
// Created 3-22-04 by Demiurge Studios
//-----------------------------------------------------------
// Implements the passenger position for the Hot Rod
class HotRodPassengerPawn extends ONSWeaponPawn;



function BeginPlay()
{
	Super.BeginPlay();

	// reset pitch limits back to defaults
	// overrides weapon pitch limits    
    PitchUpLimit = default.PitchUpLimit;
    PitchDownLimit = default.PitchDownLimit;
}


// overwrite ONSWeaponPawn.LimitPitch so gunner can look
// where they can't shoot if they want to
function int LimitPitch(int pitch)
{
	return Super(Pawn).LimitPitch(pitch);
}

defaultproperties
{
     GunClass=Class'Clones.HotRodPassengerGun'
     CrosshairTexture=Texture'Crosshairs.HUD.Crosshair_Triad2'
     DrivePos=(X=30.000000)
     ExitPositions(0)=(Y=-165.000000,Z=75.000000)
     ExitPositions(1)=(Y=165.000000,Z=75.000000)
     ExitPositions(2)=(X=-200.000000,Z=75.000000)
     ExitPositions(3)=(X=200.000000,Z=75.000000)
     ExitPositions(4)=(Z=200.000000)
     ExitPositions(5)=(Z=-100.000000)
     EntryPosition=(Y=50.000000)
     EntryRadius=170.000000
     FPCamPos=(Z=50.000000)
     TPCamDistance=200.000000
     TPCamLookat=(X=0.000000,Z=50.000000)
     TPCamWorldOffset=(Z=50.000000)
     DriverDamageMult=0.200000
     VehiclePositionString="riding Shotgun in a Barracuda"
     VehicleNameString="Barracuda Shotgun"
}
