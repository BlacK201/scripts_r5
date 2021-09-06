// GUN GAME GAMEMODE
//  Made by @Pebbers#9558, @TheyCallMeSpy#1337, @sal#3261 and @Edorion#1761
//  ReMake by Neko,雪落,black201

//  This is a modified version of the TDM made so we can have weapon upgrade, balancing when you're not good enough, etc
//  Have fun !!





global function _GunGame_Init


//ALREADY EXISTS IN sh_gamemode_custom_tdm, tho for a weird reason I have to duplicate it
global function _RegisterLocation_GunGame


string ALTERNATOR = "mp_weapon_alternator_smg"
string CHARGE_RIFLE = "mp_weapon_defender"
string DEVOTION = "mp_weapon_esaw"
string EPG = "mp_weapon_epg"
string EVA = "mp_weapon_shotgun"
string FLATLINE = "mp_weapon_vinson"
string G7 = "mp_weapon_g2"
string HAVOC = "mp_weapon_energy_ar"
string HEMLOK = "mp_weapon_hemlok"
string KRABER = "mp_weapon_sniper"
string LONGBOW = "mp_weapon_dmr"
string LSTAR = "mp_weapon_lstar"
string MASTIFF = "mp_weapon_mastiff"
string MOZAMBIQUE = "mp_weapon_shotgun_pistol"
string P2020 = "mp_weapon_semipistol"
string PEACEKEEPER = "mp_weapon_energy_shotgun"
string PROWLER = "mp_weapon_pdw"
string R301 = "mp_weapon_rspn101"
string R99 = "mp_weapon_r97"
string RE45 = "mp_weapon_autopistol"
string SPITFIRE = "mp_weapon_lmg"
string TRIPLE_TAKE = "mp_weapon_doubletake"
string WINGMAN = "mp_weapon_wingman"
string MELEE = "mp_weapon_melee_survival"

// ARMORS
string WHITE_SHIELD = "armor_pickup_lv1"
string BLUE_SHIELD = "armor_pickup_lv2"
string PURPLE_SHIELD = "armor_pickup_lv3"


array<string> GUN_LIST =[
    "mp_weapon_rspn101",
    "mp_weapon_energy_ar",
    "mp_weapon_hemlok",
    "mp_weapon_energy_shotgun",
    "mp_weapon_shotgun",
    "mp_weapon_mastiff",
    "mp_weapon_doubletake",
    "mp_weapon_r97",
    "mp_weapon_pdw",
    "mp_weapon_alternator_smg",
    "mp_weapon_esaw",
    "mp_weapon_lstar",
    "mp_weapon_lmg",
    "mp_weapon_sniper",
    "mp_weapon_dmr",
    "mp_weapon_g2",
    "mp_weapon_wingman",
    "mp_weapon_autopistol",
    "mp_weapon_shotgun_pistol",
    "mp_weapon_semipistol" 
]




array<string> ATTACHMENTS_LEVEL1 =[
    "optic_cq_hcog_classic",
    "barrel_stabilizer_l1",
    "stock_tactical_l1",
    "stock_sniper_l1",
    "shotgun_bolt_l1",
    "bullets_mag_l1",
    "highcal_mag_l1",
    "energy_mag_l1"
]

array<string> ATTACHMENTS_LEVEL2 =[
    "optic_cq_hcog_classic",
    "barrel_stabilizer_l2",
    "stock_tactical_l2",
    "stock_sniper_l2",
    "shotgun_bolt_l2",
    "bullets_mag_l2",
    "highcal_mag_l2",
    "energy_mag_l2"
]

array<string> ATTACHMENTS_LEVEL3 =[
    "optic_cq_hcog_bruiser",
    "barrel_stabilizer_l3",
    "stock_tactical_l3",
    "stock_sniper_l3",
    "shotgun_bolt_l3",
    "bullets_mag_l3",
    "highcal_mag_l3",
    "energy_mag_l3",
    "hopup_highcal_rounds",
    "hopup_energy_choke"
]

array<string> ATTACHMENTS_LEVEL4 =[
    "optic_cq_hcog_bruiser",
    "barrel_stabilizer_l4_flash_hider",
    "stock_tactical_l3",
    "stock_sniper_l3",
    "shotgun_bolt_l3",
    "bullets_mag_l3",
    "highcal_mag_l3",
    "energy_mag_l3",
    "hopup_double_tap",
    "hopup_turbocharger",
    "hopup_highcal_rounds",
    "hopup_energy_choke",
    "hopup_double_tap",
    "hopup_unshielded_dmg"
]

