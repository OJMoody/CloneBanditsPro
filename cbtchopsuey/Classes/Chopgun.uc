// Chopgun. 2k4 *hollib* - based on code by
// Demiurge Studios & Epic

class Chopgun extends ONSHoverTankCannon
	Placeable;

defaultproperties
{
     YawBone="RoofSwivel"
     YawStartConstraint=-16000.000000
     YawEndConstraint=16000.000000
     PitchBone="RoofPivot"
     PitchUpLimit=10923
     PitchDownLimit=86896
     WeaponFireAttachmentBone="RoofFire"
     GunnerAttachmentBone="rearrothub"
     WeaponFireOffset=300.000000
     FireInterval=1.600000
     AltFireInterval=1.400000
     FireSoundClass=Sound'ONSVehicleSounds-S.Grenade.GenadeFire02'
     FireSoundVolume=150.000000
     AltFireSoundClass=Sound'ONSVehicleSounds-S.VehicleImpacts.VehicleImpact07'
     AltFireSoundVolume=150.000000
     AltFireForce="Explosion05"
     ProjectileClass=Class'cbtchopsuey.Chopgunprim'
     AltFireProjectileClass=Class'cbtchopsuey.Chopgunalt'
     Mesh=SkeletalMesh'TL_Vehicles_K.roofgun'
}
