class ClonesDefaultMut extends DMMutator
	HideDropDown
	CacheExempt;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Controller(Other) != None && MessagingSpectator(Other) == None)
	{
		Controller(Other).bAdrenalineEnabled = false;
		Controller(Other).PlayerReplicationInfoClass = class'ClonesPlayerReplicationInfo';
	}

	return true;
}

defaultproperties
{
}
