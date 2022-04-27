class NoClonesTimer extends Info;

var int TeamIndex;

function Timer()
{
	ClonesGame(Owner).NoClonesTimerCallBack(TeamIndex);
}

defaultproperties
{
}
