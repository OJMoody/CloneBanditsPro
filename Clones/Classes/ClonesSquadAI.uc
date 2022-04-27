class ClonesSquadAI extends SquadAI;

var bool bDefendingSquad;
var float LastFailedNodeTeleportTime;
var float MaxObjectiveGetOutDist; //cached highest ObjectiveGetOutDist of all the vehicles available on this level
var array<CloneJarBase>	EnemyJarPoints;
var array<CloneJarBase>	OwnJarPoints;
var array<ClonePump>	ClonePumps;



// unmodified from ONSSquadAI
function Reset()
{
	Super.Reset();
	bDefendingSquad = false;
}



// modified from ONSSquadAI
function name GetOrders()
{
	local name NewOrders;

	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
		NewOrders = 'Freelance';
	else if ( bDefendingSquad || bFreelanceDefend || (SquadObjective != None) )
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
		CurrentOrders = NewOrders;
	return CurrentOrders;
}



function byte PriorityObjective(Bot B)
{
	local ClonePump Pump;

	//log("ClonesSquadAI::PriorityObjective");

	if (GetOrders() == 'Defend')
	{
		// Priority if objective is pump and control all pumps and the one you defending is under attack
		Pump = ClonePump(SquadObjective);
		if ( Pump != None && Pump.bUnderAttack && ClonesTeamAI(Team.AI).ControlAllPumps(Team.TeamIndex) )
			return 1;
	}
	else if (CurrentOrders == 'Attack')
	{
		// Priority if objective is pump and the other team control controls all the pumps
		Pump = ClonePump(SquadObjective);
		if ( Pump != None && ClonesTeamAI(Team.AI).ControlAllPumps(Abs(1 - Team.TeamIndex)) ) //A little hackery pulled from ONSSquadAI
			return 1;
	}
	return 0;
}



function SetDefenseScriptFor(Bot B)
{
	local ClonePump Pump;

	//log("ClonesSquadAI::SetDefenseScriptFor");

	//don't look for defense scripts when heading for neutral pump
	Pump = ClonePump(SquadObjective);
	if (Pump == None || (Pump.DefenderTeamIndex == Team.TeamIndex && (Pump.PumpStage == 2 || Pump.PumpStage == 0)) )
	{
		Super.SetDefenseScriptFor(B);
		return;
	}

	if (B.GoalScript != None)
		B.FreeScript();
}



// unmodified from ONSSquadAI
function float MaxVehicleDist(Pawn P)
{
	if ( GetOrders() != 'Attack' || SquadObjective == None )
		return 3000;
	return FMin(3000, VSize(P.Location - SquadObjective.Location));
}



