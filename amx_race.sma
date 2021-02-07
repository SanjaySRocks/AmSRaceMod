#include <amxmodx>
#include <amxmisc>
#include <cromchat>

#define VERSION "1.1-beta"

// Set Your Target Frags Here
#define FRAGS 2

// Uncomment to Enable Deathmatch Mode during RACE
//#define ENABLE_DM

new bool:gRaceStart=false;
new bool:gRaceLive=false;
new bool:gWinnerFound=false;

new gszWinnerName[32];
new g_maxplayers;


public plugin_init() {
    register_plugin("AmS Race Mod", VERSION, "SkY#IN")
    register_cvar("AmSRaceMod", VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)

    //Commands
    register_clcmd("say /startrace","funcStartRace");
    register_clcmd("say /stoprace", "funcStopRace")

    g_maxplayers = get_maxplayers()
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


        CC_SendMessage(0, "&x03[AmS GAMinG] &x04Race Activated &x03Starting &x01in &x045secs");

        set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 6.0, 0.1, 0.2)
        show_dhudmessage(0, "Race Activated by Admin^nTarget %d Frags ", FRAGS);

        set_task(5.0, "LoadRaceSetting");    
    }
    return PLUGIN_HANDLED;
}

public LoadRaceSetting()
{
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Loading Race Settings!!")
    set_task(2.0,"funcRestart", _,_,_,"a", 2);
    set_task(8.0,"StartRace")
}

public StartRace()
{
    #if defined ENABLE_DM
        server_cmd("mp_forcerespawn 1.0")
        server_cmd("mp_item_staytime 5")
        server_cmd("mp_respawn_immunitytime 2")
        server_cmd("mp_respawn_immunity_effects 1")
    #endif

    server_cmd("mp_buytime -1");
    server_cmd("mp_maxmoney 99999");


    gRaceLive=true;
    
    set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 6.0, 0.1, 0.2)
    show_dhudmessage(0, "Race IS LIVE GO GO GO !!!");
    
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Race is &x03LIVE");
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Race is &x03LIVE");
    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Race is &x03LIVE");


    set_task(1.0, "best_player", _, _, _, "b")
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

    if(get_user_frags(best) >= FRAGS)
    {
        formatex(gszWinnerName, charsmax(gszWinnerName), g_playername);
        gWinnerFound = true;

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
    set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 6.0, 0.1, 0.2)
    show_dhudmessage(0, "====================^n Race Winner ^n====================^n%s^nCongratulations !", gszWinnerName);

    CC_SendMessage(0, "&x03[AmS GAMinG]  &x04Loading Pub Settings!!")
}



public LoadPubSetting()
{
    gRaceLive=false;
    gRaceStart=false;
    gWinnerFound=false;

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