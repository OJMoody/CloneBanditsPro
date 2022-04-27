//=============================================================================
// ClonesAutoTurretWeapon  created on 1/29/04 by Demiurge Studios
//=============================================================================

class ClonesAutoTurretWeapon extends Weapon_Turret
	config(user)
    HideDropDown
	CacheExempt;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'Clones.ClonesAutoTurretFire'
}
