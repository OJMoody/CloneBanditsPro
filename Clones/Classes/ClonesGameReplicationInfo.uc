//=============================================================================
// ClonesGameReplicationInfo.
//=============================================================================

class ClonesGameReplicationInfo extends GameReplicationInfo;

var int	ReinforcementCountDown;

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		ReinforcementCountDown;
}

simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	SecondCount = Level.TimeSeconds;
	SetTimer(1, true);
}

simulated function Timer()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( Level.TimeSeconds - SecondCount >= Level.TimeDilation )
		{
			if ( ReinforcementCountDown > 0 ) // Reinforcements countdown..
				ReinforcementCountDown--;
		}
	}
	super.Timer();
}

defaultproperties
{
}
