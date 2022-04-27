// Created on 04/29/2004 by Demiurge Studios
// Sets vehicle class to ensure proper
// messages are spawned when someone is run
// over by a Lounge Tank.

class DamTypeLoungeTankRoadkill extends DamTypeRoadkill
	abstract;

defaultproperties
{
     VehicleClass=Class'Clones.LoungeTank'
}
