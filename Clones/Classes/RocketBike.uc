//-----------------------------------------------------------
//  RocketBike - Created on 1/20/04  Demiurge Studios
//-----------------------------------------------------------
class RocketBike extends ONSWheeledCraft;

// Configurable Vars

var() float LocalRollDamping;
var() float LocalPitchDamping;
var() float LocalTurnDamping;
var() float AntiRollStiffness;
var() float BikeTurnDamping;
var() bool MouseSteer;
var() array<sound> Countdown;	// 1,2,3,4,5 in Russian	

var() int ContactDamage;
var() name TrailAttachmentBone;
var() vector TrailOffset; // used to position the trail particle effect
var() Sound RocketingSound;

var Pawn Rocketeer; // The pawn to fire the rocket

var float RocketFOV;

// Internal Vars

var bool ClientDoRocket; // Set to true while pending a nitrous boost
var float RocketForce; // How much force to apply per-tick during nitrous
var float DestructTime; // how long (seconds) before bike explodes after entering rocket mode
var bool bCounting;		// used to display last seconds of countdown to driver (if any)
var int DestructCounter; // used to display last seconds of countdown to driver (if any)
var class<Emitter> TrailEmitterClass; // class of emitter trail when the rocket is "fired"
var Emitter Trail; // A rocket trail to follow a rocketting rocket bike
var bool ReallyInAir;

replication
{
	reliable if( Role == ROLE_Authority)
		ClientDoRocket, Rocketeer;
}


// Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it

// Copied from ONSVehicle class, but commented out call to parent factory to spawn a vehicle, as
// it breaks our multiple vehicle per factory logic -RSG
event CheckReset()
{
    local Pawn P;
    local int x;
    local Vehicle V;

	// if a weapon on the vehicle is being used
    for (x = 0; x < WeaponPawns.length; x++)
    	if (WeaponPawns[x].Driver != None)
    	{
			//Log("LoungeTank.CheckReset: Info. Manning a weapon. Extending time till self-destruct");
    		ResetTime = Level.TimeSeconds + 15;
    		return;
    	}

	// if there is a friendly (same team), non-vehicle pawn within 2500 units and there is a line of sight
	// between it and the vehicle, extend the self-destruct timer
    foreach CollidingActors(class 'Pawn', P, 2500.0)
        if (P != self && P.GetTeamNum() == GetTeamNum() && FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1)))
        {
			// test if pawn is a vehicle
			V = Vehicle(P);

			// if pawn is a non-vehicle, extend the self-destruct time
			if(V == None)
			{
				//Log("LoungeTank.CheckReset: Info. Friendly non-vehicle pawn close enough. Extending time till self-destruct");
				//Log(P.GetHumanReadableName());

				ResetTime = Level.TimeSeconds + 15;
				return;
			}
       	}

	//Log("LoungeTank.CheckReset: Info. No one around. Vehicle Self-destruct");

	// destroy vehicle (assuming this calls VehicleDestroyed from parent factory)
    Destroy();
}

// firing vehicle weapon enters rocket mode
function VehicleFire(bool bWasAltFire)
{
	Rocket();
}


simulated event KApplyForce(out vector Force, out vector Torque)
{
	local KRigidBodyState rbState;
	local Vector AngVel;
	local Vector RotDamping;
	local float RollOffset;
	local float AntiRollTorque;
	local Vector X,Y,Z;

	//Get Axes for "Calculations"
	GetAxes(Rotation, X,Y,Z);

	Super.KApplyForce(Force, Torque); // apply other forces first

	// if in rocket mode
	if(ClientDoRocket)
	{
		// add forces to any existing forces already being applied, DO NOT OVERWRITE PREVIOUS FORCE VALUES
		Force += X * RocketForce;
		//Force.z += -RocketForce * 0.30; // try and stay on the ground a bit

		//Special Rocketing Control

		//Don't steer normal
		WheelLatFrictionScale = 0;

		//Steer like AirControl
		AirTurnTorque = Default.AirTurnTorque * 2.5;
		TurnDamping = Default.TurnDamping * 2.5;
		AirPitchTorque = Default.AirPitchTorque * 2.5;
		AirPitchDamping = Default.AirPitchDamping * 2.5;
		if(bVehicleOnGround)
			Torque += vect(0,0,1) * Steering * -AirTurnTorque;

		//and Damp laterally
		Force -= Y * (Y Dot Velocity) * 0.9;
	}


	//Rotation Damping
	if(!ReallyInAir)
	{
		// Get body angular velocity in global space
		KGetRigidBodyState(rbState);
		AngVel.X = rbState.AngVel.X;
		AngVel.Y = rbState.AngVel.Y;
		AngVel.Z = rbState.AngVel.Z;

		//Local Damping - Note: currently this is global
		RotDamping.X = AngVel.X * LocalRollDamping;
		RotDamping.Y = AngVel.Y * LocalPitchDamping;
		RotDamping.Z = AngVel.Z * LocalTurnDamping;

		Torque -= RotDamping;


		//Turn damping - because TurnDamping doesn't seem to work
		Torque.Z -= AngVel.Z * BikeTurnDamping;


		//AntiRoll Stiffness
		RollOffset = Rotation.Roll / 32768.0;
		AntiRollTorque = RollOffset * AntiRollStiffness * 10;
		Torque += AntiRollTorque * X;
	}
}

