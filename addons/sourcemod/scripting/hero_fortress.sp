#pragma semicolon 1
#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2attributes>
#include <tf_econ_data>
#include <morecolors> //only for compiling
//#include <dhooks>

#define TF_ATTR_MAX_HEALTH 26 //self explanatory.
#define TF_ATTR_MAX_HEALTH_PENALTY 125  //self explanatory.

#define TF_ATTR_RELOADTIME 97
#define TF_ATTR_HEALTHREGEN 57 
#define TF_ATTR_DEFLECTOR 130   
#define TF_ATTR_WEAPON_SWITCH_SPEED 178
#define TF_ATTR_NO_FALL_DAMAGE 275
#define TF_ATTR_AMMO_REGEN 112
#define TF_ATTR_DROP_HEALTH 203
#define TF_ATTR_CAPRATE 68
#define TF_ATTR_SPEED_BONUS 107
#define TF_ATTR_EXTRA_SENTRY 286
//extra charges
#define TF_ATTR_CHARGE_METER 874 //redo, it no worki
#define TF_ATTR_CHARGE_METER_PU 2034
//extra charges

#define TF_ATTR_EXTRA_JUMP_HEIGHT 326
#define TF_ATTR_DAMAGE_BONUS 2
#define TF_ATTR_SLOW 182
#define TF_ATTR_DAMAGE_TO_HEAL_SELF 137

#define TF_ATTR_METAL_REGEN 113
#define TF_ATTR_FAST_MELEE 397
#pragma newdecls required
#define TF_MAXPLAYERS 32

//Thanks based Kennzer/Benoist
ArrayList g_aClientSentries[TF_MAXPLAYERS+1];
Handle g_hTimerClientCleanUpSentries[TF_MAXPLAYERS+1];

// double spawn notif fix
int initialNotificationSpamTimer[TF_MAXPLAYERS+1];
bool initialNotificationBool[TF_MAXPLAYERS+1];

//self exppatory
int iHintTimer;

//item cooldowns
int iOiledUpCD[TF_MAXPLAYERS+1];
int iJumpSuitCD[TF_MAXPLAYERS+1];
int iBoneBreakerCD[TF_MAXPLAYERS+1];
int iConsumableItemCD[TF_MAXPLAYERS+1];

//bool bNotifyOfStalemate = false; //old function for maps that didnt have timer that crashed the server. Too bad!

//SDK offsets
//int g_iOffsetItemDefinitionIndex;
//int g_iOffsetOuter;

///disclaimer:
/// this code is shit.

public Plugin myinfo =
{
	name = "Hero Fortress",
	author = "Kirillian, with help of Redsun.tf developers! (Especially big thank to Kennzer(Benoist)))",
	description = "Hero Fortress is a custom TF2 gamemode that gives each class an ultimate ability, and makes the gameplay closer to MOBAs.",
	version = "1.2",
	url = "null"
};

int iCredits[TF_MAXPLAYERS + 1];

int iUltChargeRequired; // currently just 100. Name is self explanatory.
int iUltChargePerPlayer[TF_MAXPLAYERS+1]; //CURRENT ultimate charge for each player
bool[TF_MAXPLAYERS+1] bUltReadyPerPlayer; //bool for each player who has the ultimate ready.

float fUltimateSpeedRate[10]; //ult secs before adding percents now.
float fUltimateSpeedRateCurrent[TF_MAXPLAYERS+1]; //current secs before giving the ult percentage

bool[TF_MAXPLAYERS+1] bHpPerPlayer; //for checking if player has added HP

bool bPlayerNewMaxHP[TF_MAXPLAYERS+1]; //self explanatory.
int bPlayerBaseMaxHP[TF_MAXPLAYERS+1]; //self explanatory.

float fChill[TF_MAXPLAYERS+1]; //command rate limiter. shit's wild.

int iUltimateSecondsLeft[TF_MAXPLAYERS+1]; //stopping the ult charge rate with this for now.

int iStoredWeaponIndexPrimary[TF_MAXPLAYERS+1]; //for ults that store the primary weapon info. //reuse to be used as tfecon fuckerooni.
bool bRentingUltWeapon[TF_MAXPLAYERS+1]; //check for "rented" weapon, basically if bool = true, that means its using a custom ultimate weapon.

float fDamageDealtByPlayerForUlt[TF_MAXPLAYERS+1]; //damage dealt by player before getting extra ulti
float fDamageDealtByPlayerForCreds[TF_MAXPLAYERS+1]; //damage dealt by player before getting extra ulti

int iMedicsHealingTargets[TF_MAXPLAYERS+1];

bool bCheckIfAustralium[TF_MAXPLAYERS+1]; //

int iPlayerLateCompensationSeconds[TF_MAXPLAYERS+1];

//int g_off_m_Item;

#include "hf/hf_stocks.sp"
#include "hf/hf_functions.sp"
#include "hf/hf_map_stuff.sp"
#include "hf/hf_caching.sp"
#include "hf/hf_menus.sp"
#include "hf/hf_include.sp" 
//#include "hf/hf_sdkcall.sp" 
//#include "hf/hf_dhook.sp"
#include <clientprefs>

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegInclude();
}

public void OnPluginStart() //
{
	//set up ultimate rates
	iHintTimer = 60;
	fUltimateSpeedRate[0] = 0.0; // haha funny array starts at 1
	fUltimateSpeedRate[1] = 1.0; //scout
	fUltimateSpeedRate[2] = 0.5; //sniper
	fUltimateSpeedRate[3] = 0.5; //soldier
	fUltimateSpeedRate[4] = 0.5; //demoman
	fUltimateSpeedRate[5] = 0.5; //medic
	fUltimateSpeedRate[6] = 0.5; //heavy
	fUltimateSpeedRate[7] = 1.0; //pyro
	fUltimateSpeedRate[8] = 1.0; //spy
	fUltimateSpeedRate[9] = 0.50;  //engi
	
	iUltChargeRequired = 99; //self explanatory
	for(int i = 1; i < TF_MAXPLAYERS+1; i++) //reset / setup ults for the initial plugin load.
	{
		iUltChargePerPlayer[i] = 0;
		iPlayerIsClassID[i] = 0;
		fChill[i] = 0.0;
		bRentingUltWeapon[i] = false;
		bInSpawn[i] = false;
		iPlayerHasConsumableType[i] = 0;
	}
	CreateHudSynchronizer();
	PreCacheGameModeSounds();     //cache the sounds
	hf_ms_Start(); //initiate gamemode stuff
	OnMapStart();
	RegCommands();
	HookEvents();
	
	int iSpawn = -1;
	
	while ((iSpawn = FindEntityByClassname(iSpawn, "func_respawnroom")) != -1)
	{
		// this is literally just spawn room detection
		SDKHook(iSpawn, SDKHook_StartTouch, SpawnStartTouch);
		SDKHook(iSpawn, SDKHook_EndTouch, SpawnEndTouch);
	}
	
	PrintToServer("Welcome to Hero Fortress");
	
	AddModelToDownloadsTable("models/kirillian/buildables/drone.mdl");
	initiateTickRate();
}

void HookEvents()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("teamplay_round_start", OnTeamplayRoundStart);
	HookEvent("player_changeclass", OnPlayerChangeClass);
	HookEvent("player_hurt", OnPlayerDamaged);
	HookEvent("teamplay_point_captured", TeamplayPointCaptured);
}

void RegCommands()
{
	RegConsoleCmd("sm_ult", hf_Ultimate, "Use your ultimate ability.");
	RegConsoleCmd("sm_ultimate", hf_Ultimate, "Use your ultimate ability.");
	RegConsoleCmd("sm_hf_ult_charge", DebugUlt, "Debug, make everyone's ult 100%."); //self explanatory, don't use otherwise.
	RegConsoleCmd("sm_hf_ult_charge_self", DebugUltOnlyClient, "Debug, make your ult 100%."); //self explanatory, don't use otherwise.
	RegConsoleCmd("sm_free_money", DebugUltOnlyClientMoney, "Debug, make your ult 100%."); //self explanatory, don't use otherwise.
	RegConsoleCmd("hf_shop", Item_Shop_Offense);
	RegConsoleCmd("hf_shop_consumable", Item_Shop_Consumable);
	RegConsoleCmd("hf_consumable", ActivateConsumableItem);
	RegConsoleCmd("hf", hf_main_menu);
	RegConsoleCmd("hf_cl", hf_main_menu_classes);
	RegConsoleCmd("hf_se", hf_main_menu_settings);
	RegConsoleCmd("hf_ch", hf_main_menu_changelog);
	RegConsoleCmd("hf_co", hf_main_menu_commands);
	RegConsoleCmd("hf_sell", Item_Shop_Sell);
}

public void OnMapStart()
{
	PrecacheModels_GameMode();
	hf_ms_MapStart();
	for(int i = 1; i < TF_MAXPLAYERS+1; i++) //reset / setup ults for the initial plugin load.
	{
		iUltChargePerPlayer[i] = 0;
		iPlayerIsClassID[i] = 0;
		fChill[i] = 0.0;
		bRentingUltWeapon[i] = false;
		iCredits[i] = 300;
		iCustomItemSlot_0[i] = -1;
		iCustomItemSlot_1[i] = -1;
		iCustomItemSlot_2[i] = -1;
		iPlayerLateCompensationSeconds[i] = 0;
		bInSpawn[i] = false;
		
		initialNotificationSpamTimer[i] = 0;
		initialNotificationBool[i] = false;
		iConsumableItemCD[i] = 0;
	}
}

