class ClonesHudW extends HudCTeamDeathMatch;

//Positioning
var const float XShifts[9];
var const float YShifts[9];

//Scaling
var bool bCorrectAspectRatio;

var float ScaleYCache;

/*
//Caching
struct CacheSpriteInfo
{
	var float	CacheCPosX; //For direct input to C.SetPos. Used if everything else is the same.
	var float	CacheCPosY;
	var int		CacheTexCoordsNearX, CacheTexCoordsFarX; //Near and far tex area for DrawTile.
	var int		CacheTexNearY, CacheTexFarY; //Same for Y.
	var int		CacheTexL, CacheTexW; //Length and width of tile.
	var float 	CacheTexScale;
};*/

//Greater than normal HUD scaling is sometimes desirable.
exec final function ScaleHUD(float F)
{
	HUDScale = FClamp(F, 0.5, ResScaleX/ResScaleY);
	SaveConfig();
}

//===========================================================================
// Draws a SpriteWidget using DrawTile.
//===========================================================================
simulated final function DrawWidgetAsTile(Canvas C, SpriteWidget W)
{
	if (!bCorrectAspectRatio)
	{
		DrawSpriteWidget(C, W);
		return;
	}
	
	C.Style = W.RenderStyle;
	
	C.DrawColor = W.Tints[TeamIndex];
	
	if (W.Scale == 1.0f || W.ScaleMode == SM_None)
	{
		C.SetPos(
					(C.ClipX * W.PosX) + (W.OffsetX - Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * XShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache),
					(C.ClipY * W.PosY) + (W.OffsetY - Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * YShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache)
		);
		C.DrawTile(
			W.WidgetTexture, 
			Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * W.TextureScale * ScaleYCache,  
			Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.TextureScale * ScaleYCache, 
			W.TextureCoords.X1, 
			W.TextureCoords.Y1, 
			W.TextureCoords.X2 - W.TextureCoords.X1, 
			W.TextureCoords.Y2 - W.TextureCoords.Y1
		);
	}
	else
	{
		switch(W.ScaleMode)
		{
			case SM_Right:
				C.SetPos(
					(C.ClipX * W.PosX) + (W.OffsetX - Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * XShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache),
					(C.ClipY * W.PosY) + (W.OffsetY - Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * YShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache)
					);
					C.DrawTile(
						W.WidgetTexture, 
						Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * W.TextureScale * W.Scale * ScaleYCache,  
						Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.TextureScale * ScaleYCache, 
						W.TextureCoords.X1, 
						W.TextureCoords.Y1, 
						(W.TextureCoords.X2 - W.TextureCoords.X1) * W.Scale, 
						W.TextureCoords.Y2 - W.TextureCoords.Y1
					);
				break;
				
			case SM_Left:
				C.SetPos(
					(C.ClipX * W.PosX) + (W.OffsetX - Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * XShifts[W.DrawPivot] + (Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * (1- W.Scale))) * (W.TextureScale * ScaleYCache),
					(C.ClipY * W.PosY) + (W.OffsetY - Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * YShifts[W.DrawPivot])  * (W.TextureScale * ScaleYCache)
					);
					C.DrawTile(
					W.WidgetTexture, 
					Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * W.TextureScale * W.Scale * ScaleYCache,  
					Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.TextureScale * ScaleYCache, 
					W.TextureCoords.X1	+	((W.TextureCoords.X2 - W.TextureCoords.X1) * (1-W.Scale)), 
					W.TextureCoords.Y1, 
					(W.TextureCoords.X2 - W.TextureCoords.X1) * W.Scale, 
					W.TextureCoords.Y2 - W.TextureCoords.Y1
					);
				break;
			
			case SM_Down:
				C.SetPos(
					(C.ClipX * W.PosX) + (W.OffsetX - Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * XShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache),
					(C.ClipY * W.PosY) + (W.OffsetY - Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * YShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache)
					);
					C.DrawTile(
					W.WidgetTexture, 
					Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * W.TextureScale * ScaleYCache,  
					Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.TextureScale * W.Scale * ScaleYCache, 
					W.TextureCoords.X1, 
					W.TextureCoords.Y1, 
					W.TextureCoords.X2 - W.TextureCoords.X1,
					(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.Scale
					);
				break;
				
			case SM_Up:
				C.SetPos(
					(C.ClipX * W.PosX) + (W.OffsetX - Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * XShifts[W.DrawPivot]) * (W.TextureScale * ScaleYCache),
					(C.ClipY * W.PosY) + (W.OffsetY - Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * YShifts[W.DrawPivot] + (Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * (1- W.Scale)))  * (W.TextureScale * ScaleYCache)
					);
					C.DrawTile(
					W.WidgetTexture, 
					Abs(W.TextureCoords.X2 - W.TextureCoords.X1) * W.TextureScale * ScaleYCache,  
					Abs(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.TextureScale * W.Scale * ScaleYCache, 
					W.TextureCoords.X1, 
					W.TextureCoords.Y1	+	((W.TextureCoords.Y2 - W.TextureCoords.Y1) * (1-W.Scale)), 
					W.TextureCoords.X2 - W.TextureCoords.X1,
					(W.TextureCoords.Y2 - W.TextureCoords.Y1) * W.Scale
					);
		}
	}
}

//===========================================================================
//	Draws a NumericWidget via DrawTile.
//===========================================================================
simulated final function DrawNumericWidgetAsTiles(Canvas C, NumericWidget W, DigitSet D)
{
	local String s;
	local array<String> t;
	local int padding, length, i;
	local byte coordindex;
	
	if (!bCorrectAspectRatio)
	{
		DrawNumericWidget(C, W, D);
		return;
	}
	
	C.Style = W.RenderStyle;

	s = String(W.Value);
	length = Len(s);
	
	padding= Max(0, W.MinDigitCount - length);
	
	if (W.bPadWithZeroes != 0)
		length += padding;

	for (i=0; i < length; i++)
	{
		if (W.bPadWithZeroes == 1 && i < padding)
			t[i] = "0";
		else
		{
			t[i] = "";
			EatStr(t[i], s, 1);
		}
	}
		
	C.SetPos((C.ClipX * W.PosX) + (W.OffsetX - (D.TextureCoords[0].X2 - D.TextureCoords[0].X1) * (((length + padding) * XShifts[W.DrawPivot]) - (padding * (1-W.bPadWithZeroes) )) ) * (W.TextureScale * ResScaleY *  HUDScale),
			(C.ClipY * W.PosY) + (W.OffsetY - (D.TextureCoords[0].Y2 - D.TextureCoords[0].Y1) * YShifts[W.DrawPivot])  * (W.TextureScale * ScaleYCache));
	C.DrawColor = W.Tints[TeamIndex];
	
	for (i = 0; i < length; i++)
	{
		if (t[i] == "-")
			coordindex = 10;
		else coordindex = byte(t[i]);
		
		C.DrawTile(
						D.DigitTexture,
						(D.TextureCoords[coordindex].X2 - D.TextureCoords[coordindex].X1) * W.TextureScale * ScaleYCache,  
						(D.TextureCoords[coordindex].Y2 - D.TextureCoords[coordindex].Y1) * W.TextureScale * ScaleYCache, 
						D.TextureCoords[coordindex].X1, 
						D.TextureCoords[coordindex].Y1, 
						(D.TextureCoords[coordindex].X2 - D.TextureCoords[coordindex].X1), 
						(D.TextureCoords[coordindex].Y2 - D.TextureCoords[coordindex].Y1)
						);
	}
}


//===========================================================================
// Manage HUD override.
//===========================================================================
simulated event PostRender( canvas Canvas )
{
    local float XPos, YPos;
    local plane OldModulate,OM;
    local color OldColor;
    local int i;

    BuildMOTD();

    OldModulate = Canvas.ColorModulate;
    OldColor = Canvas.DrawColor;

    Canvas.ColorModulate.X = 1;
    Canvas.ColorModulate.Y = 1;
    Canvas.ColorModulate.Z = 1;
    Canvas.ColorModulate.W = HudOpacity/255;

    LinkActors();

    ResScaleX = Canvas.SizeX / 640.0;
    ResScaleY = Canvas.SizeY / 480.0;
	
	ScaleYCache = ResScaleY * HUDScale;
	
	if (!bCorrectAspectRatio && ResScaleX/ResScaleY > 1.05)
		bCorrectAspectRatio = True;
	else if (bCorrectAspectRatio && ResScaleX / ResScaleY <= 1.05)
		bCorrectAspectRatio = False;

	CheckCountDown(PlayerOwner.GameReplicationInfo);

    if ( PawnOwner != None )
    {
		if ( !PlayerOwner.bBehindView )
		{
			if ( PlayerOwner.bDemoOwner || ((Level.NetMode == NM_Client) && (PlayerOwner.Pawn != PawnOwner)) )
				PawnOwner.GetDemoRecordingWeapon();
			else
				CanvasDrawActors( Canvas, false );
		}
		else
			CanvasDrawActors( Canvas, false );
	}

	if ( PawnOwner != None && PawnOwner.bSpecialHUD )
		PawnOwner.DrawHud(Canvas);
    if ( bShowDebugInfo )
    {
        Canvas.Font = GetConsoleFont(Canvas);
        Canvas.Style = ERenderStyle.STY_Alpha;
        Canvas.DrawColor = ConsoleColor;

        PlayerOwner.ViewTarget.DisplayDebug(Canvas, XPos, YPos);
        if (PlayerOwner.ViewTarget != PlayerOwner && (Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).Controller == None))
        {
        	YPos += XPos * 2;
        	Canvas.SetPos(4, YPos);
        	Canvas.DrawText("----- VIEWER INFO -----");
        	YPos += XPos;
        	Canvas.SetPos(4, YPos);
        	PlayerOwner.DisplayDebug(Canvas, XPos, YPos);
        }
    }
	else if( !bHideHud )
    {
        if ( bShowLocalStats )
        {
			if ( LocalStatsScreen == None )
				GetLocalStatsScreen();
            if ( LocalStatsScreen != None )
            {
            	OM = Canvas.ColorModulate;
                Canvas.ColorModulate = OldModulate;
                LocalStatsScreen.DrawScoreboard(Canvas);
				DisplayMessages(Canvas);
                Canvas.ColorModulate = OM;
			}
		}
        else if (bShowScoreBoard)
        {
            if (ScoreBoard != None)
            {
            	OM = Canvas.ColorModulate;
                Canvas.ColorModulate = OldModulate;
                ScoreBoard.DrawScoreboard(Canvas);
				if ( Scoreboard.bDisplayMessages )
					DisplayMessages(Canvas);
                Canvas.ColorModulate = OM;
			}
        }
        else
        {
			if ( (PlayerOwner == None) || (PawnOwner == None) || (PawnOwnerPRI == None) || (PlayerOwner.IsSpectating() && PlayerOwner.bBehindView) )
            	DrawSpectatingHud(Canvas);
			else if( !PawnOwner.bHideRegularHUD )
				DrawHud(Canvas);

			for (i = 0; i < Overlays.length; i++)
				Overlays[i].Render(Canvas);

            if (!DrawLevelAction (Canvas))
            {
            	if (PlayerOwner!=None)
                {
                	if (PlayerOwner.ProgressTimeOut > Level.TimeSeconds)
                    {
	                    DisplayProgressMessages (Canvas);
                    }
                    else if (MOTDState==1)
                    	MOTDState=2;
                }
           }

            if (bShowBadConnectionAlert)
                DisplayBadConnectionAlert (Canvas);
            DisplayMessages(Canvas);

        }

        if( bShowVoteMenu && VoteMenu!=None )
            VoteMenu.RenderOverlays(Canvas);
    }
    else if ( PawnOwner != None )
        DrawInstructionGfx(Canvas);


    PlayerOwner.RenderOverlays(Canvas);

    if (PlayerOwner.bViewingMatineeCinematic)
	DrawCinematicHUD(Canvas);

    if ((PlayerConsole != None) && PlayerConsole.bTyping)
        DrawTypingPrompt(Canvas, PlayerConsole.TypedStr, PlayerConsole.TypedStrPos);

    Canvas.ColorModulate=OldModulate;
    Canvas.DrawColor = OldColor;

    OnPostRender(Self, Canvas);
}
	
simulated function DrawAdrenaline( Canvas C )
{
	if ( !PlayerOwner.bAdrenalineEnabled )
		return;

	DrawWidgetAsTile( C, AdrenalineBackground );
	DrawWidgetAsTile( C, AdrenalineBackgroundDisc );

	if( CurEnergy == MaxEnergy )
	{
		DrawWidgetAsTile( C, AdrenalineAlert );
		AdrenalineAlert.Tints[TeamIndex] = HudColorHighLight;
	}

	DrawWidgetAsTile( C, AdrenalineIcon );
	DrawNumericWidgetAsTiles( C, AdrenalineCount, DigitsBig);

	if(CurEnergy > LastEnergy)
		LastAdrenalineTime = Level.TimeSeconds;

	LastEnergy = CurEnergy;
	DrawHUDAnimWidget( AdrenalineIcon, default.AdrenalineIcon.TextureScale, LastAdrenalineTime, 0.6, 0.6);
	AdrenalineBackground.Tints[TeamIndex] = HudColorBlack;
	AdrenalineBackground.Tints[TeamIndex].A = 150;

}

simulated function DrawTimer(Canvas C)
{
	local GameReplicationInfo GRI;
	local int Minutes, Hours, Seconds;

	GRI = PlayerOwner.GameReplicationInfo;

	if ( GRI.TimeLimit != 0 )
		Seconds = GRI.RemainingTime;
	else
		Seconds = GRI.ElapsedTime;

	TimerBackground.Tints[TeamIndex] = HudColorBlack;
    TimerBackground.Tints[TeamIndex].A = 150;

	DrawWidgetAsTile( C, TimerBackground);
	DrawWidgetAsTile( C, TimerBackgroundDisc);
	DrawWidgetAsTile( C, TimerIcon);

	TimerMinutes.OffsetX = default.TimerMinutes.OffsetX - 80;
	TimerSeconds.OffsetX = default.TimerSeconds.OffsetX - 80;
	TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX;
	TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX;

	if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

		DrawNumericWidgetAsTiles( C, TimerHours, DigitsBig);
        TimerHours.Value = Hours;

		if(Hours>9)
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX;
		}
		else
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX -40;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX -40;
			TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX - 32;
			TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX - 32;
		}
		DrawWidgetAsTile( C, TimerDigitSpacer[0]);
	}
	DrawWidgetAsTile( C, TimerDigitSpacer[1]);

	Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    TimerMinutes.Value = Min(Minutes, 60);
	TimerSeconds.Value = Min(Seconds, 60);

	DrawNumericWidgetAsTiles( C, TimerMinutes, DigitsBig);
	DrawNumericWidgetAsTiles( C, TimerSeconds, DigitsBig);
}


