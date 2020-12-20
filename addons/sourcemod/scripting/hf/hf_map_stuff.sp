#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <sdktools>

ConVar g_mp_disable_respawn_times; //self explanatory. Convar to disable respawn times thru script.
ConVar g_tf_halloween_kart_fast_turn_speed;
ConVar g_tf_halloween_kart_impact_damage;
ConVar g_tf_dropped_weapon_lifetime;
ConVar g_mp_stalemate_enable; //self explanatory
ConVar g_mp_stalemate_timelimit; //self explanatory, default 240
ConVar g_tf_weapon_criticals; //self explanatory, default 1
ConVar g_tf_use_fixed_weaponspreads; //self explanatory, default 0
ConVar g_mp_waitingforplayers_time; //just to get the time.

int waitingForPlayers;
bool waitingForPlayersInitiated = false;
int waitingForPlayersTimer;

//int iCurrentmapTimer; //
//int iForcedMapTimer = 600; //todo, enforce stalemate if match goes for way too long.
//bool bEnforcedStalemate;

float fStoredStockCVARValues[5]; //initial start up, storing server default values
int iStoredStockCVARValues[5]; //initial start up, storing server default values
bool bStoredStockCVARValues[5]; //initial start up, storing server default values

public void hf_ms_Start()
{
	g_mp_disable_respawn_times =  FindConVar("mp_disable_respawn_times"); //finds the stock cvar
	g_tf_halloween_kart_fast_turn_speed =  FindConVar("tf_halloween_kart_fast_turn_speed");
	g_tf_halloween_kart_impact_damage =  FindConVar("tf_halloween_kart_impact_damage");
	g_tf_dropped_weapon_lifetime = FindConVar("tf_dropped_weapon_lifetime");
	g_mp_stalemate_enable = FindConVar("mp_stalemate_enable");
	g_mp_stalemate_timelimit = FindConVar("mp_stalemate_timelimit");
	g_tf_weapon_criticals  = FindConVar("tf_weapon_criticals"); //self explanatory, default 1
	g_tf_use_fixed_weaponspreads  = FindConVar("tf_use_fixed_weaponspreads"); //self explanatory, default 0
	g_mp_waitingforplayers_time = FindConVar("mp_waitingforplayers_time");
	waitingForPlayersTimer = GetConVarInt(g_mp_waitingforplayers_time);
	
	fStoredStockCVARValues[0] = g_tf_halloween_kart_impact_damage.FloatValue;
	fStoredStockCVARValues[1] = g_tf_dropped_weapon_lifetime.FloatValue;
	fStoredStockCVARValues[2] = g_mp_stalemate_timelimit.FloatValue;
	
	iStoredStockCVARValues[0] = g_tf_halloween_kart_fast_turn_speed.IntValue;
	iStoredStockCVARValues[1] = g_tf_weapon_criticals.IntValue;
	iStoredStockCVARValues[2] = g_tf_use_fixed_weaponspreads.IntValue;
	
	
	bStoredStockCVARValues[0] = g_mp_disable_respawn_times.BoolValue;
	bStoredStockCVARValues[1] = g_mp_stalemate_enable.BoolValue;
	
}

public void hf_ms_MapStart()
{
	g_mp_disable_respawn_times.SetBool(true); //sets it on
	g_tf_halloween_kart_fast_turn_speed.SetFloat(125.0);
	g_tf_halloween_kart_impact_damage.SetFloat(0.2);
	g_tf_dropped_weapon_lifetime.SetFloat(0.0);
	//g_mp_stalemate_enable.SetBool(true);
	g_mp_stalemate_timelimit.SetFloat(120.0);
	
	g_tf_weapon_criticals.SetInt(0);
	g_tf_use_fixed_weaponspreads.SetInt(1);
	waitingForPlayers = 0;
	waitingForPlayersInitiated = false;
}

public void hf_ms_CvarReset()
{
	g_mp_disable_respawn_times.SetBool(bStoredStockCVARValues[0]);
	g_tf_halloween_kart_fast_turn_speed.SetInt(iStoredStockCVARValues[0]);
	g_tf_halloween_kart_impact_damage.SetFloat(fStoredStockCVARValues[0]);
	g_tf_dropped_weapon_lifetime.SetFloat(fStoredStockCVARValues[1]);
	g_mp_stalemate_enable.SetBool(bStoredStockCVARValues[1]);
	g_mp_stalemate_timelimit.SetFloat(fStoredStockCVARValues[2]);
	g_tf_weapon_criticals.SetInt(iStoredStockCVARValues[1]);
	g_tf_use_fixed_weaponspreads.SetInt(iStoredStockCVARValues[2]);
}