public void OnPlayerDamaged(Handle hEvent, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int damage = GetEventInt(hEvent, "damageamount");
	if(IsValidClient(victim))
	{
		if(victim != attacker)
		{
			/// for bought items p much.
			
			if(iCustomItemSlot_0[attacker] == 4 || iCustomItemSlot_1[attacker] == 4 || iCustomItemSlot_2[attacker] == 4)
			{
				//TF2_AddCondition(victim, 27, 1.0 , 0); //mad milk
			}
			if(iCustomItemSlot_0[attacker] == 5 || iCustomItemSlot_1[attacker] == 5 || iCustomItemSlot_2[attacker] == 5)
			{
				TF2_AddCondition(victim, TFCond_HealingDebuff , 1.0 , 0); //healing debuff
			}
			///
			if(iCustomItemSlot_0[attacker] == 6 || iCustomItemSlot_1[attacker] == 6 || iCustomItemSlot_2[attacker] == 6)
			{
				TF2_AddCondition(victim, TFCond_Gas  , 1.0 , 0); //gas hass been passed debuff
				if(iOiledUpCD[victim] == 0)
				{
					char sPath[64];
					Format(sPath, sizeof(sPath), "weapons/gas_can_inspect_movement3.wav");
					EmitSoundToAll(sPath,victim);
					TF2_IgnitePlayer(victim, attacker, 1.0);
					iOiledUpCD[victim] = 5;
				}
				
			}
			if(iCustomItemSlot_0[attacker] == 17 || iCustomItemSlot_1[attacker] == 17 || iCustomItemSlot_2[attacker] == 17)
			{
				if(iBoneBreakerCD[attacker] == 0)
				{
					char sPath[64];
					Format(sPath, sizeof(sPath), "player/taunt_chest_thump.wav");
					EmitSoundToAll(sPath,victim);
					TF2Attrib_RemoveByDefIndex(attacker, TF_ATTR_SLOW);
					iBoneBreakerCD[attacker] = 1;
				}
			}
			if(iPlayerIsClassID[attacker] == 7 && iUltimateSecondsLeft[attacker] > 0)
			{
				TF2_IgnitePlayer(victim, attacker, 1.0);
			}
			if(iUltimateSecondsLeft[attacker] <=0)
			{
				fDamageDealtByPlayerForUlt[attacker] += damage;
				fDamageDealtByPlayerForCreds[attacker] += damage;
				switch(iPlayerIsClassID[attacker])
				{
					//case 0: ignore
					case 1, 2, 3, 4, 5, 8, 9:
					{
					//	PrintToChat(attacker,"Everyone but heavy and pyro reward.");
						if(fDamageDealtByPlayerForUlt[attacker] > 25)
						{
							iUltChargePerPlayer[attacker]++;
							
						}
						if(fDamageDealtByPlayerForUlt[attacker] > 100)
						{
							iUltChargePerPlayer[attacker]++;
						}
						if(fDamageDealtByPlayerForUlt[attacker] >= 150)
						{
							iUltChargePerPlayer[attacker]++;
							fDamageDealtByPlayerForUlt[attacker] = 0.0;
						}
					}
					case 6: //this is because heavy ultimate rate was insanely high. this is a nerf.
					{
					//	PrintToChat(attacker,"Heavy reward");
						if(fDamageDealtByPlayerForUlt[attacker] > 75)
						{
							iUltChargePerPlayer[attacker]++;
						}
						if(fDamageDealtByPlayerForUlt[attacker] > 170)
						{
							iUltChargePerPlayer[attacker]++;
							fDamageDealtByPlayerForUlt[attacker] = 0.0;
						}
					}
					case 7: //this is because pyro ultimate rate was insanely high. this is a nerf.
					{
						if(fDamageDealtByPlayerForUlt[attacker] > 200)
						{
							iUltChargePerPlayer[attacker]++;
						}
						if(fDamageDealtByPlayerForUlt[attacker] > 350)
						{
							iUltChargePerPlayer[attacker]++;
							fDamageDealtByPlayerForUlt[attacker] = 0.0;
						}
					}
				}
				switch(iPlayerIsClassID[attacker])
				{
					//case 0: ignore
					case 1, 2, 3, 4, 5, 8, 9:
					{
					//	PrintToChat(attacker,"Everyone but heavy and pyro reward.");
						iCredits[attacker] += 1;
					}
					case 6: //tpyro heavy iCredits nerfs
					{
					//	PrintToChat(attacker,"Heavy reward");
						if(fDamageDealtByPlayerForCreds[attacker] > 50)
						{
							iCredits[attacker] += 1;
							fDamageDealtByPlayerForCreds[attacker] == 0;
						}
					}
					case 7: //tpyro heavy iCredits nerfs
					{
					//	PrintToChat(attacker,"Heavy reward");
						if(fDamageDealtByPlayerForCreds[attacker] > 25)
						{
							iCredits[attacker] += 1;
							fDamageDealtByPlayerForCreds[attacker] == 0;
						}
					}
				}
			}
		}
	}
	
	
}

//gameplay functions start here
void OnTeamplayRoundStart( Handle hEvent, const char[] strEventName, bool bDontBroadcast)
{
	//iCurrentmapTimer = 0;
	//bEnforcedStalemate = false;
	for(int i = 1; i < TF_MAXPLAYERS+1; i++)
	{
		if (IsValidClient(i)) //print that message for every character
		{
			{
				bInSpawn[i] = false;
				PrintToChat(i, "\nSay /ult or use SPECIAL ATTACK(Default: Middle Mouse Button) to use your ultimate ability.");
				PrintToChat(i, "Crouch and press spacebar to use your consumable item.");
			}
		}
	}
   //apparently it needs to be cached every round to work properly.
	PreCacheGameModeSounds();
}
void OnPlayerChangeClass( Handle hEvent, const char[] strEventName, bool bDontBroadcast ) //reset ult rate on class change.
{
	int iClient = GetClientOfUserId( GetEventInt( hEvent, "userid" ));
	iUltChargePerPlayer[iClient] = 0;
	bUltReadyPerPlayer[iClient] = false;
}

public void PlayerSpawn (Event hEvent, const char[] sEvName, bool bDontBroadcast)  //initiate the usual shit upon spawning/refreshing loadout.
{
	
	int iClient = GetClientOfUserId( GetEventInt( hEvent, "userid" ));
	if (iClient && IsClientInGame(iClient) && IsPlayerAlive(iClient))
	{
		if(bRentingUltWeapon[iClient] == true)
		{
			int iSentry = -1;
			while ((iSentry = FindEntityByClassname(iSentry, "obj_sentrygun")) != -1)
			{
				
				int iBuilder = GetEntPropEnt(iSentry, Prop_Send, "m_hBuilder");
				if(iBuilder == iClient)
				{
					SetVariantInt(1000);
					AcceptEntityInput(iSentry, "RemoveHealth");
				}
				
				
			}
		}
		iStoredWeaponIndexPrimary[iClient] = 0; //reset stored weapon on respawn
		SetHudTextParams(-1.0,0.2, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
		if(GetClientTeam(iClient) != 1 && iPlayerIsClassID[iClient] != 0) //no idea whats wrong with that warning
		{
			ClientCommand(iClient, "hf");
			ResetModel(iClient);
			waitingForPlayersInitiated = true;
			CPrintToChat(iClient, "{lightgreen}YOU JUST SPAWNED, YOU MOVE FASTER FOR 10 SECONDS.");
			CPrintToChat(iClient, "{yellow}To check balance info and what your ult does, click Class Info in Hero Fortress menu. Just press TAB + Reload in spawn!");
		}
		bPlayerNewMaxHP[iClient] = false;
		iUltimateSecondsLeft[iClient] = 0;
		bRentingUltWeapon[iClient] = false;
		bHpPerPlayer[iClient] = false;
		fDamageDealtByPlayerForUlt[iClient] = 0.0;
		int class = GetEventInt(hEvent, "class");
		bInSpawn[iClient] = true;
		
		switch(class)
		{
//			case 0:
//			{
//				PrintToServer("You are not supposed to exist.");
//			}
			case 1:
			{
			//	CPrintToChat(iClient, "You are now playing as {gold}Scout!");
				AddHP(iClient, 25);
				SetEntityHealth(iClient, 150); //max hp reset cause needed
			}
			case 2:
			{
			//	CPrintToChat(iClient, "You are now playing as a {gold}Sniper!");
				AddHP(iClient, 25);
				SetEntityHealth(iClient, 150); //max hp reset cause needed
			}
			case 3:
			{
			//	CPrintToChat(iClient, "You are now playing as a {gold}Soldier!");
				AddHP(iClient, 25);
				SetEntityHealth(iClient, 225); //max hp reset cause needed
			}
			case 4:
			{
				//CPrintToChat(iClient,"You are now playing as {gold}Demoman.");
				AddHP(iClient, 50);
				SetEntityHealth(iClient, 225); //max hp reset cause needed
				
			}
			case 5:
			{
			//	CPrintToChat(iClient,"You are now playing as {gold}Medic.");
				int primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
				TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
				primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
				if (primaryShot == -1)
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					TF2Items_SetClassname(item, "TF_WEAPON_SHOTGUN_PRIMARY"); //panic attack
					
					TF2Items_SetItemIndex(item, 1153);
					TF2Items_SetAttribute(item, 1, 97, 0.50);
					TF2Items_SetAttribute(item, 0, 25, 0.75);
					TF2Items_SetAttribute(item, 2, 17, 0.04); //4% ult charge
					TF2Items_SetNumAttributes(item, 3);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
				AddHP(iClient, 0);
				SetEntityHealth(iClient, 150); //max hp reset cause needed
			}
			case 6:
			{
			//	CPrintToChat(iClient,"You are now playing as {gold}Heavy.");
				AddHP(iClient, 100);
				SetEntityHealth(iClient, 400); //max hp reset cause needed
			}
			case 7:
			{
				//CPrintToChat(iClient,"You are now playing as {gold}Pyro.");
				AddHP(iClient, 25);
				SetEntityHealth(iClient, 200);
			}
			case 8:
			{
				//CPrintToChat(iClient,"You are now playing as {gold}Spy.");
				SetEntityHealth(iClient, 150);
				AddHP(iClient, 25);
				SetEntityHealth(iClient, 150); //max hp reset cause needed
			}
			case 9:
			{
				//CPrintToChat(iClient,"You are now playing as {gold}Engineer.");
				AddHP(iClient, 25);
				SetEntityHealth(iClient, 150); //max hp reset cause needed
			}
		}
		iPlayerIsClassID[iClient] = class;
		CheckItems(iClient,0);
		
		
		TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , 10.0 , 0);
	}
}


