class Bertha extends ONSWeapon;

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		local Projectile P;
		P = SpawnProjectile(ProjectileClass, False);

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			if (DualFireOffset < 0)
				PlayAnim('RightFire');
			else
				PlayAnim('LeftFire');
		}
	}
}

defaultproperties
{
     YawBone="TurretBase"
     PitchBone="Dummy01"
     PitchUpLimit=15000
     PitchDownLimit=59000
     WeaponFireAttachmentBone="TurretCockpit"
     GunnerAttachmentBone="TurretCockpit"
     WeaponFireOffset=100.000000
     DualFireOffset=75.000000
     FireInterval=1.000000
     FireSoundClass=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     FireForce="RocketLauncherFire"
     ProjectileClass=Class'Clones.BerthaProjectile'
     AIInfo(0)=(bLeadTarget=True)
     Mesh=SkeletalMesh'ONSWeapons-A.NewManualGun'
     CollisionRadius=50.000000
     CollisionHeight=70.000000
}
