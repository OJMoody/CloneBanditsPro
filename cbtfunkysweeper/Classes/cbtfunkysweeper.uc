// Sweeper. 2k4 *hollib* - based on code by
// Demiurge Studios & Epic

class cbtFunkySweeper extends HotRod
	Placeable;

defaultproperties
{
     NitrousRechargeTime=5.000000
     IdleRPM=200.000000
     BrakeLightOffset(0)=(X=-125.000000,Y=-17.000000,Z=-23.000000)
     BrakeLightOffset(1)=(X=-125.000000,Y=17.000000,Z=-23.000000)
     DriverWeapons(0)=(WeaponClass=Class'cbtfunkysweeper.Sweepergun',WeaponBone="gunmount")
     DestroyedVehicleMesh=StaticMesh'cbtdeadvehi.sweepadead'
     HeadlightCoronaOffset(0)=(X=110.000000,Y=22.000000,Z=-10.000000)
     HeadlightCoronaOffset(1)=(X=110.000000,Y=-22.000000,Z=-10.000000)
     HeadlightCoronaOffset(2)=(X=110.000000,Y=-22.000000,Z=-10.000000)
     HeadlightCoronaOffset(3)=(X=110.000000,Y=22.000000,Z=-10.000000)
     HeadlightCoronaOffset(4)=(X=110.000000,Y=-22.000000,Z=-10.000000)
     HeadlightCoronaMaxSize=32.000000
     HeadlightProjectorOffset=(X=156.000000,Z=-120.000000)
     DrivePos=(X=-15.000000,Y=-20.000000,Z=40.000000)
     VehiclePositionString="in the BadSweeper..."
     VehicleNameString="_*Sweeper*_"
     RanOverDamageType=Class'cbtfunkysweeper.DamTypeSweeperRoadkill'
     CrushedDamageType=Class'cbtfunkysweeper.DamTypeSweeperPancake'
     GroundSpeed=1240.000000
     Mesh=SkeletalMesh'cbthollsweep.redcruisa'
}
