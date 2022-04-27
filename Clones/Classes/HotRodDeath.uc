// Created 04/16/04 by Demiurge Studios
// Handles smoke and explosion effects when the HotRod blows up.
// Also handles spawning tiny parts of the vehicle that go
// flying away from the explosion.

class HotRodDeath extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\StaticMeshes\TL_DeadVehicles_S.usx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter000
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=20.000000)
         ColorScale(0)=(Color=(A=8))
         ColorScale(1)=(RelativeTime=0.200000,Color=(A=96))
         ColorScale(2)=(RelativeTime=0.500000,Color=(A=96))
         ColorScale(3)=(RelativeTime=1.000000)
         DetailMode=DM_High
         AddLocationFromOtherEmitter=1
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=50.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'Clones.HotRodDeath.SpriteEmitter000'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter001
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=50.000000,Max=100.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         InitialParticlesPerSecond=50.000000
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRadialRange=(Min=-50.000000,Max=-50.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'Clones.HotRodDeath.SpriteEmitter001'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter002
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         DetailMode=DM_High
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=100.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Max=150.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRadialRange=(Min=-50.000000,Max=-80.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'Clones.HotRodDeath.SpriteEmitter002'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter003
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         DetailMode=DM_High
         AddLocationFromOtherEmitter=8
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=50.000000,Max=80.000000))
         InitialParticlesPerSecond=13.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(3)=SpriteEmitter'Clones.HotRodDeath.SpriteEmitter003'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter004
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         DetailMode=DM_High
         AddLocationFromOtherEmitter=10
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=50.000000,Max=80.000000))
         InitialParticlesPerSecond=13.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(4)=SpriteEmitter'Clones.HotRodDeath.SpriteEmitter004'

     Begin Object Class=MeshEmitter Name=MeshEmitter000
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaTire'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=120.000000,Y=96.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=300.000000,Max=500.000000),Z=(Min=100.000000,Max=100.000000))
     End Object
     Emitters(5)=MeshEmitter'Clones.HotRodDeath.MeshEmitter000'

     Begin Object Class=MeshEmitter Name=MeshEmitter001
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaTire'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=120.000000,Y=-96.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=-300.000000,Max=-500.000000),Z=(Min=100.000000,Max=100.000000))
     End Object
     Emitters(6)=MeshEmitter'Clones.HotRodDeath.MeshEmitter001'

     Begin Object Class=MeshEmitter Name=MeshEmitter002
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaTire'
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-140.000000,Y=96.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=-150.000000,Max=-200.000000),Y=(Min=300.000000,Max=500.000000),Z=(Min=50.000000,Max=100.000000))
     End Object
     Emitters(7)=MeshEmitter'Clones.HotRodDeath.MeshEmitter002'

     Begin Object Class=MeshEmitter Name=MeshEmitter003
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaTire'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         ExtentMultiplier=(X=0.500000,Y=0.500000,Z=0.500000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.300000))
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-140.000000,Y=-96.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=-150.000000,Max=-200.000000),Y=(Min=-300.000000,Max=-500.000000),Z=(Min=100.000000,Max=100.000000))
     End Object
     Emitters(8)=MeshEmitter'Clones.HotRodDeath.MeshEmitter003'

     Begin Object Class=MeshEmitter Name=MeshEmitter004
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaBarBent'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(Y=-65.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.100000),Y=(Min=2.000000,Max=2.000000),Z=(Max=0.100000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=-100.000000),Z=(Min=100.000000,Max=700.000000))
     End Object
     Emitters(9)=MeshEmitter'Clones.HotRodDeath.MeshEmitter004'

     Begin Object Class=MeshEmitter Name=MeshEmitter005
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaLicense'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-200.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=2.000000,Max=4.000000),Z=(Max=4.000000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Max=6.000000)
         StartVelocityRange=(X=(Min=-600.000000,Max=-400.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=500.000000,Max=1000.000000))
     End Object
     Emitters(10)=MeshEmitter'Clones.HotRodDeath.MeshEmitter005'

     Begin Object Class=MeshEmitter Name=MeshEmitter006
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaGun'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=100.000000,Y=-90.000000,Z=90.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.100000,Max=1.000000),Z=(Min=-4.000000,Max=-2.000000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=200.000000,Max=400.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=300.000000,Max=700.000000))
     End Object
     Emitters(11)=MeshEmitter'Clones.HotRodDeath.MeshEmitter006'

     Begin Object Class=MeshEmitter Name=MeshEmitter007
         StaticMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaTank'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         MaxParticles=1
         DetailMode=DM_High
         StartLocationOffset=(X=-150.000000,Z=20.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.500000),Y=(Min=0.400000,Max=0.900000),Z=(Min=0.200000,Max=0.900000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         StartVelocityRange=(X=(Min=-100.000000,Max=-50.000000),Y=(Min=-75.000000,Max=75.000000),Z=(Min=10.000000,Max=100.000000))
     End Object
     Emitters(12)=MeshEmitter'Clones.HotRodDeath.MeshEmitter007'

     AutoDestroy=True
     bNoDelete=False
}
