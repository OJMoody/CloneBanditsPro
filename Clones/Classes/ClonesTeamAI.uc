class ClonesTeamAI extends TeamAI;

var array<CloneJarBase>	EnemyJarPoints;
var array<CloneJarBase>	OwnJarPoints;
var array<ClonePump>	ClonePumps;

var SquadAI DefenseSquad;



//////////////////////////////////////////
// Superclass functions



function SetObjectiveLists()
{
	local GameObjective O;
	local CloneJarBase JarBase;

	//log("ClonesTeamAI::SetObjectiveLists");

	Super.SetObjectiveLists();

	for (O = Objectives; O != None; O = O.NextObjective)
	{
		JarBase = CloneJarBase(O);
		if(JarBase != NONE)
		{
			if(JarBase.DefenderTeamIndex != Team.TeamIndex)
				EnemyJarPoints[EnemyJarPoints.length] = JarBase;
			else
				OwnJarPoints[OwnJarPoints.length] = JarBase;
		}
		else if(ClonePump(O) != NONE/* && !ClonePump(O).bStaticPump*/)
		{
			ClonePumps[ClonePumps.length] = ClonePump(O);
		}
	}
}



function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local ClonesSquadAI ClonesSAI;
	local int i;

	ClonesSAI = ClonesSquadAI(Super.AddSquadWithLeader(C, O));

	if(ClonesSAI != NONE)
	{
		for(i = 0; i < EnemyJarPoints.length; i++)
			ClonesSAI.EnemyJarPoints[ClonesSAI.EnemyJarPoints.length] = EnemyJarPoints[i];
		for(i = 0; i < OwnJarPoints.length; i++)
			ClonesSAI.OwnJarPoints[ClonesSAI.OwnJarPoints.length] = OwnJarPoints[i];
		for(i = 0; i < ClonePumps.length; i++)
			ClonesSAI.ClonePumps[ClonesSAI.ClonePumps.length] = ClonePumps[i];
	}

	return ClonesSAI;
}


/*
SetBotOrders - based on RosterEntry recommendations - unchanged from version in TeamAI except for logs
*/
function SetBotOrders(Bot NewBot, RosterEntry R)
{
	local SquadAI HumanSquad;
	local name NewOrders;

//	log("ClonesTeamAI::SetBotOrders  R="$R);

	if ( Objectives == None )
		SetObjectiveLists();

	if ( (R==None) || R.NoRecommendation() )
	{
		// pick orders
		if ( Team.Size == 0 )
			OrderOffset = 0;
		NewOrders = OrderList[OrderOffset % 8];
		OrderOffset++;
	}
	else if ( R.RecommendDefense() )
		NewOrders = 'DEFEND';
	else if ( R.RecommendAttack() )
		NewOrders = 'ATTACK';
	else if ( R.RecommendSupport() )
		NewOrders = 'FOLLOW';
	else
		NewOrders = 'FREELANCE';

	// log(NewBot$" set Initial orders "$NewOrders);
	if ( (NewOrders == 'DEFEND') && PutOnDefense(NewBot) )
		return;

	if ( NewOrders == 'FREELANCE' )
	{
		PutOnFreelance(NewBot);
		return;
	}

	if ( NewOrders == 'ATTACK' )
	{
		PutOnOffense(NewBot);
		return;
	}

	if ( NewOrders == 'FOLLOW' )
	{
		// Follow any human player
		HumanSquad = AddHumanSquad();
		if ( HumanSquad != None )
		{
			HumanSquad.AddBot(NewBot);
			return;
		}
	}
	PutOnOffense(NewBot);
}



//// Keep this around for simple testing...
//function SetBotOrders(Bot NewBot, RosterEntry R)
//{
//	//log("ClonesTeamAI::SetBotOrders");
//
//	// VERY simple
//	PutOnFreelance(NewBot);
//	//PutOnOffense(NewBot);
//	//PutOnDefense(NewBot);
//	return;
//}



// ONS had a different version... I don't *think* we need one...  but I don't know
function bool PutOnDefense(Bot B)
{
	local GameObjective O;
	local bool ret;

	O = GetLeastDefendedObjective();
	if ( O != None )
	{
		if ( DefenseSquad == None )
			DefenseSquad = AddSquadWithLeader(B, O);
		else
			DefenseSquad.AddBot(B);
		O.DefenseSquad = DefenseSquad;
		ret = true;
	}
	else
		ret = false;

	//log("ClonesTeamAI::PutOnDefense   return value: "$ret$"  B.Squad: "$B.Squad);
	return ret;
}



function PutOnOffense(Bot B)
{
	Super.PutOnOffense(B);
	//log("ClonesTeamAI::PutOnOffense   AttackSqaud="$AttackSquad);
}

function PutOnFreelance(Bot B)
{
	Super.PutOnFreelance(B);
	//log("ClonesTeamAI::PutOnFreelance   FreelanceSquad="$FreelanceSquad);
}




