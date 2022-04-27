//-----------------------------------------------------------------
// ClonesAutoTurretController - Created on 2/2/04  Demiurge Studios
//-----------------------------------------------------------------

class ClonesAutoTurretController extends TurretController;

// override TurretController version so only vehicles are relevant
function bool IsTargetRelevant( Pawn Target )
{
	if ( (Target != None) &&				// valid target
	     (Target.Controller != None) &&		// ?
	     !SameTeamAs(Target.Controller) &&  // target is not on turret's team
		 (Target.Health > 0) &&				// target is alive
		 (SVehicle(Target) != None) 		// target is a vehicle
		)
			return true;	// label it as a valid target
	return false;			// else its not a valid target (this includes infantry)
}

defaultproperties
{
}
