// GUN GAME GAMEMODE
//  Made by @Pebbers#9558, @TheyCallMeSpy#1337, @sal#3261 and @Edorion#1761
//  Remake By Neko, 雪落, black201
//
//  This is a modified version of the TDM made so we can have weapon upgrade, balancing when you're not good enough, etc
//  Have fun !!


global function Cl_GunGame_Init

global function ServerCallback_GunGame_DoAnnouncement
global function ServerCallback_GunGame_SetSelectedLocation
global function ServerCallback_GunGame_DoLocationIntroCutscene
global function ServerCallback_GunGame_DoVictoryAnnounce
global function ServerCallback_GunGame_PlayerKilled
global function ServerCallback_GunGame_DoCountDown

global function Cl_RegisterLocation_GunGame


//Victory related
global function ServerCallback_GunGame_AddWinningSquadData
global function ServerCallback_GunGame_MatchEndAnnouncement

//UI update
global function ServerCallback_UpdateAllPlayerLatency
global function MakeLatencyRUI

var BLACKBAR_RUI


global bool shouldShowLatency = false



struct {
    //Game related
    LocationSettings_GunGame &selectedLocation
    array choices
    array<LocationSettings_GunGame> LocationSettings_GunGame
    var scoreRui
	var latencyRui
	array<int> allLatencies

    //Victory related
    SquadSummaryData squadSummaryData
    SquadSummaryData winnerSquadSummaryData
    vector victorySequencePosition = < 0, 0, 10000 >
  	vector victorySequenceAngles = < 0, 0, 0 >
  	float  victorySunIntensity = 1.0
  	float  victorySkyIntensity = 1.0
  	var    victoryRui = null
  	bool IsShowingVictorySequence = false

} file;

struct PlayerInfo 
{
	string name
	int team
	int score
	int latency = -1
}



void function Cl_GunGame_Init()
{
}

void function Cl_RegisterLocation_GunGame(LocationSettings_GunGame LocationSettings_GunGame)
{
    file.LocationSettings_GunGame.append(LocationSettings_GunGame)
}


void function MakeScoreRUI()
{
    if ( file.scoreRui != null)
    {
        RuiSetString( file.scoreRui, "messageText", "正在初始化计分板..." )
        return
    }
    clGlobal.levelEnt.EndSignal( "CloseScoreRUI" )

    UISize screenSize = GetScreenSize()
    var screenAlignmentTopo = RuiTopology_CreatePlane( <( screenSize.width * 0.25),( screenSize.height * 0.0 ), 0>, <float( screenSize.width ), 0, 0>, <0, float( screenSize.height ), 0>, false )
    var rui = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopo, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )

    RuiSetGameTime( rui, "startTime", Time() )

	string msg = ""
	foreach(player in GetPlayerArray())
    {
        msg = msg + "    " + player.GetPlayerName() + ": " + "0" + "\n"
    }
    RuiSetString( rui, "messageText", msg)
    RuiSetString( rui, "messageSubText", "Text 2")
    RuiSetFloat( rui, "duration", 9999999 )
    RuiSetFloat3( rui, "eventColor", SrgbToLinear( <128, 188, 255> ) )

    file.scoreRui = rui

    OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroy( rui )
			file.scoreRui = null
		}
	)

    WaitForever()
}


void function MakeLatencyRUI()
{
    if ( file.latencyRui != null)
    {
        RuiSetString( file.latencyRui, "messageText", "-1ms" )
        return
    }
    clGlobal.levelEnt.EndSignal( "CloseScoreRUI" )

    UISize screenSize = GetScreenSize()
    var screenAlignmentTopo = RuiTopology_CreatePlane( <( screenSize.width * 0.395 ),( screenSize.height * 0.0 ), 0>, <float( screenSize.width ), 0, 0>, <0, float( screenSize.height ), 0>, false )
    var rui = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopo, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )

    RuiSetGameTime( rui, "startTime", Time() )

	string msg = ""
    RuiSetString( rui, "messageText", msg)
    RuiSetString( rui, "messageSubText", "Text 2")
    RuiSetFloat( rui, "duration", 9999999 )
    RuiSetFloat3( rui, "eventColor", SrgbToLinear( <128, 188, 255> ) )

    file.latencyRui = rui

    OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroy( rui )
			file.latencyRui = null
		}
	)

    WaitForever()
}

