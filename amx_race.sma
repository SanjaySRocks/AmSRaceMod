// Added drop block
// added random weapons
// Added Screen Fade on kill
// added hostname and game name change
// Some code optimaztion

#include <amxmodx>
#include <reapi>
#include <cromchat>
#pragma compress 1

#define VERSION "1.3a-beta"

new gCvarRaceTarget;
new gRaceTarget;
new bool:gRaceStart=false;
new bool:gRaceLive=false;
new bool:gWinnerFound=false;

//new giWinnerID;
new giFrag, giDeath;
new gszWinnerName[32];
new g_maxplayers;

new PrimaryWeapons[17][]=
{
    {CSW_SCOUT,"weapon_scout","ammo_762nato",10},
    {CSW_XM1014,"weapon_xm1014","ammo_buckshot",7},
    {CSW_MAC10,"weapon_mac10","ammo_45acp",30},
    {CSW_AUG,"weapon_aug","ammo_556nato",30},
    {CSW_UMP45,"weapon_ump45","ammo_45acp",25},
    {CSW_SG550,"weapon_sg550","ammo_556nato",30},
    {CSW_FAMAS,"weapon_famas","ammo_556nato",25},
    {CSW_AWP,"weapon_awp","ammo_338magnum",10},
    {CSW_MP5NAVY,"weapon_mp5navy","ammo_9mm",30},
    {CSW_M249,"weapon_m249","ammo_556nato",100},
    {CSW_M3,"weapon_m3","ammo_buckshot",8},
    {CSW_M4A1,"weapon_m4a1","ammo_556nato",30},
    {CSW_TMP,"weapon_tmp","ammo_9mm",30},
    {CSW_G3SG1,"weapon_g3sg1","ammo_762nato",30},
    {CSW_SG552,"weapon_sg552","ammo_556nato",30},
    {CSW_AK47,"weapon_ak47","ammo_762nato",30},
    {CSW_P90,"weapon_p90","ammo_57mm",50}
}

new SecWeapons[6][]=
{
    {CSW_GLOCK18,"weapon_glock18","ammo_9mm",20},
    {CSW_USP,"weapon_usp","ammo_45acp",12},
    {CSW_P228,"weapon_p228","ammo_357sig",13},
    {CSW_DEAGLE,"weapon_deagle","ammo_50ae",7},
    {CSW_FIVESEVEN,"weapon_fiveseven","ammo_57mm",20},
    {CSW_ELITE,"weapon_elite","ammo_9mm",30}

}

new g_szhostname[64]
new msgScreenFade;

public plugin_init() {
    register_plugin("AmS Race Mod", VERSION, "SkY#IN")
    register_cvar("AmSRaceMod", VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)

    gCvarRaceTarget = register_cvar("amx_racetarget","50");
    //Commands
    register_clcmd("say /startrace","funcStartRace");
    register_clcmd("say /stoprace", "funcStopRace")
    register_clcmd("amx_startrace", "funcStartRace")
    register_clcmd("amx_stoprace", "funcStopRace")
    register_clcmd("drop","HandleDrop");

    RegisterHookChain(RG_CBasePlayer_Spawn, "GiveRandom", true);

    msgScreenFade = get_user_msgid("ScreenFade")
    g_maxplayers = get_maxplayers()

    get_cvar_string("hostname", g_szhostname, 63)
}

public GiveRandom(id)
{
    if(gRaceLive)
    {
        new pnum = random_num(0, 16);
        new snum = random_num(0, 5);

        rg_remove_all_items(id, false);
        rg_give_item(id, PrimaryWeapons[pnum][1])
        rg_give_item(id, SecWeapons[snum][1])
        rg_give_item(id, "weapon_knife");
    }
}

public HandleDrop(id)
{
    if(gRaceLive)
    {
        CC_SendMessage(id, "&x03You &x04cannot drop &x03your weapon &x01during &x04race")
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}


public funcStartRace(id)
{
    if(!gRaceStart)
    {
        if(!(get_user_flags(id) & ADMIN_KICK))
        {
            CC_SendMessage(id, "&x04You don't have access to race command.")
            return PLUGIN_HANDLED;
        }
        gRaceStart=true;

        gRaceTarget = get_pcvar_num(gCvarRaceTarget);

        new szName[32];
        get_user_name(id, szName, 31);

        CC_SendMessage(0, "&x03[AmS GAMinG] &x04Race Activated &x03Starting &x01in &x045secs");
        CC_SendMessage(0, "&x03[AmS GAMinG] &x04Race Target &x01is &x04%d &x03Kills .", gRaceTarget)
        log_to_file("addons/amxmodx/logs/race.log","Admin %s Started Race", szName)

        set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 6.0, 0.1, 0.2)
        show_dhudmessage(0, "Race Activated by Admin^nTarget %d Frags ", gRaceTarget);
        client_cmd(0, "spk ^"fvox/activated five four three two one^"");
        set_task(5.0, "LoadRaceSetting");   
    }
    return PLUGIN_HANDLED;
}

public LoadRaceSetting()
{
    server_cmd("hostname ^"%s [LIVE RACE ON]^"", g_szhostname)

    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Loading Race Settings!!")
    set_task(3.0, "funcRestart", _, _, _, "a", 3); 
    set_task(12.0,"StartRace");
    set_task(13.0,"GiveWeaponOnStart");
}

