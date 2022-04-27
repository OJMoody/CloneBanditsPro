//-----------------------------------------------------------
// HotRod - Created on 1/16/04  Demiurge Studios
//-----------------------------------------------------------
class HotRod extends ONSWheeledCraft;

#exec OBJ LOAD FILE=../Textures/AR_ClonesHud_T.utx

// Nitrous
var bool bClientDoNitrous;	// Set to true while pending and during a nitrous boost
var float DoNitrousTime;	// How long to boost for
var float NitrousForce;		// How much force to apply per-tick during nitrous
var int NitrousRemaining;	// How many nitrous shots left in this car.
var () sound NitrousSound;	// Sound when nitrous is fired

// Fire
var () class<Emitter>	TailPipeFireClass;
var Emitter				TailPipeFire[2];
var () Vector			TailPipeFireOffset[2];
var () Rotator			TailPipeFireRotOffset[2];
var float				PotentialFireTime;
var bool				bPipeFlameOn;
var () Sound			TailPipeFireSound;

var float TimeInAir;
var const float TimeInAirForHorn;

var float NitrousRechargeTime;
var float NitrousRechargeCounter;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		bClientDoNitrous, NitrousRemaining;
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
			//Log("HotRod.CheckReset: Info. Manning a weapon. Extending time till self-destruct");
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
				//Log("HotRod.CheckReset: Info. Friendly non-vehicle pawn close enough. Extending time till self-destruct");
				//Log(P.GetHumanReadableName());

				ResetTime = Level.TimeSeconds + 15;
				return;
			}
       	}

	//Log("HotRod.CheckReset: Info. No one around. Vehicle Self-destruct");

	// destroy vehicle (assuming this calls VehicleDestroyed from parent factory)
    Destroy();
	// need to worry about destroying any damage effects on the vehicle when it dies?
}

function KDriverEnter(Pawn P)
{
    Super.KDriverEnter(P);

	//Don't allow bots to use air control
	if( Bot(P.Controller) != NONE )
		bAllowAirControl=false;
	else
		bAllowAirControl=true;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Dont bother making emitters etc. on dedicated server
	if(Level.NetMode != NM_DedicatedServer)
	{
		// Create tail pipe fire emitters.
		TailPipeFire[0] = spawn(TailPipeFireClass, self,, Location + (TailPipeFireOffset[0] >> Rotation) );
		TailPipeFire[0].SetBase(self);
		TailPipeFire[0].SetRelativeRotation(TailPipeFireRotOffset[0]);

		TailPipeFire[1] = spawn(TailPipeFireClass, self,, Location + (TailPipeFireOffset[1] >> Rotation) );
		TailPipeFire[1].SetBase(self);
		TailPipeFire[1].SetRelativeRotation(TailPipeFireRotOffset[1]);

		EnablePipeFire(false);
	}
}

// undo ONSVehicle.PostNetBeginPlay's assignment of the
// active weapon's pitch limitations to the vehicle
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Role == ROLE_Authority)
    {
		// reset to defaults, which overrides
		// weapon limits set in ONSVehicle.PostNetBeginPlay
		PitchUpLimit = default.PitchUpLimit;
		PitchDownLimit = default.PitchDownLimit;
	}
}


function VehicleFire(bool bWasAltFire)
{
	if(bWasAltFire)
	{
		//ServerPlayHorn(1);
		Nitrous();
	}
	else
		Super.VehicleFire(bWasAltFire);
}

simulated event KApplyForce(out vector Force, out vector Torque)
{
	local int i;
	local float avgLoad;

	Super.KApplyForce(Force, Torque); // apply other forces first

	// If the car is nitrousing and vehicle is on the ground
	if(bClientDoNitrous && bVehicleOnGround)
	{
		// apply the nitrous force as a function of how much grip
		// each wheel has
		avgLoad = 0;
		for(i=0; i<Wheels.Length; i++)
		{
			avgLoad += Wheels[i].TireLoad;
		}
		avgLoad = avgLoad / Wheels.Length;
		// cap avgLoad with experimentally determined value
		avgLoad = FMin(avgLoad, 20.0);
		// normalize avgLoad factor with respect to cap
		// so it can only reduce the nitrous force, never increase it beyond 100%
		avgLoad = avgLoad / 20.0;

		// add forces to any existing forces already being applied, DO NOT OVERWRITE PREVIOUS FORCE VALUES
		Force += vector(Rotation); // get direction of hot rod
		Force += Normal(Force) * NitrousForce * avgLoad; // apply force in that direction
	}

}



