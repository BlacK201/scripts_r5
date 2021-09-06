// GUN GAME GAMEMODE
//  Made by @Pebbers#9558, @TheyCallMeSpy#1337, @sal#3261 and @Edorion#1761
//  ReMake by Neko,雪落,black201
//  This is a modified version of the TDM made so we can have weapon upgrade, balancing when you're not good enough, etc
//  Have fun !!

global function Sh_GunGame_Init
global function NewLocationSettings_GunGame
global function NewLocPair_GunGame
global function NewWeaponKit_GunGame

global function GunGame_GetIntroCutsceneNumSpawns                
global function GunGame_GetIntroCutsceneSpawnDuration          
global function GunGame_GetIntroSpawnSpeed                     
global function GunGame_Spectator_GetReplayIsEnabled
global function GunGame_Spectator_GetReplayDelay    
global function GunGame_GetRespawnDelay             
global function GunGame_Equipment_GetDefaultShieldHP 
global function GunGame_GetOOBDamagePercent          
global function GunGame_GetVotingTime 

global const LOCATION_CUTSCENE_DURATION_GunGame = 9

global enum eGUNGAMEAnnounce
{
	NONE = 0
	WAITING_FOR_PLAYERS = 1
	ROUND_START = 2
	VOTING_PHASE = 3
	MAP_FLYOVER = 4
	IN_PROGRESS = 5
    WINNERWARNING = 6
    
}

#if SERVER
global enum eGUNGAMEState
{
	IN_PROGRESS = 0
	WINNER_DECIDED = 1
}
#endif

global struct LocPair_GunGame
{
    vector origin = <0, 0, 0>
    vector angles = <0, 0, 0>
}

global struct LocationSettings_GunGame {
    string name
    array<LocPair_GunGame> spawns
    vector cinematicCameraOffset
}

global struct WeaponKit_GunGame
{
    string weapon
    array<string> mods
    int slot
}

struct {
    LocationSettings_GunGame &selectedLocation
    array choices
    array<LocationSettings_GunGame> locationSettings
    var scoreRui

} file;




