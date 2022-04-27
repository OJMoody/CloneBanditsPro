class ClonesAutoTurretProjEffect extends Emitter
	notplaceable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=64,G=128,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=80,G=64,R=80,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=128,R=64,A=255))
         ColorScaleRepeats=3.000000
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=240.000000)
         SpinCCWorCW=(Y=0.000000,Z=0.000000)
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=128.000000,Max=160.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.080000,Max=0.160000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=5.000000
     End Object
     Emitters(0)=SpriteEmitter'Clones.ClonesAutoTurretProjEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=64,G=128,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=64,A=255))
         Opacity=0.660000
         FadeOutStartTime=2.000000
         FadeInEndTime=0.080000
         CoordinateSystem=PTCS_Relative
         DetailMode=DM_High
         StartLocationOffset=(X=250.000000)
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.330000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.330000)
         StartSizeRange=(X=(Min=16.000000,Max=45.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Smoke.StellarFog1aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.500000,Max=2.500000)
         StartVelocityRange=(X=(Min=-200.000000,Max=-200.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=5.000000
     End Object
     Emitters(1)=SpriteEmitter'Clones.ClonesAutoTurretProjEffect.SpriteEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseColorScale=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=64,G=128,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=64,A=255))
         Opacity=0.660000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=257.000000,Y=-10.000000)
         StartLocationRange=(Y=(Min=10.000000,Max=10.000000))
         SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(Z=(Min=1.100000,Max=1.100000))
         StartSizeRange=(X=(Min=2.500000,Max=2.500000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=1.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=MeshEmitter'Clones.ClonesAutoTurretProjEffect.MeshEmitter1'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
