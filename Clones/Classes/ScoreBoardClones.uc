//=============================================================================
//
//=============================================================================

class ScoreBoardClones extends ScoreBoardTeamDeathMatch;


var localized	string	RemainingRoundTime, CurrentRound, RoundSeparator;
var localized	string	Defender, Attacker;
var localized	string	WaitForReinforcements, WaitingToSpawnReinforcements, AutoRespawn;
var localized	string	YouWonRound, YouLostRound, PracticeRoundOver;


function String GetTitleString()
{
    return Super.GetTitleString();
}

function String GetRestartString()
{
	local string				RestartString;
	local ClonesGameReplicationInfo	CGRI;

	CGRI = ClonesGameReplicationInfo(GRI);

    // TODO Al: Handle game over and winner display

	if ( Controller(Owner).PlayerReplicationInfo != None
		&& !Controller(Owner).IsInState('PlayerWaiting') )
	{
	   if((GRI.Teams[Controller(Owner).PlayerReplicationInfo.Team.TeamIndex].Score) > 0)
            RestartString = AutoRespawn @ CGRI.ReinforcementCountDown;
        else
            RestartString = "Waiting for your team to get more clones";
	}

	return RestartString;
}

function String GetDefaultScoreInfoString()
{
    return Super.GetDefaultScoreInfoString();
}


function DrawTeam(int TeamNum, int PlayerCount, int OwnerOffset, Canvas Canvas, int FontReduction, int BoxSpaceY, int PlayerBoxSizeY, int HeaderOffsetY)
{
    Super.DrawTeam(TeamNum, PlayerCount, OwnerOffset, Canvas, FontReduction, BoxSpaceY, PlayerBoxSizeY, HeaderOffsetY);
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RemainingRoundTime="Remaining round time:"
     CurrentRound="Round:"
     RoundSeparator="/"
     Defender="( Defender )"
     Attacker="( Attacker )"
     WaitForReinforcements="   You were killed. Clone wave in"
     WaitingToSpawnReinforcements="Waiting for clones wave..."
     AutoRespawn="Automatically respawning in..."
     YouWonRound="You've won the round!"
     YouLostRound="You've lost the round."
     PracticeRoundOver="Practice round over."
     Restart="You were killed, waiting to clone"
}