/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(Bot B, Actor Obj)
{
	local vehicle OldVehicle;
	local float dist;

	//log("ClonesSquadAI::FindPathToObjective");

	//log("10");
	if ( B.Pawn.bStationary )
		return false;

	if ( Obj == None )
	{
		Obj = SquadObjective;
		if ( Obj == None )
		{
			B.GoalString = "No SquadObjective";
			return false;
		}
	}

	// Jars - get out of vehicle if don't have flag
	if ( CloneJarBase(Obj) != None && B.PlayerReplicationInfo.HasFlag == NONE )
	{
		//log("15");
		//B.MoveTarget = None; //maybe I need this... I don't know
		if ( (Vehicle(B.Pawn) != None) 
			&& (B.Pawn.Location.Z - Obj.Location.Z < 1500)
			&& (VSize(B.Pawn.Location - Obj.Location) < Vehicle(B.Pawn).ObjectiveGetOutDist)
			&& B.LineOfSightTo(Obj) ) //not sure I need this...
		{
			//log("16");
			OldVehicle = Vehicle(B.Pawn);
			Vehicle(B.Pawn).KDriverLeave(false);
			if ( (Vehicle(B.Pawn) == None) && (B.Pawn.Physics == PHYS_Falling) && B.DoWaitForLanding() )
			{
				B.Pawn.Velocity.Z = 0;
				return true;
			}
		}
	}
	// If we've got a jar heading back to base
	if ( CloneJarBase(Obj) != None && B.PlayerReplicationInfo.HasFlag != None )
	{
		// if there's a vehicle path we should use to get back to base
		if ((Vehicle(B.Pawn) != None) && (CloneJarBase(Obj).VehiclePath != None))
		{
			// if we're not already at the dest of the vehicle path and we're not in the final stretch
			dist = VSize(CloneJarBase(Obj).VehiclePath.Location - B.Pawn.Location);
			if(!(B.Pawn.ReachedDestination(CloneJarBase(Obj).VehiclePath) || dist < 1500) 
				&& !ClonesBot(B).bClonesFinalStretch)
			{
				// Go to the vehicle path instead
				Obj = CloneJarBase(Obj).VehiclePath;
			}
			// if we're already at the dest of the vehicle path, get out
			else
			{
				// if we're there, get out of the vehicle, go to base
				// Evil hack, there's probably a more correct way to do this
				Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 15;
				Vehicle(B.Pawn).KDriverLeave(false);
				ClonesBot(B).bClonesFinalStretch = true;
			}
		}
	}

	//log("20");
	// Pumps
	if ( ClonePump(Obj) != None && (ClonePump(Obj).PumpStage != 0 || ClonePump(Obj).DefenderTeamIndex == Team.TeamIndex) )
	{
		//log("21");
		B.MoveTarget = None;
		if ( (Vehicle(B.Pawn) != None) && (B.Pawn.Location.Z - Obj.Location.Z < 1500)
		     && (VSize(B.Pawn.Location - Obj.Location) < Vehicle(B.Pawn).ObjectiveGetOutDist) && B.LineOfSightTo(Obj) )
		{
			//log("22");
			OldVehicle = Vehicle(B.Pawn);
			Vehicle(B.Pawn).KDriverLeave(false);
			if ( (Vehicle(B.Pawn) == None) && (B.Pawn.Physics == PHYS_Falling) && B.DoWaitForLanding() )
			{
				B.Pawn.Velocity.Z = 0;
				return true;
			}
		}

		if ( B.ActorReachable(Obj) )
		{
			//log("23");
			if ( (Vehicle(B.Pawn) != None) && (B.Pawn.Location.Z - Obj.Location.Z < 500) )
				Vehicle(B.Pawn).KDriverLeave(false);
			if ( B.Pawn.ReachedDestination(Obj) )
			{
//				log(B.GetHumanReadableName()$" Force touch for reached objective");
				Obj.Touch(B.Pawn);
				return false;
			}
			if ( OldVehicle != None )
				OldVehicle.TeamUseTime = Level.TimeSeconds + 6;
			B.RouteGoal = Obj;
			B.RouteCache[0] = None;
			B.GoalString = "almost at "$Obj;
			B.MoveTarget = Obj;
			B.SetAttractionState();
			return true;
		}
		if ( OldVehicle != None )
			OldVehicle.UsedBy(B.Pawn);
	}
	//log("30");

	if ( Super.FindPathToObjective(B,Obj) )
		return true;

	//log("35");
	if ( Vehicle(B.Pawn) != None && !Vehicle(B.Pawn).bKeyVehicle && (B.Enemy == None || !B.EnemyVisible()) )
	{
		//log("36");
		if (B.Pawn.HasWeapon() && Vehicle(B.Pawn).MaxDesireability > 0.5)
			Vehicle(B.Pawn).bDefensive = true; //have bots use it as a turret instead
		else
			Vehicle(B.Pawn).VehicleLostTime = Level.TimeSeconds + 20;
		//log(B.PlayerReplicationInfo.PlayerName$" Abandoning "$Vehicle(B.Pawn)$" because can't reach "$Obj);
		Vehicle(B.Pawn).KDriverLeave(false);
	}
	//log("40");
	return false;
}



function float GetMaxObjectiveGetOutDist()
{
	local SVehicleFactory F;

	if (MaxObjectiveGetOutDist == 0.0)
		foreach DynamicActors(class'SVehicleFactory', F)
			if (F.VehicleClass != None)
				MaxObjectiveGetOutDist = FMax(MaxObjectiveGetOutDist, F.VehicleClass.default.ObjectiveGetOutDist);

	return MaxObjectiveGetOutDist;
}