public Action OnPlayerRunCmd(int iClient, int &buttons)
{
	if(fChill[iClient] <= 0.0)
	{
		if (buttons & (IN_ATTACK3))
		{
			ClientCommand(iClient, "sm_ult");
			fChill[iClient] = 0.25;
		}
		if (buttons & (IN_SCORE) && buttons & (IN_RELOAD))
		{
			ClientCommand(iClient, "hf");
			fChill[iClient] = 0.25;
		}
		if (buttons & (IN_DUCK) && buttons & (IN_JUMP)  && (GetEntityFlags(iClient) & FL_ONGROUND) && iConsumableItemCD[iClient] <= 0)
		{
			if(iPlayerHasConsumableAmount[iClient] > 0)
			{
				ClientCommand(iClient, "hf_consumable");
				CPrintToChat(iClient, "{lightgreen} You have used your consumable item.");
				switch(iPlayerHasConsumableType[iClient])
				{
					case 0,1,2:
					{
						hf_func_PlayItemSound(iClient, 0);
						hf_func_SpawnConsumableItem(iClient, iPlayerHasConsumableType[iClient]);
					}
					case 3,4,5:
					{
						hf_func_PlayItemSound(iClient, 1);
						hf_func_SpawnConsumableItem(iClient, iPlayerHasConsumableType[iClient]);
					}
				}
				//PrintToServer("Tried to use consumable on the ground");
				iPlayerHasConsumableAmount[iClient]--;
				fChill[iClient] = 0.25;
				iConsumableItemCD[iClient] = 3;
			}
			
		}
		if (buttons & (IN_JUMP))
		{
			if(iJumpSuitCD[iClient] == 0 && (GetEntityFlags(iClient) & FL_ONGROUND))
			{
				if(iCustomItemSlot_0[iClient] == 16 || iCustomItemSlot_1[iClient] == 16 || iCustomItemSlot_2[iClient] == 16)
				{
					char sPath[64];
					
					Format(sPath, sizeof(sPath), "player/taunt_bunnyhopper_hop5.wav");
					EmitSoundToAll(sPath, iClient);
					iJumpSuitCD[iClient] = 5;
					//PrintToChat(iClient,"Jump suit is on the cooldown %i seconds left.", iJumpSuitCD[iClient]);
				}
			}
		}
	}
}

Action TeamplayPointCaptured(Event hEvent, const char[] name, bool dontBroadcast)
{
	int team = hEvent.GetInt("team"); //no idea whats wrong with that warning
	for(int i = 1; i < TF_MAXPLAYERS+1; i++)
	{
		if(IsValidClient(i))
		{
			if(GetClientTeam(i) == team) //no idea whats wrong with that warning
			{
				CPrintToChat(i,"{green} Your team has been awarded for capturing the objective! + 100 Credits");
				char sPath[64];
				Format(sPath, sizeof(sPath), "mvm/mvm_money_pickup.wav");
				EmitSoundToClient(i,sPath);
				iCredits[i] += 100;
			}
		}
	}
}

public Action ActivateConsumableItem(int iClient,int args) //self explanatory.
{
	
}

public Action hf_Ultimate(int iClient,int args){ //self explanatory.
	args = 0;
	if(!IsPlayerAlive(iClient))
	{
		CPrintToChat(iClient,"{fullred}You must be alive to use your ultimate ability!");
		return Plugin_Handled;
	}
	if(bUltReadyPerPlayer[iClient] == false && iUltimateSecondsLeft[iClient] == 0)
	{
		PrintToChat(iClient,"Your ultimate is not ready yet... Ultimate charge is at %u%%", iUltChargePerPlayer[iClient]);
		return Plugin_Handled;
	}
	else if(IsPlayerAlive(iClient) && bUltReadyPerPlayer[iClient] == true)
	{
		UltimateEvent(iClient);
		return Plugin_Handled;
	}
	else return Plugin_Handled;
}

