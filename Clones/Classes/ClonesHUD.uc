//-----------------------------------------------------------
// CTL - new HUD yo!
//-----------------------------------------------------------
class ClonesHUD extends ClonesHUDW
    config(user);

#exec OBJ LOAD FILE=../Textures/AR_ClonesHud_T.utx

var config float RadarScale, RadarTrans, IconScale, RadarPosX, RadarPosY;
var float RadarMaxRange, RadarRange;
// Legacy onslaught code
//var ClonePump FinalCore[2];
var ClonePump Node;
var ClonesPlayerReplicationInfo OwnerPRI;
// Legacy onslaught code
//var protected array<PowerLink> PowerLinks;

//var array<color> PowerLinks;
var array<ClonePump> ClonePumps;
var bool bMapDisabled;
var bool bReceivedLinks;
var vector MapCenter;
var float ColorPercent;

var()   Material            HealthBarBackMat;
var()   Material            HealthBarMat;
var()   float               HealthBarWidth;
var()   float               HealthBarHeight, HealthBarPosition;
var()   float               HealthBarViewDist;
var()   Material            BorderMat;
var()   color               NeutralColor;
var()   color               AttackColorA;
var()   color               AttackColorB;
var()   color               SeveredColorA;
var()   color               SeveredColorB;
var()   color               LinkColor[3];

var()   SpriteWidget    SymbolGB[2];
var()   SpriteWidget    CoreWidgets[2];
var()   NumericWidget   CoreHealthWidgets[2];

var		Texture			RedCloneJarTex;
var		Texture			BlueCloneJarTex; 

var()   SpriteWidget    HudBorderNitrous;
var()   SpriteWidget    HudBorderNitrousIcon;
var()   NumericWidget   DigitsNitrous;

var()   SpriteWidget    HudBorderFlamingo;
var()   SpriteWidget    HudBorderFlamingoIcon;
var()   NumericWidget	FlamingoStatus;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=ONSInterface-TX.utx

var	array<CloneJar>	ClientCloneJarArray;	// list of all clone jars loose in the level

simulated function UpdateCloneJars()
{
	local CloneJar jar;

	ClientCloneJarArray.Length = 0;
	foreach AllActors(class'CloneJar', jar)
	{
		if(!jar.bPendingDelete)
			ClientCloneJarArray[ClientCloneJarArray.Length] = jar;
	}
}


simulated function UpdateTeamHud()
{
    local ClonesGameReplicationInfo GRI;
    local int i;

	GRI = ClonesGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if (GRI == None)
        return;

    for (i = 0; i < 2; i++)
    {
        if (GRI.Teams[i] == None)
            continue;

		TeamSymbols[i].Tints[i] = HudColorTeam[i];
        ScoreTeam[i].Value =  Min(GRI.Teams[i].Score, 999);  // max space in hud

        if (GRI.TeamSymbols[i] != None)
			TeamSymbols[i].WidgetTexture = GRI.TeamSymbols [i];
    }
}

simulated event PostBeginPlay()
{
	// Legacy onslaught code
	//local ClonePump Core;
	local ClonePump Pump;

	local TerrainInfo T, PrimaryTerrain;

	Super.PostBeginPlay();


	//foreach AllActors( class'ClonePump', Core )
	//	if ( Core.bFinalCore )
	//		FinalCore[Core.DefenderTeamIndex] = Core;


	//Node = FinalCore[0];
	//Assert(Node != None);

	//// setup links right away, even though these will be overwritten when the new link setup is received from the server
	//if ( Level.NetMode == NM_Client )
	//	SetupLinks();

	// build the ClonePumps array
	foreach AllActors(class'ClonePump', Pump)
	{
        ClonePumps[ClonePumps.Length] = Pump;
	}

	// set Node as the first clone pump in the list
	Node = ClonePumps[0];
	Assert(Node != None);

	// Determine primary terrain
    foreach AllActors(class'TerrainInfo', T)
    {
        PrimaryTerrain = T;
        if (T.Tag == 'PrimaryTerrain')
            Break;
    }

    // Set RadarMaxRange to size of primary terrain
    if (PrimaryTerrain != None)
        RadarMaxRange = (PrimaryTerrain.TerrainScale.X * PrimaryTerrain.TerrainMap.USize) / 2.0;
    else
        RadarMaxRange = Min(default.RadarMaxRange, 10000);

    RadarRange = RadarMaxRange;

	UpdateCloneJars();

    SetTimer(1.0, true);
    Timer();

    HudBorderNitrous.Tints[0] = HudColorRed;
    HudBorderNitrous.Tints[1] = HudColorBlue;
    HudBorderFlamingo.Tints[0] = HudColorRed;
    HudBorderFlamingo.Tints[1] = HudColorBlue;
}