struct {
    int gungameState = eGameState.Playing
    array<entity> playerSpawnedProps
    LocationSettings_GunGame& selectedLocation
    array<LocationSettings_GunGame> locationSettings

    entity bubbleBoundary
    entity winner
    bool needBackGun = false
} file






//
// INIT(fixed by Neko,雪落,black201)
//
void function _GunGame_Init()
{
    //In lava fissure you can freefall, so we have to initialize particles to avoid crashes
	SurvivalFreefall_Init()

    AddCallback_OnPlayerKilled(void function(entity victim, entity attacker, var damageInfo) {thread _GunGameOnPlayerDied(victim, attacker, damageInfo)})
    AddCallback_OnClientConnected( void function(entity player) { thread _GunGameOnPlayerConnected(player) } )

    /*
        AddClientCommandCallback("gg_next_round", ClientCommand_NextRound)
        AddClientCommandCallback("gg_clear_invincible_all", ClientCommand_ClearInvincibleAll)
        AddClientCommandCallback("gg_clear_invincible", ClientCommand_ClearInvincible)
        AddClientCommandCallback("gg_remove_passive", ClientCommand_RemovePassive)
        AddClientCommandCallback("gg_add_passive", ClientCommand_AddPassive)
    */
    thread RunGunGame()
}

//
// Used to set spawn location
//
void function _RegisterLocation_GunGame(LocationSettings_GunGame locationSettings)
{
    file.locationSettings.append(locationSettings)
}








//
//
// SERVER EVENTS
//
//

//Lobby location for each map(fixed by Neko,雪落,black201)
LocPair_GunGame function _GunGameGetVotingLocation()
{
    switch(GetMapName())
    {
        case "mp_rr_canyonlands_staging":
            return NewLocPair_GunGame(<26794, -6241, -27479>, <0, 0, 0>)
        case "mp_rr_canyonlands_64k_x_64k":
        case "mp_rr_canyonlands_mu1":
        case "mp_rr_canyonlands_mu1_night":
            return NewLocPair_GunGame(<-6252, -16500, 3296>, <0, 0, 0>)
        case "mp_rr_desertlands_64k_x_64k":
        case "mp_rr_desertlands_64k_x_64k_nx":
            return NewLocPair_GunGame(<1763, 5463, -3145>, <5, -95, 0>)
        default:
            Assert(false, "No voting location for the map!")
    }
    unreachable
}

//Used so we can destroy all unwanted objects when game end
void function _GunGameOnPropDynamicSpawned(entity prop)
{
    file.playerSpawnedProps.append(prop)
}

//Set all player vars and stuff when he's connected (passive, gamemode info) (fixed by Neko,雪落,black201)
void function _GunGameOnPlayerConnected(entity player)
{

    printt("Gun Game:playerConnected")


    if(!IsValidPlayer(player)) return
    //Give passive regen (pilot blood)
    GivePassive(player, ePassives.PAS_PILOT_BLOOD)

    //SetPlayerSettings(player, TDM_PLAYER_SETTINGS)
    
    if(!IsAlive(player))
    {
        _GunGameHandleRespawn(player)
    }
    

    //Give passive regen (pilot blood)
    GivePassive(player, ePassives.PAS_PILOT_BLOOD)
    DecideRespawnPlayer(player)
    TpPlayerToSpawnPoint(player)
    Reset(player)
    PlayerRestoreHP(player, 100)
    PlayerRestoreShields(player, player.GetShieldHealthMax())
    SetPlayerAbility( player )
    SetPlayerSettings(player, GUN_GAME_PLAYER_SETTINGS)
    


    switch(GetGameState())
    {
        case eGameState.WaitingForPlayers:
            //player.FreezeControlsOnServer()
            break
        case eGameState.Playing:
            player.UnfreezeControlsOnServer()
            Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoAnnouncement", 5, eGUNGAMEAnnounce.ROUND_START)
            break
        case eGameState.WinnerDetermined:
            player.FreezeControlsOnServer()
            break
        default:
            break
    }
}

// Set player default ability
void function SetPlayerAbility(entity player) {
    entity tacticalNow = player.GetOffhandWeapon( OFFHAND_TACTICAL )
    if( IsValid( tacticalNow ) ) {
        player.TakeOffhandWeapon( OFFHAND_TACTICAL )
    }
    player.GiveOffhandWeapon( "mp_ability_grapple", OFFHAND_TACTICAL )
    entity defaulttactical = player.GetOffhandWeapon( OFFHAND_TACTICAL )
    defaulttactical.SetWeaponPrimaryClipCount( defaulttactical.GetWeaponPrimaryClipCountMax() )

    entity ultimateNow = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
    if( IsValid( ultimateNow ) ) {
        player.TakeOffhandWeapon( OFFHAND_ULTIMATE )
    }
    player.GiveOffhandWeapon( "mp_ability_mirage_ultimate", OFFHAND_ULTIMATE )
}


