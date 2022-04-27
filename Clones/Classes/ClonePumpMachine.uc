//---------------------------------------------------------------
// Created on 04/16/04 by Demiurge Studios
// Handles the visual aspects of the animated mesh. Plays
// animations, and updates skins given state of ClonePump.
//---------------------------------------------------------------
class ClonePumpMachine extends Actor;

var ClonePump Pump; // ClonePump that created this instance

var array<Material> RedSkins; // special textures when controlled by red team
var array<Material> BlueSkins; // special textures when controlled by blue team
// used to display remaining clones as a texture
var		Font			CounterFont;
var		ScriptedTexture	RedCounterTexture;
var     ScriptedTexture BlueCounterTexture;
var		int				RedCount;	// internal counts of how many clones each team has
var		int				BlueCount;

var		int DisplayedRedCount, DisplayedBlueCount;

var float TickCounter;

replication
{
	reliable if(Role == ROLE_Authority && bNetDirty)
		RedCount, BlueCount;
}

simulated event Tick(float DeltaTime)
{
	TickCounter += DeltaTime;

	if(Level.NetMode != NM_DedicatedServer)
	{
		if(DisplayedRedCount != RedCount || DisplayedBlueCount != BlueCount)
			UpdateCounters(RedCount, BlueCount);
	}
}


simulated function UpdatePrecacheMaterials()
{
	local int i;

	for ( i=0; i<BlueSkins.Length; i++ )
		Level.AddPrecacheMaterial(BlueSkins[i]);

	for ( i=0; i<RedSkins.Length; i++ )
		Level.AddPrecacheMaterial(RedSkins[i]);

    Super.UpdatePrecacheMaterials();
}


