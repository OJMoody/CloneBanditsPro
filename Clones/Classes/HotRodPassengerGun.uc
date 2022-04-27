//-----------------------------------------------------------
//  Created on 03/22/04 by Demiurge Studios
//
//  Version of gatling gun with some tweaks for use on
//  passenger side of Hot Rod
//-----------------------------------------------------------
class HotRodPassengerGun extends GatlingGun;

defaultproperties
{
     YawBone="RoofSwivel"
     YawStartConstraint=0.000000
     YawEndConstraint=65535.000000
     PitchBone="RoofPivot"
     PitchUpLimit=10923
     PitchDownLimit=61896
     WeaponFireAttachmentBone="RoofFire"
     GunnerAttachmentBone="RoofRoot"
     Mesh=SkeletalMesh'TL_Vehicles_K.roofgun'
}