void function Sh_GunGame_Init()
{


    // Map locations

    switch(GetMapName())
    {
    case "mp_rr_canyonlands_staging":
        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "靶场",
                [
                    NewLocPair_GunGame(<33560, -8992, -29126>, <0, 90, 0>),
					NewLocPair_GunGame(<34525, -7996, -28242>, <0, 100, 0>),
                    NewLocPair_GunGame(<33507, -3754, -29165>, <0, -90, 0>),
					NewLocPair_GunGame(<34986, -3442, -28263>, <0, -113, 0>)
                ],
                <0, 0, 3000>
            )
        )
        break

	//case "mp_rr_canyonlands_mu1":
	case "mp_rr_canyonlands_mu1_night":
    // case "mp_rr_canyonlands_64k_x_64k": 
       /* Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "骷髅镇",
                [
                    NewLocPair_GunGame(<-9320, -13528, 3167>, <0, -100, 0>),
                    NewLocPair_GunGame(<-7544, -13240, 3161>, <0, -115, 0>),
                    NewLocPair_GunGame(<-10250, -18320, 3323>, <0, 100, 0>),
                    NewLocPair_GunGame(<-13261, -18100, 3337>, <0, 20, 0>)
                ],
                <0, 0, 3000>
            )
        )

        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "小镇",
                [
                    NewLocPair_GunGame(<-30190, 12473, 3186>, <0, -90, 0>),
                    NewLocPair_GunGame(<-28773, 11228, 3210>, <0, 180, 0>),
                    NewLocPair_GunGame(<-29802, 9886, 3217>, <0, 90, 0>),
                    NewLocPair_GunGame(<-30895, 10733, 3202>, <0, 0, 0>)
                ],
                <0, 0, 3000>
            )
        )

        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "市场",
                [
                    NewLocPair_GunGame(<-110, -9977, 2987>, <0, 0, 0>),
                    NewLocPair_GunGame(<-1605, -10300, 3053>, <0, -100, 0>),
                    NewLocPair_GunGame(<4600, -11450, 2950>, <0, 180, 0>),
                    NewLocPair_GunGame(<3150, -11153, 3053>, <0, 100, 0>)
                ],
                <0, 0, 3000>
            )
        )

        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "径流",
                [
                    NewLocPair_GunGame(<-23380, 9634, 3371>, <0, 90, 0>),
                    NewLocPair_GunGame(<-24917, 11273, 3085>, <0, 0, 0>),
                    NewLocPair_GunGame(<-23614, 13605, 3347>, <0, -90, 0>),
                    NewLocPair_GunGame(<-24697, 12631, 3085>, <0, 0, 0>)
                ],
                <0, 0, 3000>
            )
        )

        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "雷霆堡",
                [
                    NewLocPair_GunGame(<-20216, -21612, 3191>, <0, -67, 0>),
                    NewLocPair_GunGame(<-16035, -20591, 3232>, <0, -133, 0>),
                    NewLocPair_GunGame(<-16584, -24859, 2642>, <0, 165, 0>),
                    NewLocPair_GunGame(<-19019, -26209, 2640>, <0, 65, 0>)
                ],
                <0, 0, 2000>
            )
        )

        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "净水厂",
                [
                    NewLocPair_GunGame(<5583, -30000, 3070>, <0, 0, 0>),
                    NewLocPair_GunGame(<7544, -29035, 3061>, <0, 130, 0>),
                    NewLocPair_GunGame(<10091, -30000, 3070>, <0, 180, 0>),
                    NewLocPair_GunGame(<8487, -28838, 3061>, <0, -45, 0>)
                ],
                <0, 0, 3000>
            )
        )
                  */

        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "坑洞",
                [
                    NewLocPair_GunGame(<-18558, 13823, 3605>, <0, 20, 0>),
                    NewLocPair_GunGame(<-16514, 16184, 3772>, <0, -77, 0>),
                    NewLocPair_GunGame(<-13826, 15325, 3749>, <0, 160, 0>),
                    NewLocPair_GunGame(<-16160, 14273, 3770>, <0, 101, 0>)
                ],
                <0, 0, 7000>
            )
        )

       /*
        Shared_RegisterLocation(
            NewLocationSettings_GunGame(
                "机场",
                [
                    NewLocPair_GunGame(<-24140, -4510, 2583>, <0, 90, 0>),
                    NewLocPair_GunGame(<-28675, 612, 2600>, <0, 18, 0>),
                    NewLocPair_GunGame(<-24688, 1316, 2583>, <0, 180, 0>),
                    NewLocPair_GunGame(<-26492, -5197, 2574>, <0, 50, 0>)
                ],
                <0, 0, 3000>
            )
        )      */
        break

        case "mp_rr_desertlands_64k_x_64k":
       // case "mp_rr_desertlands_64k_x_64k_nx":
	       /* Shared_RegisterLocation(
                NewLocationSettings_GunGame(
                    "精炼厂",
                    [
                        NewLocPair_GunGame(<22970, 27159, -4612.43>, <0, 135, 0>),
                        NewLocPair_GunGame(<20430, 26361, -4140>, <0, 135, 0>),
                        NewLocPair_GunGame(<19142, 30982, -4612>, <0, -45, 0>),
                        NewLocPair_GunGame(<18285, 28502, -4140>, <0, -45, 0>)
                    ],
                    <0, 0, 6500>
                )
            )

            */
            Shared_RegisterLocation(
                NewLocationSettings_GunGame(
                    "主播快乐楼",
                    [
                        NewLocPair_GunGame(<11393, 5477, -4289>, <0, 90, 0>),
                        NewLocPair_GunGame(<12027, 7121, -4290>, <0, -120, 0>),
                        NewLocPair_GunGame(<8105, 6156, -4266>, <0, -45, 0>),
                        NewLocPair_GunGame(<7965.0, 5976.0, -4266.0>, <0, -135, 0>)
                    ],
                    <0, 0, 3000>
                )
            )
            /*
            Shared_RegisterLocation(
                NewLocationSettings_GunGame(
                    "热力站",
                    [
                        NewLocPair_GunGame(<-20091, -17683, -3984>, <0, -90, 0>),
						NewLocPair_GunGame(<-22919, -20528, -4010>, <0, 0, 0>),
                        NewLocPair_GunGame(<-20109, -23193, -4252>, <0, 90, 0>),
						NewLocPair_GunGame(<-17140, -20710, -3973>, <0, -180, 0>)
                    ],
                    <0, 0, 11000>
                )
            )

            Shared_RegisterLocation(
                NewLocationSettings_GunGame(
                    "熔岩裂缝",
                    [
                        NewLocPair_GunGame(<-26550, 13746, -3048>, <0, -134, 0>),
						NewLocPair_GunGame(<-28877, 12943, -3109>, <0, -88.70, 0>),
                        NewLocPair_GunGame(<-29881, 9168, -2905>, <-1.87, -2.11, 0>),
						NewLocPair_GunGame(<-27590, 9279, -3109>, <0, 90, 0>)
                    ],
                    <0, 0, 2500>
                )
            )

            Shared_RegisterLocation(
                NewLocationSettings_GunGame(
                    "穹顶",
                    [
                        NewLocPair_GunGame(<17445.83, -36838.45, -2160.64>, <-2.20, -37.85, 0>),
						NewLocPair_GunGame(<17405.53, -39860.60, -2248>, <-6, -52, 0>),
                        NewLocPair_GunGame(<21700.48, -40169, -2164.30>, <2, 142, 0>),
						NewLocPair_GunGame(<20375.39, -36068.25, -2248>, <-1, -128, 0>)
                    ],
                    <0, 0, 2850>
                )
            )
            */

        default:
            Assert(false, "No TDM locations found for map!")
    }

    //Client Signals
    RegisterSignal( "CloseScoreRUI" )

}