simulated function DrawUDamage( Canvas C )
{
	local xPawn P;

	if (Vehicle(PawnOwner) != None)
		P = xPawn(Vehicle(PawnOwner).Driver);
	else
		P = xPawn(PawnOwner);

	if (P != None && P.UDamageTime > Level.TimeSeconds)
	{
         if (P.UDamageTime > Level.TimeSeconds + 15 )
			UDamageIcon.TextureScale = default.UDamageIcon.TextureScale * FMin((P.UDamageTime - Level.TimeSeconds)* 0.0333,1);

         DrawWidgetAsTile(C, UDamageIcon);
         UDamageTime.Value = P.UDamageTime - Level.TimeSeconds ;
         DrawNumericWidgetAsTiles(C, UDamageTime, DigitsBig);
    }
}

simulated function DrawCrosshair (Canvas C)
{
    local float NormalScale;
    local int i, CurrentCrosshair;
    local float OldScale,OldW, CurrentCrosshairScale;
    local color CurrentCrosshairColor;
	local SpriteWidget CHtexture;

	if ( PawnOwner.bSpecialCrosshair )
	{
		PawnOwner.SpecialDrawCrosshair( C );
		return;
	}

	if (!bCrosshairShow)
        return;

	if ( bUseCustomWeaponCrosshairs && (PawnOwner != None) && (PawnOwner.Weapon != None) )
	{
		CurrentCrosshair = PawnOwner.Weapon.CustomCrosshair;
		if (CurrentCrosshair == -1 || CurrentCrosshair == Crosshairs.Length)
		{
			CurrentCrosshair = CrosshairStyle;
			CurrentCrosshairColor = CrosshairColor;
			CurrentCrosshairScale = CrosshairScale;
		}
		else
		{
			CurrentCrosshairColor = PawnOwner.Weapon.CustomCrosshairColor;
			CurrentCrosshairScale = PawnOwner.Weapon.CustomCrosshairScale;
			if ( PawnOwner.Weapon.CustomCrosshairTextureName != "" )
			{
				if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
				{
					PawnOwner.Weapon.CustomCrosshairTexture = Texture(DynamicLoadObject(PawnOwner.Weapon.CustomCrosshairTextureName,class'Texture'));
					if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
					{
						log(PawnOwner.Weapon$" custom crosshair texture not found!");
						PawnOwner.Weapon.CustomCrosshairTextureName = "";
					}
				}
				CHTexture = Crosshairs[0];
				CHTexture.WidgetTexture = PawnOwner.Weapon.CustomCrosshairTexture;
			}
		}
	}
	else
	{
		CurrentCrosshair = CrosshairStyle;
		CurrentCrosshairColor = CrosshairColor;
		CurrentCrosshairScale = CrosshairScale;
	}

	CurrentCrosshair = Clamp(CurrentCrosshair, 0, Crosshairs.Length - 1);

    NormalScale = Crosshairs[CurrentCrosshair].TextureScale;
	if ( CHTexture.WidgetTexture == None )
		CHTexture = Crosshairs[CurrentCrosshair];
    CHTexture.TextureScale *= 0.5 * CurrentCrosshairScale;

    for( i = 0; i < ArrayCount(CHTexture.Tints); i++ )
        CHTexture.Tints[i] = CurrentCrossHairColor;

	if ( LastPickupTime > Level.TimeSeconds - 0.4 )
	{
		if ( LastPickupTime > Level.TimeSeconds - 0.2 )
			CHTexture.TextureScale *= (1 + 5 * (Level.TimeSeconds - LastPickupTime));
		else
			CHTexture.TextureScale *= (1 + 5 * (LastPickupTime + 0.4 - Level.TimeSeconds));
	}
    OldScale = HudScale;
    HudScale=1;
    OldW = C.ColorModulate.W;
    C.ColorModulate.W = 1;
    DrawWidgetAsTile (C, CHTexture);
    C.ColorModulate.W = OldW;
	HudScale=OldScale;
    CHTexture.TextureScale = NormalScale;

	DrawEnemyName(C);
}