//upadate latency UI
void function ServerCallback_UpdateAllPlayerLatency()
{
	if(file.latencyRui) {
		
		if(!shouldShowLatency) return

		array<PlayerInfo> playersInfo = []
        foreach(player in GetPlayerArray())
        {
            PlayerInfo p
            p.name = player.GetPlayerName()
            p.team = player.GetTeam()
            p.score = GameRules_GetTeamScore(p.team)
			p.latency = player.GetPlayerNetInt("latency")
            //PlayerInfo p = { name = player.GetPlayerName(), team = player.GetTeam(), score = GameRules_GetTeamScore(player.GetTeam()) }
            //printt("playername : " + p.name + "  score : " + p.score)
			playersInfo.append(p)
        }

        
        playersInfo.sort(ComparePlayerInfo)

        string msg = ""

        for(int i = 0; i < playersInfo.len(); i++)
	    {	
		    PlayerInfo p = playersInfo[i]
        	//printt("playername : " + p.name + "  score : " + p.score)
            msg = msg + p.latency + "ms" + "\n"       
        }

		RuiSetString( file.latencyRui, "messageText", msg);
	}
}

void function ServerCallback_GunGame_DoAnnouncement(float duration, int type)
{
    string message = ""
    string subtext = ""
    switch(type)
    {

        case eGUNGAMEAnnounce.ROUND_START:
        {
            thread MakeScoreRUI();
			thread MakeLatencyRUI();
            message = "回合开始！"
			subtext = ""
            break
        }
        case eGUNGAMEAnnounce.VOTING_PHASE:
        {
            clGlobal.levelEnt.Signal( "CloseScoreRUI" )
            message = "欢迎来到军备竞赛!"
			subtext = ""
            break
        }
        case eGUNGAMEAnnounce.MAP_FLYOVER:
        {

            if(file.LocationSettings_GunGame.len())
                message = file.selectedLocation.name
			subtext = "第一个使用最终武器击杀获得胜利！"
            break
        }
		case eGUNGAMEAnnounce.WINNERWARNING:
        {
        	message = "已经有人拥有了P2020"
			subtext = "Tips:使用近战攻击击杀该玩家可让其武器回滚"
            break
        }
    }
	AnnouncementData announcement = Announcement_Create( message )
    Announcement_SetSubText(announcement, subtext)
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING )
	Announcement_SetPurge( announcement, true )
	Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	announcement.duration = duration
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}


void function ServerCallback_GunGame_DoCountDown(int timeToWait)
{
    string message = ""
    string subtext = ""

    //message = "Game starting in " + timeToWait
	message = "游戏即将开始于 " + timeToWait
	subtext = ""


	AnnouncementData announcement = Announcement_Create( message )
    Announcement_SetSubText(announcement, subtext)
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	Announcement_SetPurge( announcement, true )
	Announcement_SetOptionalTextArgsArray( announcement, [ "true" ] )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	announcement.duration = 0.9
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}


void function ServerCallback_GunGame_DoLocationIntroCutscene()
{
    thread ServerCallback_GunGame_DoLocationIntroCutscene_Body()
}

