//-----------------------------------------------------------
// Created 04/30/2004 by Demiurge Studios
// 
// Creates smoke and fire effect when the rocket bike
// enters "rocket" mode.
//-----------------------------------------------------------
class RocketBikeFlameEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\CS_ParticleFX_T.utx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter01
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         FadeOutStartTime=0.880000
         FadeInEndTime=0.200000
         MaxParticles=300
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.170000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(1)=(RelativeTime=0.040000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=30.000000,Max=50.000000),Z=(Min=30.000000,Max=50.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'CS_ParticleFX_T.Smoke2'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'Clones.RocketBikeFlameEffect.SpriteEmitter01'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter02
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=81,R=190,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.150000
         FadeInEndTime=0.063000
         CoordinateSystem=PTCS_Relative
         MaxParticles=11
         SpinsPerSecondRange=(X=(Min=0.040000,Max=0.428000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=0.500000,Max=0.950000))
         SizeScale(0)=(RelativeSize=0.449000)
         SizeScale(1)=(RelativeTime=0.170000,RelativeSize=0.985000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.420000)
         StartSizeRange=(X=(Min=42.000000,Max=42.000000),Y=(Min=42.000000,Max=42.000000),Z=(Min=42.000000,Max=42.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'CS_ParticleFX_T.FireSmallPart2'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.186000,Max=0.300000)
         StartVelocityRange=(X=(Min=-600.000000,Max=-600.000000),Y=(Min=-67.478004,Max=67.478004),Z=(Min=-67.478004,Max=67.478004))
         MaxAbsVelocity=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     End Object
     Emitters(1)=SpriteEmitter'Clones.RocketBikeFlameEffect.SpriteEmitter02'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter03
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=83,G=83,R=255,A=255))
         ColorScale(1)=(Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.300000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         SpinsPerSecondRange=(X=(Min=0.056000,Max=0.340000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=0.500000,Max=0.900000))
         SizeScale(1)=(RelativeTime=0.170000,RelativeSize=0.745000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.780000)
         StartSizeRange=(X=(Min=32.000000,Max=32.000000),Y=(Min=32.000000,Max=32.000000),Z=(Min=32.000000,Max=32.000000))
         Texture=Texture'CS_ParticleFX_T.Fire1'
         LifetimeRange=(Min=0.182000,Max=0.182000)
         StartVelocityRange=(X=(Min=-300.000000,Max=-500.000000),Y=(Min=-33.770000,Max=33.770000),Z=(Min=-33.770000,Max=33.770000))
         MaxAbsVelocity=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     End Object
     Emitters(2)=SpriteEmitter'Clones.RocketBikeFlameEffect.SpriteEmitter03'

     AutoDestroy=True
     bNoDelete=False
     AmbientSound=Sound'DB_Vehicles_A.RocketBike.RocketBikeEngineLoop'
     bHardAttach=True
     SoundVolume=255
     SoundRadius=600.000000
}
