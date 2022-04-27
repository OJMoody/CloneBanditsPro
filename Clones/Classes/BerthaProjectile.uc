class BerthaProjectile extends Projectile;

var xEmitter Trail;
var class<xEmitter> HitEffectClass;

simulated function Destroyed()
{
    if ( Trail != None )
        Trail.mRegen = false; 
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer)
    {
        Trail = Spawn(class'GrenadeSmokeTrail', self,, Location, Rotation);
    }

    if ( Role == ROLE_Authority )
    {
        Velocity = Speed * Vector(Rotation);
		Velocity.Z += TossZ;
        RandSpin(25000);
    }
}


simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	Explode(HitLocation, Normal(HitLocation-Other.Location));
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Explode(Location, HitNormal);
	return;
}

simulated function BlowUp(vector HitLocation)
{
	DelayedHurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    BlowUp(HitLocation);
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
		// TODO Al: Make explosions look the size of the blast radius
        //Spawn(class'NewExplosionB',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(class'ONSTankHitRockEffect',,,HitLocation,rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
    Destroy();
}

defaultproperties
{
     HitEffectClass=Class'XEffects.WallSparks'
     Speed=3000.000000
     MaxSpeed=10000.000000
     TossZ=300.000000
     Damage=70.000000
     DamageRadius=500.000000
     MomentumTransfer=250000.000000
     MyDamageType=Class'XWeapons.DamTypeAssaultGrenade'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.GrenadeMesh'
     Physics=PHYS_Falling
     DrawScale=7.000000
     AmbientGlow=100
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
