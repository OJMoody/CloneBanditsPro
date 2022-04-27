//-----------------------------------------------------------
//  CLNMessage created on 2/5/04 by Demiurge Studios
//-----------------------------------------------------------
// Only has Clones specific game messages. All generic messages
// are still handled by ONSOnslaughtMessage. -RSG
// Specifies messages that players see on their HUD.
// Can also set on screen position and color of the text.

// TODO add clone stealing and capping messages

class CLNMessage extends CriticalEventPlus;

var(Message) localized string RedPumpActivatedString;		// team pump activated
var(Message) localized string BluePumpActivatedString;
var(Message) localized string RedBaseAttackedString;		// team base is under attack
var(Message) localized string BlueBaseAttackedString;
var(Message) localized string RedClonePumpAttackedString;	// team pump is under attack
var(Message) localized string BlueClonePumpAttackedString;
var(Message) localized string RedClonePumpShutDownString;	// team pump is shut down
var(Message) localized string BlueClonePumpShutDownString;
var(Message) localized string RedClonePumpPoweringUpString;	// team pump powering up
var(Message) localized string BlueClonePumpPoweringUpString;
var(Message) localized string RedClonePumpRanDryString;		// team pump out of clones
var(Message) localized string BlueClonePumpRanDryString;
var(Message) localized string ClonesLeftString;				// report clones left in reservoir
var(Message) localized string RedClonesLostString;			// report clones lost when a jar expires
var(Message) localized string BlueClonesLostString;
var(Message) localized string ClonesLostString;
var(Message) localized string RedCloneJarTakenString;
var(Message) localized string BlueCloneJarTakenString;

var(Message) localized string RocketCountdown[6];			// warning countdown before rocket bike explodes

var name MessageAnnouncements[24];

var color RedColor;
var color BlueColor;
var color YellowColor;
var color OrangeColor;

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	// play beep sound if rocket bike countdown is being displayed
	if( (40 < Switch) && (Switch < 46) ) // only 41-45, as 40 is the BOOM message
	{
		P.PlayBeepSound();
	}

	// only play "under attack" announcer messages every 10 seconds
	if (ClonePump(OptionalObject) != None)
	{
		if (P.Level.TimeSeconds < ClonePump(OptionalObject).LastAttackAnnouncementTime + 10)
			return;
		else
			ClonePump(OptionalObject).LastAttackAnnouncementTime = P.Level.TimeSeconds;
	}

	if( Switch < 24 && default.MessageAnnouncements[Switch] != '' )
	{
		// Clone jar stolen message.  Play sound for other team
		if( Switch >= 14 && Switch <= 15
		    && P.PlayerReplicationInfo.Team != None
			&& P.PlayerReplicationInfo.Team.TeamIndex == (Switch % 2)
		  )
		{
			P.PlayStatusAnnouncement(default.MessageAnnouncements[Switch], 1, true);
		}
	}
// onslaught legacy code
//	if ( default.MessageAnnouncements[Switch] != '' )
//		P.PlayStatusAnnouncement(default.MessageAnnouncements[Switch], 2, true);

//	if (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != None && P.PlayerReplicationInfo.Team.TeamIndex == Switch)
//		P.ClientPlaySound(default.VictorySound);
}


// return different lifetime based on message
static function float GetLifeTime(int Switch)
{
	// display rocket bike countdown for only 1 second
	if( (39 < Switch) && (Switch < 46) )
	{
		return 0.95;
	}
	else
		return default.LifeTime;
}