simulated function DrawChargeBar( Canvas C)
{
	local float ScaleFactor;

	ScaleFactor = HUDScale * 0.135 * C.ClipX;
	if (bCorrectAspectRatio)
		ScaleFactor *= ResScaleY / ResScaleX;
	C.Style = ERenderStyle.STY_Alpha;
	if ( (PawnOwner.PlayerReplicationInfo == None) || (PawnOwner.PlayerReplicationInfo.Team == None)
		|| (PawnOwner.PlayerReplicationInfo.Team.TeamIndex == 1) )
		C.DrawColor = HudColorBlue;
	else
		C.DrawColor = HudColorRed;

	C.SetPos(C.ClipX - ScaleFactor - 0.0011*HUDScale*C.ClipX, (1 - 0.0975*HUDScale)*C.ClipY);
	C.DrawTile( Material'HudContent.HUD', ScaleFactor, 0.223*ScaleFactor, 0, 110, 166, 53 );

	RechargeBar.Scale = FMin(PawnOwner.Weapon.ChargeBar(), 1);
	if ( RechargeBar.Scale > 0 )
	{
		DrawWidgetAsTile( C, RechargeBar);
		ShowReloadingPulse(RechargeBar.Scale);
	}
}

simulated function DrawVehicleChargeBar(Canvas C)
{
	local float ScaleFactor;

	ScaleFactor = HUDScale * 0.135 * C.ClipX;
	if (bCorrectAspectRatio)
		ScaleFactor *= ResScaleY / ResScaleX;
	C.Style = ERenderStyle.STY_Alpha;
	if ( (PawnOwner.PlayerReplicationInfo == None) || (PawnOwner.PlayerReplicationInfo.Team == None)
		|| (PawnOwner.PlayerReplicationInfo.Team.TeamIndex == 1) )
		C.DrawColor = HudColorBlue;
	else
		C.DrawColor = HudColorRed;

	C.SetPos(C.ClipX - ScaleFactor - 0.0011*HUDScale*C.ClipX, (1 - 0.0975*HUDScale)*C.ClipY);
	C.DrawTile( Material'HudContent.HUD', ScaleFactor, 0.223*ScaleFactor, 0, 110, 166, 53 );

	DrawWidgetAsTile(C, RechargeBar);
	RechargeBar.Scale = Vehicle(PawnOwner).ChargeBar();
	ShowReloadingPulse(RechargeBar.Scale);
}