public void UltimateEvent(int iClient)
{
	if(bInSpawn[iClient] == false)
	{
		
		int primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
		
		
		
		CPrintToChat(iClient,"{lightgreen}You have used your ultimate ability!");
		iUltChargePerPlayer[iClient] = 0;
		bUltReadyPerPlayer[iClient] = false;
		bHpPerPlayer[iClient] = false;

		
		int galaxybrainfix;// If you remove this, weapon swapping ultiamtes break hard. I repeat, this is a workaround.
		
		if(primaryShot != -1)
		{
		
			galaxybrainfix =  GetEntProp(primaryShot, Prop_Send, "m_iItemDefinitionIndex"); // If you remove this, weapon swapping ultiamtes break hard. I repeat, this is a workaround.
			//bCheckIfAustralium[iClient] = TF2_IsWeaponAustralium(galaxybrainfix);
			
			iStoredWeaponIndexPrimary[iClient] = galaxybrainfix; // If you remove this, weapon swapping ultiamtes break hard. I repeat, this is a workaround.
			//sdk call fuckery goes here.
			//iStoredWeaponIndexPrimary[iClient] = SDKCall_GetLoadoutItem(iClient, iPlayerIsClassID[iClient], primaryShot);
			PrintToServer("i%", iStoredWeaponIndexPrimary[iClient]);

			//iStoredWeaponIndexPrimary[iClient] = 0;
		}
		else if(primaryShot == -1)
		{
			galaxybrainfix = 0; // If you remove this, weapon swapping ultiamtes break hard. I repeat, this is a workaround.
		}
		switch(iPlayerIsClassID[iClient])
		{
			//case 0: ignore
			case 1:
			{
				//smokin is used to show that ultimate activated, to do better visual effect for the ultimate activating.
				float ScoutUltDuration = 10.0;
				PrintToServer("Scout Ultimate."); //reduced the reload speed and etc
				TF2_AddCondition(iClient, TFCond_Disguising, ScoutUltDuration , 0);				//smokin
				TF2_AddCondition(iClient, TFCond_RuneAgility  , ScoutUltDuration , 0);
				TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , ScoutUltDuration -1 , 0);			//faster
				TF2_AddCondition(iClient, TFCond_RuneHaste   , ScoutUltDuration , 0);		//haste
				
				SetAmmo(iClient,2, 6);
				//TF2_AddCondition(iClient, TFCond_HalloweenSpeedBoost , 12.0 , 0);	//infinite jumps effect
				iUltimateSecondsLeft[iClient] = RoundToZero(ScoutUltDuration);
			}
			case 2:
			{
				PrintToServer("Sniper Ultimate.");
				float SniperUltDuration = 10.0;
				TF2_AddCondition(iClient, TFCond_Disguising, SniperUltDuration , 0);			//smokin
				TF2_AddCondition(iClient, TFCond_KingAura  , SniperUltDuration , 0);		//faster all
				TF2_AddCondition(iClient, TFCond_CritOnFirstBlood  , SniperUltDuration , 0); 		//crits
				TF2_AddCondition(iClient, TFCond_RunePrecision , SniperUltDuration, 0); 			//accuracy
				iUltimateSecondsLeft[iClient] = RoundToZero(SniperUltDuration);
				
				int coveredPlayers[MAXPLAYERS];
				int count;
				
				for(int i = 1; i < TF_MAXPLAYERS+1; i++)
				{
					if(IsValidClient(i))
					{
						if(GetClientTeam(i) != GetClientTeam(iClient))
						{
							float distanceVector;
							
							float attackerPos[3];
							float victimPos[3];
							
							GetClientAbsOrigin(iClient, attackerPos);
							GetClientAbsOrigin(i, victimPos);
							
							distanceVector = GetVectorDistance(attackerPos, victimPos);
							if(distanceVector < 800.0)
							{
								CPrintToChat(i, "{fullred}You got affected by Sniper's ultimate.");
								TF2_AddCondition(i, TFCond_Jarated , 10.0, 0); 			//piss
								coveredPlayers[count] = i;
								count++;
							}
						}
					}
				}
				
				Forward_OnSniperUseUltimate(iClient, coveredPlayers, count);
			}
			case 3:
			{
				float SoldierUltDuration = 6.0;
				PrintToServer("Soldier Ultimate.");
				TF2_AddCondition(iClient, TFCond_Disguising, SoldierUltDuration , 0);			//smokin
				TF2_AddCondition(iClient, TFCond_SwimmingNoEffects, SoldierUltDuration , 0); 		//airswim 2
				TF2_AddCondition(iClient, TFCond_KingAura  , SoldierUltDuration , 0);		//faster all, regen, fire rate, etc.
				TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , SoldierUltDuration , 0);		//faster
				iUltimateSecondsLeft[iClient] = RoundToZero(SoldierUltDuration);
				ClientCommand(iClient, "firstperson"); // shrug
				
				TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
				primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
				
				
				if (primaryShot == -1)
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					TF2Items_SetClassname(item, "tf_weapon_rocketlauncher"); //demo ult gun
					
					TF2Items_SetItemIndex(item, 15130);
					TF2Items_SetAttribute(item, 0, 6, 0.25); //firerate buff
					TF2Items_SetAttribute(item, 1, 4, 8.00); //clip size
					TF2Items_SetAttribute(item, 2, 104, 0.55); //projectile speed
					
					TF2Items_SetNumAttributes(item, 3);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
				
				bRentingUltWeapon[iClient] = true;
				
				
			}
			case 4:
			{
				float DemomanUltDuration = 8.0;
				PrintToServer("Demoman Ultimate");
				TF2_AddCondition(iClient, TFCond_Disguising, DemomanUltDuration , 0);			//smokin
				TF2_AddCondition(iClient, TFCond_KingAura  , DemomanUltDuration , 0);	 	//faster all
				TF2_AddCondition(iClient, TFCond_CritCola   , DemomanUltDuration , 0); 		//minicrits
				TF2_AddCondition(iClient, TFCond_Disguising   , DemomanUltDuration , 0);		//NoKnock
				iUltimateSecondsLeft[iClient] = RoundToZero(DemomanUltDuration);
				int secondarySlot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Secondary);
				if (primaryShot == -1 && secondarySlot == -1)
				{
					PrintToServer("DemoKnight Ultimate");
					TF2_AddCondition(iClient, TFCond_RuneHaste   , 8.0 , 0);		//haste
					TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , 8.0 , 0);		//faster
					TF2_AddCondition(iClient, TFCond_UberBulletResist, 8.0,0); //bullet resistance, not immunity
				}
				else if (primaryShot != -1 || secondarySlot != -1)
				{
					TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
					primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
					
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					TF2Items_SetClassname(item, "tf_weapon_grenadelauncher"); //demo ult gun
					
					TF2Items_SetItemIndex(item, 1151);
					TF2Items_SetAttribute(item, 0, 6, 0.25); //firerate buff
					TF2Items_SetAttribute(item, 1, 4, 1.00); //clip size
					TF2Items_SetAttribute(item, 2, 99, 4.00); //explosion radius
					//TF2Items_SetAttribute(item, 3, 521 , 1.00); //nuke explosion
					TF2Items_SetAttribute(item, 3, 522 , 1.00); //airfart explosion
					TF2Items_SetNumAttributes(item, 5);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
					bRentingUltWeapon[iClient] = true;
				}
				
			}
			case 5:
			{
				float MedicUltDuration = 8.0;
				PrintToServer("Medic Ultimate.");
				TF2_AddCondition(iClient, TFCond_Disguising, MedicUltDuration , 0);			//smokin
				//TF2_AddCondition(iClient, TFCond_UberchargeFading, 1.0, 0);
				//TF2_AddCondition(iClient, TFCond_BulletImmune, 8.0 , 0); 		//bullet immunity
				//TF2_AddCondition(iClient, TFCond_BlastImmune,  8.0 , 0); 		//blast immunity
				//TF2_AddCondition(iClient, TFCond_FireImmune,  8.0 , 0); 		//fire immunity
				//TF2_AddCondition(iClient, TFCond_Disguising, 8.0 , 0);		//NoKnock
				//TF2_AddCondition(iClient, TFCond_PreventDeath, 8.0 , 0);		//Survive death
				TF2_AddCondition(iClient, TFCond_RadiusHealOnDamage, MedicUltDuration , 0); 		//amputator self heal
				iUltimateSecondsLeft[iClient] = RoundToZero(MedicUltDuration);
				for(int i = 1; i < TF_MAXPLAYERS+1; i++)
				{
					if(IsValidClient(i))
					{
						if(GetClientTeam(i) == GetClientTeam(iClient))
						{
							float distanceVector;
							
							float attackerPos[3];
							float victimPos[3];
							
							GetClientAbsOrigin (iClient, attackerPos);
							GetClientAbsOrigin (i, victimPos);
							
							distanceVector = GetVectorDistance(attackerPos, victimPos);
							if(distanceVector < 700.0)
							{
								CPrintToChat(i, "{lightgreen}Medic used his ultimate.");
								TF2_AddCondition(i, TFCond_UberchargeFading, 1.0, 0);
								SetEntityHealth(i, TF2_GetPlayerMaxHealth(i) + 25);
								//TODO make a circle?
							}
						}
					}
				}
				
			}
			case 6:
			{
				float HeavyUltDuration = 10.0;
				PrintToServer("Heavy Ultimate");
				SetEntityHealth(iClient, 500);
				//TF2_RemoveCondition(iClient, TFCond_Slowed);
				TF2_AddCondition(iClient, TFCond_Disguising, HeavyUltDuration , 0);			//smokin
				TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SPEED_BONUS, 1.55); //speed bonus
				TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , HeavyUltDuration , 0);		//faster
				TF2_AddCondition(iClient, TFCond_Disguising   , HeavyUltDuration , 0);		//NoKnock
				TF2_AddCondition(iClient, TFCond_UberBulletResist   , HeavyUltDuration , 0);		//bullet resistance
				TF2_AddCondition(iClient, TFCond_UberBlastResist   , HeavyUltDuration , 0);		//blast resistance
				TF2_AddCondition(iClient, TFCond_UberFireResist  , HeavyUltDuration , 0);		//fire resistance
				TF2_AddCondition(iClient, TFCond_RuneKnockout  , HeavyUltDuration , 0);		//Knockout
				TF2_AddCondition(iClient, TFCond_CritOnFirstBlood  , HeavyUltDuration , 0); 		//crits
				
				TF2_AddCondition(iClient, TFCond_RestrictToMelee  , HeavyUltDuration , 0);
				//ClientCommand(iClient, "slot3");
				if(IsWeaponSlotActive(iClient,0))
				{
					int weapon;
					weapon = GetPlayerWeaponSlot(iClient, 0);
					int iWeaponState = GetEntProp(weapon, Prop_Send, "m_iWeaponState");
					if(iWeaponState == 3 || iWeaponState == 1 || iWeaponState == 2 )
					{
						SetEntPropEnt(weapon, Prop_Send, "m_iWeaponState", 0);
						TF2_RemoveCondition(iClient, TFCond_Slowed); //heavy speed exploit fix
						
					}
				}
				
				int weapon;
				weapon = GetPlayerWeaponSlot(iClient, 2);
				SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", weapon);
				
				//TF2_RemoveCondition(iClient, TFCond_Slowed);
				
				iUltimateSecondsLeft[iClient] = RoundToZero(HeavyUltDuration);
				bRentingUltWeapon[iClient] = true;
				
			}
			case 7:
			{
				PrintToServer("Pyro ultimate.");
				
				float PyroUltDuration = 8.0;
				TF2_AddCondition(iClient, TFCond_Disguising, PyroUltDuration , 0);			//smokin
				//TF2_AddCondition(iClient, 94  , 8.0 , 0);		//vampire
				TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , PyroUltDuration , 0);		//faster
				TF2_AddCondition(iClient, TFCond_Disguising   , PyroUltDuration , 0);		//NoKnock
				TF2_AddCondition(iClient, TFCond_UberBulletResist, PyroUltDuration ,0); //bullet resistance, not immunity
				iUltimateSecondsLeft[iClient] = RoundToZero(PyroUltDuration);
				//TF2Attrib_SetByDefIndex(iClient, TF_PYRO_ULT_ATTRIBUTE, 5.00); //pyrofart
				SetAmmo(iClient, 0, 450);
				TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
				primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
				
				if (primaryShot == -1)
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					TF2Items_SetClassname(item, "tf_weapon_minigun"); //pyro ult gun //todo
					
					TF2Items_SetItemIndex(item, 1178);
					TF2Items_SetAttribute(item, 1, 6, 1.25); //airblast cost
					TF2Items_SetAttribute(item, 2, 1, 0.25); //airblast cost
					TF2Items_SetAttribute(item, 3, 522, 1.00); //airblast on hit
					TF2Items_SetNumAttributes(item, 4);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
				bRentingUltWeapon[iClient] = true;
				
			}
			case 8:
			{
				float SpyUltDuration = 12.0;
				PrintToServer(" Spy Ultimate,");
				TF2_AddCondition(iClient, TFCond_Disguising, 	SpyUltDuration , 0);		//smokin
				TF2_AddCondition(iClient, TFCond_Stealthed  , SpyUltDuration , 0);		//invis
				iUltimateSecondsLeft[iClient] = RoundToZero(SpyUltDuration);
				
				TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
				primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
				
				if (primaryShot == -1)
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					TF2Items_SetClassname(item, "tf_weapon_revolver"); //spy ult gun
					
					TF2Items_SetItemIndex(item, 751);
					//TF2Items_SetAttribute(item, 1, 522, 4.5); //airblast buff
					TF2Items_SetAttribute(item, 0, 6, 0.15); //firerate buff
					TF2Items_SetAttribute(item, 1, 4, 4.90); //clip size increase
					TF2Items_SetAttribute(item, 2, 37, 16.00); //ammunition increase
					TF2Items_SetAttribute(item, 3, 166 , 2.00); //cloak on hit accuracy
					TF2Items_SetAttribute(item, 4, 1 , -0.90); //damage penalty
					TF2Items_SetAttribute(item, 5, 221 , 0.05); //decloak rate
					TF2Items_SetAttribute(item, 6, 253 , 0.05); //cloak rate
					TF2Items_SetNumAttributes(item, 7);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
				bRentingUltWeapon[iClient] = true;
			}
			case 9:
			{
							//none yet
				PrintToServer("Engineer Ultimate.");
				float EngineerUltDuration = 8.0;
				FunctionCreateSentries(iClient);
				
				TF2_AddCondition(iClient, TFCond_Disguising,  EngineerUltDuration , 0);			//smokin
				TF2_AddCondition(iClient, TFCond_RadiusHealOnDamage  , EngineerUltDuration , 0); 		//amputator self heal
				iUltimateSecondsLeft[iClient] = RoundToZero(EngineerUltDuration);
				
				TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
				primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
				if (primaryShot == -1)
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					TF2Items_SetClassname(item, "tf_weapon_shotgun_primary"); //demo ult gun
					
					TF2Items_SetItemIndex(item, 441);
					TF2Items_SetAttribute(item, 0, 305, 1.00); //tracers
					TF2Items_SetAttribute(item, 1, 4, 0.10); //clip size
					TF2Items_SetAttribute(item, 2, 96, 2.50); //reload time speed
					TF2Items_SetAttribute(item, 3, 2, 1.50); //dps
					TF2Items_SetAttribute(item, 4, 106, 0.10); //accuracy time speed
					TF2Items_SetNumAttributes(item, 5);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
				
				bRentingUltWeapon[iClient] = true;
				
				
				SetEntityHealth(iClient, 300);
				SetUltModelTest(iClient);
			}
		}
		
		
		hf_func_PlayUltimateSound(iClient, iPlayerIsClassID[iClient]); //loudness?
		Forward_OnClientUseUltimate(iClient);
	}
	else
	{
		CPrintToChat(iClient, "{fullred}You can't ultimate in spawn!");
	}
}