// get actual text of the message based on the switch
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	// catch any index values 
	// 40-45
	if( (39 < Switch) && (Switch < 46) )
	{
		return Default.RocketCountdown[Switch - 40];
	}

		// catch any unique Switch values
	switch (Switch)
	{
		case 0:
			return Default.RedPumpActivatedString;
			break;
		case 1:
			return Default.BluePumpActivatedString;
			break;
		case 2:
			return Default.RedBaseAttackedString;
			break;
		case 3:
			return Default.BlueBaseAttackedString;
			break;
		case 4:
			return Default.RedClonePumpAttackedString;
			break;
		case 5:
			return Default.BlueClonePumpAttackedString;
			break;
		case 6:
			return Default.RedClonePumpShutDownString;
			break;
		case 7:
			return Default.BlueClonePumpShutDownString;
			break;
		case 8:
			return Default.RedClonePumpPoweringUpString;
			break;
		case 9:
			return Default.BlueClonePumpPoweringUpString;
			break;
		case 10:
			return Default.RedClonePumpRanDryString;
			break;
		case 11:
			return Default.BlueClonePumpRanDryString;
			break;
		case 12:
			// test that OptionalObject contains a clone jar
			if (CloneJar(OptionalObject) != None) // TODO_CL: remove this run time checks when code is final
				return Default.RedClonesLostString@CloneJar(OptionalObject).ClonesInJar@Default.ClonesLostString;
			else
			{
				Log("Invalid object passed as a CloneJar",'CLNMessage');
				return "";
			}
			break;
		case 13:
			// test that OptionalObject contains a clone jar
			if (CloneJar(OptionalObject) != None) // TODO_CL: remove this run time checks when code is final
				return Default.BlueClonesLostString@CloneJar(OptionalObject).ClonesInJar@Default.ClonesLostString;
			else
			{
				Log("Invalid object passed as a CloneJar",'CLNMessage');
				return "";
			}
			break;
		case 14: 
			// test that OptionalObject contains a clone jar
			if (CloneJar(OptionalObject) != None) // TODO_CL: remove this run time check when code is final
			{
				// Temporary hack workaround to replication problem
				if(CloneJar(OptionalObject).ClonesInJar == 0)
					return RelatedPRI_1.PlayerName@"took a Clone Jar!";
				else
					return RelatedPRI_1.PlayerName@Default.RedCloneJarTakenString@CloneJar(OptionalObject).ClonesInJar@"Clones!";
			}
			else
			{
				Log("Invalid object passed as a CloneJar",'CLNMessage');
				return "";
			}
			break;
		case 15: 
	        // test that OptionalObject contains a clone jar
			if (CloneJar(OptionalObject) != None) // TODO_CL: remove this run time check when code is final
			{
				// Temporary hack workaround to replication problem
				if(CloneJar(OptionalObject).ClonesInJar == 0)
					return RelatedPRI_1.PlayerName@"took a Clone Jar!";
				else
					return RelatedPRI_1.PlayerName@Default.BlueCloneJarTakenString@CloneJar(OptionalObject).ClonesInJar@"Clones!";
			}
			else
			{
				Log("Invalid object passed as a CloneJar",'CLNMessage');
				return "";
			}
			break;
		case 16: 
			return RelatedPRI_1.PlayerName@"Scored"@CloneJar(OptionalObject).ClonesInJar@"Clones!";
		case 17: 
			return RelatedPRI_1.PlayerName@"Scored"@CloneJar(OptionalObject).ClonesInJar@"Clones!";
		case 18: 
			return RelatedPRI_1.PlayerName@"Returned A Clone Jar Containing"@CloneJar(OptionalObject).ClonesInJar@"Clones!";
		case 19: 
			return RelatedPRI_1.PlayerName@"Returned A Clone Jar Containing"@CloneJar(OptionalObject).ClonesInJar@"Clones!";
		case 20:
			if(RelatedPRI_1 != NONE)
				return RelatedPRI_1.PlayerName@"Dropped A Red Clone Jar Containing"@CloneJar(OptionalObject).ClonesInJar@"Clones!";
			else
				return "A Red Clone Jar Containing"@CloneJar(OptionalObject).ClonesInJar@"Clones was Dropped!";
		case 21: 
			if(RelatedPRI_1 != NONE)
				return RelatedPRI_1.PlayerName@"Dropped A Blue Clone Jar Containing"@CloneJar(OptionalObject).ClonesInJar@"Clones!";
			else
				return "A Blue Clone Jar Containing"@CloneJar(OptionalObject).ClonesInJar@"Clones was Dropped!";
		case 22:
			// called when player touches a friendly, active clone pump
			// tells player how many clones are left in pump's reservoir
			// test that OptionalObject contains the clone pump
			if (ClonePump(OptionalObject) != None)
				return ClonePump(OptionalObject).NumClonesToTake@Default.ClonesLeftString;
			else
				return "";
			break;
		case 23:
			return "You are in the way of Clone Jar spawning";
			break;
		default:
			return "";
			break;
	}
}