// Legacy onslaught code?
// Finds a ClonePump within 2500 units of PosX/PosY on the RadarMap (assumes a map centered at 0,0,0)
simulated function ClonePump LocateClonePump(float PosX, float PosY, float RadarWidth)
{
    local float WorldToMapScaleFactor, Distance, LowestDistance;
    local vector WorldLocation, DistanceVector;
    local ClonePump BestPump, Pump;

    WorldToMapScaleFactor = RadarRange/RadarWidth;

    WorldLocation.X = PosX * WorldToMapScaleFactor;
    WorldLocation.Y = PosY * WorldToMapScaleFactor;

    LowestDistance = 2500.0;

	Pump = Node;
	do
	{
        DistanceVector = Pump.Location - WorldLocation;
        DistanceVector.Z = 0;
		Distance = VSize(DistanceVector);
        if (Distance < LowestDistance)
        {
            BestPump = Pump;
            LowestDistance = Distance;
        }

		Pump = Pump.NextPump;
    } until ( Pump == None || Pump == Node );

    return BestPump;
	return NONE;
}

simulated function DrawRadarMap(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth, bool bShowDisabledNodes)
{
	local float PawnIconSize, PlayerIconSize, CoreIconSize, JarIconSize, MapScale, MapRadarWidth;
	local vector HUDLocation;
	local FinalBlend PlayerIcon;
	local Actor Player;
	local ClonePump CurPump;
	local int i;

	local plane SavedModulation;

	SavedModulation = C.ColorModulate;

	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = 1;

	// Make sure that the canvas style is alpha
	C.Style = ERenderStyle.STY_Alpha;

	MapRadarWidth = RadarWidth;
    if (PawnOwner != None)
    {
    	MapCenter.X = FClamp(PawnOwner.Location.X, -RadarMaxRange + RadarRange, RadarMaxRange - RadarRange);
    	MapCenter.Y = FClamp(PawnOwner.Location.Y, -RadarMaxRange + RadarRange, RadarMaxRange - RadarRange);
    }
    else
        MapCenter = vect(0,0,0);

	HUDLocation.X = RadarWidth;
	HUDLocation.Y = RadarRange;
	HUDLocation.Z = RadarTrans;

	// for all clone pumps
	for(i=0; i < ClonePumps.Length; i++)
	{
		// draw the health bar if possible
		if( ClonePumps[i].HasHealthBar() )
		{
			DrawHealthBar(C, ClonePumps[i], ClonePumps[i].Health, ClonePumps[i].DamageCapacity, HealthBarPosition);
		}
	}

   	DrawMapImage( C, Level.RadarMapImage, CenterPosX, CenterPosY, MapCenter.X, MapCenter.Y, HUDLocation );

	CoreIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;
	PawnIconSize = CoreIconSize * 0.5;
	PlayerIconSize = CoreIconSize * 1.5;
    MapScale = MapRadarWidth/RadarRange;
    C.Font = GetConsoleFont(C);

	// update position of all clone pumps
	for(i = 0; i < ClonePumps.Length; i++)
	{
		ClonePumps[i].UpdateHUDLocation( CenterPosX, CenterPosY, RadarWidth, RadarRange, MapCenter );
	}

	for(i = 0; i < ClonePumps.Length; i++)
	{
		CurPump = ClonePumps[i];

		// don't draw disabled ClonePumps or static clone pumps
		if(!bShowDisabledNodes && (ClonePumps[i].PumpStage == 255 || ClonePumps[i].PumpStage == 254))
		{
			continue;
		}

		C.DrawColor = LinkColor[CurPump.DefenderTeamIndex];

		// Draw appropriate icon to represent the current state of this node
	    if (CurPump.bUnderAttack)
	    	DrawAttackIcon( C, CurPump, CurPump.HUDLocation, IconScale, HUDScale, ColorPercent );
		else
			DrawNodeIcon( C, CurPump.HUDLocation, ClonePumpAttackable(CurPump), CurPump.PumpStage, IconScale, HUDScale, ColorPercent );
	}

	// Draw clone jar locations
	for(i = 0; i < ClientCloneJarArray.Length; i++)
	{
		if(ClientCloneJarArray[i].Base != NONE && Pawn(ClientCloneJarArray[i].Base) != NONE)
			HUDLocation = ClientCloneJarArray[i].Base.Location - MapCenter;
		else
			HUDLocation = ClientCloneJarArray[i].Location - MapCenter;
        HUDLocation.Z = 0;
    	if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
    	{
        	C.SetPos( CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5,
                          CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 );

			JarIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;

			// update if more than 2 teams
			if(ClientCloneJarArray[i].TeamNum == 0)
			{
				C.DrawColor = C.MakeColor(255,255,255);
				C.DrawTile(RedCloneJarTex, JarIconSize * 1.25, JarIconSize * 1.25, 0, 0, 32, 32);
			}
			else if(ClientCloneJarArray[i].TeamNum == 1)
			{
				C.DrawColor = C.MakeColor(255,255,255);
				C.DrawTile(BlueCloneJarTex, JarIconSize * 1.25, JarIconSize * 1.25, 0, 0, 32, 32);
			}
         }
	}

    // Draw PlayerIcon
    if (PawnOwner != None)
    	Player = PawnOwner;
    else if (PlayerOwner.IsInState('Spectating'))
        Player = PlayerOwner;
    else if (PlayerOwner.Pawn != None)
    	Player = PlayerOwner.Pawn;

    if (Player != None)
    {
    	PlayerIcon = FinalBlend'CurrentPlayerIconFinal';
    	TexRotator(PlayerIcon.Material).Rotation.Yaw = -Player.Rotation.Yaw - 16384;
        HUDLocation = Player.Location - MapCenter;
        HUDLocation.Z = 0;
    	if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
    	{
        	C.SetPos( CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5,
                          CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 );

            C.DrawColor = C.MakeColor(40,255,40);
            C.DrawTile(PlayerIcon, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
        }
    }

//    // Useful for showing what effects exist in the level in real-time
//    ForEach DynamicActors(class'Actor', A)
//    {
//        if (A.IsA('Projector') || A.IsA('Emitter') || A.IsA('xEmitter'))
//        {
//            HUDLocation = A.Location - MapCenter;
//            HUDLocation.Z = 0;
//        	C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);
//            C.DrawColor = C.MakeColor(255,255,0);
//            C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.25, PlayerIconSize * 0.25, 0, 0, 32, 32);
//        }
//    }

    // Draw Border
    C.DrawColor = C.MakeColor(200,200,200);
	C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
	C.DrawTile(BorderMat,
               RadarWidth * 2.0,
               RadarWidth * 2.0,
               0,
               0,
               256,
               256);

    C.ColorModulate = SavedModulation;
}

function bool ClonePumpAttackable(ClonePump CP)
{
    if  (PawnOwnerPRI != None && PawnOwnerPRI.Team != None)
    {
        if (CP.DefenderTeamIndex != PawnOwnerPRI.Team.TeamIndex)
            return (CP.OwnedBy(PawnOwnerPRI.Team.TeamIndex));
        else
        {
            if (PawnOwnerPRI.Team.TeamIndex == 0)
                return (CP.OwnedBy(1));
            else
                return (CP.OwnedBy(0));
        }
    }

    return False;
}


simulated function ShowTeamScorePassC(Canvas C)
{
    local float RadarWidth, CenterRadarPosX, CenterRadarPosY;

    if (!bMapDisabled)
    {
        RadarWidth = 0.5 * RadarScale * HUDScale * C.ClipX;
        CenterRadarPosX = (RadarPosX * C.ClipX) - RadarWidth;
        CenterRadarPosY = (RadarPosY * C.ClipY) + RadarWidth;
        DrawRadarMap(C, CenterRadarPosX, CenterRadarPosY, RadarWidth, false);
    }
}

simulated function DrawHealthBar(Canvas C, Actor A, int Health, int MaxHealth, float Height)
{
	local vector		CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator		CameraRotation;
	local float			Dist, HealthPct;
	local color         OldDrawColor;

	// rjp --  don't draw the health bar if menus are open
	if ( PlayerOwner.Player.GUIController.bActive )
		return;

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation( CameraLocation, CameraRotation );
	TargetLocation = A.Location + vect(0,0,1) * Height;
	Dist = VSize(TargetLocation - CameraLocation);

	// Check Distance Threshold
	if (Dist > HealthBarViewDist)
		return;

	CamDir	= vector(CameraRotation);

	// Target is located behind camera
	HBScreenPos = C.WorldToScreen(TargetLocation);
	if ((TargetLocation - CameraLocation) dot CamDir < 0 || HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		TargetLocation = A.Location + vect(0,0,1) * A.CollisionHeight;
		if ((TargetLocation - CameraLocation) dot CamDir < 0)
			return;
		HBScreenPos = C.WorldToScreen(TargetLocation);
		if (HBScreenPos.X <= 0 || HBScreenPos.X >= C.ClipX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.ClipY)
			return;
	}

	if (FastTrace(TargetLocation, CameraLocation))
	{
	    	C.DrawColor = WhiteColor;

	    	C.SetPos(HBScreenPos.X - HealthBarWidth * 0.5, HBScreenPos.Y);
	    	C.DrawTileStretched(HealthBarBackMat, HealthBarWidth, HealthBarHeight);

	    	HealthPct = 1.0f * Health / MaxHealth;

	    	if (HealthPct < 0.35)
	    	   C.DrawColor = RedColor;
	    	else if (HealthPct < 0.70)
	    	   C.DrawColor = GoldColor;
	    	else
	    	   C.DrawColor = GreenColor;

	    	C.SetPos(HBScreenPos.X - HealthBarWidth * 0.5, HBScreenPos.Y);
	    	C.DrawTileStretched(HealthBarMat, HealthBarWidth * HealthPct, HealthBarHeight);
	}

	C.DrawColor = OldDrawColor;
}


simulated function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	ColorPercent = 0.5f + Cos((Level.TimeSeconds * 4.0) * 3.14159 * 0.5f) * 0.5f;
}

