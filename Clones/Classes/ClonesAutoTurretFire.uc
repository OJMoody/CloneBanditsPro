//=============================================================================
// ClonesAutoTurretFire  created on 1/29/04 by Demiurge Studios
//=============================================================================

//class ClonesAutoTurretFire extends FM_SpaceFighter_Fire;
class ClonesAutoTurretFire extends FM_BallTurret_Fire;


// HAK : Overwrites the FM_BallTurret_Fire version
// Don't spawn a projectile based on the instigator team, always spawn
// projectile 0 in the TeamProjectileClasses array
function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

	//p = Weapon.Spawn(TeamProjectileClasses[Instigator.GetTeamNum()], Instigator, , Start, Dir);
	p = Weapon.Spawn(TeamProjectileClasses[0], Instigator, , Start, Dir);
    if ( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     TeamProjectileClasses(0)=Class'Clones.ClonesAutoTurretProjectile'
     TeamProjectileClasses(1)=Class'Clones.ClonesAutoTurretProjectile'
     aimerror=10000.000000
}