// set color of message based on message
static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
	// Special cases for "Dropped a clone jar"
	if (Switch == 20) 
	{
		return Default.BlueColor;
	} 
	if (Switch == 21)
	{
		return Default.RedColor;
	}
	// draw rocket bike countdown in orange
	if( (39 < Switch) && (Switch < 46) )
	{
		return Default.OrangeColor;
	}
	if( (11 < Switch) && (Switch < 22) )
	{
		return Default.YellowColor;
	}
	else if( Switch < 22 ) // anything less than 22 is a team-specific message (even:red, odd:blue)
	{
		if( (Switch % 2) == 0 ) // draw even messages in red
		{
			return Default.RedColor;
		}
		else if( (Switch % 2) == 1 ) // draw odd messages in blue
		{
			return Default.BlueColor;
		}
	}
	else
	{
		return Default.DrawColor;
	}
}

defaultproperties
{
     RedPumpActivatedString="Red Team Clone Pump Activated!"
     BluePumpActivatedString="Blue Team Clone Pump Activated!"
     RedBaseAttackedString="Red Team Base Is Under Attack!"
     BlueBaseAttackedString="Blue Team Base Is Under Attack!"
     RedClonePumpAttackedString="Red Team Clone Pump Is Under Attack!"
     BlueClonePumpAttackedString="Blue Team Clone Pump Is Under Attack!"
     RedClonePumpShutDownString="Red Team Clone Pump Shut Down!"
     BlueClonePumpShutDownString="Blue Team Clone Pump Shut Down!"
     RedClonePumpPoweringUpString="Red Team Clone Pump Powering Up!"
     BlueClonePumpPoweringUpString="Blue Team Clone Pump Powering Up!"
     RedClonePumpRanDryString="Red Team Clone Pump Ran Dry!"
     BlueClonePumpRanDryString="Blue Team Clone Pump Ran Dry!"
     ClonesLeftString="Clones Remaining In This Pump!"
     RedClonesLostString="Red Team Clone Jar Expired!"
     BlueClonesLostString="Blue Team Clone Jar Expired!"
     ClonesLostString="Clones Lost!"
     RedCloneJarTakenString="Stole A Red Team Clone Jar Containing"
     BlueCloneJarTakenString="Stole A Blue Team Clone Jar Containing"
     RocketCountdown(0)="BOOM!"
     RocketCountdown(1)="Self Destruct In...1"
     RocketCountdown(2)="Self Destruct In...2"
     RocketCountdown(3)="Self Destruct In...3"
     RocketCountdown(4)="Self Destruct In...4"
     RocketCountdown(5)="Self Destruct In...5"
     MessageAnnouncements(14)="Stole_Clone_Jar"
     MessageAnnouncements(15)="Stole_Clone_Jar"
     RedColor=(R=255,A=255)
     BlueColor=(B=255,A=255)
     YellowColor=(G=255,R=255,A=255)
     OrangeColor=(G=128,R=255,A=255)
     bIsUnique=False
     bIsPartiallyUnique=True
     DrawColor=(G=255,R=255)
     StackMode=SM_Down
}