exec function ToggleRadarMap()
{
	bMapDisabled = !bMapDisabled;
}

// hmm, why are these commented out?
//exec function ZoomInRadarMap()
//{
//    RadarRange = Max(RadarRange - (RadarMaxRange * 0.1), 3000.0);
//}
//
//exec function ZoomOutRadarMap()
//{
//    RadarRange = Min(RadarRange + (RadarMaxRange * 0.1), RadarMaxRange);
//}


simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'HudContent.Generic.NoEntry');
    Level.AddPrecacheMaterial(Material'AR_ClonesHud_T.Generic.HUD');
    Level.AddPrecacheMaterial(Material'InterfaceContent.BorderBoxD');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.HealthBar');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.MapBorderTex');

	Super.UpdatePrecacheMaterials();
}

simulated static function bool CoreWorldToScreen( ClonePump Core, out vector ScreenPos, float ScreenX, float ScreenY, float RadarWidth, float Range, vector Center, optional bool bIgnoreRange )
{
	local vector ScreenLocation;
	local float Dist;

	if ( Core == None )
		return false;

    ScreenLocation = Core.Location - Center;
    ScreenLocation.Z = 0;
	Dist = VSize(ScreenLocation);
	if ( bIgnoreRange || (Dist < (Range * 0.95)) )
	{
        ScreenPos.X = ScreenX + ScreenLocation.X * (RadarWidth/Range);
        ScreenPos.Y = ScreenY + ScreenLocation.Y * (RadarWidth/Range);
        ScreenPos.Z = 0;
        return true;
    }

    return false;
}

