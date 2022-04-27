//-----------------------------------------------------------
//  LoungeTank - Created on 1/20/04  Demiurge Studios
//-----------------------------------------------------------
class LoungeTank extends ONSHoverTank;

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

function AltFire(optional float F)
{
    // No Zooming
    Super(ONSTreadCraft).AltFire(F);
}

// Overridden because ONSVehicles ClientVehicleCeaseFire is all fucked up
function ClientVehicleCeaseFire(bool bWasAltFire)
{
    Super(SVehicle).ClientVehicleCeaseFire(bWasAltFire);
}



function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	return Super.BotDesireability(S, TeamIndex, Objective);
}

defaultproperties
{
     TreadVelocityScale=-450.000000
     ThrusterOffsets(0)=(X=75.000000,Y=110.000000,Z=20.000000)
     ThrusterOffsets(1)=(X=25.000000,Y=110.000000,Z=20.000000)
     ThrusterOffsets(2)=(X=-25.000000,Y=110.000000,Z=20.000000)
     ThrusterOffsets(3)=(X=-75.000000,Y=110.000000,Z=20.000000)
     ThrusterOffsets(4)=(X=75.000000,Y=-110.000000,Z=20.000000)
     ThrusterOffsets(5)=(X=25.000000,Y=-110.000000,Z=20.000000)
     ThrusterOffsets(6)=(X=-25.000000,Y=-110.000000,Z=20.000000)
     ThrusterOffsets(7)=(X=-75.000000,Y=-110.000000,Z=20.000000)
     HoverSoftness=0.100000
     HoverCheckDist=80.000000
     MaxThrust=85.000000
     PitchTorqueFactor=-60.000000
     BankTorqueFactor=-90.000000
     DriverWeapons(0)=(WeaponClass=Class'Clones.LoungeTankCannon',WeaponBone="TankGun")
     bHasAltFire=True
     RedSkin=None
     BlueSkin=None
     DestroyedVehicleMesh=StaticMesh'CS_DeadVehicles_S.TankDead.DeadChassis'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Clones.LoungeTankDeath'
     DisintegrationHealth=-150.000000
     DestructionLinearMomentum=(Min=20000.000000,Max=30000.000000)
     DestructionAngularMomentum=(Min=10.000000,Max=15.000000)
     bEnableProximityViewShake=False
     bEjectPassengersWhenFlipped=False
     HeadlightCoronaOffset(0)=(X=128.000000,Y=-88.000000,Z=83.000000)
     HeadlightCoronaOffset(1)=(X=128.000000,Y=88.000000,Z=83.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=65.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=128.000000,Z=83.000000)
     HeadlightProjectorRotation=(Pitch=1000)
     HeadlightProjectorScale=0.700000
     bTeamLocked=False
     ExitPositions(0)=(Z=150.000000)
     ExitPositions(1)=(Z=150.000000)
     ExitPositions(2)=(X=-200.000000,Z=150.000000)
     ExitPositions(3)=(X=200.000000,Z=150.000000)
     EntryPosition=(Z=60.000000)
     EntryRadius=300.000000
     TPCamWorldOffset=(Z=320.000000)
     TPCamDistRange=(Max=1200.000000)
     VehiclePositionString="in a Lounge Tank"
     VehicleNameString="Lounge Tank"
     RanOverDamageType=Class'Clones.DamTypeLoungeTankRoadkill'
     CrushedDamageType=Class'Clones.DamTypeLoungeTankPancake'
     StolenAnnouncement=
     StolenSound=None
     ObjectiveGetOutDist=2000.000000
     FlagBone="TankGun"
     bLightChanged=True
     Mesh=SkeletalMesh'CS_CloneVehicles_K.BigTank'
     Skins(0)=Texture'CS_Vehicles_T.Tank.TankBody'
     Skins(1)=Texture'CS_Vehicles_T.Tank.tankTreads'
     Skins(2)=Texture'CS_Vehicles_T.Tank.tankTreads'
     Skins(3)=Texture'CS_Vehicles_T.Tank.TankExtras'
     CollisionRadius=200.000000
     CollisionHeight=100.000000
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull0
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
     End Object
     KParams=KarmaParamsRBFull'Clones.LoungeTank.KarmaParamsRBFull0'

}