function Nitrous()
{
	// If we have any left and we're not currently using it
	if(NitrousRemaining > 0 && !bClientDoNitrous)
	{
    	NitrousRechargeCounter=0;
	    PlaySound(NitrousSound, SLOT_Misc, 1);
		bClientDoNitrous = true;
		NitrousRemaining--;
	}
}



simulated event Timer()
{
//	Log("Hot Rod Nitro Disabled",'HotRod');

	// when nirtous exceeds time limit, turn it off
	bClientDoNitrous = false;
	EnablePipeFire(bClientDoNitrous);
}



simulated event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// If bClientDoNitrous and pipe fire don't agree
	if(bClientDoNitrous != bPipeFlameOn)
	{
//		Log("Nitrous state change!");

		// it means we need to change the state of the car (bPipeFlameOn)
		// to match the desired state (bClientDoNitrous)
		EnablePipeFire(bClientDoNitrous); // show/hide flames

		// if we just enabled pipe flames, set the timer
		// to turn them off after nitrous time has expired
		if(bClientDoNitrous)
		{
			SetTimer(DoNitrousTime, false);
//			Log("Hot Rod Nitro Timer set");
		}
	}

	if(Level.NetMode != NM_DedicatedServer)
	{
		if(!bVehicleOnGround)
		{
			TimeInAir+=DeltaTime;
		}
		else
		{
			TimeInAir = 0.0;
		}

		/*
		Horn deamed stupid and problem-causing so we removed it.
		if(TimeInAir >= TimeInAirForHorn)
		{
			TimeInAir = 0;
			ServerPlayHorn(1);
		}
		*/
	}

	if(Role == ROLE_Authority)
	{
	   // Recharge cars with nitrous over time
	   NitrousRechargeCounter+=DeltaTime;
	   if(NitrousRechargeCounter > NitrousRechargeTime)
	   {
	        if(NitrousRemaining < 1)
	           NitrousRemaining++;
	        NitrousRechargeCounter = 0;
	   }
	}
}



// rewritten to skip ONSWheeledCraft version
simulated function DrawHUD(Canvas C)
{
  	// skip ONSWheeledCraft::DrawHUD
	Super(ONSVehicle).DrawHUD(C);
}



// overwrite ONSVehicle.LimitPitch, as it calls
// LimitPitch of the active weapon. We don't want that
function int LimitPitch(int pitch)
{
	// just call pawn version
	return Super(Pawn).LimitPitch(pitch);
}



simulated event Destroyed()
{
	if(Level.NetMode != NM_DedicatedServer)
	{
		TailPipeFire[0].Destroy();
		TailPipeFire[1].Destroy();
	}

	Super.Destroyed();
}

// Enable/disable pipe fire effects
// via passed bool Enable
simulated function EnablePipeFire(bool bEnable)
{
	local int i,j;

	// enable/disable emitters
	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i = 0; i < 2; i++)
		{
			for(j = 0; j < TailPipeFire[i].Emitters.Length; j++)
			{
				TailPipeFire[i].Emitters[j].Disabled = !bEnable;
			}
		}
	}

	bPipeFlameOn = bEnable; // update state of pipe flames
}

function ServerAwardNitrous(int Count)
{
    NitrousRemaining+=Count;
}

simulated function int DaredevilToNitrousAward(int InDaredevilPoints)
{
	return max(2,InDaredevilPoints/10);
}



simulated event OnDaredevil()
{
	local PlayerController PC;
	local TeamPlayerReplicationInfo PRI;

	PC = PlayerController(Controller);
	if (PC != None)
	{
        if (Role == ROLE_Authority)
        {
			PC.ReceiveLocalizedMessage(DaredevilMessageClass, DaredevilToNitrousAward(DaredevilPoints), None, None, self);

    		PRI = TeamPlayerReplicationInfo(PC.PlayerReplicationInfo);
    		if(PRI != None)
    		{
    			PRI.DaredevilPoints += DaredevilPoints;
    		}
			ServerAwardNitrous(DaredevilToNitrousAward(DaredevilPoints));
    	}
	}
}



function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local float Desireability;

	Desireability = Super.BotDesireability(S, TeamIndex, Objective);
	if( CloneJarBase(Objective) != NONE )
		Desireability *= 3;

	return Desireability;
}

