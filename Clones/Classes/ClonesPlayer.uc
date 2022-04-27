//=============================================================================
// ClonesPlayer
//=============================================================================
class ClonesPlayer extends XPlayer;


var bool LockOutViewNextPlayer;


replication
{
    // Functions client can call.
    reliable if( Role<ROLE_Authority )
        ReliableServerViewNextPlayer, ReliableServerViewSelf;
}

function ReliableServerViewNextPlayer()
{
	if(!LockOutViewNextPlayer)
		ServerViewNextPlayer();
}

// This function is reverting back to an old version of PlayerController::ServerViewSelf
// which changed in a patch and was cauing people to spawn in at their death location
// in single player games.
function ClonesPlayerServerViewSelf()
{
    bBehindView = false;
    SetViewTarget(self);
    ClientSetViewTarget(self);
    ClientMessage(OwnCamera, 'Event');
}

function ReliableServerViewSelf()
{
	ClonesPlayerServerViewSelf();
	LockOutViewNextPlayer = true;
}


simulated function PlayStatusAnnouncement(name AName, byte AnnouncementLevel, optional bool bForce)
{
	StatusAnnouncer.AlternateFallbackSoundPackage = "CL_AnnouncerClones";
	Super.PlayStatusAnnouncement(AName, AnnouncementLevel, bForce);
}

function SetPawnClass(string inClass, string inCharacter)
{
	Super.SetPawnClass(inClass, "Garrett");
}


simulated state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

	// Spectating Fire
    exec function Fire( optional float F )
    {
    	if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}

		ReliableServerViewNextPlayer();
    }

	function BeginState()
	{
		Super.BeginState();
		LockOutViewNextPlayer = false;
	}

	function EndState()
	{
		Super.EndState();

		if (Role == ROLE_Authority)
		{
			bBehindView = false;
			ReliableServerViewSelf();
		}
	}



Begin:
	Sleep(2.0);
	if ( myHUD != None )
		myHUD.bShowScoreBoard = true;
}



event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local RocketBike rb;

	Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);

	rb = RocketBike(ViewActor);
	if(rb != NONE)
	{
		DesiredFOV = rb.RocketFOV;
	}
}

defaultproperties
{
}