function bool CheckVehicle(Bot B)
{
	if ( B == NONE || B.Pawn == NONE )
		return false;

	// Don't get in a vehicle if we're in the final stretch
	if(ClonesBot(B).bClonesFinalStretch)
		return false;

	// if we are picking up a loose jar
	if(	B.GoalString == "Pickup dropped jar")
	{
		if(Vehicle(B.Pawn) != None)
	     	Vehicle(B.Pawn).KDriverLeave(false);
	    return false;
	}

	if ( Vehicle(B.Pawn) != None 
		&& GetOrders() == 'Defend' 
		&& !Vehicle(B.Pawn).bDefensive 
		&& SquadObjective != None
	    && VSize(B.Pawn.Location - SquadObjective.Location) < 2000 
		&& !Vehicle(B.Pawn).bKeyVehicle 
		&& (B.Enemy == None || !B.EnemyVisible()) )
	{
	     	Vehicle(B.Pawn).KDriverLeave(false);
	     	return false;
	}


	// Jars
	if (Vehicle(B.Pawn) == None && CloneJarBase(SquadObjective) != None) //TODO_CL (maybe) This isn't right... not in vehcile...
	{
		if ( B.PlayerReplicationInfo.HasFlag == NONE
			&& (B.Enemy == None || (!B.EnemyVisible() && Level.TimeSeconds - B.LastSeenTime > 3))
			&& VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist() )
		{
		     	// Vehicle(B.Pawn).KDriverLeave(false); //TODO_CL
				return false;
		}
	}
	// Pumps
	else if (Vehicle(B.Pawn) == None && ClonePump(SquadObjective) != None)
	{
		if (ClonePump(SquadObjective).PumpStage == 0)
		{
			if ( GetOrders() == 'Defend' && (B.Enemy == None || (!B.EnemyVisible() && Level.TimeSeconds - B.LastSeenTime > 3))
			     && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist()
			     && ClonePump(SquadObjective).Health < ClonePump(SquadObjective).DamageCapacity
			     && ((B.Pawn.Weapon != None && B.Pawn.Weapon.CanHeal(SquadObjective)) || (B.Pawn.PendingWeapon != None && B.Pawn.PendingWeapon.CanHeal(SquadObjective))) )
				return false;
		}
		if (ClonePump(SquadObjective).PumpStage == 2)
		{
			if ( (B.Enemy == None || !B.EnemyVisible()) && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist() )
				return false;
		}
		if ((ClonePump(SquadObjective).PumpStage == 4 || ClonePump(SquadObjective).PumpStage == 1) && VSize(B.Pawn.Location - SquadObjective.Location) < GetMaxObjectiveGetOutDist())
			return false;
	}

	if (Super.CheckVehicle(B))
		return true;

	//// CTL - shouldn't this maybe be first??? because right here it does nothing...
	//if ( Vehicle(B.Pawn) != None
	//	|| (B.Enemy != None && B.EnemyVisible())
	//	|| ClonePump(SquadObjective) == None
	//	|| ClonesPlayerReplicationInfo(B.PlayerReplicationInfo) == None
	//	|| B.Skill + B.Tactics < 2 + FRand() )
	//	return false;

	return false;
}



//return a value indicating how useful this vehicle is to the bot
function float VehicleDesireability(Vehicle V, Bot B)
{
	local float Rating;

	//log("ClonesSquadAI::VehicleDesireability");

	if (CurrentOrders == 'Defend')
	{
		if ((SquadObjective == None || VSize(SquadObjective.Location - B.Pawn.Location) < 2000) && Super.VehicleDesireability(V, B) <= 0)
			return 0;
		if (V.Health < V.HealthMax * 0.125 && B.Enemy != None && B.EnemyVisible())
			return 0;
		Rating = V.BotDesireability(self, Team.TeamIndex, SquadObjective);
		if (Rating <= 0)
			return 0;

		if (V.bDefensive)
		{
			if (ClonePump(SquadObjective) != None)
			{
				//turret can't hit priority enemy
				if ( V.bStationary && B.Enemy != None && ClonePump(SquadObjective).LastDamagedBy == B.Enemy.PlayerReplicationInfo
				     && !FastTrace(B.Enemy.Location + B.Enemy.CollisionHeight * vect(0,0,1), V.Location) )
					return 0;
				if (ClonePump(SquadObjective).ClosestTo(V) != SquadObjective)
					return 0;
			}
			if (ONSStationaryWeaponPawn(V) != None && !ONSStationaryWeaponPawn(V).bPowered)
				return 0;
		}

		return Rating;
	}

	return Super.VehicleDesireability(V, B);
}



// just call super
function bool CheckSpecialVehicleObjectives(Bot B)
{
	return Super.CheckSpecialVehicleObjectives(B);
}