simulated static function DrawMapImage( Canvas C, Material Image, float MapX, float MapY, float PlayerX, float PlayerY, vector Dimensions )
{
	local float MapScale, MapSize;

	/*
	Dimensions.X = Width
	Dimensions.Y = Range
	Dimensions.Z = Alpha

	*/

	if ( Image == None || C == None )
		return;

	MapSize = Image.MaterialUSize();
	MapScale = MapSize / (Dimensions.Y * 2);

	C.DrawColor = default.WhiteColor;
	C.DrawColor.A = Dimensions.Z;

	C.SetPos( MapX - Dimensions.X, MapY - Dimensions.X );
	C.DrawTile( Image, Dimensions.X * 2.0, Dimensions.X * 2.0,
	           (PlayerX - Dimensions.Y) * MapScale + MapSize / 2.0,
			   (PlayerY - Dimensions.Y) * MapScale + MapSize / 2.0,
			   Dimensions.Y * 2 * MapScale, Dimensions.Y * 2 * MapScale );
}

simulated static function DrawAttackIcon( Canvas C, ClonePump CurCore, vector HUDLocation, float IconScaling, float HUDScaling, float ColorPercentage )
{
	local float AttackIconSize, CoreIconSize;
	local color HoldColor;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;

    AttackIconSize = CoreIconSize * (2.5 + 1.5 * ColorPercentage);

    HoldColor = C.DrawColor;

    C.DrawColor = default.AttackColorA * ColorPercentage + default.AttackColorB * (1.0 - ColorPercentage);

    C.SetPos(HUDLocation.X - AttackIconSize * 0.5, HUDLocation.Y - AttackIconSize * 0.5);
    C.DrawTile(Material'NewHUDIcons', AttackIconSize, AttackIconSize, 0, 64, 64, 64);
    C.DrawColor = HoldColor;
}

