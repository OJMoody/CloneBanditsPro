//-----------------------------------------------------------
//  LoungeTankCannon - Created on 1/20/04  Demiurge Studios
//-----------------------------------------------------------

// LoungeTankCannon is a large turret. It was originally
// created for mounting on a tank.
class LoungeTankCannon extends ONSWeapon;

var () Sound		TurretTurnSound;
var rotator			OldAim;
var bool			bTurretTurning;

var bool FlamingoReloading;
var float FlamingoReloadTime;

var vector OldDir;
var rotator OldRot;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		FlamingoReloading;
}

function Tick(float Delta)
{
    // Ripped from ONSHoverTankCannon
	local int i;
	local xPawn P;
	local vector NewDir, PawnDir;
    local coords WeaponBoneCoords;


    Super.Tick(Delta);

	if ( (Role == ROLE_Authority) && (Base != None) )
	{
	    WeaponBoneCoords = GetBoneCoords(YawBone);
		NewDir = WeaponBoneCoords.XAxis;
		if ( (Vehicle(Base).Controller != None) && (NewDir.Z < 0.9) )
		{
			for ( i=0; i<Base.Attached.Length; i++ )
			{
				P = XPawn(Base.Attached[i]);
				if ( (P != None) && (P.Physics != PHYS_None) && (P != Vehicle(Base).Driver) )
				{
					PawnDir = P.Location - WeaponBoneCoords.Origin;
					PawnDir.Z = 0;
					PawnDir = Normal(PawnDir);
					if ( ((PawnDir.X <= NewDir.X) && (PawnDir.X > OldDir.X))
						|| ((PawnDir.X >= NewDir.X) && (PawnDir.X < OldDir.X)) )
					{
						if ( ((PawnDir.Y <= NewDir.Y) && (PawnDir.Y > OldDir.Y))
							|| ((PawnDir.Y >= NewDir.Y) && (PawnDir.X < OldDir.Y)) )
						{
							P.SetPhysics(PHYS_Falling);
							P.Velocity = WeaponBoneCoords.YAxis;
							if ( ((NewDir - OldDir) Dot WeaponBoneCoords.YAxis) < 0 )
								P.Velocity *= -1;
							P.Velocity = 500 * (P.Velocity + 0.3*NewDir);
							P.Velocity.Z = 200;
						}
					}
				}
			}
		}
		OldDir = NewDir;
	}




	//Believe it or not, CurrentAim fluctuates even when the aim is apparently still,
	//   thus the need for the +/- 6 fudge factor.
	//log("Old:"$OldAim.Yaw@"Current:"$CurrentAim.Yaw);
	if (abs(CurrentAim.Yaw - OldAim.Yaw)>200 && !bTurretTurning) {
		AmbientSound = TurretTurnSound;
		bTurretTurning = true;
    }
    else if (abs(CurrentAim.Yaw - OldAim.Yaw)<=200 && bTurretTurning) {
		AmbientSound = None;
		bTurretTurning = false;
    }
    OldAim = CurrentAim;
}



event Timer()
{
	FlamingoReloading=false;
}

state ProjectileFireMode
{

    function Fire(Controller C)
    {
    	SpawnProjectile(ProjectileClass, False);
    }

	function AltFire(Controller C)
	{
		local Projectile p;
		local Rotator dir;

		if(!FlamingoReloading)
		{
			dir = Owner.Rotation;
			dir.yaw -= 32768;

			p = Spawn(AltFireProjectileClass, self,, Owner.location + vect(0,0,100) + vector(dir) * 300 , dir);

			FlamingoReloading=true;
			SetTimer(FlamingoReloadTime, false);
		}
	}
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	Owner.KAddImpulse( vect(0,0,5000), location + (vector(WeaponFireRotation)*5000) );
	return Super.SpawnProjectile(ProjClass, bAltFire);
}



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OldDir = Vector(CurrentAim);
}

simulated function ShakeView()
{
}

// Ripped from ONSWeapon so we can make it not do effects on altfires
simulated event FlashMuzzleFlash()
{
    if (Role == ROLE_Authority)
    {
    	FlashCount++;
    	NetUpdateTime = Level.TimeSeconds - 1;
    }
    else
        CalcWeaponFire();

    if (FlashEmitter != None)
        FlashEmitter.Trigger(Self, Instigator);

    if (EffectEmitterClass != None && !bIsAltFire)
        EffectEmitter = spawn(EffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
}

defaultproperties
{
     TurretTurnSound=Sound'WeaponSounds.Minigun.miniempty'
     FlamingoReloadTime=10.000000
     YawBone="TurretYaw"
     PitchBone="GunPitch"
     PitchUpLimit=6000
     PitchDownLimit=61500
     WeaponFireAttachmentBone="GunShot"
     GunnerAttachmentBone="TurretAttach"
     WeaponFireOffset=200.000000
     RotationsPerSecond=0.160000
     Spread=0.015000
     FireInterval=2.000000
     AltFireInterval=2.000000
     EffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireSoundVolume=512.000000
     FireForce="Explosion05"
     ProjectileClass=Class'Onslaught.ONSRocketProjectile'
     AltFireProjectileClass=Class'Clones.FlamingoMine'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.500000)
     Mesh=SkeletalMesh'CS_CloneVehicles_K.BigTankGun'
}
