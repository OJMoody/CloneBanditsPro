class ClonesPawn extends xPawn;

#exec LOAD OBJ FILE="../Textures/CS_CloneSkins_T.utx"

// Stolen from xPawn so we can force a skin without making a new species...oye
simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	if ( (rec.Species == None) || class'DeathMatch'.default.bForceDefaultCharacter )
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());

    Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	if ( !Species.static.Setup(self,rec) )
	{
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
		if ( !Species.static.Setup(self,rec) )
			return;
	}

	// Added by Demiurge to force skins because I didn't want to make a new Species???

	if(PlayerReplicationInfo != None)
	{
		switch(PlayerReplicationInfo.Team.TeamIndex)
		{
		case 0:
			Skins[1] = Material'CS_CloneSkins_T.Clone_One.CloneHeadRed_FB';
			Skins[0] = Material'CS_CloneSkins_T.Clone_One.GlowCombinerRed';
			break;
		case 1:
			Skins[1] = Material'CS_CloneSkins_T.Clone_One.CloneHeadBlue_FB';
			Skins[0] = Material'CS_CloneSkins_T.Clone_One.GlowCombinerBlue';
			break;
		}
	}
	
	ResetPhysicsBasedAnim();
}

// This will cause the Setup function to never access none and always be called after PRI is set
simulated function bool ForceDefaultCharacter()
{
	return false; 
}

defaultproperties
{
     ControllerClass=Class'Clones.ClonesBot'
}