//fixed by neko,雪落,black201
void function ServerCallback_GunGame_DoLocationIntroCutscene_Body()
{
	entity player = GetLocalClientPlayer()
    float desiredSpawnSpeed = Deathmatch_GetIntroSpawnSpeed()
    float desiredSpawnDuration = Deathmatch_GetIntroCutsceneSpawnDuration()
    float desireNoSpawns = Deathmatch_GetIntroCutsceneNumSpawns()

    if(!IsValid(player)) return
    EmitSoundOnEntity( player, "music_skyway_04_smartpistolrun" )
    
    entity camera = CreateClientSidePointCamera(file.selectedLocation.spawns[0].origin + file.selectedLocation.cinematicCameraOffset, <90, 90, 0>, 17)
    camera.SetFOV(90)
    
    entity cutsceneMover = CreateClientsideScriptMover($"mdl/dev/empty_model.rmdl", file.selectedLocation.spawns[0].origin + file.selectedLocation.cinematicCameraOffset, <90, 90, 0>)
    camera.SetParent(cutsceneMover)
    wait 1

	GetLocalClientPlayer().SetMenuCameraEntity( camera )
    ////////////////////////////////////////////////////////////////////////////////
    ///////// EFFECTIVE CUTSCENE CODE START

    array<LocPair_GunGame> cutsceneSpawns
    for(int i = 0; i < desireNoSpawns; i++)
    {
        if(!cutsceneSpawns.len())
            cutsceneSpawns = clone file.selectedLocation.spawns

        LocPair_GunGame spawn = cutsceneSpawns.getrandom()
        cutsceneSpawns.fastremovebyvalue(spawn)

        cutsceneMover.SetOrigin(spawn.origin)
        camera.SetAngles(spawn.angles)

        cutsceneMover.NonPhysicsMoveTo(spawn.origin + AnglesToForward(spawn.angles) * desiredSpawnDuration * desiredSpawnSpeed, desiredSpawnDuration, 0, 0)
        wait desiredSpawnDuration
    }


    ///////// EFFECTIVE CUTSCENE CODE END
    ////////////////////////////////////////////////////////////////////////////////


    GetLocalClientPlayer().ClearMenuCameraEntity()
    cutsceneMover.Destroy()

    if(IsValid(player))
        FadeOutSoundOnEntity( player, "music_skyway_04_smartpistolrun", 1 )
    
    camera.Destroy()
}

void function ServerCallback_GunGame_SetSelectedLocation(int sel)
{
    file.selectedLocation = file.LocationSettings_GunGame[sel]
}

void function ServerCallback_GunGame_PlayerKilled()
{
    if(file.scoreRui) {
		
		if(!shouldShowLatency)
		{
			shouldShowLatency = true
		}

		array<PlayerInfo> playersInfo = []
        foreach(player in GetPlayerArray())
        {
            PlayerInfo p
            p.name = player.GetPlayerName()
            p.team = player.GetTeam()
            p.score = GameRules_GetTeamScore(p.team)
			p.latency = player.GetPlayerNetInt("latency")
            //PlayerInfo p = { name = player.GetPlayerName(), team = player.GetTeam(), score = GameRules_GetTeamScore(player.GetTeam()) }
            //printt("playername : " + p.name + "  score : " + p.score)
			playersInfo.append(p)
        }

        
        playersInfo.sort(ComparePlayerInfo)

        string msg = ""

        for(int i = 0; i < playersInfo.len(); i++)
	    {	
		    PlayerInfo p = playersInfo[i]
        	//printt("playername : " + p.name + "  score : " + p.score)
            switch(i)
            {
                case 0:
                    msg = msg + "1st " + p.name + ": " + p.score + "\n" 
                    break
                case 1:
                    msg = msg + "2nd " + p.name + ": " + p.score + "\n"
                    break
                case 2:
                    msg = msg + "3rd " + p.name + ": " + p.score + "\n"
                    break
                default:
                    msg = msg + "     " + p.name + ": " + p.score + "\n"
                    break

            }
            
        }

		RuiSetString( file.scoreRui, "messageText", msg);
	}
	
}

int function ComparePlayerInfo(PlayerInfo a, PlayerInfo b)
{
	if(a.score < b.score) return 1;
	else if(a.score > b.score) return -1;
	return 0; 
}