simulated Event Tick(float DeltaTime)
{
	local Vector X, Y, Z;

	Super.Tick(DeltaTime);

	if(!bDoStuntInfo && bVehicleOnGround)
		LastOnGroundTime = Level.TimeSeconds;
	ReallyInAir = (Level.TimeSeconds - LastOnGroundTime) > 0.2;

	if(ClientDoRocket)
	{
		// mess with FOV
		if(Controller != None && PlayerController(Controller) != NONE)
			RocketFOV = PlayerController(Controller).DefaultFOV * 1.4;

		// On the client if we're rocketing and haven't yet spawned a rocket trail spawn one
		if(Trail == None && Level.NetMode != NM_DedicatedServer)
		{
			GetAxes(Rotation, X,Y,Z);
			Trail = spawn(TrailEmitterClass,,,Location + TrailOffset.X*X + TrailOffset.Y*Y + TrailOffset.Z*Z);
			Trail.SetBase(self);

		    AmbientSound=RocketingSound;
			IdleRPM=10000;
			EngineRPMSoundRange=40000;
		}
	}
	else if(Controller != None && PlayerController(Controller) != NONE)
		RocketFOV = PlayerController(Controller).DefaultFOV;

	if(MouseSteer && (Level.NetMode != NM_DedicatedServer))
	{
		AdjustForMouseSteering();
	}
}


simulated event UpdateVehicle(float DeltaTime)
{
	if(MouseSteer)
	{
		AdjustForMouseSteering();
	}

	Super.UpdateVehicle(DeltaTime);
}



function AdjustForMouseSteering()
{
	local vector Dir;
	local int YawDiff;
	local float NewSteering;
	local int PitchDiff;
	local float NewRise;

	if(Controller == NONE)
		return;

	// Mouse Steering
	YawDiff = (Rotation.Yaw - Controller.Rotation.Yaw) & 65535;
	if(YawDiff > 32768)
		YawDiff -= 65536;
	NewSteering = YawDiff / 12000.0;
	FClamp(NewSteering, -1.0, 1.0);

	//Reverse
	Dir = Vector(Rotation);
	if(Dir Dot Velocity < 0)
		NewSteering = -NewSteering;

	Steering = NewSteering;


	// Mouse Pitching in Air
	if(ReallyInAir)
	{
		PitchDiff = (Rotation.Pitch - Controller.Rotation.Pitch) & 65535;
		if(PitchDiff > 32768)
			PitchDiff -= 65536;
		NewRise = -PitchDiff / 12000.0;
		FClamp(NewRise, -1.0, 1.0);

		Rise = NewRise;
	}
}



function Rocket()
{
	// if rocket mode not activated yet
	if(!ClientDoRocket)
	{
		ClientDoRocket = true;

		// initiate self-destruct sequence
		if (DestructTime > 5.0)
			SetTimer(DestructTime - 5.0, false);
		else // go right into the final countdown
		{
			DestructCounter = 5; // 5 seconds left
			bCounting = true; // flag that last 5 seconds have started

			// display 5 second warning if there is a driver 
			if(PlayerController(Controller) != None) 
			{
				PlayerController(Controller).ClientPlaySound(CountDown[DestructCounter - 1],,, SLOT_Misc);
				PlayerController(Controller).ReceiveLocalizedMessage(class'CLNMessage', 40 + DestructCounter);
			}
			SetTimer(1.0, true); // run timer every second
		}
	}
}