public StartRace()
{
    server_cmd("mp_forcerespawn 1.0")
    server_cmd("mp_respawn_immunitytime 2")
    server_cmd("mp_round_infinite ^"abcdefg^"")

    server_cmd("mp_item_staytime 2");
    server_cmd("mp_buytime 0.0");
    server_cmd("mp_maxmoney 99999");
    server_cmd("mp_infinite_ammo 2");


    gRaceLive=true;
    
    set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 6.0, 0.1, 0.2)
    show_dhudmessage(0, "Race IS LIVE GO GO GO !!!");
    
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Race is &x03LIVE");
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Race is &x03LIVE");
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Race is &x03LIVE");

    set_task(1.0, "best_player", _, _, _, "b")
}

public GiveWeaponOnStart()
{
    new iPlayers[32], iPnum, iPlayer
    get_players(iPlayers, iPnum, "h")

    for(new i = 0; i < iPnum; i++)
    {
        iPlayer = iPlayers[i]
        GiveRandom(iPlayer);
    } 
}


GetPlayers()
{
    static Players, id 
    Players= 0
    for (id = 1; id <= g_maxplayers; id++)
    {
        if(is_user_connected(id)) 
            Players++
    }
    return Players
}

GetRandomPlayers(n)
{
    static Players, id 
    Players= 0
    for (id = 1; id <= g_maxplayers; id++)
    {
        if(is_user_connected(id)) 
            Players++
        
        if (Players == n)
            return id;
    }
    return -1;
}

public best_player()
{
    if(!gRaceStart)
        return;

    if(gWinnerFound)
        return
    
    static iPlayersnum; iPlayersnum = GetPlayers()
    if (iPlayersnum < 1) return;
    static best; best = GetRandomPlayers(random_num(1, iPlayersnum))
    
    for (new i = 1; i < g_maxplayers; i++)
    {
        if (!is_user_connected(i)) continue;
        
        if (get_user_frags(i) > get_user_frags(best))
            best = i
        else if (get_user_frags(i) == get_user_frags(best) && get_user_deaths(i) < get_user_deaths(best))
            best = i
        else if (get_user_frags(i) == get_user_frags(best) && get_user_deaths(i) == get_user_deaths(best))
            best = i
    }
    
    new g_playername[32];
    get_user_name(best, g_playername, 31);

    set_dhudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.0, 0, 6.0, 1.0, 0.1, 0.2)
    show_dhudmessage(0, "[ Race Leader ]")

    set_dhudmessage(192,192,192, -1.0, 0.06, 0, 6.0, 1.0, 0.1, 0.2)
    show_dhudmessage(0, "%s [kills %d]", g_playername, get_user_frags(best))

    server_cmd("hostname ^"%s [Race Leader: %s ]^"", g_szhostname, g_playername);

    if(get_user_frags(best) >= gRaceTarget)
    {
        //giWinnerID = best;
        giFrag = get_user_frags(best)
        giDeath = get_user_deaths(best)

        formatex(gszWinnerName, charsmax(gszWinnerName), g_playername);
        gWinnerFound = true;

        client_cmd(0, "spk ^"fvox/bell^"")
        server_cmd("mp_freezetime 999")
        server_cmd("sv_restart 1");
        set_task(4.0, "ShowRaceWinner");
        set_task(10.0, "LoadPubSetting")
        set_task(13.0, "funcRestart");
    }
} 



public ShowRaceWinner()
{
    // CC_SendMessage(0, "RAce Winner is %s", gszWinnerName);
    set_dhudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 8.0, 0.1, 0.2)
    show_dhudmessage(0, "====================^n Race Winner ^n====================");

    set_dhudmessage(255, 255, 255, -1.0, 0.36, 0, 6.0, 8.0, 0.1, 0.2)
    show_dhudmessage(0, "%s^nScore ( %d : %d ) ^n^n Congratulations !", gszWinnerName, giFrag, giDeath)

    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Loading Pub Settings!!")

}



public LoadPubSetting()
{
    gRaceLive=false;
    gRaceStart=false;
    gWinnerFound=false;

    server_cmd("mp_forcerespawn 0")
    server_cmd("mp_respawn_immunitytime 0")
    server_cmd("mp_round_infinite ^"0^"")

    // Reset to default 
    server_cmd("mp_item_staytime 300");
    server_cmd("mp_buytime 1.5")
    server_cmd("mp_maxmoney 16000");
    server_cmd("mp_infinite_ammo 0");

    //Load Server.cfg
    server_cmd("exec server.cfg");
}


public funcRestart()
{
    server_cmd("sv_restartround 1");
}


public funcStopRace(id)
{
    if(!(get_user_flags(id) & ADMIN_KICK))
    {
        CC_SendMessage(id, "&x04You don't have access to race command.")
        return PLUGIN_HANDLED;
    }

    if(gRaceStart || gRaceLive)
    {
        LoadPubSetting()
        CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Force Ended Race !!! Loading Pub Setting")
        server_cmd("sv_restart 3");
    }
    return PLUGIN_HANDLED;
}

public client_death(attacker, victim, weaponid, hitplace, tk)
{
    if(gRaceLive)
    {
        if(is_user_alive(attacker) && is_user_connected(attacker))
        {
            fadeScreen(attacker, 30, 144, 255, 75);
        }
    }
}

stock fadeScreen(id, red, green, blue, amount)
{
    if (amount > 255)
        amount = 255
    
    message_begin(MSG_ONE_UNRELIABLE, msgScreenFade, {0,0,0}, id)
    write_short(1<<10)//D
    write_short(1<<10)//H
    write_short(0x0000)//T
    write_byte(red)
    write_byte(green)
    write_byte(blue)
    write_byte(amount)
    message_end()
}  