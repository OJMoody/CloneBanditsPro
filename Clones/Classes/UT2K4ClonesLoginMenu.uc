//==============================================================================
//	UT2K4CloneLoginMenu: Created on 02/26/04 by Demiurge Studios	
//	Clones specific implementation of login menu
//  Implementation modelled off of UT2K4OnslaughtLoginMenu
//==============================================================================
class UT2K4ClonesLoginMenu extends UT2K4PlayerLoginMenu;

// don't even want to have a map tab
//var() GUITabItem OnslaughtMapPanel;
//var() GUITabItem ClonesMapPanel; // this creates the "Map" tab that you can open
								 // and select spawn points 

function AddPanels()
{
//	Panels.Insert(0,1);
//	Panels[0] = OnslaughtMapPanel;
//    Panels[0] = ClonesMapPanel;
//	Panels[1].ClassName = "GUI2K4.UT2K4Tab_PlayerLoginControlsOnslaught";
//	Panels[1].ClassName = "Clones.UT2K4Tab_PlayerLoginControlsClones";

	// add only the panel that allows the player to switch teams or exit
	Panels.Insert(0, 0);
	Panels[0].ClassName = "Clones.UT2K4Tab_PlayerLoginControlsClones";

	Super.AddPanels();
}

function HandleParameters(string Param1, string Param2)
{
	// this controls the auto-opening of the map panel
//	if (PlayerOwner().IsInState('PlayerWaiting') || PlayerOwner().IsDead())
//	{
//		c_Main.ActivateTabByName(ClonesMapPanel.Caption, True);
//		//c_Main.ActivateTabByName(OnslaughtMapPanel.Caption, True);
//		return;
//
//	}

//	if (Param1 ~= "TL")
//	{
//		c_Main.ActivateTabByName(ClonesMapPanel.Caption, True);
//		//c_Main.ActivateTabByName(OnslaughtMapPanel.Caption, True);
//		// hmmm, do we want this given no teleporting via nodes?
//		UT2K4Tab_ClonesMap(c_Main.ActiveTab.MyPanel).NodeTeleporting();
//		return;
//	}

	c_Main.ActivateTabByName(Panels[1].Caption, true);
}

defaultproperties
{
}