/*
void function ServerCallback_GunGame_GetAllPlayerLatency(int playerCount, int playerIndex, float latency)
{
	playersInfo[playerIndex].latency = latency

	if(playerIndex == playerCount)
		ServerCallback_GunGame_PlayerKilled(true)
}
*/

var function CreateTemporarySpawnRUI(entity parentEnt, float duration)
{
	var rui = AddOverheadIcon( parentEnt, RESPAWN_BEACON_ICON, false, $"ui/overhead_icon_respawn_beacon.rpak" )
	RuiSetFloat2( rui, "iconSize", <80,80,0> )
	RuiSetFloat( rui, "distanceFade", 50000 )
	RuiSetBool( rui, "adsFade", true )
	RuiSetString( rui, "hint", "SPAWN POINT" )

    wait duration

    parentEnt.Destroy()
}

void function CreateBlackBars() {
    BLACKBAR_RUI = CreateFullscreenRui( $"ui/death_screen_black_bar.rpak", 1000 )
}

void function DestroyBlackBars() {
    if (BLACKBAR_RUI != null) RuiDestroyIfAlive(BLACKBAR_RUI)
    BLACKBAR_RUI = null
}








//
//
// VICTORY SCREEN
//
//

//Thanks to @Pebbers#9558 for extracting this code from br !!!


struct VictorySoundPackage
{
	string youAreChampPlural
	string youAreChampSingular
	string theyAreChampPlural
	string theyAreChampSingular
}

struct VictoryCameraPackage
{
	vector camera_offset_start
	vector camera_offset_end
	vector camera_focus_offset
	float  camera_fov
}

array<void functionref( bool )> s_callbacks_OnUpdateShowButtonHints
array<void functionref( entity, ItemFlavor, int )> s_callbacks_OnVictoryCharacterModelSpawned

void function ServerCallback_GunGame_AddWinningSquadData( int index, int eHandle)
{
	if ( index == -1 )
	{
		file.winnerSquadSummaryData.playerData.clear()
		file.winnerSquadSummaryData.squadPlacement = -1
		return
	}

	SquadSummaryPlayerData data
	data.eHandle = eHandle
	file.winnerSquadSummaryData.playerData.append( data )
	file.winnerSquadSummaryData.squadPlacement = 1
}

void function ServerCallback_GunGame_DoVictoryAnnounce(int winnerTeam) {
  if ( file.victoryRui != null )
		return

    string message = ""

	asset ruiAsset = GetChampionScreenRuiAsset()
	file.victoryRui = CreateFullscreenRui( ruiAsset )
	RuiSetBool( file.victoryRui, "onWinningTeam",  GetLocalClientPlayer().GetTeam() == winnerTeam)
    //RuiSetString(file.victoryRui, "messageText", message);
    //RuiSetFloat( file.victoryRui, "duration", duration )
    //RuiSetFloat3( file.victoryRui, "eventColor", SrgbToLinear( <128, 188, 255> ) )


	EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_ChampionVictory" )

    thread DestroyVictoryRui()
}

void function DestroyVictoryRui()
{
    wait 5
    RuiDestroy( file.victoryRui )
    file.victoryRui = null
}

void function ServerCallback_GunGame_MatchEndAnnouncement( bool victory, int winningTeam )
{
	clGlobal.levelEnt.Signal( "SquadEliminated" )

	CreateBlackBars()
	entity clientPlayer = GetLocalClientPlayer()
	Assert( IsValid( clientPlayer ) )

	GunGame_ShowChampionVictoryScreen( winningTeam )
}

void function GunGame_ShowChampionVictoryScreen( int winningTeam )
{
	if ( file.victoryRui != null )
		return

	entity clientPlayer = GetLocalClientPlayer()

	//
	HideGladiatorCardSidePane( true )

	asset ruiAsset = GetChampionScreenRuiAsset()
	file.victoryRui = CreateFullscreenRui( ruiAsset )
    printl("VICTORY RUI " + file.victoryRui)
	RuiSetBool( file.victoryRui, "onWinningTeam", GetLocalClientPlayer().GetTeam() == winningTeam )

	EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_ChampionVictory" )

	Chroma_VictoryScreen()
}