simulated event KImpact(Actor actor, vector Pos, vector ImpactVel, vector ImpactNorm)
{
	Super.KImpact(actor, Pos, ImpactVel, ImpactNorm);
	// if in rocket mode
	if(ClientDoRocket && SVehicle(actor) != None)
	{
		BigExplode(SVehicle(actor));
	}
}

function BigExplode(optional Actor Target)
{
	local Pawn DamageDoer;	

	if(Driver != None)
		DamageDoer = Driver;
	else
		DamageDoer = Rocketeer;

	// apply damage to hit vehicle
	if(SVehicle(Target) != None)
	{
		Target.TakeDamage(10000, DamageDoer, location, vect(0,0,0), class'Clones.DamTypeRocketBike');
		// destroy rocket bike
		TakeDamage(10000, DamageDoer, location, vect(0,0,0), class'Clones.DamTypeRocketBike');
	}
	// We we've hit another actor, but NOT a player (just run players over)
	else if(Target != None && xPawn(Target) == None)
	{
        Target.TakeDamage(ContactDamage, DamageDoer, location, vect(0,0,0), class'Clones.DamTypeRocketBike');
		// destroy rocket bike
		TakeDamage(10000, DamageDoer, location, vect(0,0,0), class'Clones.DamTypeRocketBike');
	}
	// If we're just exploding, not hitting anything
	else if(Target == None)
	{
		// destroy rocket bike
		TakeDamage(10000, DamageDoer, location, vect(0,0,0), class'Clones.DamTypeRocketBike');
	}


}


function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
	Rocketeer = P;
}


// called when Timer runs out
simulated event Timer()
{
	// if haven't started the final countdown yet
	if(!bCounting)
	{
		DestructCounter = 5; // 5 seconds left
		bCounting = true; // flag that last 5 seconds have started

		// display 5 second warning if there is a driver
		if(PlayerController(Controller) != None)
		{
			PlayerController(Controller).ClientPlaySound(CountDown[DestructCounter - 1],,, SLOT_Misc);
			PlayerController(Controller).ReceiveLocalizedMessage(class'CLNMessage', 40 + DestructCounter);
		}
		SetTimer(1.0, true); // run timer every second
	}
	else // else continue the final countdown
	{
		// Note: Waiting an extra loop of the timer here to give lagged out people a better feel
		// At some point we should re-write this so the countdown is better simulated in laggy
		// environments
		if(DestructCounter == 0) // if time ran out
		{
			// BOOM
			BigExplode();
			SetTimer(0.0, false); // disable timer
		}
		else
		{
			DestructCounter--;	// update counter value

			// display message to driver (if any)
			if(PlayerController(Controller) != None)
			{
				if(DestructCounter > 0)
					PlayerController(Controller).ClientPlaySound(CountDown[DestructCounter - 1],,, SLOT_Misc);
				PlayerController(Controller).ReceiveLocalizedMessage(class'CLNMessage', 40 + DestructCounter);
			}
		}
	}
}

simulated function Destroyed()
{
	if(Trail != None)
	{
		Trail.Kill();
		Trail.AmbientSound = NONE;
	}

	super.Destroyed();
}



event Touch(actor Other)
{
    Super.Touch(Other);
    if(Other.bBlockActors && ClientDoRocket)
    {
        BigExplode(Other);
    }
}



function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	return 0;
}