//Used to upgrade weapons, shield (fixed by Neko,雪落,black201)
void function _GunGameOnPlayerDied(entity victim, entity attacker, var damageInfo)
{
    switch(GetGameState())
    {
        case eGameState.Playing:

            bool isMeleeAttack = false;

            if(bool(DamageInfo_GetCustomDamageType( damageInfo ) & DF_MELEE))
            {
                isMeleeAttack = true 
            }

            //victim
            void functionref() victimHandleFunc = void function() : (isMeleeAttack, victim, attacker, damageInfo) 
            {
                if(!IsValidPlayer(victim)) return

                UpgradeShields(victim, true)

                string weapon0 = SURVIVAL_GetWeaponBySlot(victim, 0)
                string weapon1 = SURVIVAL_GetWeaponBySlot(victim, 1)

                //victim.p.storedWeapons = StoreWeapons(victim)

                if(Spectator_GetReplayIsEnabled() && IsValid(victim) && ShouldSetObserverTarget( attacker ))
                {
                    victim.SetObserverTarget( attacker )
                    victim.SetSpecReplayDelay( Spectator_GetReplayDelay() )
                    victim.StartObserverMode( OBS_MODE_IN_EYE )
                    Remote_CallFunction_NonReplay(victim, "ServerCallback_KillReplayHud_Activate")
                }

                if(IsValidPlayer(attacker))
                {
                    Remote_CallFunction_NonReplay(attacker, "ServerCallback_GunGame_PlayerKilled")
                }

                wait GunGame_GetRespawnDelay()

                if(IsValidPlayer(victim) )
                {
                    if( victim.IsObserver())
                    {
                        victim.StopObserverMode()
                        Remote_CallFunction_NonReplay(victim, "ServerCallback_KillReplayHud_Deactivate")
                    }

                    DecideRespawnPlayer( victim )
                    //Sets consecutive death vars
                    victim.SetPlayerGameStat( PGS_DEATHS, victim.GetPlayerGameStat( PGS_DEATHS ) + 1 )
                    //Sets his weapon, and since he died he'll have attachments based on hom many consecutive deaths he has
                    //melee will lead player weapon back

                    if(isMeleeAttack)
                    {
                        //printt("before victim kills : " + victim.GetPlayerGameStat(PGS_KILLS))
                        victim.SetPlayerGameStat(PGS_KILLS, victim.GetPlayerGameStat(PGS_KILLS) - 1)
                        GameRules_SetTeamScore(victim.GetTeam(), GameRules_GetTeamScore(victim.GetTeam()) - 1)
                        file.needBackGun = true
                        UpgradeWeapons(victim)
                        //printt("after victim kills : " + victim.GetPlayerGameStat(PGS_KILLS))
                        
                    }
                    else
                    {
                        PlayerRestoreWeapons(victim, weapon0, weapon1, GetAttachmentsBasedOnLevel(weapon0, victim.GetPlayerGameStat( PGS_DEATHS )))
                    }    
                    

                    //Set gamemode settings
                    SetPlayerSettings(victim, GUN_GAME_PLAYER_SETTINGS)
                    PlayerRestoreHP(victim, 100)
                    PlayerRestoreShields(victim, victim.GetShieldHealthMax())
                    SetPlayerAbility( victim )
                    TpPlayerToSpawnPoint(victim)
                    thread GrantSpawnImmunity(victim, 3)
                    
                }
            
            }

            //attacker
            void functionref() attackerHandleFunc = void function() : (victim, attacker, damageInfo)  
            {
                if(IsValidPlayer(attacker) && IsAlive(attacker) && attacker != victim)
                {
                    //update attacker weapon and recover his life&armor
                    int score = GameRules_GetTeamScore(attacker.GetTeam());
                    score++;
                    GameRules_SetTeamScore(attacker.GetTeam(), score);

                    if(score == GUN_LIST.len())
                    {
                        foreach(player in GetPlayerArray())
                            Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoAnnouncement", 5, eGUNGAMEAnnounce.WINNERWARNING)
                    }

                    UpgradeWeapons(attacker)
                    UpgradeShields(attacker, false)
                    attacker.SetPlayerGameStat( PGS_DEATHS, 0)
                }
                
            }

           

            //excute declared funcref
            thread attackerHandleFunc()
            waitthread victimHandleFunc()

            ResetUI()
            break
    default:
        break
    }
}