public void initiateTickRate() //self explanatory.
{
	CreateTimer(1.0, updateUltRate, _, TIMER_REPEAT);
	CreateTimer(0.1, updateUltButton, _, TIMER_REPEAT);
}

public Action updateUltRate(Handle timer) //self explanatory.
{
  //PrintToServer("Ult Tick Rate.");
	ultChecker();
	return Plugin_Continue;
}

public Action updateUltButton(Handle timer) //self explanatory.
{
  //PrintToServer("Ult Tick Rate.");
	ultCheckerButton();
	return Plugin_Continue;
}

public void GiveClientStockWeapon(int iClient, int weaponIndex)
{
	int primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
	//TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
	primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
	switch(iPlayerIsClassID[iClient]) //system is set up like that for easy implementation of other classes's stuff.
	{
					//case 0: ignore
		case 1:
		{
			PrintToServer("Scout weapon returned.");
		}
		case 2:
		{
			PrintToServer("Sniper weapon returned.");
			TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
			primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
			
			if (primaryShot == -1)
			{
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					if(iStoredWeaponIndexPrimary[iClient] != 1005 && iStoredWeaponIndexPrimary[iClient] != 1092 && iStoredWeaponIndexPrimary[iClient] != 56 && iStoredWeaponIndexPrimary[iClient] != 402 && iStoredWeaponIndexPrimary[iClient] != 1098)
					{
						TF2Items_SetClassname(item, "tf_weapon_sniperrifle"); //if not bow
												//TF2Items_SetAttribute(item, 1, 305, 1.0); //tracer bulletss
					}
					switch(iStoredWeaponIndexPrimary[iClient])
					{
						case 1005, 1092, 56:
						{
							TF2Items_SetClassname(item, "tf_weapon_compound_bow"); //if bow
						}
						case 402:
						{
							TF2Items_SetClassname(item, "tf_weapon_sniperrifle_decap"); // if bazaar bargain
												//TF2Items_SetAttribute(item, 1, 305, 1.0); //tracer bulletss
						}
						case 1098:
						{
							TF2Items_SetClassname(item, "tf_weapon_sniperrifle_classic"); // classic, replace all that shit with a switch tho tbh fam
						}
					}
					TF2Items_SetItemIndex(item, iStoredWeaponIndexPrimary[iClient]);
					
											//TF2Items_SetAttribute(item, 2, 4, 2.00); //clip size
					if(bCheckIfAustralium[iClient] == true)
					{
						TF2Items_SetAttribute(item, 5, 2027, 1.00); //aussie
					}
					TF2Items_SetNumAttributes(item, 6);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
			}
		}
		case 3:
		{
			PrintToServer("Soldier weapon returned.");
			TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
			primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
			
			if (primaryShot == -1)
			{
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					if(iStoredWeaponIndexPrimary[iClient] != 127 && iStoredWeaponIndexPrimary[iClient] != 1104 && iStoredWeaponIndexPrimary[iClient] != 441) //if not direct hit, not air strike, not Life Rip mangler
					{
						TF2Items_SetClassname(item, "tf_weapon_rocketlauncher");
												//TF2Items_SetAttribute(item, 1, 305, 1.0); //tracer bulletss
					}
					switch(iStoredWeaponIndexPrimary[iClient])
					{
						case 127:
						{
							TF2Items_SetClassname(item, "tf_weapon_rocketlauncher_directhit");
						}
						case 1104:
						{
							TF2Items_SetClassname(item, "tf_weapon_rocketlauncher_airstrike");
						}
						case 441:
						{
							TF2Items_SetClassname(item, "tf_weapon_particle_cannon");
						}
					}
					
					TF2Items_SetItemIndex(item, iStoredWeaponIndexPrimary[iClient]);
					
					if(bCheckIfAustralium[iClient] == true)
					{
						TF2Items_SetAttribute(item, 5, 2027, 1.00); //aussie
					}
					TF2Items_SetNumAttributes(item, 6);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
			}
		}
		case 4:
		{
			PrintToServer("Demoman  weapon returned.");
			TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
			if (primaryShot != -1)
			{
				Handle item = TF2Items_CreateItem(PRESERVE_ATTRIBUTES); // FIND ME m_iItemDefinitionIndex < dunno how
				
				if(weaponIndex != 1101 && weaponIndex != 405 && weaponIndex != 608 && weaponIndex != 996 && weaponIndex != 0)
				{
					TF2Items_SetClassname(item, "TF_WEAPON_GRENADELAUNCHER"); //demo ult gun
				}
				switch(iStoredWeaponIndexPrimary[iClient])
				{
					case 996:
					{
						TF2Items_SetClassname(item, "TF_WEAPON_CANNON"); //loool cannon is different ok
					}
					case 405, 608:
					{
						TF2Items_SetClassname(item, "tf_wearable"); //bootis
						ClientCommand(iClient, "invnext");
					}
					case 1101:
					{
						TF2Items_SetClassname(item, "tf_weapon_parachute"); //parachute
						ClientCommand(iClient, "invnext");
					}
					case 0:
					{
						int weapon;
						weapon = GetPlayerWeaponSlot(iClient, 1);
						SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", weapon);
						//TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
					}
				}
				TF2Items_SetNumAttributes(item, 6);
				
				if(bCheckIfAustralium[iClient] == true)
				{
					TF2Items_SetAttribute(item, 5, 2027, 1.00); //aussie
				}
				TF2Items_SetItemIndex(item, weaponIndex);
				
				if(weaponIndex == 0)
				{
					int weapon;
					weapon = GetPlayerWeaponSlot(iClient, 1);
					SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", weapon);
					//	TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
				}
				
				if(weaponIndex != 0)
				{
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					CloseHandle(item);
					EquipPlayerWeapon(iClient, primaryShot);
				}
				
			}
			else if (primaryShot == -1)
			{
				//do nothing
			}
		}
		case 5:
		{
			PrintToServer("Medic weapon returned.");
		}
		case 6:
		{
			PrintToServer("Heavy  weapon returned.");
		}
		case 7:
		{
			PrintToServer("Pyro weapon returned.");
			//SetVariantInt(0);
			//AcceptEntityInput(iClient, "SetForcedTauntCam"); //for new ultimate.
			TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
			primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
			
			if (primaryShot == -1)
			{
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					switch(iStoredWeaponIndexPrimary[iClient])
					{
						case 21,208,40,215,594,659,741,798,807,887,896,905,914,963,972,1146,15005,15017,15030,15034,15049,15054,15066,15067,15068,15089,15090,15115,15141,30474: //stock and skins
						{
							TF2Items_SetClassname(item, "tf_weapon_flamethrower");
							if(iStoredWeaponIndexPrimary[iClient] == 594)
							{
								GetEntPropFloat(iClient, Prop_Send, "m_flRageMeter"); //restore mmmph meter test
							}
							
							SetAmmo(iClient, 0, 200);
						}
						case 1178:
						{
							TF2Items_SetClassname(item, "tf_weapon_rocketlauncher_fireball");
							SetAmmo(iClient, 0, 40);
						}
					}
					
					TF2Items_SetItemIndex(item, iStoredWeaponIndexPrimary[iClient]);
					
					if(bCheckIfAustralium[iClient] == true)
					{
						TF2Items_SetAttribute(item, 5, 2027, 1.00); //aussie
					}
					
					TF2Items_SetNumAttributes(item, 6);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
			}
			SetAmmo(iClient, 0, 200);
			
			
		}
		case 8:
		{
			TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
			
			//test
			
			//TF2_CreateAndEquipWeapon(iClient, iStoredWeaponIndexPrimary[iClient]);
			
			
			
			PrintToServer(" Spy  weapon returned.");
			//if (primaryShot == -1)
			{
				Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
				TF2Items_SetClassname(item, "tf_weapon_revolver"); //spy ult gun
				TF2Items_SetItemIndex(item, weaponIndex);
				if(bCheckIfAustralium[iClient] == true)
				{
					TF2Items_SetAttribute(item, 5, 2027, 1.00); //aussie
				}
				TF2Items_SetNumAttributes(item, 6);
				primaryShot = TF2Items_GiveNamedItem(iClient, item);
				CloseHandle(item);
				EquipPlayerWeapon(iClient, primaryShot);
			}
		}
		case 9:
		{
			PrintToServer("Engineer weapon returned.");
			//SetVariantInt(0);
			//AcceptEntityInput(iClient, "SetForcedTauntCam"); //for new ultimate.
			TF2_RemoveWeaponSlot(iClient, TFWeaponSlot_Primary);
			primaryShot = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
			
			if (primaryShot == -1)
			{
				{
					Handle item = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
					switch(iStoredWeaponIndexPrimary[iClient])
					{
						case 199,1141,1153,15003,15016,15044,15047,15085,15109,15132,15133,15152: //stock and skins
						{
							TF2Items_SetClassname(item, "tf_weapon_shotgun");
						}
						case 997:
						{
							TF2Items_SetClassname(item, "tf_weapon_shotgun_building_rescue");
						}
						case 9,527:
						{
							TF2Items_SetClassname(item, "tf_weapon_shotgun_primary");
						}
						case 588:
						{
							TF2Items_SetClassname(item, "tf_weapon_drg_pomson");
						}
						case 141, 1004:
						{
							TF2Items_SetClassname(item, "tf_weapon_sentry_revenge");
						}
					}
					
					TF2Items_SetItemIndex(item, iStoredWeaponIndexPrimary[iClient]);
					
					if(bCheckIfAustralium[iClient] == true)
					{
						TF2Items_SetAttribute(item, 5, 2027, 1.00); //aussie
					}
					
					TF2Items_SetNumAttributes(item, 6);
					
					primaryShot = TF2Items_GiveNamedItem(iClient, item);
					
					CloseHandle(item);
					
					EquipPlayerWeapon(iClient, primaryShot);
				}
			}
			ResetModel(iClient);
		}
	}
}