simulated function DrawWeaponBar( Canvas C )
{
    local int i, Count, Pos;
    local float IconOffset;
	local float HudScaleOffset, HudMinScale;

    local Weapon Weapons[WEAPON_BAR_SIZE];
    local byte ExtraWeapon[WEAPON_BAR_SIZE];
    local Inventory Inv;
    local Weapon W, PendingWeapon;

	HudMinScale=0.5;
    //no weaponbar for vehicles
    if (Vehicle(PawnOwner) != None)
	return;

    if (PawnOwner.PendingWeapon != None)
        PendingWeapon = PawnOwner.PendingWeapon;
    else
        PendingWeapon = PawnOwner.Weapon;

	// fill:
    for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        W = Weapon( Inv );
		Count++;
		if ( Count > 100 )
			break;

        if( (W == None) || (W.IconMaterial == None) )
            continue;

		if ( W.InventoryGroup == 0 )
			Pos = 8;
		else if ( W.InventoryGroup < 10 )
			Pos = W.InventoryGroup-1;
		else
			continue;

		if ( Weapons[Pos] != None )
			ExtraWeapon[Pos] = 1;
		else
			Weapons[Pos] = W;
    }

	if ( PendingWeapon != None )
	{
		if ( PendingWeapon.InventoryGroup == 0 )
			Weapons[8] = PendingWeapon;
		else if ( PendingWeapon.InventoryGroup < 10 )
			Weapons[PendingWeapon.InventoryGroup-1] = PendingWeapon;
	}

    // Draw:
    for( i=0; i<WEAPON_BAR_SIZE; i++ )
    {
        W = Weapons[i];

		// Keep weaponbar organized when scaled
		HudScaleOffset= 1-(HudScale-HudMinScale)/HudMinScale;
		if (!bCorrectAspectRatio)
			BarBorder[i].PosX =  default.BarBorder[i].PosX +( BarBorderScaledPosition[i] - default.BarBorder[i].PosX) *HudScaleOffset;
		else
			BarBorder[i].PosX = 0.5 - ((0.5 - default.BarBorder[i].PosX) * (ResScaleY / ResScaleX) * HUDScale); 
		BarWeaponIcon[i].PosX = BarBorder[i].PosX;

		IconOffset = (default.BarBorder[i].TextureCoords.X2 - default.BarBorder[i].TextureCoords.X1) * 0.5;
		
        BarBorder[i].Tints[0] = HudColorRed;
        BarBorder[i].Tints[1] = HudColorBlue;
        BarBorder[i].OffsetY = 0;
		BarWeaponIcon[i].OffsetY = default.BarWeaponIcon[i].OffsetY;

		if( W == none )
        {
			BarWeaponStates[i].HasWeapon = false;
			if ( bShowMissingWeaponInfo )
			{
				BarWeaponIcon[i].OffsetX =  IconOffset;
				
				if ( BarWeaponIcon[i].Tints[TeamIndex] != HudColorBlack )
				{
					BarWeaponIcon[i].WidgetTexture = default.BarWeaponIcon[i].WidgetTexture;
					BarWeaponIcon[i].TextureCoords = default.BarWeaponIcon[i].TextureCoords;
					BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale;
					BarWeaponIcon[i].Tints[TeamIndex] = HudColorBlack;
					BarWeaponIconAnim[i] = 0;
				}
				DrawWidgetAsTile( C, BarBorder[i] );
				DrawWidgetAsTile( C, BarWeaponIcon[i] ); // FIXME- have combined version
			}
       }
        else
        {
			if( !BarWeaponStates[i].HasWeapon )
			{
				// just picked this weapon up!
				BarWeaponStates[i].PickupTimer = Level.TimeSeconds;
				BarWeaponStates[i].HasWeapon = true;
			}

	    	BarBorderAmmoIndicator[i].PosX = BarBorder[i].PosX;
			BarBorderAmmoIndicator[i].OffsetY = 0;
			
			BarWeaponIcon[i].WidgetTexture = W.IconMaterial;
			BarWeaponIcon[i].TextureCoords = W.IconCoords;
			
			//Cheese
			if (Abs(W.IconCoords.Y1 - W.IconCoords.Y2) > 64)
			{
				BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale / ((Abs(W.IconCoords.Y1 - W.IconCoords.Y2) + 1)/ 32);
				IconOffset *= (default.BarWeaponIcon[i].TextureScale / BarWeaponIcon[i].TextureScale);
				BarWeaponIcon[i].OffsetY = -30 * (default.BarWeaponIcon[i].TextureScale / BarWeaponIcon[i].TextureScale);
			}
			else
			{
				BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale;
				BarWeaponIcon[i].OffsetY = default.BarWeaponIcon[i].OffsetY;
			}
			
			BarWeaponIcon[i].OffsetX =  IconOffset;
			
            BarBorderAmmoIndicator[i].Scale = FMin(W.AmmoStatus(), 1);
            BarWeaponIcon[i].Tints[TeamIndex] = HudColorNormal;

			if( BarWeaponIconAnim[i] == 0 )
            {
                if ( BarWeaponStates[i].PickupTimer > Level.TimeSeconds - 0.6 )
	            {
		           if ( BarWeaponStates[i].PickupTimer > Level.TimeSeconds - 0.3 )
	               {
					   	BarWeaponIcon[i].TextureScale = BarWeaponIcon[i].TextureScale * (1 + 1.3 * (Level.TimeSeconds - BarWeaponStates[i].PickupTimer));
                        BarWeaponIcon[i].OffsetX =  IconOffset - IconOffset * ( Level.TimeSeconds - BarWeaponStates[i].PickupTimer );
                   }
                   else
                   {
					    BarWeaponIcon[i].TextureScale = BarWeaponIcon[i].TextureScale * (1 + 1.3 * (BarWeaponStates[i].PickupTimer + 0.6 - Level.TimeSeconds));
                        BarWeaponIcon[i].OffsetX = IconOffset - IconOffset * (BarWeaponStates[i].PickupTimer + 0.6 - Level.TimeSeconds);
                   }
                }
                else
                    BarWeaponIconAnim[i] = 1;
			}

            if (W == PendingWeapon)
            {
				// Change color to highlight and possibly changeTexture or animate it
				BarBorder[i].Tints[TeamIndex] = HudColorHighLight;
				BarBorder[i].OffsetY = -10;
				BarBorderAmmoIndicator[i].OffsetY = -10;
				BarWeaponIcon[i].OffsetY += -10 * (default.BarWeaponIcon[i].TextureScale / BarWeaponIcon[i].TextureScale);
			}
			
		    if ( ExtraWeapon[i] == 1 )
		    {
			    if ( W == PendingWeapon )
			    {
                    BarBorder[i].Tints[0] = HudColorRed;
                    BarBorder[i].Tints[1] = HudColorBlue;
				    BarBorder[i].OffsetY = 0;
				    BarBorder[i].TextureCoords.Y1 = 80;
				    DrawWidgetAsTile( C, BarBorder[i] );
				    BarBorder[i].TextureCoords.Y1 = 39;
				    BarBorder[i].OffsetY = -10;
				    BarBorder[i].Tints[TeamIndex] = HudColorHighLight;
			    }
			    else
			    {
				    BarBorder[i].OffsetY = -52;
				    BarBorder[i].TextureCoords.Y2 = 48;
		            DrawWidgetAsTile( C, BarBorder[i] );
				    BarBorder[i].TextureCoords.Y2 = 93;
				    BarBorder[i].OffsetY = 0;
			    }
		    }
			
			//Try to unroll this loop.
	        DrawWidgetAsTile( C, BarBorder[i] );
            DrawWidgetAsTile( C, BarBorderAmmoIndicator[i] );
            DrawWidgetAsTile( C, BarWeaponIcon[i] );
       }
    }
}

