// Created 05/26/04 by Demiurge Studios
// Handles smoke and explosion effects when the Pump blows up.
// Also handles spawning tiny parts that go
// flying away from the explosion.

class PumpExplosion extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaBarBent'
         UseMeshBlendMode=False
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-400.000000)
         FadeOutStartTime=1.000000
         MaxParticles=8
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         MeshScaleRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=1.000000),Y=(Min=0.200000,Max=1.000000),Z=(Min=0.200000,Max=1.000000))
         StartSpinRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         InitialParticlesPerSecond=8.000000
         DrawStyle=PTDS_Regular
         LifetimeRange=(Max=5.000000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=600.000000,Max=800.000000))
     End Object
     Emitters(0)=MeshEmitter'Clones.PumpExplosion.MeshEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         RespawnDeadParticles=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         MaxParticles=20
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=100.000000))
         StartSizeRange=(X=(Max=300.000000),Y=(Max=300.000000),Z=(Max=300.000000))
         Texture=Texture'AW-2004Explosions.Fire.Part_explode2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=2.000000)
     End Object
     Emitters(1)=SpriteEmitter'Clones.PumpExplosion.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         RespawnDeadParticles=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         MaxParticles=6
         StartLocationOffset=(Z=500.000000)
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         StartSizeRange=(X=(Min=150.000000,Max=300.000000),Y=(Min=150.000000,Max=300.000000),Z=(Min=150.000000,Max=300.000000))
         Texture=Texture'AW-2004Explosions.Fire.Part_explode2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=2.000000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(2)=SpriteEmitter'Clones.PumpExplosion.SpriteEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=136,G=71,R=32,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=2.000000
         FadeInEndTime=1.000000
         MaxParticles=40
         StartLocationOffset=(Z=100.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=150.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.070000),Y=(Min=0.050000,Max=0.070000),Z=(Min=0.050000,Max=0.070000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=70.000000),Y=(Min=70.000000),Z=(Min=70.000000))
         InitialParticlesPerSecond=20.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
         LifetimeRange=(Min=3.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=100.000000))
     End Object
     Emitters(3)=SpriteEmitter'Clones.PumpExplosion.SpriteEmitter9'

     AutoDestroy=True
     bNoDelete=False
}