simulated static function DrawCoreIcon( Canvas C, vector HUDLocation, bool bAttackable, float IconScaling, float HUDScaling, float ColorPercentage )
{
	local float CoreIconSize;
//	local color HoldColor;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;
    C.SetPos(HUDLocation.X - CoreIconSize * 3.0 * 0.5, HUDLocation.Y - CoreIconSize * 3.0 * 0.5);

//    HoldColor = C.DrawColor;

    if (bAttackable)
        C.DrawColor = C.DrawColor * ColorPercentage + (C.DrawColor * 0.5) * (1.0 - ColorPercentage);

    C.DrawTile(Material'NewHUDIcons', CoreIconSize * 3.0, CoreIconSize * 3.0, 64, 0, 64, 64);
//    C.DrawColor = HoldColor;
}

simulated static function DrawNodeIcon( Canvas C, vector HUDLocation, bool bAttackable, byte Stage, float IconScaling, float HUDScaling, float ColorPercentage )
{
	local float CoreIconSize;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;
    if (Stage == 4 || Stage == 1)
    {
        if (bAttackable)
        {
            C.SetPos(HUDLocation.X - CoreIconSize * 0.75 * 0.5, HUDLocation.Y - CoreIconSize * 0.75 * 0.5);
            C.DrawTile(Material'NewHUDIcons', CoreIconSize * 0.75, CoreIconSize * 0.75, 0, 0, 32, 32);
        }
        else
        {
            C.SetPos(HUDLocation.X - CoreIconSize * 1.75 * 0.5, HUDLocation.Y - CoreIconSize * 1.75 * 0.5);
            C.DrawTile(Material'NewHUDIcons', CoreIconSize * 1.75, CoreIconSize * 1.75, 0, 32, 32, 32);
        }
    }
    else
	{
		if ( Stage != 0 )
			C.DrawColor = C.DrawColor * ColorPercentage + default.LinkColor[2] * (1.0 - ColorPercentage);

		if (bAttackable)
	    {
	        C.SetPos(HUDLocation.X - CoreIconSize * 2.0 * 0.5, HUDLocation.Y - CoreIconSize * 2.0 * 0.5);
	        C.DrawTile(Material'NewHUDIcons', CoreIconSize * 2.0, CoreIconSize * 2.0, 32, 0, 32, 32);
	    }
	    else
	    {
	        C.SetPos(HUDLocation.X - CoreIconSize * 1.75 * 0.5, HUDLocation.Y - CoreIconSize * 1.75 * 0.5);
	        C.DrawTile(Material'NewHUDIcons', CoreIconSize * 1.75, CoreIconSize * 1.75, 0, 32, 32, 32);
	    }
	}
}


