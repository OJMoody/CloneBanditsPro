#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax
#exec OBJ LOAD FILE=..\StaticMeshes\CS_CloneItems_S.usx

// Overtly stolen from grenades
class FlamingoMine extends Projectile;

var bool bCanHitOwner;
var xEmitter Trail;
var() float DampenFactor, DampenFactorParallel;
var class<xEmitter> HitEffectClass;
var float LastSparkTime;
var Actor IgnoreActor; //don't stick to this actor
var byte Team;
var Emitter Beacon;

var Actor StuckActor;

var int Health;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		IgnoreActor, Team;
}

simulated function Destroyed()
{
    if ( Trail != None )
        Trail.mRegen = false; // stop the emitter from regenerating
    //explosion
    if ( !bNoFX )
    {
		if ( EffectIsRelevant(Location,false) )
		{
			Spawn(class'ONSGrenadeExplosionEffect',,, Location, rotator(vect(0,0,1)));
			Spawn(ExplosionDecal,self,, Location, rotator(vect(0,0,-1)));
		}
		PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
	}

	if ( Beacon != None )
		Beacon.Destroy();

    Super.Destroyed();
}


event Touch(Actor Other)
{
	if(StuckActor == None)
		Stick(Other);
	else if(SVehicle(Other) != None)
		BigExplode(SVehicle(Other));
}

event Bump(Actor Other)
{
	if(StuckActor == None)
		Stick(Other);
	else if(SVehicle(Other) != None)
		BigExplode(SVehicle(Other));
}


function BigExplode(optional SVehicle Target)
{
	// apply damage to hit vehicle
	if(Target != None)
		Target.TakeDamage(10000, Instigator, location, vect(0,0,0), class'Clones.DamTypeFlamingo'); // TODO Al: Make new damage type

	// destroy mine
	TakeDamage(10000, Instigator, location, vect(0,0,0), class'Clones.DamTypeFlamingo');
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Velocity = Speed * Vector(Rotation);
    if (PhysicsVolume.bWaterVolume)
        Velocity = 0.6*Velocity;

    if (Role == ROLE_Authority && Instigator != None)
    	Team = Instigator.GetTeamNum();
}

simulated function PostNetBeginPlay()
{
	Beacon = spawn(class'ONSGrenadeBeaconRed', self);

	if (Beacon != None)
		Beacon.SetBase(self);

	Super.PostNetBeginPlay();
}

function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

function ProcessTouch( actor Other, vector HitLocation )
{
    if (StuckActor == None && !bPendingDelete && Base == None && Other != IgnoreActor && (!Other.bWorldGeometry && Other.Class != Class && (Other != Instigator || bCanHitOwner)))
		Stick(Other);
}

function HitWall( vector HitNormal, actor Wall )
{
	Stick(wall);
}

function Explode(optional vector HitLocation, optional vector HitNormal)
{
    LastTouched = Base;
    BlowUp(HitLocation);
    Destroy();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	Health -= Damage;
	if (Health <= 0)
	{
		Explode(Location, vect(0,0,1));
	}
}

function Stick(actor HitActor)
{
	if(HitActor == None || StuckActor != None)
		return;

    if ( Trail != None )
        Trail.mRegen = false; // stop the emitter from regenerating

    bBounce = False;
    LastTouched = HitActor;
    SetPhysics(PHYS_None);
	StuckActor = HitActor;
    SetBase(HitActor);
    bCollideWorld = False;
    bProjTarget = true;

	PlaySound(Sound'MenuSounds.Select3',,2.5*TransientSoundVolume);
}

function PawnBaseDied()
{
	Explode(Location, vect(0,0,1));
}

defaultproperties
{
     DampenFactor=0.500000
     DampenFactorParallel=0.800000
     HitEffectClass=Class'XEffects.WallSparks'
     Health=20
     Speed=700.000000
     MaxSpeed=1200.000000
     TossZ=0.000000
     bSwitchToZeroCollision=True
     Damage=100.000000
     DamageRadius=175.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'Onslaught.DamTypeONSGrenade'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CS_CloneItems_S.Props.Flamingo'
     CullDistance=5000.000000
     bNetTemporary=False
     bOnlyDirtyReplication=True
     Physics=PHYS_Falling
     RemoteRole=ROLE_DumbProxy
     LifeSpan=0.000000
     DrawScale=2.500000
     AmbientGlow=100
     bHardAttach=True
     CollisionRadius=12.000000
     CollisionHeight=40.000000
     bProjTarget=True
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
