//=============================================================================
// Clones_FX_Laser_Blue  created 1/29/04 by Demiurge Studios
//=============================================================================


class Clones_FX_Laser_Blue extends FX_Laser_Blue;


// lets us make green lasers
simulated function SetGreenColor()
{
	// might want to tweak these RGB values
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(48, 200, 80);
	Emitters[0].ColorScale[1].Color = Emitters[0].ColorScale[0].Color;
	Emitters[1].ColorScale[0].Color = Emitters[0].ColorScale[0].Color;
	Emitters[1].ColorScale[1].Color = Emitters[0].ColorScale[0].Color;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=64))
         ColorScale(1)=(RelativeTime=0.750000,Color=(B=255,G=128,R=64))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=150.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=0.150000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=0.750000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=50.000000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.050000,Max=0.050000)
     End Object
     Emitters(0)=SpriteEmitter'Clones.Clones_FX_Laser_Blue.SpriteEmitter1'

     Begin Object Class=BeamEmitter Name=BeamEmitter1
         BeamEndPoints(0)=(offset=(X=(Min=600.000000,Max=600.000000)),Weight=1.000000)
         DetermineEndPointBy=PTEP_Offset
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=128,R=64))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=64))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=-150.000000)
         StartSizeRange=(X=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AS_FX_TX.Beams.LaserTex'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=10.000000)
     End Object
     Emitters(1)=BeamEmitter'Clones.Clones_FX_Laser_Blue.BeamEmitter1'

}