simulated function DrawSpectatingHud (Canvas C)
{
	Super(HudCDeathMatch).DrawSpectatingHud(C);

	if ( (PlayerOwner == None) || (PlayerOwner.PlayerReplicationInfo == None)
		|| !PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
		return;

	UpdateRankAndSpread(C);
	ShowTeamScorePassA(C);
	ShowTeamScorePassC(C);
	UpdateTeamHUD();
}

simulated function Tick(float deltaTime)
{
	Super(HudCDeathMatch).Tick(deltaTime);

	if (Links >0)
	{
		TeamLinked = true;
	}
	else
	{
		TeamLinked = false;
	}
}

simulated function showLinks()
{
	if ( PawnOwner.Weapon != None && PawnOwner.Weapon.IsA('LinkGun') )
		Links = LinkGun(PawnOwner.Weapon).Links;
	else
		Links = 0;
}

simulated function drawLinkText(Canvas C)
{
	text = LinkEstablishedMessage;

	C.Font = LoadLevelActionFont();
	C.DrawColor = LevelActionFontColor;

	C.DrawColor = LevelActionFontColor;
	C.Style = ERenderStyle.STY_Alpha;

	C.DrawScreenText (text, 1, 0.81, DP_LowerRight);
}

simulated function UpdateRankAndSpread(Canvas C)
{
	// making sure that the Rank and Spread dont get drawn in other gametypes
}

simulated function DrawTeamOverlay( Canvas C )
{
     // TODO: draw top 5 playersnames and Position on map
}

simulated function DrawMyScore ( Canvas C )
{
     // Dont show MyScore in team games
}
simulated function DrawHudPassA (Canvas C)
{
	local Pawn RealPawnOwner;
	local class<Ammunition> AmmoClass;

	ZoomFadeOut(C);

	if ( PawnOwner != None )
	{
		if( bShowWeaponInfo && (PawnOwner.Weapon != None) )
		{
			if ( PawnOwner.Weapon.bShowChargingBar )
    			DrawChargeBar(C);

			DrawWidgetAsTile( C, HudBorderAmmo );

			if( PawnOwner.Weapon != None )
			{
				AmmoClass = PawnOwner.Weapon.GetAmmoClass(0);
				if ( (AmmoClass != None) && (AmmoClass.Default.IconMaterial != None) )
				{
					if( (CurAmmoPrimary/MaxAmmoPrimary) < 0.15)
					{
						DrawWidgetAsTile(C, HudAmmoALERT);
						HudAmmoALERT.Tints[0] = HudColorRed;
						HudAmmoALERT.Tints[1] = HudColorBlue;
						if ( AmmoClass.Default.IconFlashMaterial == None )
							AmmoIcon.WidgetTexture = Material'HudContent.Generic.HUDPulse';
						else
							AmmoIcon.WidgetTexture = AmmoClass.Default.IconFlashMaterial;
					}
					else
					{
						AmmoIcon.WidgetTexture = AmmoClass.default.IconMaterial;
					}

					AmmoIcon.TextureCoords = AmmoClass.Default.IconCoords;
					DrawWidgetAsTile (C, AmmoIcon);
				}
			}
			DrawNumericWidgetAsTiles( C, DigitsAmmo, DigitsBig);
		}

		if ( bShowWeaponBar && (PawnOwner.Weapon != None) )
			DrawWeaponBar(C);

		if( bShowPersonalInfo )
		{
    		if ( Vehicle(PawnOwner) != None && Vehicle(PawnOwner).Driver != None )
    		{
    			if (Vehicle(PawnOwner).bShowChargingBar)
    				DrawVehicleChargeBar(C);
    			RealPawnOwner = PawnOwner;
    			PawnOwner = Vehicle(PawnOwner).Driver;
    		}

			DrawHUDAnimWidget( HudBorderHealthIcon, default.HudBorderHealthIcon.TextureScale, LastHealthPickupTime, 0.6, 0.6);
			DrawWidgetAsTile( C, HudBorderHealth );

			if(CurHealth/PawnOwner.HealthMax < 0.26)
			{
				HudHealthALERT.Tints[0] = HudColorRed;
				HudHealthALERT.Tints[1] = HudColorBlue;
				DrawWidgetAsTile( C, HudHealthALERT);
				HudBorderHealthIcon.WidgetTexture = Material'HudContent.Generic.HUDPulse';
			}
			else
				HudBorderHealthIcon.WidgetTexture = default.HudBorderHealth.WidgetTexture;

			DrawWidgetAsTile( C, HudBorderHealthIcon);

			if( CurHealth < LastHealth )
				LastDamagedHealth = Level.TimeSeconds;

			DrawHUDAnimDigit( DigitsHealth, default.DigitsHealth.TextureScale, LastDamagedHealth, 0.8, default.DigitsHealth.Tints[TeamIndex], HudColorHighLight);
			DrawNumericWidgetAsTiles( C, DigitsHealth, DigitsBig);

			if(CurHealth > 999)
			{
				DigitsHealth.OffsetX=220;
				DigitsHealth.OffsetY=-35;
				DigitsHealth.TextureScale=0.39;
			}
			else
			{
				DigitsHealth.OffsetX = default.DigitsHealth.OffsetX;
				DigitsHealth.OffsetY = default.DigitsHealth.OffsetY;
				DigitsHealth.TextureScale = default.DigitsHealth.TextureScale;
			}

			if (RealPawnOwner != None)
			{
				PawnOwner = RealPawnOwner;

				DrawWidgetAsTile( C, HudBorderVehicleHealth );

				if (CurVehicleHealth/PawnOwner.HealthMax < 0.26)
				{
					HudVehicleHealthALERT.Tints[0] = HudColorRed;
					HudVehicleHealthALERT.Tints[1] = HudColorBlue;
					DrawWidgetAsTile(C, HudVehicleHealthALERT);
					HudBorderVehicleHealthIcon.WidgetTexture = Material'HudContent.Generic.HUDPulse';
				}
				else
					HudBorderVehicleHealthIcon.WidgetTexture = default.HudBorderVehicleHealth.WidgetTexture;

				DrawWidgetAsTile(C, HudBorderVehicleHealthIcon);

				if (CurVehicleHealth < LastVehicleHealth )
					LastDamagedVehicleHealth = Level.TimeSeconds;

				DrawHUDAnimDigit(DigitsVehicleHealth, default.DigitsVehicleHealth.TextureScale, LastDamagedVehicleHealth, 0.8, default.DigitsVehicleHealth.Tints[TeamIndex], HudColorHighLight);
				DrawNumericWidgetAsTiles(C, DigitsVehicleHealth, DigitsBig);

				if (CurVehicleHealth > 999)
				{
					DigitsVehicleHealth.OffsetX = 445;
					DigitsVehicleHealth.OffsetY = -35;
					DigitsVehicleHealth.TextureScale = 0.39;
				}
				else
				{
					DigitsVehicleHealth.OffsetX = default.DigitsVehicleHealth.OffsetX;
					DigitsVehicleHealth.OffsetY = default.DigitsVehicleHealth.OffsetY;
					DigitsVehicleHealth.TextureScale = default.DigitsVehicleHealth.TextureScale;
				}
			}

			DrawAdrenaline(C);
		}
	}

	UpdateRankAndSpread(C);
    DrawUDamage(C);

    if(bDrawTimer)
		DrawTimer(C);

    // Temp Draw with Hud Colors
    HudBorderShield.Tints[0] = HudColorRed;
    HudBorderShield.Tints[1] = HudColorBlue;
    HudBorderHealth.Tints[0] = HudColorRed;
    HudBorderHealth.Tints[1] = HudColorBlue;
    HudBorderVehicleHealth.Tints[0] = HudColorRed;
    HudBorderVehicleHealth.Tints[1] = HudColorBlue;
    HudBorderAmmo.Tints[0] = HudColorRed;
    HudBorderAmmo.Tints[1] = HudColorBlue;

    if( bShowPersonalInfo && (CurShield > 0) )
    {
	    DrawWidgetAsTile( C, HudBorderShield );
		DrawWidgetAsTile( C, HudBorderShieldIcon);
		DrawNumericWidgetAsTiles( C, DigitsShield, DigitsBig);
		DrawHUDAnimWidget( HudBorderShieldIcon, default.HudBorderShieldIcon.TextureScale, LastArmorPickupTime, 0.6, 0.6);
    }

	if( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
		DisplayVoiceGain(C);

    DisplayLocalMessages (C);
	UpdateRankAndSpread(C);
	ShowTeamScorePassA(C);

	if ( Links >0 )
	{
		DrawWidgetAsTile (C, LinkIcon);
	    DrawNumericWidgetAsTiles (C, totalLinks, DigitsBigPulse);
	}
	totalLinks.value = Links;
}

simulated function ShowTeamScorePassA(Canvas C)
{
	if ( bShowPoints )
	{
		DrawWidgetAsTile (C, TeamScoreBackground[0]);
		DrawWidgetAsTile (C, TeamScoreBackground[1]);
		DrawWidgetAsTile (C, TeamScoreBackgroundDisc[0]);
		DrawWidgetAsTile (C, TeamScoreBackgroundDisc[1]);

        TeamScoreBackground[0].Tints[TeamIndex] = HudColorBlack;
        TeamScoreBackground[0].Tints[TeamIndex].A = 150;
        TeamScoreBackground[1].Tints[TeamIndex] = HudColorBlack;
        TeamScoreBackground[1].Tints[TeamIndex].A = 150;


		if (TeamSymbols[0].WidgetTexture != None)
			DrawWidgetAsTile (C, TeamSymbols[0]);

		if (TeamSymbols[1].WidgetTexture != None)
			DrawWidgetAsTile (C, TeamSymbols[1]);

        ShowVersusIcon(C);
	 	DrawNumericWidgetAsTiles (C, ScoreTeam[0], DigitsBig);
		DrawNumericWidgetAsTiles (C, ScoreTeam[1], DigitsBig);
	}
}

simulated function ShowVersusIcon(Canvas C)
{
	DrawWidgetAsTile (C, VersusSymbol );
}

simulated function ShowTeamScorePassC(Canvas C);
simulated function TeamScoreOffset();

// Alpha Pass ==================================================================================
simulated function DrawHudPassC (Canvas C)
{
    Super(HudCDeathMatch).DrawHudPassC (C);
	ShowTeamScorePassC(C);
}

// Alternate Texture Pass ======================================================================

simulated function UpdateTeamHud()
{
    local GameReplicationInfo GRI;
    local int i;

	GRI = PlayerOwner.GameReplicationInfo;

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

simulated function UpdateHud()
{
	UpdateTeamHUD();
	showLinks();
    Super(HudCDeathMatch).UpdateHud();
}

function bool CustomHUDColorAllowed()
{
	return false;
}

defaultproperties
{
     XShifts(1)=0.500000
     XShifts(2)=1.000000
     XShifts(3)=1.000000
     XShifts(4)=1.000000
     XShifts(5)=0.500000
     XShifts(8)=0.500000
     YShifts(3)=0.500000
     YShifts(4)=1.000000
     YShifts(5)=1.000000
     YShifts(6)=1.000000
     YShifts(7)=0.500000
     YShifts(8)=0.500000
     bCorrectAspectRatio=True
     DigitsVehicleHealth=(PosX=0.000000,OffsetX=357)
     HudVehicleHealthALERT=(PosX=0.000000,OffsetX=168)
     HudBorderVehicleHealth=(PosX=0.000000,OffsetX=168)
     HudBorderVehicleHealthIcon=(PosX=0.000000,OffsetX=173)
     BarWeaponIcon(0)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(1)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(2)=(DrawPivot=DP_MiddleMiddle,OffsetY=-25)
     BarWeaponIcon(3)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(4)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(5)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(6)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(7)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
     BarWeaponIcon(8)=(DrawPivot=DP_MiddleMiddle,OffsetY=-30)
}