// Deal with picking when to attack and defend
function ReAssessStrategy()
{
	local GameObjective O;
	local int i;

	//log("ClonesTeamAI::ReAssessStrategyfor team:"$Team.TeamIndex);

	if (FreelanceSquad == None)
	{
		//log("ReAssessStrategy: 1");
		return;
	}


	// If there are no jar points and no pumps, then this is prob going to be a bad game of Clones so
	// just do the super.
	if (EnemyJarPoints.length == 0 && ClonePumps.length == 0)
	{
		Super.ReAssessStrategy();
		//log("ReAssessStrategy: 2");
		return;
	}

	for(i = 0; i < ClonePumps.length; i++)
	{
		if(ClonePumps[i].PumpStage == 4)
		{
			if( AttackSquad != NONE
				&& AttackSquad.SquadObjective != ClonePumps[i]
				&& Bot(AttackSquad.SquadLeader) != NONE 
				&& Bot(AttackSquad.SquadLeader).LineOfSightTo(ClonePumps[i]) // distance might be better but... oh well in out one map this works well
				&& AttackSquad.SquadObjective != ClonePumps[i]
				)
			{
//				log("ClonesTeamAI::ReAssessStrategy - AttackSquad sees free pump, changes objective");
				AttackSquad.SetObjective(ClonePumps[i],true);
			}

			if( FreelanceSquad != NONE
				&& FreelanceSquad.SquadObjective != ClonePumps[i]
				&& Bot(FreelanceSquad.SquadLeader) != NONE 
				&& Bot(FreelanceSquad.SquadLeader).Enemy == None
				&& Bot(FreelanceSquad.SquadLeader).LineOfSightTo(ClonePumps[i]) // distance might be better but... oh well in out one map this works well
				&& FreelanceSquad.SquadObjective != ClonePumps[i]
				)
			{
//				log("ClonesTeamAI::ReAssessStrategy - FreelanceSquad sees free pump, changes objective");
				FreelanceSquad.SetObjective(ClonePumps[i],true);
			}
		}
	}

	if( ClonePump(FreelanceSquad.SquadObjective) != NONE && ClonePump(FreelanceSquad.SquadObjective).PumpStage == 4 )
		return;

	if(DefenseSquad != NONE)
	{
		O = GetLeastDefendedObjective();
		if( (O != None) && (O != DefenseSquad.SquadObjective) )
		DefenseSquad.SetObjective(O,true);
	}

	// decide whether to play defensively or aggressively

	//// Figure out if control all pumps
	//bControlAllPumps = ControlAllPumps(Team.TeamIndex);

	//FreelanceSquad.bFreelanceAttack = false;
	//FreelanceSquad.bFreelanceDefend = false;
	//if ( Team.Score > EnemyTeam.Score*1.5 && bControlAllPumps )
	//{
	//	FreelanceSquad.bFreelanceDefend = true;
	//	O = GetLeastDefendedObjective();
	//}
	//else if ( Team.Score < EnemyTeam.Score*1.5 && !bControlAllPumps ) // note that this is not the inverse of the above check
	//{
	//	FreelanceSquad.bFreelanceAttack = true;
	//	O = GetPriorityAttackObjectiveFor(FreelanceSquad);
	//}
	//else
	//	O = GetPriorityFreelanceObjective();

	O = GetPriorityFreelanceObjective();

	//if( (O != None) && (ClonePump(O) != NONE) && (ClonePump(FreelanceSquad.SquadObjective) != NONE) &&
 //       (RatePumpObjective(ClonePump(O)) > RatePumpObjective(ClonePump(FreelanceSquad.SquadObjective))) )
	//		FreelanceSquad.SetObjective(O,true);
	//else if ( (O != None) && (O != FreelanceSquad.SquadObjective) )
	//	FreelanceSquad.SetObjective(O,true);
	if ( (O != None) && (O != FreelanceSquad.SquadObjective) )
		FreelanceSquad.SetObjective(O,true);

	//log("ReAssessStrategy  new objective = "$O);
}



