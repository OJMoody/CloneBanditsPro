class BigBerthaPawn extends ONSStationaryWeaponPawn;

// TODO_CL: This will not work when placed in the maps because 
// it does not have the bStaticTeam variable (which is in the
// BerthaPawn). The correct way to fix this is to create a 
// parent class that has the bStaticTeam var defined and then
// derive the BerthaPawn and BigBertha Pawns from it. One would
// also have to change the ClonePump code, which is currently 
// written assuming all manned turrets are BerthaPawns.

var Actor MissileViewTarget;

simulated function MissileView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = MissileViewTarget;
	CamLookAt = ViewActor.Location + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, true, vect(10, 10, 10));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(10, 10, 10)) != None) )
			CameraLocation = HitLocation;

    CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;

	bOwnerNoSee = false;

	if(bDrawDriverInTP)
		Driver.bOwnerNoSee = false;
	else
		Driver.bOwnerNoSee = true;
}

simulated event bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local PlayerController pc;

	if(MissileViewTarget == None)
	{
		Super.SpecialCalcView(ViewActor, CameraLocation, CameraRotation );
	}
	else
	{
		pc = PlayerController(Controller);
		MissileView(PC,ViewActor,CameraLocation,CameraRotation);
	}

	LastCameraCalcTime = Level.TimeSeconds;

	return true;
}

defaultproperties
{
     RespawnTime=60.000000
     GunClass=Class'Clones.BigBertha'
     CameraBone="TurretCockpit"
     DrivePos=(X=-11.384000)
     EntryRadius=175.000000
     FPCamPos=(X=-27.000000,Z=26.000000)
     TPCamDistance=450.000000
     TPCamLookat=(X=0.000000,Z=320.000000)
     DriverDamageMult=0.000000
     HealthMax=350.000000
     Health=350
     StaticMesh=StaticMesh'ONSDeadVehicles-SM.MANUALbaseGunDEAD'
     Mesh=SkeletalMesh'ONSWeapons-A.NewManualGun'
     bPathColliding=True
}
