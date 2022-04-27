//=============================
// VJumppad - bounces vehicles up
// not directly placeable.  Make a subclass with appropriate sound effect etc.
//
class VJumpPad extends JumpPad;

var(JumpPad) float VelocityScale;

function PostBeginPlay()
{
	super.PostBeginPlay();
}


event Touch(Actor Other)
{
	if (Vehicle(Other) == None)
		return;

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

event PostTouch(Actor Other)
{
	local SVehicle V;
	local rotator R;
	local float MassZMod;
	local float MassXYMod;
	local vector VectorMod;
	
	R.Pitch = 0;
	
	V = SVehicle(Other);
	if (V == None)
		return;

	if ( ONSRV(V) == None )
		return;
			
	MassZMod  = 700000 * (V.VehicleMass / 3.5);
	MassXYMod = 600000 * (V.VehicleMass / 3.5);

		
	VectorMod.X = MassXYMod;
	VectorMod.Y = MassXYMod;
	VectorMod.Z = MassZMod;
		
	if ( AIController(V.Controller) != None )
	{
		V.Controller.Movetarget = JumpTarget;
		V.Controller.Focus = JumpTarget;
		if ( V.Physics != PHYS_Flying )
			V.Controller.MoveTimer = 2.0;
		V.DestinationOffset = JumpTarget.CollisionRadius;
	}
	if ( V.Physics == PHYS_Walking )
		V.SetPhysics(PHYS_Falling);
	V.KAddImpulse(JumpVelocity * VectorMod * VelocityScale,  V.Location);
	V.Acceleration = vect(0,0,0);
	if ( JumpSound != None )
		V.PlaySound(JumpSound);

}

defaultproperties
{
     VelocityScale=1.000000
     JumpZModifier=10.000000
}
