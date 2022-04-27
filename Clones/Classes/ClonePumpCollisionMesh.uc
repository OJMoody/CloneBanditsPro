//---------------------------------------------------------------
// Created on 04/22/04 by Demiurge Studios
// Handles collision with the animated mesh by creating a visually
// invisible static mesh that maps onto the same place. Damage
// and healing are passed on to the ClonePump.
//---------------------------------------------------------------
class ClonePumpCollisionMesh extends Actor;
// TODO_CL: has to extend DestroyableObjective to be heal-able

var ClonePump Pump; // ClonePump that created this instance


function PostBeginPlay()
{
	Pump = ClonePump(Owner); // assign Owner as the parent pump
}


// any damage the machinery sustains, pass it along to the
// ClonePump via the HandleDamage function, so that the
// ClonePump only handles damage to the machinery.
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	if(Pump != None)
	{
		// Total HAK
		// There is a bug in the code that applies a negative scale factor
		// with a magnitude that could be greater than 1 to damage whose
		// hit location is outside the collision radius. This means damage
		// values much bigger than normal (and negative) can be passed
		// in for this object. So we HAK fix it be reassigning damage amounts
		// based on the type of damage. Note that the damage values are manually
		// entered based on the projectile type, so any changes to those damage
		// values would have to be changed here as well.

		// All these damage types have bDelayedDamage set to TRUE
		// Some of these damage types are used for multiple weapons/projectiles, so
		// one had to be picked over the other if their damage values were different.
		if(damageType == class'DamTypeRocket')
		{
			Damage = 90.0;
		}
		else if(damageType == class'DamTypeONSAVRiLRocket')
		{
			Damage = 125.0;
		}
		else if(damageType == class'DamTypeAttackCraftMissle')
		{
			Damage = 100.0;
		}
		else if(damageType == class'DamTypeAttackCraftPlasma')
		{
			Damage = 25.0;
		}
		else if(damageType == class'DamTypeHoverBikePlasma')
		{
			Damage = 30.0;
		}
		else if(damageType == class'DamTypeONSGrenade')
		{
			Damage = 100.0;
		}
		else if(damageType == class'DamTypeONSMine')
		{
			Damage = 95.0;
		}
		else if(damageType == class'DamTypeONSWeb')
		{
			Damage = 65.0;
		}
		else if(damageType == class'DamTypePRVCombo')
		{
			Damage = 200.0;
		}
		else if(damageType == class'DamTypeSkyMine')
		{
			Damage = 25.0;
		}
		else if(damageType == class'DamTypeTankShell')
		{
			Damage = 300.0;
		}
		else if(damageType == class'DamTypeMASPlasma')
		{
			Damage = 30.0;
		}
		else if(damageType == class'DamTypeSentinelLaser')
		{
			Damage = 20.0;
		}
		else if(damageType == class'DamTypeBallTurretPlasma')
		{
			Damage = 20.0; // ClonesAutoTurretProjectile, not PROJ_TurretSkaarjPlasma!
		}
		else if(damageType == class'DamTypeSpaceFighterMissile')
		{
			Damage = 400.0;
		}
		else if(damageType == class'DamTypeAssaultGrenade')
		{
			Damage = 70.0;
		}
		else if(damageType == class'DamTypeBioGlob')
		{
			Damage = 19.0;
		}
		else if(damageType == class'DamTypeFlakChunk')
		{
			Damage = 13.0;
		}
		else if(damageType == class'DamTypeFlakShell')
		{
			Damage = 90.0;
		}
		else if(damageType == class'DamTypeLinkPlasma')
		{
			Damage = 30.0;
		}
		else if(damageType == class'DamTypeRedeemer')
		{
			Damage = 250.0;
		}
		else if(damageType == class'DamTypeShockBall')
		{
			Damage = 45.0;
		}

		Pump.HandleDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
}

function Bump(Actor Other)
{
   Pump.Bump(Other);
}


// any healing to the machinery is passed along to the ClonePump via
// the HandleHealing function, so that the ClonePump only cares
// about healing done to the machinery.
//function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
//{
//	if(Pump != None)
//	{
//		Log("HealDamage Called!",'ClonePumpCollisionMesh');
//		return Pump.HandleHealing(Amount, Healer, DamageType);
//	}
//}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CS_CloneItems_S.ClonePump.MachineCollision'
     bHidden=True
     bIgnoreEncroachers=True
     DrawScale=2.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bBlockKarma=True
     bPathColliding=True
}