simulated function PostBeginPlay()
{
	Pump = ClonePump(Owner); // assign Owner as the parent pump

	Skins = default.Skins;

	CounterFont = Font(DynamicLoadObject("2k4Fonts.Verdana34", class'Font'));
	RedCounterTexture = InitCounter(ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture')));
	BlueCounterTexture = InitCounter(ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture')));
	Skins[3] = RedCounterTexture;
	Skins[6] = BlueCounterTexture;
}

// call to set the skins for the machine for when its in
// the neutral state. Assign half-transparent skins so
// players know the machinery isn't active.
simulated function SetNeutral()
{
	// do not overwrite the two dynamic skins that display the team clone counts
	// as those do not ever change.
	// Reset all the other skins to the neutral values.
	Skins[0] = default.Skins[0];
	Skins[1] = default.Skins[1];
	Skins[2] = default.Skins[2];
	Skins[4] = default.Skins[4];
	Skins[5] = default.Skins[5];
	Skins[7] = default.Skins[7];
	Skins[8] = default.Skins[8];
}


// call to set the machine's skins when constructing.
// Show the machinery as opaque with the swirly colored
// texture you see when you steal a vehicle, colored for
// which team is constructing the pump.
simulated function SetConstructing(byte Team)
{
	// update skins with which team is constructing this pump
    if (Team == 0)
	{
		// reassign only specific skins
		Skins[0] = RedSkins[0]; // apply crazy swirling texture to machinery
	}
    else
	{
        // reassign only specific skins
        Skins[0] = BlueSkins[0]; // apply crazy swirling texture to machinery
	}
}


// call to set the machine's skins when active.
// Show the machinery as opaque and colored according
// to the controlling team.
simulated function SetActive(byte Team)
{
	LoopAnim('Pump',1.0); // loop the "pumping" animation

	// update skins with which team is constructing this pump
    if (Team == 0)
	{
		// reassign only specific skins
		Skins[0] = RedSkins[1]; // apply solid coloring to machinery
		Skins[2] = RedSkins[3]; // highlight controlling team's sign
		Skins[8] = RedSkins[2]; // play proper lighting sequence of neon clones
	}
    else
	{
        // reassign only specific skins
        Skins[0] = BlueSkins[1]; // apply solid coloring to machinery
		Skins[5] = BlueSkins[3]; // highlight controlling team's sign
		Skins[8] = BlueSkins[2]; // play proper lighting sequence of neon clones
	}
}

simulated function SetDestroyed()
{
	// stop pumping animation
	StopAnimating();

	// set skins back to defaults
    Skins[0] = default.Skins[0];
	Skins[2] = default.Skins[2];
	Skins[5] = default.Skins[5];
	Skins[8] = default.Skins[8];
}


// update the internal counts for this pump so it displays
// the correct number of clones for each team
simulated function UpdateCounters(int NumRed, int NumBlue)
{
	DisplayedRedCount = NumRed;
	DisplayedBlueCount = NumBlue;

	RedCounterTexture.Revision++;
	BlueCounterTexture.Revision++;
}


// Creates a dynamic texture for use in displayed the number
// of clones left at this pump
simulated function ScriptedTexture InitCounter(ScriptedTexture Counter)
{
    Counter.SetSize(256,128);
    Counter.Client = Self;

	return Counter;
}

simulated event RenderSingleTexture(ScriptedTexture Tex, int Count)
{
    local int SizeX,  SizeY;
	local string CounterString;
    local color BackColor, ForegroundColor, HighLightColor;

    HighLightColor.R=100;
    HighLightColor.G=100;
    HighLightColor.B=100;
    HighLightColor.A=255;

    ForegroundColor.R=0;
    ForegroundColor.G=255;
    ForegroundColor.B=0;
    ForegroundColor.A=255;

    BackColor.R=128;
    BackColor.G=128;
    BackColor.B=128;
    BackColor.A=0;

    CounterString = string(Count);
    Tex.TextSize(CounterString, CounterFont, SizeX, SizeY);
    //Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, LicensePlateBackground, BackColor);
    Tex.DrawText(((Tex.USize - SizeX) * 0.5) - 1, 40 - 1, CounterString, CounterFont, HighLightColor);
    Tex.DrawText((Tex.USize - SizeX) * 0.5, 40, CounterString, CounterFont, ForegroundColor);
}

// Renders the scripted texture according to how many
// clones are left in this pump
simulated event RenderTexture(ScriptedTexture Tex)
{
	if(Tex==RedCounterTexture)
		RenderSingleTexture(Tex, RedCount);
	if(Tex==BlueCounterTexture)
		RenderSingleTexture(Tex, BlueCount);
}

defaultproperties
{
     RedSkins(0)=Shader'CS_CloneItems_T.ClonePump.BuildFXRed'
     RedSkins(1)=Combiner'CS_CloneItems_T.ClonePump.PumpRedCombo'
     RedSkins(2)=FinalBlend'CS_CloneItems_T.ClonePump.ClonesToRedFinal'
     RedSkins(3)=MaterialSequence'CS_CloneItems_T.ClonePump.EdgeFlashRed'
     BlueSkins(0)=Shader'CS_CloneItems_T.ClonePump.BuildFXBlue'
     BlueSkins(1)=Combiner'CS_CloneItems_T.ClonePump.PumpBlueCombo'
     BlueSkins(2)=FinalBlend'CS_CloneItems_T.ClonePump.ClonesToBlueFinal'
     BlueSkins(3)=MaterialSequence'CS_CloneItems_T.ClonePump.EdgeFlashBlue'
     RedCount=666
     BlueCount=888
     DrawType=DT_Mesh
     bIgnoreEncroachers=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Mesh=SkeletalMesh'CS_CloneItems_K.ClonePumpMachine'
     DrawScale=2.000000
     Skins(0)=Texture'CS_CloneItems_T.ClonePump.ClonePumpGhost'
     Skins(1)=Texture'CS_CloneItems_T.Props.RampartsRed'
     Skins(2)=Shader'CS_CloneItems_T.ClonePump.EdgeGlowRedShader'
     Skins(3)=Texture'CS_CloneItems_T.ClonePump.ScreenNumberRed'
     Skins(4)=Texture'CS_CloneItems_T.Props.RampartsBlue'
     Skins(5)=Shader'CS_CloneItems_T.ClonePump.EdgeGlowBlueShader'
     Skins(6)=Texture'CS_CloneItems_T.ClonePump.ScreenNumberBlue'
     Skins(7)=Texture'CS_CloneItems_T.ClonePump.CloneSign'
     Skins(8)=Texture'CS_CloneItems_T.ClonePump.CloneSignGlow2'
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
