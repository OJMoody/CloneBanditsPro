class BotNitrousSpot extends Actor
	placeable;

var() int AllowedYawDiff;



function int GetRotDiff(int A, int B)
{
	local int comp;

	comp = (A - B) & 65535;
	if(comp > 32768)
		comp -= 65536;

	return comp;
}



event Touch(Actor Other)
{
	local HotRod hr;

	hr = HotRod(Other);
	if(hr != NONE && Bot(hr.Controller) != NONE)
	{
		if(GetRotDiff(hr.Rotation.Yaw, Rotation.Yaw) <= AllowedYawDiff)
			hr.Nitrous();
	}
}

defaultproperties
{
     AllowedYawDiff=7000
     bHidden=True
     RemoteRole=ROLE_None
     CollisionRadius=160.000000
     CollisionHeight=80.000000
     bCollideActors=True
     bDirectional=True
}