//Returns a valid spawn point based on team and how many players are near the spawn point (fixed by Neko,雪落,black201)
LocPair_GunGame function _GunGameGetAppropriateSpawnLocation(entity player)
{
    int ourTeam = player.GetTeam()

    LocPair_GunGame selectedSpawn = _GunGameGetVotingLocation()

    switch(GetGameState())
    {
        //if votingphase now
        case eGameState.MapVoting:
            selectedSpawn = _GunGameGetVotingLocation()
        break

        case eGameState.Playing:
            float maxDistToEnemy = 0
            foreach(spawn in file.selectedLocation.spawns)
            {
                vector enemyOrigin = GetClosestEnemyToOrigin(spawn.origin, ourTeam)
                float distToEnemy = Distance(spawn.origin, enemyOrigin)

                if(distToEnemy > maxDistToEnemy)
                {
                    maxDistToEnemy = distToEnemy
                    selectedSpawn = spawn
                }
            }
            break
        //If not in game, return default lobby location to avoid any bugs
        default:
            selectedSpawn = _GunGameGetVotingLocation()
            break
    }
    return selectedSpawn
}







void function GetPlayerLatency()
{
   while(true)
   {
       foreach(player in GetPlayerArray())
       {
           if(!IsValidPlayer(player)) continue
           player.SetPlayerNetInt("Latency", (player.GetLatency() * 1000).tointeger())
       }
       foreach(player in GetPlayerArray())
       {
           if(!IsValidPlayer(player)) continue
           Remote_CallFunction_NonReplay(player, "ServerCallback_UpdateAllPlayerLatency")
       }
       
       wait 0.5
   }
}



//
//
// MAIN GAMEMODE FUNCTIONS
//
//

//Main function
void function RunGunGame()
{
    WaitForGameState(eGameState.Playing)
    AddSpawnCallback("prop_dynamic", _GunGameOnPropDynamicSpawned)
    thread GetPlayerLatency()

    for(; ; )
    {
        VotingPhase();
        StartRound();
    }
    WaitForever()
}



//Executed before the match starts. Selects a location after spawning each player in the "lobby" (fixed by Neko,雪落,black201)
void function VotingPhase()
{

    DestroyPlayerProps();
    SetGameState(eGameState.MapVoting)
    
    foreach(player in GetPlayerArray()) 
    {
        if(!IsValidPlayer(player)) continue
        GameRules_SetTeamScore(player.GetTeam(), 0)
        DecideRespawnPlayer(player)
        TpPlayerToSpawnPoint(player)
        MakeInvincible(player)
		HolsterAndDisableWeapons( player )
        player.ForceStand()
        Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoAnnouncement", 2, eGUNGAMEAnnounce.VOTING_PHASE)
        TpPlayerToSpawnPoint(player)
        player.UnfreezeControlsOnServer();
        Reset(player)
    }
    wait GunGame_GetVotingTime()

    int choice = RandomIntRangeInclusive(0, file.locationSettings.len() - 1)

    file.selectedLocation = file.locationSettings[choice]
    
    foreach(player in GetPlayerArray())
    {
        Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_SetSelectedLocation", choice)
    }

    WaitForGameState(eGameState.MapVoting)
   
}