simulated static function DrawSelectionIcon( Canvas C, vector HUDLocation, color IconColor, float IconScaling, float HUDScaling )
{
	local float CoreIconSize;

	if ( C == None )
		return;

	CoreIconSize = IconScaling * 16 * C.ClipX * HUDScaling/1600;

	C.DrawColor = IconColor;
	C.SetPos( HUDLocation.X - CoreIconSize * 1.5, HUDLocation.Y - CoreIconSize * 1.5);
	C.DrawTile( Material'NewHUDIcons', CoreIconSize * 3, CoreIconSize * 3, 32, 32, 32, 32 );
}

simulated function String GetInfoString()
{
	local string InfoString;

	if ( PlayerOwner.IsDead() )
	{
	    if ( PlayerOwner.PlayerReplicationInfo.bOutOfLives )
	        InfoString = class'ScoreBoardClones'.default.OutFireText;
	    else if ( Level.TimeSeconds - UnrealPlayer(PlayerOwner).LastKickWarningTime < 2 )
    		InfoString = class'GameMessage'.Default.KickWarning;
	    else
	        InfoString = class'ScoreBoardClones'.default.Restart;
	}
	else if ( Level.TimeSeconds - UnrealPlayer(PlayerOwner).LastKickWarningTime < 2 )
    	InfoString = class'GameMessage'.Default.KickWarning;
    else if ( GUIController(PlayerOwner.Player.GUIController).ActivePage!=None)
    	InfoString = AtMenus;
	else if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	    InfoString = WaitingToSpawn;
    else
		InfoString = InitialViewingString;

	return InfoString;
}

// This code is in ClonesHUD rather than HotRod so we can use widgets and such
simulated function DrawHotRodHUD(Canvas C)
{
	DrawHUDAnimWidget( HudBorderNitrousIcon, default.HudBorderNitrousIcon.TextureScale, 0, 0.6, 0.6);
	DrawSpriteWidget( C, HudBorderNitrous );

	HudBorderNitrousIcon.WidgetTexture = default.HudBorderNitrous.WidgetTexture;

	DrawSpriteWidget( C, HudBorderNitrousIcon);

    DigitsNitrous.Value = HotRod(PlayerOwner.Pawn).NitrousRemaining;
	DrawHUDAnimDigit( DigitsNitrous, default.DigitsNitrous.TextureScale, 0, 0.8, default.DigitsNitrous.Tints[TeamIndex], HudColorHighLight);
	DrawNumericWidget( C, DigitsNitrous, DigitsBig);
}

// draw the lounge tank hud, done this way for the same reason we do the hot rod this way
simulated function DrawLTHud(Canvas C)
{
	DrawHUDAnimWidget( HudBorderFlamingoIcon, default.HudBorderFlamingoIcon.TextureScale, 0, 0.6, 0.6);
	DrawSpriteWidget( C, HudBorderFlamingo );

	HudBorderNitrousIcon.WidgetTexture = default.HudBorderFlamingo.WidgetTexture;

	DrawSpriteWidget( C, HudBorderFlamingoIcon);

	if( LoungeTankCannon(LoungeTank(PlayerOwner.Pawn).Weapons[0]).FlamingoReloading )
		FlamingoStatus.Value = 0;
	else
		FlamingoStatus.Value = 1;

	DrawHUDAnimDigit( FlamingoStatus, default.FlamingoStatus.TextureScale, 0, 0.8, default.FlamingoStatus.Tints[TeamIndex], HudColorHighLight);
	DrawNumericWidget( C, FlamingoStatus, DigitsBig);
}



