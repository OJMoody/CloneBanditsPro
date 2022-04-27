class HotRodDaredevilMessage extends LocalMessage;

#exec OBJ LOAD FILE="..\Sounds\announcermale2k4.uax"
#exec OBJ LOAD FILE="..\Sounds\ONSVehicleSounds-S.uax"

var		localized String	StuntInfoString1;
var		sound				CheerSound;

static function string GetString(
								 optional int SwitchNum,
								 optional PlayerReplicationInfo RelatedPRI_1,
								 optional PlayerReplicationInfo RelatedPRI_2,
								 optional Object OptionalObject
								 )
{
	return Default.StuntInfoString1$SwitchNum;
}

static simulated function ClientReceive(
										PlayerController P,
										optional int SwitchNum,
										optional PlayerReplicationInfo RelatedPRI_1,
										optional PlayerReplicationInfo RelatedPRI_2,
										optional Object OptionalObject
										)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	P.ClientPlaySound(Default.CheerSound);
}

defaultproperties
{
     StuntInfoString1="Nice Stunt! Nitrous Awarded: "
     CheerSound=Sound'ONSVehicleSounds-S.PowerNode.whooshthunk'
     bFadeMessage=True
     Lifetime=9
     DrawColor=(B=128,G=0)
     StackMode=SM_Down
     PosY=0.700000
}