WeaponKit_GunGame function NewWeaponKit_GunGame(string weapon, array<string> mods, int slot)
{
    WeaponKit_GunGame weaponKit
    weaponKit.weapon = weapon
    weaponKit.mods = mods
    weaponKit.slot = slot

    return weaponKit
}

LocPair_GunGame function NewLocPair_GunGame(vector origin, vector angles)
{
    LocPair_GunGame locPair
    locPair.origin = origin
    locPair.angles = angles

    return locPair
}

LocationSettings_GunGame function NewLocationSettings_GunGame(string name, array<LocPair_GunGame> spawns, vector cinematicCameraOffset)
{
    LocationSettings_GunGame locationSettings
    locationSettings.name = name
    locationSettings.spawns = spawns
    locationSettings.cinematicCameraOffset = cinematicCameraOffset

    return locationSettings
}


void function Shared_RegisterLocation(LocationSettings_GunGame locationSettings)
{
    #if SERVER
    _RegisterLocation_GunGame(locationSettings)
    #endif


    #if CLIENT
    Cl_RegisterLocation_GunGame(locationSettings)
    #endif


}



// Playlist GET

float function GunGame_GetIntroCutsceneNumSpawns()                { return GetCurrentPlaylistVarFloat("intro_cutscene_num_spawns", 5)}
float function GunGame_GetIntroCutsceneSpawnDuration()            { return GetCurrentPlaylistVarFloat("intro_cutscene_spawn_duration", 5)}
float function GunGame_GetIntroSpawnSpeed()                       { return GetCurrentPlaylistVarFloat("intro_cutscene_spawn_speed", 40)}
bool function GunGame_Spectator_GetReplayIsEnabled()                         { return GetCurrentPlaylistVarBool("replay_enabled", false ) } 
float function GunGame_Spectator_GetReplayDelay()                            { return GetCurrentPlaylistVarFloat("replay_delay", 1 ) } 
float function GunGame_GetRespawnDelay()                          { return GetCurrentPlaylistVarFloat("respawn_delay", 8) }
float function GunGame_Equipment_GetDefaultShieldHP()                        { return GetCurrentPlaylistVarFloat("default_shield_hp", 100) }
float function GunGame_GetOOBDamagePercent()                      { return GetCurrentPlaylistVarFloat("oob_damage_percent", 25) }
float function GunGame_GetVotingTime()                            { return GetCurrentPlaylistVarFloat("voting_time", 5) }