/* OrdersForJarCarrier()
Tell bot what to do if he's carrying a jar
*/
function bool OrdersForJarCarrier(Bot B)
{
	if ( CheckVehicle(B) )
	{
		B.GoalString = "Go to vehicle";
		B.SetAttractionState();
		return true;
	}

	//// pickup dropped flag if see it nearby
	//// FIXME - don't use pure distance - also check distance returned from pathfinding
	//if ( !FriendlyFlag.bHome )
	//{
	//	// if one-on-one ctf, then get flag back
	//	if ( Team.Size == 1 )
	//	{
	//		// make sure healthed/armored/ammoed up
	//		if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
	//		{
	//			B.SetAttractionState();
	//			return true;
	//		}

	//		if ( FriendlyFlag.Holder == None )
	//		{
	//			if ( GoPickupFlag(B) )
	//				return true;
	//			return false;
	//		}
	//		else
	//		{
	//			if ( (B.Enemy != None) && (B.Enemy.PlayerReplicationInfo != None) && (B.Enemy.PlayerReplicationInfo.HasFlag != FriendlyFlag) )
	//				FindNewEnemyFor(B,(B.Enemy != None) && B.LineOfSightTo(B.Enemy));
	//			if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
	//				LastSeeFlagCarrier = Level.TimeSeconds;
	//			B.GoalString = "Attack enemy flag carrier";
	//			if ( B.IsSniping() )
	//				return false;
	//			B.bPursuingFlag = true;
	//			return ( TryToIntercept(B,FriendlyFlag.Holder,EnemyFlag.Homebase) );
	//		}
	//	}
	//	// otherwise, only get if convenient
	//	if ( (FriendlyFlag.Holder == None) && B.LineOfSightTo(FriendlyFlag.Position())
	//		&& (VSize(B.Pawn.Location - FriendlyFlag.Location) < 1500.f)
	//		&& GoPickupFlag(B) )
	//		return true;

	//	// otherwise, go hide
	//	if ( HidePath != None )
	//	{
	//		if ( B.Pawn.ReachedDestination(HidePath) )
	//		{
	//			if ( ((B.Enemy == None) || (Level.TimeSeconds - B.LastSeenTime > 7)) && (FRand() < 0.7) )
	//			{
	//				HidePath = None;
	//				if ( B.Enemy == None )
	//					B.WanderOrCamp(true);
	//				else
	//					B.DoStakeOut();
	//				return true;
	//			}
	//		}
	//		else if ( B.SetRouteToGoal(HidePath) )
	//			return true;
	//	}
	//}
	//HidePath = None;

	//// super pickups if nearby
	//// see if should get superweapon/ pickup
	//if ( (B.Skill > 2) && (Vehicle(B.Pawn) == None) )
	//{
	//	if ( (!FriendlyFlag.bHome || (VSize(FriendlyFlag.HomeBase.Location - B.Pawn.Location) > 2000))
	//			&& Team.AI.SuperPickupAvailable(B)
	//			&& (B.Pawn.Anchor != None) && B.Pawn.ReachedDestination(B.Pawn.Anchor)
	//			&& B.FindSuperPickup(800) )
	//	{
	//		B.GoalString = "Get super pickup";
	//		B.SetAttractionState();
	//		return true;
	//	}
	//}

	if ( (B.Enemy != None) && (B.Pawn.Health < 60 ))
		B.SendMessage(None, 'OTHER', B.GetMessageIndex('NEEDBACKUP'), 25, 'TEAM');
	B.GoalString = "Return to Base with enemy CloneJar!";
	if ( !FindPathToObjective(B,OwnJarPoints[0]) ) //TODO_CL deal with this better...
	{
		B.GoalString = "No path to home base for jar carrier";
		// FIXME - suicide after a while
		return false;
	}
	if ( B.MoveTarget == OwnJarPoints[0] )
	{
		B.GoalString = "Near my Base with enemy jar!";
		if ( VSize(B.Pawn.Location - OwnJarPoints[0].location) < OwnJarPoints[0].CollisionRadius )
			OwnJarPoints[0].Touch(B.Pawn);
	}
	return true;
}



/* GoPickupJar()
have bot go pickup dropped jar
*/
function bool GoPickupJar(Bot B, CloneJar Jar)
{
	if(Vehicle(B.Pawn) != None)
	    Vehicle(B.Pawn).KDriverLeave(false);

	if ( FindPathToObjective(B,Jar) )
	{
		// Send chat message about intent 
		//if ( Level.TimeSeconds - CTFTeamAI(Team.AI).LastGotFlag > 6 )
		//{
		//	CTFTeamAI(Team.AI).LastGotFlag = Level.TimeSeconds;
		//	B.SendMessage(None, 'OTHER', B.GetMessageIndex('GOTOURFLAG'), 20, 'TEAM');
		//}
		B.GoalString = "Pickup dropped jar";
		return true;
	}
	return false;
}