defaultproperties
{
     DoNitrousTime=2.000000
     NitrousForce=250.000000
     NitrousRemaining=2
     NitrousSound=Sound'WeaponSounds.Misc.redeemer_shoot'
     TailPipeFireClass=Class'Clones.PipeFire'
     TailPipeFireOffset(0)=(X=-140.000000,Y=20.000000,Z=-16.000000)
     TailPipeFireOffset(1)=(X=-140.000000,Y=-20.000000,Z=-16.000000)
     TailPipeFireRotOffset(0)=(Yaw=32768)
     TailPipeFireRotOffset(1)=(Yaw=32768)
     TimeInAirForHorn=4.000000
     NitrousRechargeTime=15.000000
     WheelSoftness=0.030000
     WheelPenScale=1.800000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=20.000000),(InVal=80.000000,OutVal=0.350000),(InVal=1000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=3.100000
     WheelHandbrakeSlip=0.350000
     WheelHandbrakeFriction=1.000000
     WheelSuspensionTravel=15.000000
     WheelSuspensionOffset=-4.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.200000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=30.000000),(InVal=1800.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=10.000000),(InVal=200.000000,OutVal=17.000000),(InVal=1500.000000,OutVal=22.000000),(InVal=4000.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.350000
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
     SteerSpeed=180.000000
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
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-134.000000,Y=39.000000,Z=6.000000)
     BrakeLightOffset(1)=(X=-134.000000,Y=-39.000000,Z=6.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=300.000000
     DaredevilThreshInAirRoll=150.000000
     DaredevilThreshInAirTime=3.000000
     DaredevilThreshInAirDistance=100.000000
     DaredevilMessageClass=Class'Clones.HotRodDaredevilMessage'
     bDoStuntInfo=True
     bAllowAirControl=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     MinAirControlDamping=0.200000
     DriverWeapons(0)=(WeaponClass=Class'Clones.GatlingGun',WeaponBone="gunLmount")
     PassengerWeapons(0)=(WeaponPawnClass=Class'Clones.HotRodPassengerPawn',WeaponBone="gunRTmount")
     bHasAltFire=False
     IdleSound=Sound'DB_Vehicles_A.HotRod.CudaLoudC'
     StartUpSound=Sound'DB_Vehicles_A.HotRod.CudaStartB'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'TL_DeadVehicles_S.CudaExploded.CudaDead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Clones.HotRodDeath'
     DisintegrationHealth=-75.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(X=60.000000,Y=10.000000,Z=-20.000000)
     bEjectPassengersWhenFlipped=False
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=135.000000,Y=44.000000)
     HeadlightCoronaOffset(1)=(X=135.000000,Y=-44.000000)
     HeadlightCoronaOffset(2)=(X=10.000000,Y=33.500000,Z=40.000000)
     HeadlightCoronaOffset(3)=(X=12.000000,Y=25.000000,Z=42.000000)
     HeadlightCoronaOffset(4)=(X=11.000000,Y=14.500000,Z=40.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=65.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=139.000000,Z=6.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.300000
     CrosshairTexture=Texture'Crosshairs.HUD.Crosshair_Triad2'
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=20.000000)
         WheelRadius=24.200001
     End Object
     Wheels(0)=SVehicleWheel'Clones.HotRod.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-20.000000)
         WheelRadius=24.200001
     End Object
     Wheels(1)=SVehicleWheel'Clones.HotRod.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=20.000000)
         WheelRadius=20.000000
     End Object
     Wheels(2)=SVehicleWheel'Clones.HotRod.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-20.000000)
         WheelRadius=20.000000
     End Object
     Wheels(3)=SVehicleWheel'Clones.HotRod.LFWheel'

     VehicleMass=3.500000
     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bTeamLocked=False
     bHasHandbrake=True
     bSeparateTurretFocus=True
     DrivePos=(Y=-30.000000,Z=35.000000)
     ExitPositions(0)=(Y=-165.000000,Z=45.000000)
     ExitPositions(1)=(Y=165.000000,Z=45.000000)
     ExitPositions(2)=(X=-200.000000,Z=45.000000)
     ExitPositions(3)=(X=200.000000,Z=45.000000)
     ExitPositions(4)=(Z=170.000000)
     ExitPositions(5)=(Z=-60.000000)
     EntryPosition=(Y=-40.000000,Z=-30.000000)
     EntryRadius=180.000000
     FPCamPos=(X=30.000000,Z=60.000000)
     TPCamDistance=300.000000
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=70.000000)
     DriverDamageMult=0.200000
     VehiclePositionString="in a Barracuda"
     VehicleNameString="Barracuda"
     RanOverDamageType=Class'Clones.DamTypeHotRodRoadkill'
     CrushedDamageType=Class'Clones.DamTypeHotRodPancake'
     StolenAnnouncement=
     StolenSound=None
     ObjectiveGetOutDist=2000.000000
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn06'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Dixie_Horn'
     GroundSpeed=940.000000
     HealthMax=350.000000
     Health=350
     Mesh=SkeletalMesh'TL_Vehicles_K.HotRod'
     CollisionRadius=150.000000
     CollisionHeight=60.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=0.250000,Z=-1.000000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'Clones.HotRod.KParams0'

}