//Called when game start. Contains main game loop(Remake by Neko,雪落,black201)
void function StartRound()
{
    SetGameState(eGameState.Playing)
    //printt("max teams : " + GetCurrentPlaylistVarInt("max_teams",20))
    
    foreach(player in GetPlayerArray())
    {
        if(IsValidPlayer(player))
        {
            thread ScreenFadeToFromBlack(player)
            AddCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD | CE_FLAG_INTRO)
            player.FreezeControlsOnServer()
        }
        
    }
    wait 1
    foreach(player in GetPlayerArray())
    {
        if(!IsValidPlayer(player)) continue;
        Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoLocationIntroCutscene")      
        
    }

    file.bubbleBoundary = GunGame_CreateBubbleBoundary(file.selectedLocation)

    foreach(player in GetPlayerArray())
    {
        if(IsValid(player))
            Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoAnnouncement", 4, eGUNGAMEAnnounce.MAP_FLYOVER)
    }
    
    wait GunGame_GetIntroCutsceneSpawnDuration() * GunGame_GetIntroCutsceneNumSpawns()

    foreach(player in GetPlayerArray())
    {
        if( IsValidPlayer( player ) )
        {
            thread ScreenFadeFromBlack(player, 0.5, 0.5)
            RemoveCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD | CE_FLAG_INTRO)

            Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoAnnouncement", 5, eGUNGAMEAnnounce.ROUND_START)
            
            Reset(player)
            printt("ready Clear Invincible")
            ClearInvincible(player)
            printt("already Clear Invincible")
            
            DeployAndEnableWeapons(player)
            player.UnforceStand() 

            player.UnfreezeControlsOnServer()
            SetPlayerAbility( player )
            TpPlayerToSpawnPoint(player)
            
        }
        
    }

    file.bubbleBoundary = GunGame_CreateBubbleBoundary(file.selectedLocation)

    float endTime = Time() + GetCurrentPlaylistVarInt("round_time", 999999)

    //Main loop, will continue until winner is decided
    while( Time() <= endTime )
	{
        if(GetGameState() == eGameState.WinnerDetermined) {

            foreach( entity player in GetPlayerArray() )
            {
                //Stop everything
                MakeInvincible(player)
                player.FreezeControlsOnServer()

                //Play win sound
                if(player.GetTeam() == file.winner.GetTeam())
                    thread EmitSoundOnEntityOnlyToPlayer( player, player, "diag_ap_aiNotify_winnerFound_10_03" )
                else   
                    thread EmitSoundOnEntityOnlyToPlayer( player, player, "diag_ap_aiNotify_winnerFound" )

            }

            ResetAllPlayerStats()
            break
        }
		WaitFrame()
	}

    foreach(player in GetPlayerArray())
    {
        if( player.IsObserver())
        {
            player.StopObserverMode()
            DecideRespawnPlayer(player) 
            MakeInvincible(player)
            Remote_CallFunction_NonReplay(player, "ServerCallback_KillReplayHud_Deactivate")
        }
        if(!IsValid(player)) continue;
        // DecideRespawnPlayer(player) 
		HolsterAndDisableWeapons( player )
        player.ForceStand()
        player.FreezeControlsOnServer();
        Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_DoVictoryAnnounce", file.winner.GetTeam())
        
    }
    
    wait 5
    
    foreach(player in GetPlayerArray())
    {
        if(!IsValid(player)) continue;
        ClearInvincible(player)
        DeployAndEnableWeapons(player)
        player.UnforceStand()
        player.UnfreezeControlsOnServer();
    }

    file.gungameState = eGUNGAMEState.IN_PROGRESS

    file.bubbleBoundary.Destroy()

}







//
//
// UTILITY
//
//

void function DestroyPlayerProps()
{
    foreach(prop in file.playerSpawnedProps)
    {
        if(IsValid(prop))
            prop.Destroy()
    }
    file.playerSpawnedProps.clear()
}


void function ScreenFadeToFromBlack(entity player, float fadeTime = 1, float holdTime = 1)
{
    if( IsValidPlayer( player ) )
        ScreenFadeToBlack(player, fadeTime / 2, holdTime / 2)
    wait fadeTime
    if( IsValidPlayer( player ) )
        ScreenFadeFromBlack(player, fadeTime / 2, holdTime / 2)
}


//Get closest ennemy distance from point
vector function GetClosestEnemyToOrigin(vector origin, int ourTeam)
{
    float minDist = -1
    vector enemyOrigin = <0, 0, 0>

    foreach(player in GetPlayerArray_Alive())
    {
        if(player.GetTeam() == ourTeam) continue

        float dist = Distance(player.GetOrigin(), origin)
        if(dist < minDist || minDist < 0)
        {
            minDist = dist
            enemyOrigin = player.GetOrigin()
        }
    }

    return enemyOrigin
}


//Self explanatory(fixed by Neko,雪落,black201))
void function TpPlayerToSpawnPoint(entity player)
{

	LocPair_GunGame loc = _GunGameGetAppropriateSpawnLocation(player)

    player.SetOrigin(loc.origin)
    player.SetAngles(loc.angles)


    PutEntityInSafeSpot( player, null, null, player.GetOrigin() + <0,0,128>, player.GetOrigin() )
}

