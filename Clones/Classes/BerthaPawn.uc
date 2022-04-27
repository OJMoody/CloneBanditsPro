class BerthaPawn extends ONSStationaryWeaponPawn;

var()	bool	bStaticTeam;	// set to true if this pawn is always on its original team and always powered

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

simulated function ActivateOverlay(bool bActive)
{
    Super.ActivateOverlay(bActive);

    if (Gun != None)
    {
        if (bActive)
            Gun.SetBoneScale(4, 0.0, 'TurretCockpit');
        else
            Gun.SetBoneScale(4, 1.0, 'TurretCockpit');
    }
}

defaultproperties
{
     bStaticTeam=True
     bPowered=True
     RespawnTime=60.000000
     GunClass=Class'Clones.Bertha'
     CameraBone="TurretCockpit"
     CrosshairTexture=Texture'Crosshairs.HUD.Crosshair_Dot'
     DrivePos=(X=-50.000000,Z=48.000000)
     EntryRadius=175.000000
     FPCamPos=(X=-27.000000,Z=26.000000)
     TPCamDistance=450.000000
     TPCamLookat=(X=-200.000000,Z=220.000000)
     DriverDamageMult=0.000000
     VehicleNameString="Bertha Turret"
     HUDOverlayClass=Class'Onslaught.ONSManualGunOverlay'
     HUDOverlayOffset=(X=60.000000,Z=-25.000000)
     HUDOverlayFOV=45.000000
     HealthMax=400.000000
     Health=400
     StaticMesh=StaticMesh'ONSDeadVehicles-SM.MANUALbaseGunDEAD'
     Mesh=SkeletalMesh'ONSWeapons-A.NewManualGun'
     bPathColliding=True
}
