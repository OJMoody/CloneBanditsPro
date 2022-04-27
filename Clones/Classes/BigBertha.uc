class BigBertha extends ONSWeapon;

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		local Projectile P;
		local BigBerthaPawn B;
		P = SpawnProjectile(ProjectileClass, False);

		B = BigBerthaPawn(Owner);
        B.MissileViewTarget = P;
	}
}

defaultproperties
{
     YawBone="RocketPivot"
     PitchBone="RocketPivot"
     WeaponFireAttachmentBone="RocketPackFirePoint"
     DualFireOffset=80.000000
     bDualIndependantTargeting=True
     FireInterval=0.350000
     FireSoundClass=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     FireForce="RocketLauncherFire"
     ProjectileClass=Class'Clones.BigBerthaProjectile'
     AIInfo(0)=(bLeadTarget=True)
     Mesh=SkeletalMesh'ONSWeapons-A.NewManualGun'
     CollisionRadius=60.000000
}