function bool CheckSquadObjectives(Bot B)
{
	local bool bResult;
	local int i;
	local CloneJar cj;

	//log("ClonesSquadAI::CheckSquadObjectives");

	if ( B.PlayerReplicationInfo.HasFlag != NONE  )
		return OrdersForJarCarrier(B);

	for(i = 0; i < ClonesGame(Level.Game).CloneJarArray.length; i++)
	{
		cj = ClonesGame(Level.Game).CloneJarArray[i];
		if ( cj.IsInState('Dropped')
			&& B.LineOfSightTo(cj.Position())
			&& (VSize(B.Pawn.Location - cj.Location) < 4000.f)
			&& GoPickupJar(B, cj) )
			return true;
	}

	bResult = Super.CheckSquadObjectives(B);

	// Get a jar
	if (!bResult && CloneJarBase(SquadObjective) != None && B.PlayerReplicationInfo.HasFlag == NONE)
	{
		return FindPathToObjective(B, SquadObjective);
	}

	if (!bResult && CurrentOrders == 'Freelance' && B.Enemy == None && ClonePump(SquadObjective) != None)
	{
		if (ClonePump(SquadObjective).DefenderTeamIndex == Team.TeamIndex)
		{
			B.GoalString = "Disable Objective "$SquadObjective;
			return SquadObjective.TellBotHowToDisable(B);
		}
		else if (!B.LineOfSightTo(SquadObjective))
		{
			B.GoalString = "Harass enemy at "$SquadObjective;
			return FindPathToObjective(B, SquadObjective);
		}
	}

	return bResult;
}



function bool AssignSquadResponsibility(Bot B)
{
	//log("ClonesSquadAI::AssignSquadResponsibility");

	return Super.AssignSquadResponsibility(B);
}



function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	local float PlayerTreatMod;
	//log("ClonesSquadAI::ModifyThreat");

	 if ( NewThreat.IsHumanControlled() )
		PlayerTreatMod = 0.5;
	else
		PlayerTreatMod = 0;

	if ( (NewThreat.PlayerReplicationInfo != None)
		&& (NewThreat.PlayerReplicationInfo.HasFlag != None)
		&& bThreatVisible )
	{
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 1500) || (B.Pawn.Weapon != None && B.Pawn.Weapon.bSniping)
			|| (VSize(NewThreat.Location - EnemyJarPoints[0].Location) < 2000) ) //TODO_CL one point hack
			return current + 6 + PlayerTreatMod;
		else
			return current + 1.5 + PlayerTreatMod;
	}

	if ( NewThreat.PlayerReplicationInfo != None && ClonePump(SquadObjective) != None
	     && ClonePump(SquadObjective).LastDamagedBy == NewThreat.PlayerReplicationInfo
	     && ClonePump(SquadObjective).bUnderAttack )
	{
		if (!bThreatVisible)
			return current + 0.5 + PlayerTreatMod;
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 2000) || B.Pawn.IsA('Vehicle') || B.Pawn.Weapon.bSniping
			|| ClonePump(SquadObjective).Health < ClonePump(SquadObjective).DamageCapacity * 0.5 )
			return current + 6 + PlayerTreatMod;
		else
			return current + 1.5 + PlayerTreatMod;
	}
	else
		return current;
}



function bool MustKeepEnemy(Pawn E)
{
	//log("ClonesSquadAI::MustKeepEnemy");

	return ( E.PlayerReplicationInfo != None && ClonePump(SquadObjective) != None
		 && ClonePump(SquadObjective).LastDamagedBy == E.PlayerReplicationInfo
		 && ClonePump(SquadObjective).bUnderAttack );
}



//don't actually merge squads, because they could be two defending squads from different teams going to same neutral pump
function MergeWith(SquadAI S)
{
	//log("ClonesSquadAI::MergeWith");

	SquadObjective = S.SquadObjective;
}



function AddBot(Bot B)
{
	//log("ClonesSquadAI::AddBot");

	if ( B.Squad == self )
		return;
	if ( B.Squad != None )
		B.Squad.RemoveBot(B);

	Size++;

	B.NextSquadMember = SquadMembers;
	SquadMembers = B;
	B.Squad = self;
	if ( TeamPlayerReplicationInfo(B.PlayerReplicationInfo) != None )
	TeamPlayerReplicationInfo(B.PlayerReplicationInfo).Squad = self;
}

defaultproperties
{
     GatherThreshold=0.000000
     MaxSquadSize=3
     bAddTransientCosts=True
}