// Mostly like the ONS version but sometime randomly don't care about this warning.
function CriticalObjectiveWarning(GameObjective AttackedObjective, Pawn EventInstigator)
{
	local SquadAI S;
	local Bot M;
	local bool bFoundDefense;

	//log("ClonesTeamAI::CriticalObjectiveWarning for team:"$Team.TeamIndex);

	// If you aren't defending this objective, don't take notice
	if(AttackedObjective.DefenderTeamIndex != Team.TeamIndex)
		return;

	// Taken from ONSTeamAI
	for (S = Squads; S != None; S = S.NextSquad)
	{
		if (S.SquadObjective == AttackedObjective)
		{
			S.CriticalObjectiveWarning(EventInstigator);
			bFoundDefense = true;
			for (M = S.SquadMembers; M != None; M = M.NextSquadMember)
				if ( (M.Enemy == None || M.Enemy == EventInstigator) && Vehicle(M.Pawn) != None && M.Pawn.bStationary
				     && !FastTrace(EventInstigator.Location + EventInstigator.CollisionHeight * vect(0,0,1), M.Pawn.Location) )
				{
					Vehicle(M.Pawn).KDriverLeave(false);
					M.WhatToDoNext(67);
				}
		}
	}

	// If you are supposed to defend and you "feel" like it (see rand), defend this thing being attacked
	// Maybe handle situation of already defending something...
	if (!bFoundDefense)
	{
		for (S = Squads; S != None; S = S.NextSquad)
			if ( (S.GetOrders() == 'Defend' || S.bFreelanceDefend) && rand(2) == 0) // rand number are like smarts
			{
				S.SetObjective(AttackedObjective, true);
				S.CriticalObjectiveWarning(EventInstigator);
				return;
			}
	}
}



// Just do the super class version... for now
function FindNewObjectives(GameObjective DisabledObjective)
{
	//log("ClonesTeamAI::FindNewObjectives");

	Super.FindNewObjectives(DisabledObjective);
}



// Attack the clone pumps
function GameObjective GetPriorityAttackObjectiveFor(SquadAI AttackSquad)
{
	local GameObjective Best;
	local int ObjectiveRating, NewRating;
	local array<int> PumpsToPickFrom;
	local int i;

   if(ClonePumps.length > 0)
	{
		ObjectiveRating = 0;

		for(i = 0; i < ClonePumps.length; i++)
		{
			NewRating = RatePumpObjective(ClonePumps[i]);
			if(NewRating > ObjectiveRating)
			{
				PumpsToPickFrom.length = 0;
				PumpsToPickFrom[PumpsToPickFrom.length] = i;
				ObjectiveRating = NewRating;
			}
			if(NewRating == ObjectiveRating)
			{
				PumpsToPickFrom[PumpsToPickFrom.length] = i;
			}
		}
		Best = ClonePumps[PumpsToPickFrom[rand(PumpsToPickFrom.length)]];
	}

	if(Best == NONE)
	{
//		log("Can't find GameObjective in GetPriorityAttackObjectiveFor!");
	}

	//log("GetPriorityAttackObjectiveFor = "$Best$" for team:"$Team.TeamIndex);
	return Best;
}



// Defend the main base where the jars are
function GameObjective GetLeastDefendedObjective()
{
	local GameObjective Best;
	//local GameObjective O, Best;

	if(ControlAllPumps(Team.TeamIndex))
	{
		Best = OwnJarPoints[0]; //TODO_CL... maybe do something more complex
	}
	else
	{
		Best = GetPriorityAttackObjectiveFor(NONE);
	}

	//log("GetLeastDefendedObjective = "$Best$" for team:"$Team.TeamIndex);
	return Best;
}



// This function is never called anywhere is code
function GameObjective GetMostDefendedObjective()
{
	return Super.GetMostDefendedObjective();
}



// Go after clone jars
function GameObjective GetPriorityFreelanceObjective()
{
	local GameObjective Best;

	Best = EnemyJarPoints[0]; //TODO_CL... maybe do something more complex

	if(Best == NONE)
	{
//		log("Can't find GameObjective in GetPriorityFreelanceObjective!");
	}

	//log("GetPriorityFreelanceObjective = "$Best);
	return Best;
}




//////////////////////////////////////////
// Helper functions



// really should be more than 1/2 
function bool ControlAllPumps(int TeamIndex)
{
	local bool bControlAllPumps;
	local int i;

	//log("ClonesTeamAI::ControlAllPumps");

	bControlAllPumps = true;
	for(i = 0; i < ClonePumps.length; i++)
	{
		if(ClonePumps[i].DefenderTeamIndex != TeamIndex)
		{
			bControlAllPumps = false;
			break;
		}
	}

	return bControlAllPumps;
}



function int RatePumpObjective(ClonePump Pump)
{
	local int Rating;

	Rating = 0;

	// Your clone pump is being attacked
	if(Pump.DefenderTeamIndex == Team.TeamIndex && Pump.bUnderAttack)
		Rating = 10;

	// Neutral pump
	else if(Pump.PumpStage == 4)
		Rating = 10;

	// Other teams pump that your teammates seem to be attacking - go help
	else if(Pump.DefenderTeamIndex != Team.TeamIndex && Pump.bUnderAttack)
		Rating = 8;

	// Other teams pump - go get it
	else if(Pump.DefenderTeamIndex != Team.TeamIndex)
		Rating = 5;

	//log("Rating for "$Pump$" : "$Rating);
	return Rating;
}

defaultproperties
{
     SquadType=Class'Clones.ClonesSquadAI'
     OrderList(0)="Attack"
     OrderList(2)="Freelance"
     OrderList(4)="Defend"
}