//MakeBubble
entity function GunGame_CreateBubbleBoundary(LocationSettings_GunGame location)
{
    array<LocPair_GunGame> spawns = location.spawns
    
    vector bubbleCenter
    foreach(spawn in spawns)
    {
        bubbleCenter += spawn.origin
    }
    
    bubbleCenter /= spawns.len()

    float bubbleRadius = 0

    foreach(LocPair_GunGame spawn in spawns)
    {
        if(Distance(spawn.origin, bubbleCenter) > bubbleRadius)
        bubbleRadius = Distance(spawn.origin, bubbleCenter)
    }
    
    bubbleRadius += GetCurrentPlaylistVarFloat("bubble_radius_padding", 800)

    entity bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.SetValueForModelKey( BUBBLE_BUNKER_SHIELD_COLLISION_MODEL )
    bubbleShield.SetOrigin(bubbleCenter)
    bubbleShield.SetModelScale(bubbleRadius / 235)
    bubbleShield.kv.CollisionGroup = 0
    bubbleShield.kv.rendercolor = "127 73 37"
    DispatchSpawn( bubbleShield )



    thread GunGame_MonitorBubbleBoundary(bubbleShield, bubbleCenter, bubbleRadius)


    return bubbleShield

}


void function GunGame_MonitorBubbleBoundary(entity bubbleShield, vector bubbleCenter, float bubbleRadius)
{
    while(IsValid(bubbleShield))
    {

        foreach(player in GetPlayerArray_Alive())
        {
            if(!IsValid(player)) continue
            if(Distance(player.GetOrigin(), bubbleCenter) > bubbleRadius)
            {
				Remote_CallFunction_Replay( player, "ServerCallback_PlayerTookDamage", 0, 0, 0, 0, DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS, eDamageSourceId.deathField, null )
                player.TakeDamage( int( Deathmatch_GetOOBDamagePercent() / 100 * float( player.GetMaxHealth() ) ), null, null, { scriptType = DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS, damageSourceId = eDamageSourceId.deathField } )
            }
        }
        wait 1
    }
    
}


//Restore shield health by X amount
void function PlayerRestoreShields(entity player, int shields)
{
    if(IsValidPlayer(player) && IsAlive( player ))
        player.SetShieldHealth(clamp_gun_game(shields, 0, player.GetShieldHealthMax()))
}

void function PlayerRestoreHP(entity player, int health)
{
    if(IsValidPlayer(player) && IsAlive( player ))
        player.SetHealth( health )
}

int function clamp_gun_game(int value, int min, int max) {
    if(value < min) return min
    else if (value > max) return max
    else return value

    unreachable
}

//Restore weapon with given attachments (if there's one)
void function PlayerRestoreWeapons(entity player, string weapon0, string weapon1, array<string> mods1 = [], array<string> mods2 = [])
{
    if(IsValid(weapon0) && weapon0 != "")
    {
        if(player.GetNormalWeapon(WEAPON_INVENTORY_SLOT_PRIMARY_0) == null)
        {
            player.GiveWeapon(weapon0, WEAPON_INVENTORY_SLOT_PRIMARY_0, mods1)
        }
    }
    if(IsValid(weapon1) && weapon1 != "")
    {
        if(player.GetNormalWeapon(WEAPON_INVENTORY_SLOT_PRIMARY_1) == null)
        {
            player.GiveWeapon_NoDeploy(weapon1, WEAPON_INVENTORY_SLOT_PRIMARY_1, mods2)
        }
        
    }
}

//(fixed By by Neko,雪落,black201)
void function GrantSpawnImmunity(entity player, float duration)
{
    if(!IsValidPlayer(player)) return
    player.SetInvulnerable()
    HolsterAndDisableWeapons(player)
    wait duration

    //Check if player is valid again because he could have disconnected
    if(!IsValidPlayer(player)) return
    player.ClearInvulnerable()
    DeployAndEnableWeapons(player)
}


//Upgrade shield
void function UpgradeShields(entity player, bool died) {

    if (!IsValidPlayer(player)) return

    //If player to upgrade died, then dont do killstreak upgrade, just reset their shield
    if (died) {
        player.SetPlayerGameStat( PGS_TITAN_KILLS, 0 )
        Inventory_SetPlayerEquipment(player, WHITE_SHIELD, "armor")
    } else {
        player.SetPlayerGameStat( PGS_TITAN_KILLS, player.GetPlayerGameStat( PGS_TITAN_KILLS ) + 1)

        switch (player.GetPlayerGameStat( PGS_TITAN_KILLS )) {
	    	case 1:
                Inventory_SetPlayerEquipment(player, WHITE_SHIELD, "armor")
                break
            case 2:
            case 3:
                Inventory_SetPlayerEquipment(player, BLUE_SHIELD, "armor")
                break
            default:
                Inventory_SetPlayerEquipment(player, PURPLE_SHIELD, "armor")
                break
        }
    }



    PlayerRestoreShields(player, player.GetShieldHealthMax())
    PlayerRestoreHP(player, 100)
}


