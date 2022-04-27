//=============================================================================
// ClonesPlayer
//=============================================================================
class ClonesBot extends xBot;

var bool bClonesFinalStretch;

event PostBeginPlay()
{
	Super.PostBeginPlay();
}

function SetPawnClass(string inClass, string inCharacter)
{
	// Force clones pawn and the proper model
	Super.SetPawnClass("Clones.ClonesPawn", "Garrett");
}

state Dead
{
	function BeginState()
	{
		Super.BeginState();
		bClonesFinalStretch = false;
	}
}

function Reset()
{
	Super.Reset();
	bClonesFinalStretch = false;
}

defaultproperties
{
}