simulated function DrawHudPassA(Canvas C)
{
    Super.DrawHudPassA(C);
    if(HotRod(PlayerOwner.Pawn) != None)
        DrawHotRodHud(C);
    if(LoungeTank(PlayerOwner.Pawn) != None)
        DrawLTHud(C);
}

defaultproperties
{
     RadarScale=0.200000
     RadarTrans=255.000000
     IconScale=1.000000
     RadarPosX=1.000000
     RadarPosY=0.100000
     RadarMaxRange=10000.000000
     HealthBarBackMat=Texture'InterfaceContent.Menu.BorderBoxD'
     HealthBarMat=Texture'ONSInterface-TX.HealthBar'
     HealthBarWidth=75.000000
     HealthBarHeight=8.000000
     HealthBarPosition=485.000000
     HealthBarViewDist=4000.000000
     BorderMat=Texture'ONSInterface-TX.MapBorderTEX'
     AttackColorA=(G=189,R=244,A=255)
     AttackColorB=(B=11,G=162,R=234,A=255)
     SeveredColorA=(B=192,G=192,R=192,A=255)
     SeveredColorB=(B=128,G=128,R=128,A=255)
     LinkColor(0)=(R=255,A=255)
     LinkColor(1)=(B=255,A=255)
     LinkColor(2)=(B=255,G=255,R=255,A=255)
     SymbolGB(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.600000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-32,OffsetY=7,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SymbolGB(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.600000,PosX=0.500000,OffsetX=32,OffsetY=7,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CoreWidgets(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=365,Y1=233,X2=432,Y2=313),TextureScale=0.250000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-110,OffsetY=45,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=100,G=100,R=255,A=200),Tints[1]=(B=32,G=32,R=255,A=200))
     CoreWidgets(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=365,Y1=233,X2=432,Y2=313),TextureScale=0.250000,PosX=0.500000,OffsetX=110,OffsetY=45,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=128,A=200),Tints[1]=(B=255,G=210,R=32,A=200))
     CoreHealthWidgets(0)=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.240000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-149,OffsetY=88,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CoreHealthWidgets(1)=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.240000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=149,OffsetY=88,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RedCloneJarTex=Texture'CS_CloneItems_T.HUD.JarIconRed'
     BlueCloneJarTex=Texture'CS_CloneItems_T.HUD.JarIconBlue'
     HudBorderNitrous=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderNitrousIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=343,Y1=141,X2=385,Y2=210),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=0.910000,PosY=1.000000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     DigitsNitrous=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-10,OffsetY=-10,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderFlamingo=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderFlamingoIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=284,Y1=383,X2=347,Y2=455),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=0.910000,PosY=1.000000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     FlamingoStatus=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-10,OffsetY=-10,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ScoreTeam(0)=(MinDigitCount=2,PosX=0.442000)
     ScoreTeam(1)=(MinDigitCount=2,PosX=0.558000)
     VersusSymbol=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     TeamScoreBackGround(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',PosX=0.442000)
     TeamScoreBackGround(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',PosX=0.558000)
     TeamScoreBackGroundDisc(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',PosX=0.442000)
     TeamScoreBackGroundDisc(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD',PosX=0.558000)
     TeamSymbols(0)=(PosX=0.442000)
     TeamSymbols(1)=(PosX=0.558000)
     DigitsBig=(DigitTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     TimerDigitSpacer(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     TimerDigitSpacer(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     TimerIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     TimerBackground=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     TimerBackgroundDisc=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     UDamageIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     AdrenalineIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     AdrenalineBackground=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     AdrenalineBackgroundDisc=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     MyScoreIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     MyScoreBackground=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderShield=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderHealth=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderVehicleHealth=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderAmmo=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderShieldIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderHealthIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     HudBorderVehicleHealthIcon=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(2)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(3)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(4)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(5)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(6)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(7)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarWeaponIcon(8)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(2)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(3)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(4)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(5)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(6)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(7)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorder(8)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(0)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(1)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(2)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(3)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(4)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(5)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(6)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(7)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     BarBorderAmmoIndicator(8)=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     RechargeBar=(WidgetTexture=Texture'AR_ClonesHud_T.Generic.HUD')
     LocationDot=Texture'AR_ClonesHud_T.Generic.HUD'
}