//Upgrade weapons to the next level
void function UpgradeWeapons(entity player)
{
    printt(player)
    //Always check if entity is a player
	if (!player.IsPlayer())
		return



    int nextGun = player.GetPlayerGameStat( PGS_KILLS )
    printt(nextGun)
    if(file.needBackGun)
    {
        nextGun = nextGun - 1
        file.needBackGun = false
    }
    

    //If the player has reached weapon number limit
    if (nextGun >= GUN_LIST.len()) {
        foreach( entity player_TMP in GetPlayerArray() )
        {
            thread EmitSoundOnEntityOnlyToPlayer( player_TMP, player_TMP, "diag_ap_aiNotify_winnerFound" )
        }
        file.winner = player
        SetGameState(eGameState.WinnerDetermined)
        return
    }

    //Gives the player next weaponw
    SetGun(player, GetNextGun(nextGun))
}


//Returns all attachments compatible with weaponName based on level
array<string> function GetAttachmentsBasedOnLevel(string weaponName, int level) {

    //We execute the function to find attachments based on lose streak (consecutive deaths)
    switch (level) {
        case 0:
        return []
            break
        case 1:
            return GetCompatibleAttachmentFromList(weaponName, ATTACHMENTS_LEVEL1)
            break
        case 2:
            return GetCompatibleAttachmentFromList(weaponName, ATTACHMENTS_LEVEL2)
            break
        case 3:
            return GetCompatibleAttachmentFromList(weaponName, ATTACHMENTS_LEVEL3)
            break
        default:
            return GetCompatibleAttachmentFromList(weaponName, ATTACHMENTS_LEVEL4)
            break
    }

    unreachable
}

//Return all valid attachment for weaponName that are in attachments
array<string> function GetCompatibleAttachmentFromList(string weaponName, array<string> attachments) {

    array<string> attachmentsToReturn = []
    foreach (attachment in attachments) {
        print(attachmentsToReturn)
        if (CanAttachToWeapon(attachment, weaponName)) attachmentsToReturn.append(attachment)
    }

    return attachmentsToReturn
}


//Self explanatory
void function ResetAllPlayerStats() {
    foreach(player in GetPlayerArray()) {
        if(!IsValidPlayer(player)) continue
        ResetPlayerStats(player)
    }
}

void function ResetUI() {
    foreach(player in GetPlayerArray()) {
        if(!IsValidPlayer(player)) continue
        //Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_PlayerKilled", GetBestPlayer(), GetBestPlayerScore())
        Remote_CallFunction_NonReplay(player, "ServerCallback_GunGame_PlayerKilled")
    }
}

void function ResetPlayerStats(entity player) {
    player.SetPlayerGameStat( PGS_SCORE, 0 )
    player.SetPlayerGameStat( PGS_DEATHS, 0)
    player.SetPlayerGameStat( PGS_TITAN_KILLS, 0)
    player.SetPlayerGameStat( PGS_KILLS, 0)
    player.SetPlayerGameStat( PGS_PILOT_KILLS, 0)
    player.SetPlayerGameStat( PGS_ASSISTS, 0)
    player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0)
    player.SetPlayerGameStat( PGS_DEFENSE_SCORE, 0)
    player.SetPlayerGameStat( PGS_ELIMINATED, 0)
}

//Used in the beginning of the match, set base weapon and reset stats
void function Reset(entity player) {
    SetGun(player, FLATLINE)
    ResetPlayerStats(player)
    UpgradeShields(player, true)
}

void function SetGun( entity ent, string weaponName, array<string> mods = [] )
{
	TakePrimaryWeapon( ent )
	if ( weaponName != "") {
		ent.GiveWeapon( weaponName, WEAPON_INVENTORY_SLOT_ANY, mods)
		ent.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponName )
       /* if(weaponName == MELEE)
        {
            entity weapon = ent.GetActiveWeapon( eActiveInventorySlot.mainHand )
            table weaponData = expect table(weapon.s)
            weaponData["melee_damage"] = 75.0
        }
        */
	}
}

string function GetNextGun(int index) {
    if (index >= GUN_LIST.len() || index < 0) {
        printt("INDEX OVERFLOW _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_")
        return FLATLINE
    }

    return GUN_LIST[index]
}