asset function GetChampionScreenRuiAsset()
{
	return $"ui/champion_screen.rpak"
}

void function VictorySequenceOrderLocalPlayerFirst( entity player )
{
	int playerEHandle = player.GetEncodedEHandle()
	bool hadLocalPlayer = false
	array<SquadSummaryPlayerData> playerDataArray
	SquadSummaryPlayerData localPlayerData

	foreach( SquadSummaryPlayerData data in file.winnerSquadSummaryData.playerData )
	{
		if ( data.eHandle == playerEHandle )
		{
			localPlayerData = data
			hadLocalPlayer = true
			continue
		}

		playerDataArray.append( data )
	}

	file.winnerSquadSummaryData.playerData = playerDataArray
	if ( hadLocalPlayer )
		file.winnerSquadSummaryData.playerData.insert( 0, localPlayerData )
}


void function ShowVictorySequence( bool placementMode = false )
{
    printl("RUI: " + file.victoryRui)
    if ( file.victoryRui != null ) {
        printl("DESTROYING RUI")
    	RuiDestroyIfAlive( file.victoryRui )
    }

    file.victoryRui = null

	#if(!DEV)
		placementMode = false
	#endif

	entity player = GetLocalClientPlayer()

	player.EndSignal( "OnDestroy" )

	#if(true)
		array<int> offsetArray = [90, 78, 78, 90, 90, 78, 78, 90, 90, 78]
	#endif

	//
	ScreenFade( player, 255, 255, 255, 255, 0.4, 2.0, FFADE_OUT | FFADE_PURGE )

	EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_ChampionMountain_Whoosh" )

	wait 0.4

	file.IsShowingVictorySequence = true
    DestroyBlackBars()
	DeathScreenUpdate()


	HideGladiatorCardSidePane( true )
	Signal( player, "Bleedout_StopBleedoutEffects" )

	ScreenFade( player, 255, 255, 255, 255, 0.4, 0.0, FFADE_IN | FFADE_PURGE )

	//
	asset defaultModel                = GetGlobalSettingsAsset( DEFAULT_PILOT_SETTINGS, "bodyModel" )
	LoadoutEntry loadoutSlotCharacter = Loadout_CharacterClass()
	vector characterAngles            = < file.victorySequenceAngles.x / 2.0, file.victorySequenceAngles.y, file.victorySequenceAngles.z >

	array<entity> cleanupEnts
	array<var> overHeadRuis

	//
	VictoryPlatformModelData victoryPlatformModelData = GetVictorySequencePlatformModel()
	entity platformModel
	int maxPlayersToShow = -1
	if ( victoryPlatformModelData.isSet )
	{
		platformModel = CreateClientSidePropDynamic( file.victorySequencePosition + victoryPlatformModelData.originOffset, victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
		#if(true)
			entity platformModel2 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -284, 1000, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
			entity platformModel3 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -284, 0, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )					//
			entity platformModel4 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -500, 200, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
			entity platformModel5 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, -284, 500, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
			entity platformModel6 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, 0, 500, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )					//
			entity platformModel7 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, 300, 300, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
			entity platformModel8 = CreateClientSidePropDynamic( PositionOffsetFromEnt( platformModel, 0, 1000, 0 ), victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
			cleanupEnts.append( platformModel2 )
			cleanupEnts.append( platformModel3 )
			cleanupEnts.append( platformModel4 )
			cleanupEnts.append( platformModel5 )
			cleanupEnts.append( platformModel6 )
			cleanupEnts.append( platformModel7 )
			cleanupEnts.append( platformModel8 )
			maxPlayersToShow = 16
		#endif //

		cleanupEnts.append( platformModel )
		int playersOnPodium = 0

		//
		VictorySequenceOrderLocalPlayerFirst( player )

		foreach( int i, SquadSummaryPlayerData data in file.winnerSquadSummaryData.playerData )
		{
			if ( maxPlayersToShow > 0 && i > maxPlayersToShow )
				break

			string playerName = ""
			if ( EHIHasValidScriptStruct( data.eHandle ) )
				playerName = EHI_GetName( data.eHandle )

			if ( !LoadoutSlot_IsReady( data.eHandle, loadoutSlotCharacter ) )
				continue

			ItemFlavor character = LoadoutSlot_GetItemFlavor( data.eHandle, loadoutSlotCharacter )

			if ( !LoadoutSlot_IsReady( data.eHandle, Loadout_CharacterSkin( character ) ) )
				continue

			ItemFlavor characterSkin = LoadoutSlot_GetItemFlavor( data.eHandle, Loadout_CharacterSkin( character ) )

			vector pos = GetVictorySquadFormationPosition( file.victorySequencePosition, file.victorySequenceAngles, i )

			//
			entity characterNode = CreateScriptRef( pos, characterAngles )
			characterNode.SetParent( platformModel, "", true )
			entity characterModel = CreateClientSidePropDynamic( pos, characterAngles, defaultModel )
			SetForceDrawWhileParented( characterModel, true )
			characterModel.MakeSafeForUIScriptHack()
			CharacterSkin_Apply( characterModel, characterSkin )
			cleanupEnts.append( characterModel )

			//
			foreach( func in s_callbacks_OnVictoryCharacterModelSpawned )
				func( characterModel, character, data.eHandle )

			//
			characterModel.SetParent( characterNode, "", false )
			string victoryAnim = GetVictorySquadFormationActivity( i, characterModel )
			characterModel.Anim_Play( victoryAnim )
			characterModel.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()


			#if R5DEV
				if ( GetBugReproNum() == 1111 || GetBugReproNum() == 2222 )
				{
					playersOnPodium++
					continue
				}
			#endif

			//
			bool createOverheadRui = true
			if ( createOverheadRui )
			{
				int offset = 78

				entity overheadEnt = CreateClientSidePropDynamic( pos + (AnglesToUp( file.victorySequenceAngles ) * offset), <0, 0, 0>, $"mdl/dev/empty_model.rmdl" )
				overheadEnt.Hide()
				var overheadRui = RuiCreate( $"ui/winning_squad_member_overhead_name.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
				RuiSetString( overheadRui, "playerName", playerName )
				RuiTrackFloat3( overheadRui, "position", overheadEnt, RUI_TRACK_ABSORIGIN_FOLLOW )
				overHeadRuis.append( overheadRui )
			}

			playersOnPodium++
		}

		//
		VictorySoundPackage victorySoundPackage = GetVictorySoundPackage()
		string dialogueApexChampion
		if ( player.GetTeam() == GetWinningTeam() )
		{
			//
			if ( playersOnPodium > 1 )
				dialogueApexChampion = victorySoundPackage.youAreChampPlural
			else
				dialogueApexChampion = victorySoundPackage.youAreChampSingular
		}
		else
		{
			if ( playersOnPodium > 1 )
				dialogueApexChampion = victorySoundPackage.theyAreChampPlural
			else
				dialogueApexChampion = victorySoundPackage.theyAreChampSingular
		}

		EmitSoundOnEntityAfterDelay( platformModel, dialogueApexChampion, 0.5 )

		//
		VictoryCameraPackage victoryCameraPackage = GetVictoryCameraPackage()

		vector camera_offset_start = victoryCameraPackage.camera_offset_start
		vector camera_offset_end   = victoryCameraPackage.camera_offset_end
		vector camera_focus_offset = victoryCameraPackage.camera_focus_offset
		float camera_fov           = victoryCameraPackage.camera_fov

		vector camera_start_pos = OffsetPointRelativeToVector( file.victorySequencePosition, camera_offset_start, AnglesToForward( file.victorySequenceAngles ) )
		vector camera_end_pos   = OffsetPointRelativeToVector( file.victorySequencePosition, camera_offset_end, AnglesToForward( file.victorySequenceAngles ) )
		vector camera_focus_pos = OffsetPointRelativeToVector( file.victorySequencePosition, camera_focus_offset, AnglesToForward( file.victorySequenceAngles ) )

		vector camera_start_angles = VectorToAngles( camera_focus_pos - camera_start_pos )
		vector camera_end_angles   = VectorToAngles( camera_focus_pos - camera_end_pos )

		entity cameraMover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", camera_start_pos, camera_start_angles )
		entity camera      = CreateClientSidePointCamera( camera_start_pos, camera_start_angles, camera_fov )
		player.SetMenuCameraEntity( camera )
		camera.SetTargetFOV( camera_fov, true, EASING_CUBIC_INOUT, 0.0 )
		camera.SetParent( cameraMover, "", false )
		cleanupEnts.append( camera )

		//
		GetLightEnvironmentEntity().ScaleSunSkyIntensity( file.victorySunIntensity, file.victorySkyIntensity )

		//
		float camera_move_duration = 6.5
		cameraMover.NonPhysicsMoveTo( camera_end_pos, camera_move_duration, 0.0, camera_move_duration / 2.0 )
		cameraMover.NonPhysicsRotateTo( camera_end_angles, camera_move_duration, 0.0, camera_move_duration / 2.0 )
		cleanupEnts.append( cameraMover )

		wait camera_move_duration - 0.5
	}

	file.IsShowingVictorySequence = false

	Assert( !IsSquadDataPersistenceEmpty(), "Persistence didn't get transmitted to the client in time!" )
	SetSquadDataToLocalTeam()    //

	wait 1.0

    ScreenFade( player, 255, 255, 255, 255, 0.4, 2.0, FFADE_OUT | FFADE_PURGE )
	foreach( rui in overHeadRuis )
		RuiDestroyIfAlive( rui )

	foreach( entity ent in cleanupEnts )
		ent.Destroy()

	wait 1
	ScreenFade( player, 255, 255, 255, 255, 0.4, 0.0, FFADE_IN | FFADE_PURGE )
}



vector function GetVictorySquadFormationPosition( vector mainPosition, vector angles, int index )
{
	if ( index == 0 )
		return mainPosition - <0, 0, 8>

	float offset_side = 48.0
	float offset_back = -28.0

	#if(false)
				if ( index < 7 )
				{
					offset_side = 48.0
					offset_back = -48.0
				}
				else if ( index == 7 )
					return OffsetPointRelativeToVector( mainPosition, <24, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 8 )
					return OffsetPointRelativeToVector( mainPosition, <48, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 9 )
					return OffsetPointRelativeToVector( mainPosition, <72, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 10 )
					return OffsetPointRelativeToVector( mainPosition, <96, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 11 )
					return OffsetPointRelativeToVector( mainPosition, <120, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 12 )
					return OffsetPointRelativeToVector( mainPosition, <-24, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 13 )
					return OffsetPointRelativeToVector( mainPosition, <-48, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 14 )
					return OffsetPointRelativeToVector( mainPosition, <-96, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 15 )
					return OffsetPointRelativeToVector( mainPosition, <-120, 16, -8>, AnglesToForward( angles ) )
				else if ( index == 16 )
					return OffsetPointRelativeToVector( mainPosition, <12, 32, -8>, AnglesToForward( angles ) )

			else
			{
				if ( index > 2 )
				{
					//
					offset_side = 56.0
					offset_back = -28.0

				}
			}


	#endif //

	int countBack = (index + 1) / 2
	vector offset = < offset_side, offset_back, 0 > * countBack

	if ( index % 2 == 0 )
		offset.x *= -1

	vector point = OffsetPointRelativeToVector( mainPosition, offset, AnglesToForward( angles ) )
	return point - <0, 0, 8>
}

string function GetVictorySquadFormationActivity( int index, entity characterModel )
{
	#if(false)
		bool animExists = characterModel.LookupSequence( "ACT_VICTORY_DANCE" ) != -1
		if ( animExists )
			return "ACT_VICTORY_DANCE"
		else
		{
			Assert( characterModel.LookupSequence( "ACT_MP_MENU_LOBBY_SELECT_IDLE" ) != -1, "Unable to find victory idle for " + characterModel )
			return "ACT_MP_MENU_LOBBY_SELECT_IDLE"
		}
	#endif //

	return "ACT_MP_MENU_LOBBY_SELECT_IDLE"
}

VictoryCameraPackage function GetVictoryCameraPackage()
{
	VictoryCameraPackage victoryCameraPackage

	#if(false)

		if ( true )
		{
			victoryCameraPackage.camera_offset_start = <0, 725, 100>
			victoryCameraPackage.camera_offset_end = <0, 400, 48>
		}
		else
		{
			victoryCameraPackage.camera_offset_start = <0, 735, 68>
			victoryCameraPackage.camera_offset_end = <0, 625, 48>
		}

		victoryCameraPackage.camera_focus_offset = <0, 0, 36>
		victoryCameraPackage.camera_fov = 35.5

		return victoryCameraPackage

	#endif //

	victoryCameraPackage.camera_offset_start = <0, 320, 68>
	victoryCameraPackage.camera_offset_end = <0, 200, 48>
	victoryCameraPackage.camera_focus_offset = <0, 0, 36>
	victoryCameraPackage.camera_fov = 35.5

	return victoryCameraPackage
}

VictorySoundPackage function GetVictorySoundPackage()
{
	VictorySoundPackage victorySoundPackage

	#if(false)
		if ( true )
		{
			float randomFloat = RandomFloatRange( 0, 1 )
			if ( true )
			{
				string shadowsWinAlias
				if ( randomFloat < 0.33 )
					shadowsWinAlias = "diag_ap_nocNotify_shadowSquadWin_01_3p"
				else if ( randomFloat < 0.66 )
					shadowsWinAlias = "diag_ap_nocNotify_shadowSquadWin_02_3p"
				else
					shadowsWinAlias = "diag_ap_nocNotify_shadowSquadWin_03_3p"
				victorySoundPackage.youAreChampPlural = shadowsWinAlias
				victorySoundPackage.youAreChampSingular = shadowsWinAlias
				victorySoundPackage.theyAreChampPlural = shadowsWinAlias
				victorySoundPackage.theyAreChampSingular = shadowsWinAlias
			}
			else //
			{
				if ( randomFloat < 0.33 )
				{
					victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_01_3p" //
					victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_03_3p" //
					victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_01_3p" //
				}
				else if ( randomFloat < 0.66 )
				{
					victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_02_3p" //
					victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_04_3p" //
					victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_02_3p" //
				}
				else
				{
					victorySoundPackage.youAreChampPlural = "diag_ap_nocNotify_victorySquad_03_3p" //
					victorySoundPackage.youAreChampSingular = "diag_ap_nocNotify_victorySolo_05_3p" //
					victorySoundPackage.theyAreChampSingular = "diag_ap_nocNotify_victorySolo_01_3p" //
				}
				victorySoundPackage.theyAreChampPlural = "diag_ap_nocNotify_victorySquad_03_3p" //

			}

			return victorySoundPackage
		}
	#endif //

	victorySoundPackage.youAreChampPlural = "diag_ap_aiNotify_winnerFound_07" //
	victorySoundPackage.youAreChampSingular = "diag_ap_aiNotify_winnerFound_10" //
	victorySoundPackage.theyAreChampPlural = "diag_ap_aiNotify_winnerFound_08" //
	victorySoundPackage.theyAreChampSingular = "diag_ap_ainotify_introchampion_01_02" //

	return victorySoundPackage
}
