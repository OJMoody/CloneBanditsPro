class BigBerthaProjectile extends Projectile;

var	NewRedeemerTrail SmokeTrail;


var() vector ShakeRotMag;           
var() vector ShakeRotRate;          
var() float  ShakeRotTime;          
var() vector ShakeOffsetMag;        
var() vector ShakeOffsetRate;       
var() float  ShakeOffsetTime;       
var bool bExploded;

simulated function Destroyed() 
{
	if ( SmokeTrail != None )
		SmokeTrail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local vector Dir;
	
	if ( bDeleteMe || IsInState('Dying') )
		return;
		
	Dir = vector(Rotation);
	Velocity = speed * Dir;
	
	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'NewRedeemerTrail',self,,Location - 40 * Dir, Rotation);
		SmokeTrail.SetBase(self);	
	}
}

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;
		
	return false;
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( Other != instigator ) 
		Explode(HitLocation,Vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal) 
{
	BlowUp(HitLocation);
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
	BlowUp(Location);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	BlowUp(Location);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType) 
{
	if ( Damage > 0 )
	{
		if ( InstigatedBy == None )
			BlowUp(Location);
		else
		{
	 		Spawn(class'SmallRedeemerExplosion');	
		    SetCollision(false,false,false);
		    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
		    Destroy();
		}
	}
}

simulated event FellOutOfWorld(eKillZType KillType)
{
	BlowUp(Location);
}	

function BlowUp(vector HitLocation)
{
    Spawn(class'RedeemerExplosion',,, HitLocation - 100 * Normal(Velocity), Rot(0,16384,0));
	MakeNoise(1.0);
	SetPhysics(PHYS_None);
	bHidden = true;
    GotoState('Dying'); 
}

state Dying
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType) {}
							
    function BeginState()
    {
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		if ( !bExploded )
		{
			Spawn(class'IonCore',,, Location, Rotation);
			ShakeView();
		}
		InitialState = 'Dying';
		if ( SmokeTrail != None )
			SmokeTrail.Destroy();
    }

    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None )
            {
                Dist = VSize(Location - PC.ViewTarget.Location);
                if ( Dist < DamageRadius * 2.0)
                {
                    if (Dist < DamageRadius)
                        Scale = 1.0;
                    else
                        Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}

defaultproperties
{
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     Speed=1000.000000
     MaxSpeed=1000.000000
     Damage=250.000000
     DamageRadius=2000.000000
     MomentumTransfer=200000.000000
     MyDamageType=Class'XWeapons.DamTypeRedeemer'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerMissile'
     bDynamicLight=True
     bNetTemporary=False
     AmbientSound=Sound'WeaponSounds.Misc.redeemer_flight'
     DrawScale=0.500000
     AmbientGlow=96
     bUnlit=False
     SoundVolume=255
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     bProjTarget=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}
