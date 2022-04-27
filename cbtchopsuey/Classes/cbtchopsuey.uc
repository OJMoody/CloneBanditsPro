// Chopsuey.(cannedheat-saturdayafternoon-shopping-heli)
// 2k4 *hollib* - based on code by
// Demiurge Studios & Epic

class cbtChopsuey extends ONSAttackCraft
    placeable;

//#exec OBJ LOAD FILE=..\textures\*.utx

defaultproperties
{
     MaxPitchSpeed=4300.000000
     TrailEffectClass=None
     StreamerEffectClass=None
     UprightStiffness=550.000000
     UprightDamping=350.000000
     MaxThrustForce=150.000000
     MaxStrafeForce=100.000000
     MaxRiseForce=80.000000
     TurnTorqueFactor=750.000000
     TurnTorqueMax=250.000000
     TurnDamping=80.000000
     MaxYawRate=2.000000
     PitchTorqueFactor=250.000000
     PitchTorqueMax=50.000000
     PitchDamping=25.000000
     RollTorqueTurnFactor=1200.000000
     RollTorqueStrafeFactor=80.000000
     RollTorqueMax=80.000000
     RollDamping=50.000000
     StopThreshold=150.000000
     MaxRandForce=5.000000
     RandForceInterval=1.000000
     DriverWeapons(0)=(WeaponClass=Class'cbtchopsuey.Chopgun',WeaponBone="Gun")
     bHasAltFire=False
     DestroyedVehicleMesh=StaticMesh'cbtdeadvehi.sueydead'
     DamagedEffectOffset=(X=-20.000000,Y=0.000000,Z=20.000000)
     DamagedEffectHealthFireFactor=2.000000
     HeadlightCoronaOffset(0)=(X=42.000000,Y=10.000000,Z=8.000000)
     HeadlightCoronaOffset(1)=(X=42.000000,Y=-10.000000,Z=8.000000)
     HeadlightCoronaMaterial=Texture'AW-2004Particles.Weapons.PlasmaStar2Red'
     HeadlightCoronaMaxSize=160.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-2000)
     HeadlightProjectorScale=0.200000
     bDrawDriverInTP=True
     bTeamLocked=False
     DrivePos=(X=-20.000000,Z=70.000000)
     EntryPosition=(X=0.000000,Y=-30.000000,Z=40.000000)
     EntryRadius=240.000000
     VehiclePositionString="in the Chopsuey"
     VehicleNameString="*_Chopsuey_*"
     RanOverDamageType=Class'cbtchopsuey.DamTypeChopsueyRoadkill'
     CrushedDamageType=Class'cbtchopsuey.DamTypeChopsueyPancake'
     MaxDesireability=3.400000
     HealthMax=240.000000
     Health=240
     Mesh=SkeletalMesh'cbthollvehic.sueygyro'
}