defaultproperties
{
     LocalRollDamping=8.000000
     LocalPitchDamping=8.000000
     AntiRollStiffness=5.000000
     BikeTurnDamping=30.000000
     MouseSteer=True
     CountDown(0)=Sound'DB_Vehicles_A.RocketBike.RussianOne'
     CountDown(1)=Sound'DB_Vehicles_A.RocketBike.RussianTwo'
     CountDown(2)=Sound'DB_Vehicles_A.RocketBike.RussianThree'
     CountDown(3)=Sound'DB_Vehicles_A.RocketBike.RussianFour'
     CountDown(4)=Sound'DB_Vehicles_A.RocketBike.RussianFive'
     ContactDamage=200
     TrailAttachmentBone="Chassis"
     TrailOffset=(X=-83.000000,Y=5.000000,Z=35.000000)
     RocketingSound=Sound'DB_Vehicles_A.RocketBike.RocketBikeEngineLoop'
     RocketFOV=90.000000
     RocketForce=600.000000
     DestructTime=5.000000
     TrailEmitterClass=Class'Clones.RocketBikeFlameEffect'
     WheelSoftness=0.017000
     WheelPenScale=1.800000
     WheelPenOffset=-0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=2.000000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=10.000000
     WheelSuspensionOffset=-1.500000
     WheelSuspensionMaxRenderTravel=8.000000
     FTScale=0.030000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=20.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=25000.000000)))
     TorqueCurve=(Points=((OutVal=10.000000),(InVal=200.000000,OutVal=17.000000),(InVal=1500.000000,OutVal=22.000000),(InVal=4800.000000)))
     GearRatios(0)=-0.400000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.150000
     ChangeUpPoint=3000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=75.000000
     SteerSpeed=100.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.150000
     IdleRPM=500.000000
     EngineRPMSoundRange=9000.000000
     SteerBoneName="SteeringWheel"
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     OutputBrake=1.000000
     Gear=1
     RevMeterScale=4000.000000
     BrakeLightOffset(0)=(Z=35.000000)
     BrakeLightOffset(1)=(Z=35.000000)
     DaredevilThreshInAirSpin=180.000000
     DaredevilThreshInAirTime=5.000000
     DaredevilThreshInAirDistance=60.000000
     bAllowAirControl=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     MinAirControlDamping=0.200000
     bHasAltFire=False
     IdleSound=Sound'DB_Vehicles_A.RocketBike.RocketIdle'
     StartUpSound=Sound'DB_Vehicles_A.RocketBike.RocketStartB'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'CS_DeadVehicles_S.RocketBikeDead.DeadBike'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Clones.RocketBikeDeath'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(X=60.000000,Y=10.000000,Z=10.000000)
     bEjectPassengersWhenFlipped=False
     ImpactDamageMult=0.001000
     Begin Object Class=SVehicleWheel Name=SVehicleWheel6
         SteerType=VST_Steered
         BoneName="WheelFront"
         BoneSteerAxis=AXIS_Y
         WheelRadius=21.500000
         SupportBoneName="StrutFront"
         SupportBoneAxis=AXIS_X
         SupportPivotDistance=8.198524
     End Object
     Wheels(0)=SVehicleWheel'Clones.RocketBike.SVehicleWheel6'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel7
         ChassisTorque=1.000000
         bPoweredWheel=True
         BoneName="WheelBack"
         WheelRadius=21.500000
         SupportBoneName="StrutBack"
         SupportBoneAxis=AXIS_X
         SupportPivotDistance=-9.545372
     End Object
     Wheels(1)=SVehicleWheel'Clones.RocketBike.SVehicleWheel7'

     VehicleMass=2.000000
     bDrawDriverInTP=True
     bFollowLookDir=True
     bDrawMeshInFP=True
     bTeamLocked=False
     bHasHandbrake=True
     bSeparateTurretFocus=True
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     DrivePos=(X=25.000000,Z=90.000000)
     DriveRot=(Pitch=-5000)
     ExitPositions(0)=(Y=-50.000000,Z=25.000000)
     ExitPositions(1)=(Y=50.000000,Z=25.000000)
     ExitPositions(2)=(X=-120.000000,Z=25.000000)
     ExitPositions(3)=(X=120.000000,Z=25.000000)
     EntryRadius=160.000000
     TPCamDistance=375.000000
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     DriverDamageMult=0.300000
     VehiclePositionString="on a Moscowboy"
     VehicleNameString="Moscowboy"
     RanOverDamageType=Class'Clones.DamTypeRocketBikeRoadkill'
     CrushedDamageType=Class'Clones.DamTypeRocketBikePancake'
     StolenAnnouncement=
     StolenSound=None
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn06'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Dixie_Horn'
     GroundSpeed=940.000000
     HealthMax=200.000000
     Health=200
     bReplicateAnimations=True
     Mesh=SkeletalMesh'CS_CloneVehicles_K.RocketBike'
     CollisionRadius=110.000000
     CollisionHeight=40.000000
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull2
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(Z=-0.900000)
         KLinearDamping=0.050000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=1.200000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         StayUprightStiffness=0.000000
         KFriction=0.100000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'Clones.RocketBike.KarmaParamsRBFull2'

}
