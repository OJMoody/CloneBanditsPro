// Hoverbeast. 2k4 *hollib* - based on code by
// Demiurge Studios & Epic

class cbtHoverbeast extends ONSHoverBike
    placeable;

defaultproperties
{
     UprightStiffness=550.000000
     UprightDamping=350.000000
     MaxThrustForce=100.000000
     MaxStrafeForce=70.000000
     MaxRiseForce=80.000000
     TurnTorqueFactor=550.000000
     TurnTorqueMax=180.000000
     TurnDamping=80.000000
     MaxYawRate=2.000000
     PitchTorqueFactor=180.000000
     PitchTorqueMax=50.000000
     PitchDamping=25.000000
     RollTorqueTurnFactor=570.000000
     RollTorqueStrafeFactor=80.000000
     RollTorqueMax=80.000000
     RollDamping=50.000000
     StopThreshold=140.000000
     MaxRandForce=5.000000
     RandForceInterval=1.000000
     DriverWeapons(0)=(WeaponClass=Class'cbthoverbeast.HoverGun',WeaponBone="Gun")
     bHasAltFire=True
     DestroyedVehicleMesh=StaticMesh'cbtdeadvehi.hovadead'
     DamagedEffectOffset=(X=-20.000000,Y=0.000000,Z=20.000000)
     DamagedEffectHealthFireFactor=2.000000
     HeadlightCoronaOffset(0)=(X=42.000000,Z=8.000000)
     HeadlightCoronaOffset(1)=(X=42.000000,Z=8.000000)
     HeadlightCoronaMaxSize=40.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-2000)
     HeadlightProjectorScale=0.300000
     bTeamLocked=False
     DrivePos=(X=0.000000,Z=70.000000)
     EntryPosition=(X=-10.000000,Y=-30.000000,Z=40.000000)
     EntryRadius=240.000000
     VehiclePositionString="in a Hoverbeast"
     VehicleNameString="*_Hoverbeast_*"
     RanOverDamageType=Class'cbthoverbeast.DamTypeHoverbeastRoadkill'
     CrushedDamageType=Class'cbthoverbeast.DamTypeHoverbeastPancake'
     MaxDesireability=3.400000
     HealthMax=240.000000
     Health=240
     Mesh=SkeletalMesh'cbthollvehic.daglide'
}