void stalemateChecker()
{
	//REDO
//	char mapName[64];
//	GetCurrentMap(mapName, 32);
//	if(StrContains(mapName, "cp_"))
//	{
//		if(bEnforcedStalemate == false)
//		{
//			iCurrentmapTimer++;
//		//PrintToServer("Stalemate %u out of %i.", iCurrentmapTimer, iForcedMapTimer);
//			if(iCurrentmapTimer > iForcedMapTimer)
//			{
//				PrintToServer("Ending game because it took too long.");
//				int iEnt = -1;
//				iEnt = FindEntityByClassname(iEnt, "game_round_win");
//				
//				if (iEnt < 1)
//				{
//					iEnt = CreateEntityByName("game_round_win");
//					if (IsValidEntity(iEnt))
//					DispatchSpawn(iEnt);
//				}
//				
//				
//				SetVariantInt(0);
//				AcceptEntityInput(iEnt, "SetTeam");
//				AcceptEntityInput(iEnt, "RoundWin");
//				bEnforcedStalemate = true;
//			}
//		}
//		
//	}
	
}

public Action ultCheckerButton() //improved ultimate button reaction ig
{
	for(int i = 1; i < TF_MAXPLAYERS+1; i++)
	{
		if(IsValidClient(i))
		{
			if(bInSpawn[i] == false && bPlayerBuyMenuPreference[i] == false)
			{
			//	hf_main_menu(i, MenuAction_Cancel);
				CancelClientMenu(i);
			}
			if(bInSpawn[i] == true)
			{
				if(iUltimateSecondsLeft[i] > 0)
				{
					iUltimateSecondsLeft[i]--;
					
					//removing stuff in spawn
					TF2_RemoveCondition(i, TFCond_SpeedBuffAlly );		//faster
					TF2_RemoveCondition(i, TFCond_Disguising  );		//NoKnock
					TF2_RemoveCondition(i, TFCond_UberBulletResist );		//bullet resistance
					TF2_RemoveCondition(i, TFCond_UberBlastResist  );		//blast resistance
					TF2_RemoveCondition(i, TFCond_UberFireResist );		//fire resistance
					TF2_RemoveCondition(i, TFCond_RuneKnockout  );		//Knockout
					TF2_RemoveCondition(i, TFCond_CritOnFirstBlood ); 		//crits
				}
				
			}
			if(fChill[i] > 0.0) //cooldown for calling the command because, it kicks you otherwise if you use attack3
			{
				fChill[i] -= 0.2;
			}
			
			if(bUltReadyPerPlayer[i] == false && iUltimateSecondsLeft[i] == 0)
			{
				SetHudTextParams(-1.0,-0.25, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
				if(bRentingUltWeapon[i] == true)
				{
					GiveClientStockWeapon(i, iStoredWeaponIndexPrimary[i]); //returns the stock weapon to the player.
					bRentingUltWeapon[i] = false; //says we are not using the ultimate weapon anymore.
				}
				if(GetClientTeam(i) != 1) //no idea whats wrong with that warning
				{
					if(iUltChargePerPlayer[i] < 99)
					{
						if(waitingForPlayers > waitingForPlayersTimer)
						{
							ShowHudText(i, 2, "ULTIMATE: %u%%", iUltChargePerPlayer[i]);
						}else ShowHudText(i, 2, "----");
					}
					else if(iUltChargePerPlayer[i] >= 99)
					{
						ShowHudText(i, 2, "ULTIMATE: 99");
					}
					
				}
				
			}
			else if(iUltimateSecondsLeft[i] > 0)
			{
				SetHudTextParams(-1.0,-0.25, 0.15, 255,255,255,255,  0 , 1.0, 0.0, 0.2);
				ShowHudText(i, 2, "ULTIMATE TIME LEFT: %u", iUltimateSecondsLeft[i]);
			}
			else if(bUltReadyPerPlayer[i] == true)
			{
				SetHudTextParams(-1.0,-0.25, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
				ShowHudText(i, 2, "ULTIMATE IS READY.");
			}
			
			SetHudTextParams(-1.0,-0.20, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
			if(waitingForPlayers < waitingForPlayersTimer)
			{
				ShowHudText(i, 5, "WAITING FOR PLAYERS");
			} else if(waitingForPlayers > waitingForPlayersTimer)
			{
				ShowHudText(i, 5, "CREDITS: %u", iCredits[i]);
			}
			
			
			if(iJumpSuitCD[i] > 0)
			{
				SetHudTextParams(-1.0,-0.30, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
				ShowHudText(i, 1, "JUMP SUIT CD: %i", iJumpSuitCD[i]);
			} else CheckItems(i,2);
			
			if(iPlayerHasConsumableAmount[i] > 0)
			{
				SetHudTextParams(-1.0,-0.17, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
				ShowHudText(i, 0,  "CONSUMABLE: %s x%i", GetConsumableItem(i), iPlayerHasConsumableAmount[i]);
			}
			if(iConsumableItemCD[i] > 0 && iPlayerHasConsumableAmount[i] > 0)
			{
				SetHudTextParams(-1.0,-0.17, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
				ShowHudText(i, 0,  "CONSUMABLE ITEM COOLDOWN: %i", iConsumableItemCD[i]);
			}
			
			if(iBoneBreakerCD[i] == 0)
			{
				CheckItems(i,3);
			}
			if(iCustomItemSlot_0[i] != -1 || iCustomItemSlot_1[i] != -1 || iCustomItemSlot_2[i] != -1)
			{
				if(bInSpawn[i] == true)
				{
					if(bPlayerHudPreference[i] == false)
					{
						SetHudTextParams(-0.2,-0.4, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
						ShowHudText(i, 4, "Items owned (Tab + R to open menu): \n1) %s \n2) %s \n3) %s", GetEquippedItem(i, 0),GetEquippedItem(i, 1),GetEquippedItem(i, 2));
					}
				}
			}
			
			switch(iPlayerIsClassID[i]) //system is set up like that for easy implementation of other classes's stuff.
			{
				case 1: //scout speed fix
				{
					if(iUltimateSecondsLeft[i] == 0  && iUltChargePerPlayer[i] == 1)
					{
						TF2_AddCondition(i, TFCond_SpeedBuffAlly   , 0.010 , 0);
					}
					
				}
				case 5:
				{
					iMedicsHealingTargets[i] = TF2_GetHealingTarget(i);
					SetHudTextParams(-1.0,0.62, 0.15, 255,255,255,255, 0 , 1.0, 0.0, 0.2);
					if(TF2_GetHealingTarget(i) != -1)
					{
						if(iUltChargePerPlayer[iMedicsHealingTargets[i]] < 99)
						{
							ShowHudText(i, 3, "HEALED PLAYER'S ULTIMATE: %u", iUltChargePerPlayer[iMedicsHealingTargets[i]]);
						}
						else if (iUltChargePerPlayer[iMedicsHealingTargets[i]] >= 99)
						{
							ShowHudText(i, 3, "HEALED PLAYER'S ULTIMATE IS READY");
						}
						CheckItems(iMedicsHealingTargets[i], 1); //this is done to prevent vaccinator removing buffs... There should be a better way for this.
					}
				}
				case 6:
				{
					if(bRentingUltWeapon[i] == true)
					{
						if(iUltimateSecondsLeft[i] == 1)
						{
							TF2Attrib_RemoveByDefIndex(i, TF_ATTR_SPEED_BONUS);
							CheckItems(i, 0);
						}
					}
				}
				case 7:
				{
//					if(bRentingUltWeapon[i] == true)
//					{
//						if(iUltimateSecondsLeft[i] == 1)
//						{
//							TF2Attrib_RemoveByDefIndex(i, TF_PYRO_ULT_ATTRIBUTE);
//							CheckItems(i);
//						}
//					}
				}
				case 9:
				{
					if(bRentingUltWeapon[i] == true)
					{
						if(iUltimateSecondsLeft[i] == 1)
						{
							
							DeleteSentries(i);
						}
					}
				}
			}
			
			
		}
	}
	
}
public Action ultChecker()  //Tick rate, not just ults. But for everything in general
{
	//int clownTimer;
	//GetMapTimeLeft(clownTimer);
	//clownTimer = clownTimer * 60;
	if(waitingForPlayersInitiated == true)
	{
		waitingForPlayers++;
	}
	
	
//	if(clownTimer != 0)
//	{
//		GetMapTimeLimit(iForcedMapTimer); //dynamic map timer if mode gets extended
//		iForcedMapTimer = (iForcedMapTimer * 60) + 300;
//	}
	
	
	
	
	iHintTimer--;
	for(int i = 1; i < TF_MAXPLAYERS+1; i++)
	{
		if(!IsValidClient(i))
		{
			iPlayerLateCompensationSeconds[i]++;
		}
		else if(IsValidClient(i))
		{
//			if(bNotifyOfStalemate == false && iCurrentmapTimer >= iForcedMapTimer - 300)
//			{
//				CPrintToChat(i, "{fullred}Map is taking too long to finish. Ending gamemode in 5 minutes.");
//				char sPath[64];
//				Format(sPath, sizeof(sPath), "vo/announcer_captureflag_miscspace_19.mp3");
//				EmitSoundToClient(i,sPath);
//				bNotifyOfStalemate = true; //whoops
//			}
			
			
			if(iHintTimer <= 0)
			{
				GenerateHint(i, GetRandomInt(0,11));
				iHintTimer = 120;
			}
			if(GetClientTeam(i) != 1) //no idea whats wrong with that warning
			{
				if(iOiledUpCD[i] > 0)
				{
					iOiledUpCD[i]--;
				}
				if(iBoneBreakerCD[i] > 0)
				{
					TF2Attrib_RemoveByDefIndex(i, TF_ATTR_EXTRA_JUMP_HEIGHT);
					iBoneBreakerCD[i]--;
				}
				if(iJumpSuitCD[i] > 0)
				{
					TF2Attrib_RemoveByDefIndex(i, TF_ATTR_EXTRA_JUMP_HEIGHT);
					iJumpSuitCD[i]--;
				}
				if(iConsumableItemCD[i] > 0)
				{
					iConsumableItemCD[i]--;
				}
				//	CheckItems(i);
				if(iCredits[i] < 1000)
				{
					if(waitingForPlayers > waitingForPlayersTimer)
					{
						iCredits[i]++;
					}
				}
				if(iCredits[i] > 1000)
				{
					iCredits[i] = 1000;
				}
			}
			
			if(iUltimateSecondsLeft[i] > 0)
			{
				iUltimateSecondsLeft[i] -= 1;
			}
			if(iUltChargePerPlayer[i] < iUltChargeRequired)
			{
				bUltReadyPerPlayer[i] = false;
				if(iUltimateSecondsLeft[i] <= 0)
				{
					fUltimateSpeedRateCurrent[i] += fUltimateSpeedRate[iPlayerIsClassID[i]];
					if(fUltimateSpeedRateCurrent[i] >= 1.0) //we'll see
					{
						fUltimateSpeedRateCurrent[i] = 0.0;
						if(waitingForPlayers > waitingForPlayersTimer)
						{
							iUltChargePerPlayer[i]++;
						}
						
					}
				}
				switch(fUltimateSpeedRate[iPlayerIsClassID[i]]) //shitty way of fixing the charge rate notification, but it works. 1 is slow, 2 is normal, 3 is fast.
				{
					case 1:
					{
						
						if(iUltChargePerPlayer[i] == 75)
						{
							hf_func_PlayAlmostReadySound(i);
						}
					}
					case 2:
					{
						if(iUltChargePerPlayer[i] == 76)
						{
							hf_func_PlayAlmostReadySound(i);
						}
					}
					case 3:
					{
						if(iUltChargePerPlayer[i] == 75)
						{
							hf_func_PlayAlmostReadySound(i);
						}
					}
				}
			}
			else if(iUltChargePerPlayer[i] >= iUltChargeRequired)
			{
				if(bUltReadyPerPlayer[i] == false)
				{
					bUltReadyPerPlayer[i] = true;
					hf_func_PlayUltimateReadySound(i, iPlayerIsClassID[i]); // self explanatory. depending on class plays their ult ready line.
					//	ShowHudText(i, -1, "Ultimate is ready.");
					PrintToServer("Ult %i ready to use.", i); //only use when debugging,  really should make it a bool
					CPrintToChat(i, "{green}Ultimate is ready.{default} \nSay /ult or press {yellow}SPECIALATTACK (default: Mouse Wheel) to use your ultimate ability!");
					
				}
			}
			if(IsFakeClient(i))
			{
				if(bUltReadyPerPlayer[i] == true)
				{
				//	BotUltimate(i); //heavy bot ult should work now
					
				}
			}
		}
	}
	stalemateChecker();
}

//gameplay functions end here

//working with clients go here.
public void OnClientDisconnect(int iClient) //self explanatory.
{
	if(IsValidClient(iClient))
	{
		//isMounterPerPlayer[iClient] = false;
		iUltChargePerPlayer[iClient] = 0;
		bUltReadyPerPlayer[iClient] = false;
		iCredits[iClient] = 300;
		bInSpawn[iClient] = false;
		fDamageDealtByPlayerForCreds[iClient] = 0.0;
		iCustomItemSlot_0[iClient] = -1;
		iCustomItemSlot_1[iClient] = -1;
		iCustomItemSlot_2[iClient] = -1;
		bPlayerHudPreference[iClient] = false;
		bPlayerBuyMenuPreference[iClient] = false;
		
		iPlayerLateCompensationSeconds[iClient] = 300;
		
		PrintToServer("player %p left, removing their shit from the gamemode.", iClient);
	}
}
public void OnClientConnected(int iClient)
{
	//CPrintToChat(i, "Say /mount or /kart or /cart to mount/dismount your bumper car. {fullred}You will dismount if you recieve damage.");
	//PrintToChat(i, "Say /ult or use SPECIALATTACK(Default: MOUSE WHEEL) to use your ultimate ability.");
	//PrintToChat(iClient, "Your ultimate charges over time! And resets to zero when you die! Try to survive and have fun!");
	
	if(IsValidClient(iClient))
	{
		if(iPlayerLateCompensationSeconds[iClient] >= 300)
		{
			PrintToChat(iClient, "You have been compensated with 300 iCredits for joining late.");
			iCredits[iClient] += 300;
		}
	}
	
	//CacheCookies(iClient);
}

//working with clients end here.

//functions, non gameplay go here.
public void OnMapEnd() //call when map ends.
{
	//resets default stuff
	hf_ms_CvarReset();
	PrintToServer("Resetting cvars map end, loaded plugin.");
}


public void OnPluginEnd()
{
	hf_ms_CvarReset();
	PrintToServer("Resetting cvars. unloading plugin");
}


void AddHP(int iClient, int health) //self explanatory
{
	if(!bPlayerNewMaxHP[iClient])
	{
		int playerBaseHP = TF2_GetPlayerMaxHealth(iClient);
		bPlayerBaseMaxHP[iClient] = playerBaseHP; //reset before adding
		TF2Attrib_SetByDefIndex(iClient, TF_ATTR_MAX_HEALTH, float(health));
		TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_MAX_HEALTH_PENALTY);
		bPlayerNewMaxHP[iClient] = true;
	}
	
}

void CacheSound(const char sound[64]) //yup, that method was taken online and modified
{
	if (strlen(sound) > 0)
	{
		char filePath[255];
		Format(filePath, sizeof(filePath), "sound/%s", sound);
		{
			AddFileToDownloadsTable(filePath);
			PrecacheSound(sound, true);
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname) //remove powerups to prevent players from picking them up.
{
	if (StrEqual(classname, "item_powerup_rune"))
	{
		RemoveEntity(entity);
	}
	
	if (StrContains(classname, "tf_projectile") == 0)
	{
		SDKHook(entity, SDKHook_Spawn, Hook_OnProjectileSpawn);
	}
	if (StrEqual(classname, "func_respawnroom", false))	// This is the earliest we can catch this
	{
		SDKHook(entity, SDKHook_StartTouch, SpawnStartTouch);
		SDKHook(entity, SDKHook_EndTouch, SpawnEndTouch);
	}
	if (StrEqual(classname, "tf_spell_pickup"))
	{
		RemoveEntity(entity);
	}
}


public void Hook_OnProjectileSpawn(int entity)
{
	int iClient = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(iClient < TF_MAXPLAYERS+1)
	{
		if(bRentingUltWeapon[iClient] == true)
		{
			switch(iPlayerIsClassID[iClient])
			{
							//case 0: ignore
				case 4:
				{
					{
						
						SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 2.0);
					}
				}
			}
		}
	}
}

void PrecacheModels_GameMode()
{
	PrecacheModel("models/bots/engineer/bot_engineer.mdl", true);
	PrecacheModel("models/bots/gameplay_cosmetic/bot_light_bomb_helmet.mdl", true);
	PrecacheModel("models/kirillian/buildables/drone.mdl", true);
}

void SetUltModelTest(int iClient)
{
	char modelpath[255];
	modelpath = "models/bots/engineer/bot_engineer.mdl";
	SetVariantString(modelpath);
	AcceptEntityInput(iClient, "SetCustomModel");
	SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", true);
}

void ResetModel(int iClient)
{
	SetVariantString("");
	AcceptEntityInput(iClient, "SetCustomModel");
}

//void ForceTPClientCamera(int iClient) //currently unused. I have no ways of setting that stuff without turning sv_cheats but maybe there will be a bypass eventually. hence why this is kept.
//{
//	ClientCommand(iClient, "cam_idealdistright 25");
//	ClientCommand(iClient, "cam_idealdistup -25");
//	ClientCommand(iClient, "cam_idealdist 50");
//	if(!IsPlayerAlive(iClient)){
//		AcceptEntityInput(iClient, "SetForcedTauntCam");
//	}
//
//}

//functions, non gameplay end here.

//debug goes here
public void BotUltimate(int iClient) //debug/singleplayer only. Bots can use ultimate abilities.
{
	if(!IsPlayerAlive(iClient))
	{
		ReplyToCommand(iClient, "You must be alive to use your ultimate ability!");
	}
	else if(IsPlayerAlive(iClient) && bUltReadyPerPlayer[iClient] == true)
	{
		PrintToChat(iClient, "You have used your ultimate ability!");
		UltimateEvent(iClient);
	}
}

public Action DebugUlt(int iClient,int args) //charge ultiamte for everyone. Admin only.
{
	if(GetUserAdmin(iClient) != INVALID_ADMIN_ID)
	{
		PrintToServer("Ult charged for all players..");
		for(int i = 1; i < 32; i++)
		{
			if (IsValidClient(i))
			{
				CPrintToChat(i, "{green}Ultimate was charged for all players. Go wild!");
				iUltChargePerPlayer[i] = 99;
				bUltReadyPerPlayer[i] = true;
				hf_func_PlayUltimateReadySound(i,iPlayerIsClassID[i]);
			}
		}
	}
	else
	{
		PrintToChat(iClient, "Only administrators can use this command.");
	}
}

public Action DebugUltOnlyClient(int iClient, int args) //charge ultiamte for client. Admin only.
{
	if(GetUserAdmin(iClient) != INVALID_ADMIN_ID)
	{
		CPrintToChat(iClient, "{green}Ultimate was charged for you only. Go wild!");
		iUltChargePerPlayer[iClient] = 99;
		bUltReadyPerPlayer[iClient] = true;
		hf_func_PlayUltimateReadySound(iClient,iPlayerIsClassID[iClient]);
	}
	else
	{
		PrintToChat(iClient, "Only administrators can use this command.");
	}
}

public Action DebugUltOnlyClientMoney(int iClient, int args) //give yourself money. Admin only
{
	if(GetUserAdmin(iClient) != INVALID_ADMIN_ID)
	{
		CPrintToChat(iClient, "{green}Free money!");
		iCredits[iClient] = 1000;
	}
	else
	{
		PrintToChat(iClient, "Only administrators can use this command.");
	}
}
 //debug ends here



///benoist kenzzer did dis, the mehtod. the awful pasting is mine. ty beno/kenzzer

void FunctionCreateSentries(int iClient)
{
	if (g_aClientSentries[iClient] == null)
	g_aClientSentries[iClient] = new ArrayList();
	DeleteSentries(iClient);
	
	char iClientName[64];
	GetClientName(iClient, iClientName, sizeof(iClientName));
	
	
	float vector3PlrOrigin[3];
	GetClientAbsOrigin(iClient, vector3PlrOrigin);
	float vector3PlrOrigin2[3];
	GetClientAbsOrigin(iClient, vector3PlrOrigin2);
	
	float fEyeAngles[3], fDirection[3];
	GetClientEyeAngles(iClient, fEyeAngles);
	float fRight[3];
	float fLeft[3];
	GetAngleVectors(fEyeAngles, fDirection, fRight, NULL_VECTOR);
	vector3PlrOrigin[2] += 100;
	vector3PlrOrigin2[2] += 100;
	fRight[0] = fRight[0] * 100;
	fRight[1] = fRight[1] * 100;
	fRight[2] = fRight[2] * 100;
	fLeft[0] -= fRight[0];
	fLeft[1] -= fRight[1];
	fLeft[2] -= fRight[2];
	AddVectors(vector3PlrOrigin, fRight, vector3PlrOrigin);
	AddVectors(vector3PlrOrigin2, fLeft, vector3PlrOrigin2);
	
	
	int iTeam = GetClientTeam(iClient);
	
	int iSentry = CreateEntityByName("obj_sentrygun");
	if (iSentry != -1)
	{
		CreateSentryGun(iClient,iSentry, vector3PlrOrigin, fEyeAngles, iTeam);
	}
	
	int iSentry_2 = CreateEntityByName("obj_sentrygun");
	if (iSentry_2 != -1)
	{
		CreateSentryGun(iClient,iSentry_2, vector3PlrOrigin2, fEyeAngles,  iTeam);
	}
	
	g_hTimerClientCleanUpSentries[iClient] = CreateTimer(10.0, Timer_CleanupSentries, GetClientUserId(iClient));
}

void DeleteSentries(int iClient)
{
	for (int i = g_aClientSentries[iClient].Length-1; i >= 0; i--)
	{
		int iSentry = EntRefToEntIndex(g_aClientSentries[iClient].Get(i));
		if (iSentry > MaxClients) // Remember, if the entity became invalid, -1 is returned
		{
			SetVariantInt(1000);
			AcceptEntityInput(iSentry, "RemoveHealth");
		}
	}
	g_aClientSentries[iClient].Clear(); // Empty array
}

public Action Timer_CleanupSentries(Handle hTimer, int iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	if (!iClient) return Plugin_Continue; // Client index is 0, if they left the server (became invalid)
	
	if (hTimer != g_hTimerClientCleanUpSentries[iClient]) return Plugin_Continue; // Prevent old timer overlaps
	
	DeleteSentries(iClient);
	return Plugin_Handled;
}


public void SetPlayerHUDPref(int iClient)
{
	bPlayerHudPreference[iClient] = !bPlayerHudPreference[iClient];
	PrintToChat(iClient, "Your hud preference has been changed.");
	//CacheCookies(iClient);
}


public void SetPlayerBuyPref(int iClient)
{
	bPlayerBuyMenuPreference[iClient] = !bPlayerBuyMenuPreference[iClient];
	PrintToChat(iClient, "Your buy menu preference has been changed.");
	//CacheCookies(iClient);
}