int function GetBestPlayerScore() {
    int bestScore = 0
    foreach(player in GetPlayerArray()) {
        if(!IsValidPlayer(player)) continue
        if (player.GetPlayerGameStat( PGS_KILLS ) > bestScore) bestScore = player.GetPlayerGameStat( PGS_KILLS )
    }

    return bestScore
}

entity function GetBestPlayer() {
    int bestScore = 0
    entity bestPlayer
    foreach(player in GetPlayerArray()) {
        if(!IsValidPlayer(player)) continue
        if (player.GetPlayerGameStat( PGS_KILLS ) > bestScore) {
            bestScore = player.GetPlayerGameStat( PGS_KILLS )
            bestPlayer = player
        }
    }

    return bestPlayer
}




//
//
// VICTORY SCREEN
//
//

//Thanks to @Pebbers#9558 for extracting this code from br !!!
/*
void function threadedVictory() {

    //If there is a winner
    if (file.winner != null) {
        //Launch end screen ("You are the champion") for each player
	    foreach ( playerO in GetPlayerArray() )
	    {
	    	Remote_CallFunction_NonReplay( playerO, "ServerCallback_PlayMatchEndMusic" )


            printl("DEBUG: " + file.winner.GetPlayerName() + " " + playerO.GetTeam())
            //Check if player is winner or is in winning team (first check isn't needed)
            if (file.winner == playerO || file.winner.GetTeam() == playerO.GetTeam()) {
	        	Remote_CallFunction_NonReplay( playerO, "ServerCallback_Gun_Game_MatchEndAnnouncement", true, file.winner.GetTeam() )
            } else { //If not in winning team
                Remote_CallFunction_NonReplay( playerO, "ServerCallback_Gun_Game_MatchEndAnnouncement", false, file.winner.GetTeam() )
            }
	    }
    } else {
        //Launch end screen ("You are the champion") for each player
	    foreach ( playerO in GetPlayerArray() )
	    {
        printl("DEBUG: " + file.winner.GetPlayerName() + " " + playerO.GetTeam())

	    	Remote_CallFunction_NonReplay( playerO, "ServerCallback_PlayMatchEndMusic" )
	    	Remote_CallFunction_NonReplay( playerO, "ServerCallback_Gun_Game_MatchEndAnnouncement", true, playerO.GetTeam() )
	    }
    }
	wait 6

    //Add winning data (required by the sequence)
    if (file.winner != null) {
	     foreach ( playerO in GetPlayerArray() )
	      {
          printl("DEBUG: " + file.winner.GetPlayerName() + " " + playerO.GetTeam())
     	    Remote_CallFunction_NonReplay(playerO, "ServerCallback_Gun_Game_AddWinningSquadData", 0, file.winner.GetEncodedEHandle())
	      }
     }

    //Play end cinematic
	foreach( playerO in GetPlayerArray() ) {
		thread Remote_CallFunction_NonReplay(playerO, "ServerCallback_Gun_Game_DoVictory")
	}

	wait 8

    SetGameState(eGameState.MapVoting)
}
*/


void function _GunGameHandleRespawn(entity player, bool forceGive = false)
{
    if(!IsValid(player)) return

    if( player.IsObserver())
    {
        player.StopObserverMode()
        Remote_CallFunction_NonReplay(player, "ServerCallback_KillReplayHud_Deactivate")
    }

    if(!IsAlive(player))
    {
        DecideRespawnPlayer(player)     
    }

    SetPlayerSettings(player, GUN_GAME_PLAYER_SETTINGS)
    PlayerRestoreHP(player, 100)
    PlayerRestoreShields(player, player.GetShieldHealthMax())

    TpPlayerToSpawnPoint(player)
    thread GrantSpawnImmunity(player, 3)
}


//
//
// CONSOLE COMMANDS
//
//

bool function ClientCommand_NextRound(entity player, array<string> args)
{
    if( !IsServer() ) return false
    file.winner = player
    SetGameState(eGameState.WinnerDetermined)
    return true
}

bool function ClientCommand_ClearInvincibleAll(entity player, array<string> args) {
    foreach ( playerO in GetPlayerArray() )
	{
		playerO.ClearInvulnerable()
	}

    return true
}

bool function ClientCommand_ClearInvincible(entity player, array<string> args) {
	player.ClearInvulnerable()
    return true
}

bool function ClientCommand_RemovePassive(entity player, array<string> args) {
	player.RemovePassive( ePassives.PAS_PILOT_BLOOD )
    return true
}

bool function ClientCommand_AddPassive(entity player, array<string> args) {
    GivePassive(player, ePassives.PAS_PILOT_BLOOD)
    return true
}
