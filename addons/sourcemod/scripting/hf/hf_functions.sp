
int iCustomItemSlot_0[TF_MAXPLAYERS + 1];
int iCustomItemSlot_1[TF_MAXPLAYERS + 1];
int iCustomItemSlot_2[TF_MAXPLAYERS + 1];

int iPlayerIsClassID[TF_MAXPLAYERS + 1]; //this is stupid and hacky but it works. It cointains each CLASS ID per player. so it counts Player IDName is ClassID

bool bInSpawn[TF_MAXPLAYERS + 1];
int iPlayerHasConsumableType[TF_MAXPLAYERS+1];
int iPlayerHasConsumableAmount[TF_MAXPLAYERS+1];

//int builtSentryID[TF_MAXPLAYERS + 1];

public void hf_func_PlayAlmostReadySound(int id) //self explanatory.
{
	char sPath[64];
	Format(sPath, sizeof(sPath), "herofortress/vfx/almost_charged.mp3");
	EmitSoundToClient(id,sPath);
}

public void hf_func_PlayUltimateReadySound(int iClient,int ultSoundVal) // self explanatory, iClient is for which client, ultSoundVal is which sound to play.
{
	switch(ultSoundVal)
	{
		//HAHA FUNNY CLASS STARTS AT 1
		case 1: //scout ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/scout_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 2://sniper ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/sniper_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 3://soldier ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/soldier_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 4://demo ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/demo_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 5: //medic ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/medic_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 6:  //heavy ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/heavy_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 7: //pyro ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/pyro_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 8: //spy ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/spy_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
		case 9: //engi ult READY sound
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "herofortress/vfx/engi_ult_ready_notif.mp3");
			EmitSoundToClient(iClient,sPath);
		}
	}
}
public void hf_func_PlayUltimateSound(int iClient,int ultSoundVal) //self explanatory, works just like ultready
{
	for(int i = 1; i <= TF_MAXPLAYERS; i++)
	{
		if(IsValidClient(i))
		{
			if(TF2_GetClientTeam(iClient) != TF2_GetClientTeam(i))
			{
				switch(ultSoundVal)
				{
						//ignore case 0
					case 1:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/scout_ultimate.mp3");
						Format(sFxPath, sizeof(sFxPath), "misc/halloween/merasmus_stun.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
						
					}
					case 2:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/sniper_ultimate.mp3");
						Format(sFxPath, sizeof(sFxPath), "items/powerup_pickup_precision.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 3:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/soldier_ultimate_v2.mp3");
						Format(sFxPath, sizeof(sFxPath), "coach/coach_attack_here.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 4:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/demoman_ultimate.mp3");
						Format(sFxPath, sizeof(sFxPath), "items/taunts/badpipes/badpipes1.mp3");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 5:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/medic_ultimate_v2.mp3");
						Format(sFxPath, sizeof(sFxPath), "player/mannpower_invulnerable.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_USER_BASE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 6:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/heavy_ultimate_v2.mp3");
						Format(sFxPath, sizeof(sFxPath), "misc/halloween/strongman_bell_01.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 7:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/pyro_ultimate.mp3");
						Format(sFxPath, sizeof(sFxPath), "misc/halloween/gotohell.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 8:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/spy_ultimate.mp3");
						Format(sFxPath, sizeof(sFxPath), "replay/snip.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 9:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/engineer_ultimate.mp3");
						Format(sFxPath, sizeof(sFxPath), "replay/performanceeditorclosed.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
				}		
			}
			else if(TF2_GetClientTeam(iClient) == TF2_GetClientTeam(i))
			{
				switch(ultSoundVal)
				{
					
					case 1:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/scout_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "misc/halloween/merasmus_stun.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
							//						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
					}
					case 2:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/sniper_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "items/powerup_pickup_precision.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 3:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/soldier_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "coach/coach_attack_here.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 4:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/demoman_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "items/taunts/badpipes/badpipes1.mp3");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 5:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/medic_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "player/mannpower_invulnerable.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_USER_BASE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 6:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/heavy_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "player/taunt_bell.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 7:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/pyro_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "misc/halloween/gotohell.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 8:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/spy_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "replay/snip.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
					case 9:
					{
						char sPath[64];
						char sFxPath[64];
						Format(sPath, sizeof(sPath), "herofortress/vo/engineer_ultimate_friendly.mp3");
						Format(sFxPath, sizeof(sFxPath), "replay/performanceeditorclosed.wav");
						EmitSoundToClient(i, sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_GUNFIRE);
						EmitSoundToClient(i, sFxPath, iClient, SNDCHAN_STREAM, SNDLEVEL_GUNFIRE);
					}
				}
			}
		} //we'll see...
	}
	
}

public void hf_func_PlayItemSound(int iClient, int itemSoundVal)
{
	switch(itemSoundVal)
	{
		case 0: 
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "passtime/target_lock.wav");
			EmitSoundToClient(iClient,sPath);
		}
		case 1:
		{
			char sPath[64];
			Format(sPath, sizeof(sPath), "items/ammo_pickup.wav");
			EmitSoundToClient(iClient,sPath);
		}
	}
}

char[] GetConsumableItem(int iClient)
{
	char itemName[64];
	switch(iPlayerHasConsumableType[iClient])
	{
		case 0:
		{
			Format(itemName, sizeof(itemName), "Small HP Pack.");
			return itemName;	
		}
		case 1:
		{
			Format(itemName, sizeof(itemName), "Medium HP Pack.");
			return itemName;	
		}
		case 2:
		{
			Format(itemName, sizeof(itemName), "Large HP Pack.");
			return itemName;	
		}
		case 3:
		{
			Format(itemName, sizeof(itemName), "Small Ammo Pack.");
			return itemName;	
		}
		case 4:
		{
			Format(itemName, sizeof(itemName), "Medium Ammo Pack.");
			return itemName;	
		}
		case 5:
		{
			Format(itemName, sizeof(itemName), "Large Ammo Pack.");
			return itemName;	
		}
	}
	return itemName;
}

public void CheckItems(int iClient, int mode)
{
	switch(mode)
	{
		case 0:
		{
		//	TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_BONUS, 1.00); //aggression revert
		//	TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_TO_HEAL_SELF, 1.00); //vampiro revert
			TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , 0.001 , 0);			//faster
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_RELOADTIME);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_HEALTHREGEN);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_CAPRATE);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_CHARGE_METER);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_CHARGE_METER_PU);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_DAMAGE_BONUS);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_NO_FALL_DAMAGE);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_AMMO_REGEN);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_WEAPON_SWITCH_SPEED);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_DROP_HEALTH);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_SLOW);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_SPEED_BONUS);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_DAMAGE_TO_HEAL_SELF);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_METAL_REGEN);
			TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_FAST_MELEE);
			
	//TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_HEAL_RECIEVED);
			
			
			TF2_RemoveCondition(iClient, TFCond_SmallBulletResist);
			TF2_RemoveCondition(iClient, TFCond_SmallBlastResist);
			TF2_RemoveCondition(iClient, TFCond_SmallFireResist);
			
//			if(iPlayerIsClassID[iClient] != 9)
//			{
//				TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_EXTRA_SENTRY);
//			}
			
			switch(iCustomItemSlot_0[iClient])
			{
				case 0:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SPEED_BONUS, 1.15); //speed bonus
					TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , 0.05 , 0);			//faster
					
				}
				case 1:
				{
					TF2_AddCondition(iClient, TFCond_SmallBulletResist, TFCondDuration_Infinite , 0);
				}
				case 2:
				{
					TF2_AddCondition(iClient, TFCond_SmallBlastResist, TFCondDuration_Infinite , 0);
				}
				case 3:
				{
					TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0);
				}
				case 4:
				{
				//just vampirism.
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_TO_HEAL_SELF, 1.25); //vampiro
				}
				case 5:
				{
				//just healing reduction.
				}
				case 6:
				{
					
				//just gas.
				}
				case 7:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_RELOADTIME, 0.50); //deft hands
				}
				case 8:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_HEALTHREGEN, 5.00); //regen
				}
				case 9:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_CAPRATE, 2.00); //caprate
				}
				case 10:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_FAST_MELEE, 100.0); //anger
				}
				case 11:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_BONUS, 1.10); //aggression
				}
				case 12:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_NO_FALL_DAMAGE, 100.00); //jumper
				}
				case 13:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_AMMO_REGEN, 0.15); //pocket dispenser
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_METAL_REGEN, 35.0); //pocket dispenser
				}
				case 14:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_WEAPON_SWITCH_SPEED, 0.50); //weapon switch
				}
				case 15:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DROP_HEALTH, 1.00); //pocket medic
				}
				case 16:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT, 2.00); //extra jump
				}
				case 17:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SLOW, 1.00); //slowdown
				}
				
			}
			switch(iCustomItemSlot_1[iClient])
			{
				case 0:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SPEED_BONUS, 1.15); //speed bonus
					TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , 0.05 , 0);			//faster
				}
				case 1:
				{
					TF2_AddCondition(iClient, TFCond_SmallBulletResist,TFCondDuration_Infinite , 0);
				}
				case 2:
				{
					TF2_AddCondition(iClient, TFCond_SmallBlastResist, TFCondDuration_Infinite , 0);
				}
				case 3:
				{
					TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0);
				}
				case 4:
				{
			//TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0)
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_TO_HEAL_SELF, 1.25); //vampiro
				}
				case 5:
				{
			//TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0)
			//just healing reduction.
				}
				case 6:
				{
					
			//TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0)
			//just gas.
				}
				case 7:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_RELOADTIME, 0.50); //deft hands
				}
				case 8:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_HEALTHREGEN, 5.00); //regen
				}
				case 9:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_CAPRATE, 2.00); //caprate
				}
				case 10:
				{		
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_FAST_MELEE, 100.0); //anger
				}
				case 11:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_BONUS, 1.10); //aggression
				}
				case 12:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_NO_FALL_DAMAGE, 100.00); //jumper
				}
				case 13:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_AMMO_REGEN, 0.15); //pocket dispenser
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_METAL_REGEN, 35.0); //pocket dispenser
				}
				case 14:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_WEAPON_SWITCH_SPEED, 0.50); //weapon switch
				}
				case 15:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DROP_HEALTH, 1.00); //pocket medic
				}
				case 16:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT, 2.00); //extra jump
				}
				case 17:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SLOW, 1.00); //slowdown
				}
			}
			switch(iCustomItemSlot_2[iClient])
			{
				case 0:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SPEED_BONUS, 1.15); //speed bonus
					TF2_AddCondition(iClient, TFCond_SpeedBuffAlly  , 0.05 , 0);			//faster
				}
				case 1:
				{
					TF2_AddCondition(iClient, TFCond_SmallBulletResist,TFCondDuration_Infinite , 0);
				}
				case 2:
				{
					TF2_AddCondition(iClient, TFCond_SmallBlastResist, TFCondDuration_Infinite , 0);
				}
				case 3:
				{
					TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0);
				}
				case 4:
				{
			//TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0)
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_TO_HEAL_SELF, 1.25); //vampiro
				}
				case 5:
				{
			//TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0)
			//just healing reduction.
				}
				case 6:
				{
					
			//TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0)
			//just gas.
				}
				case 7:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_RELOADTIME, 0.50); //deft hands
				}
				case 8:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_HEALTHREGEN, 5.00); //regen
				}
				case 9:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_CAPRATE, 2.00); //caprate
				}
				case 10:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_FAST_MELEE, 100.0); //anger
				}
				case 11:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DAMAGE_BONUS, 1.10); //aggression
				}
				case 12:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_NO_FALL_DAMAGE, 100.00); //jumper
				}
				case 13:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_AMMO_REGEN, 0.15); //pocket dispenser
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_METAL_REGEN, 35.0); //pocket dispenser
				}
				case 14:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_WEAPON_SWITCH_SPEED, 0.50); //weapon switch
				}
				case 15:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_DROP_HEALTH, 1.00); //pocket medic
				}
				case 16:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT, 2.00); //extra jump
				}
				case 17:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SLOW, 1.00); //slowdown
				}
			}
			if(IsValidClient(iClient))
			{
				//TF2Attrib_ClearCache(iClient);
			}
		}
		case 1: //separate item mode for resistances fix
		{
			switch(iCustomItemSlot_0[iClient])
			{
				case 1:
				{
					TF2_AddCondition(iClient, TFCond_SmallBulletResist,TFCondDuration_Infinite , 0);
				}
				case 2:
				{
					TF2_AddCondition(iClient, TFCond_SmallBlastResist, TFCondDuration_Infinite , 0);
				}
				case 3:
				{
					TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0);
				}
			}
			switch(iCustomItemSlot_1[iClient])
			{
				case 1:
				{
					TF2_AddCondition(iClient, TFCond_SmallBulletResist,TFCondDuration_Infinite , 0);
				}
				case 2:
				{
					TF2_AddCondition(iClient, TFCond_SmallBlastResist, TFCondDuration_Infinite , 0);
				}
				case 3:
				{
					TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0);
				}
			}
			switch(iCustomItemSlot_2[iClient])
			{
				case 1:
				{
					TF2_AddCondition(iClient, TFCond_SmallBulletResist,TFCondDuration_Infinite , 0);
				}
				case 2:
				{
					TF2_AddCondition(iClient, TFCond_SmallBlastResist, TFCondDuration_Infinite , 0);
				}
				case 3:
				{
					TF2_AddCondition(iClient, TFCond_SmallFireResist, TFCondDuration_Infinite , 0);
				}
			}
		}
		case 2:
		{
			switch(iCustomItemSlot_0[iClient])
			{
				case 16:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT, 2.00); //extra jump
				}
			}
			switch(iCustomItemSlot_1[iClient])
			{
				case 16:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT, 2.00); //extra jump
				}
			}
			switch(iCustomItemSlot_2[iClient])
			{
				case 16:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_EXTRA_JUMP_HEIGHT, 2.00); //extra jump
				}
			}
		}
		case 3: //mode for checking cd of bone breaker
		{
			switch(iCustomItemSlot_0[iClient])
			{
				case 17:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SLOW, 1.00); //slowdown		TF2Attrib_RemoveByDefIndex(iClient, TF_ATTR_SLOW);
				}
			}
			switch(iCustomItemSlot_1[iClient])
			{
				case 17:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SLOW, 1.00); //slowdown
				}
			}
			switch(iCustomItemSlot_2[iClient])
			{
				case 17:
				{
					TF2Attrib_SetByDefIndex(iClient, TF_ATTR_SLOW, 1.00); //slowdown
				}
			}
		}
	}
	
}

public void GetClassInformation(int iClient, int characterClass)
{   
    CPrintToChat(iClient, "{yellow} --------------- CLASS INFO --------------- ");
    switch(characterClass)
    {
        case 1:
        {
            CPrintToChat(iClient, "Scout default HP: {lightgreen}150 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 12 seconds, gain the haste powerup, faster move speed, fire rate and reload speed. {lightgreen}Sandman and Wrap Assassin gain 6 balls.");
            CPrintToChat(iClient, "{lightgreen}Your ultimate charges faster than usual.");
        }
        case 2:
        {
            CPrintToChat(iClient, "Sniper default HP: {lightgreen}150 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 10 seconds, gain the precision power up, critical hits, faster fire rate and cover ALL nearby enemies in jarate.");
        } 
        case 3:
        {
            CPrintToChat(iClient, "Soldier default HP: {lightgreen}225 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 10 seconds, gain flight, increased movespeed and a {green}ROCKET BARRAGE OF 32 SLOW ROCKETS.");
        }
        case 4:
        {
            CPrintToChat(iClient, "Demoman default HP: {lightgreen}225 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 8 seconds, gain a rapid fire iron bomber with 4 bombs per clip, ENORMOUS knockback, minicrits for 4 seconds and no self knockback.");
            CPrintToChat(iClient, "{purple}Demoknight.{default} For 8 seconds, Gain haste powerup, bullet damage resistance, speed increase and minicrits instead of normal Demoman ultimate.");
            
        }
        case 5:
        {
            CPrintToChat(iClient, "Medic default HP: {lightgreen}150 (Items that affect HP stack.)");
            CPrintToChat(iClient, "{lightblue}your primary gun is replaced with a panic attack that gains 4% ubercharge percentage on hit. {default}To swap to a syringe gun, use resupply locker.");
            CPrintToChat(iClient, "ULTIMATE: Heal all nearby allies and yourself to max +25hp overheal.");
            
        }
        case 6:
        {
            CPrintToChat(iClient, "Heavy default HP: {lightgreen}400 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 10 seconds, go BERSERK, gaining 500 HP, increased movespeed, crits, knockback powerup and damage resistances, BUT become melee only.");
        }
        case 7:
        {
            CPrintToChat(iClient, "Pyro default HP: {lightgreen}200 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 8 seconds, gain a minigun that deals 1-2 damage, ignites on hit, and increasing knockback based on how long you've fired.");
        }
        case 8:
        {
            CPrintToChat(iClient, "Spy default HP: {lightgreen}150 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 12 seconds, become cloaked until you attack, gain faster cloak / decloak speed and gain a special 24 ammo SMG that refils cloak on hit.");
        }
        case 9:
        {
            CPrintToChat(iClient, "Engineer default HP: {lightgreen}150 (Items that affect HP stack.)");
            CPrintToChat(iClient, "ULTIMATE: For 8 seconds, become a robot with 300 HP, summon 2 flying sentry drones, and gain a laser weapon that deals 135 damage based on range.");
            
        }
        
    }
    CPrintToChat(iClient, "{yellow} --------------------------------------------");
}
 
char[] GetEquippedItem(int iClient,int slot)
{
	char itemName[64];
	switch(slot)
	{
		case 0:
		{
			switch(iCustomItemSlot_0[iClient])
			{
				case -1:
				{
					Format(itemName, sizeof(itemName), "Nothing.");
					return itemName;	
				}
				case 0:
				{
					Format(itemName, sizeof(itemName), "Speed Shoes");
					return itemName;	
				}
				case 1:
				{
					Format(itemName, sizeof(itemName), "Bullet Damage Resistance");
					return itemName;	
				}
				case 2:
				{
					Format(itemName, sizeof(itemName), "Splash Damage Resistance");
					return itemName;	
				}
				case 3:
				{
					Format(itemName, sizeof(itemName), "Fire Damage Resistance");
					return itemName;	
				}
				case 4:
				{
					Format(itemName, sizeof(itemName), "Zapper");
					return itemName;	
				}
				case 5:
				{
					Format(itemName, sizeof(itemName), "Cauterize");
					return itemName;	
				}
				case 6:
				{
					Format(itemName, sizeof(itemName), "Oil It Up");
					return itemName;	
				}
				case 7:
				{
					Format(itemName, sizeof(itemName), "Deft hands");
					return itemName;	
				}
				case 8:
				{
					Format(itemName, sizeof(itemName), "Veteran");
					return itemName;	
				}
				case 9:
				{
					Format(itemName, sizeof(itemName), "Best Buddy");
					return itemName;	
				}
				case 10:
				{
					Format(itemName, sizeof(itemName), "Anger");
					return itemName;	
				}
				case 11:
				{
					Format(itemName, sizeof(itemName), "Aggression");
					return itemName;	
				}
				case 12:
				{
					Format(itemName, sizeof(itemName), "Jumper's dream");
					return itemName;	
				}
				case 13:
				{
					Format(itemName, sizeof(itemName), "Pocket Dispenser");
					return itemName;	
				}
				case 14:
				{
					Format(itemName, sizeof(itemName), "Secret Agent");
					return itemName;	
				}
				case 15:
				{
					Format(itemName, sizeof(itemName), "Pocket Medic");
					return itemName;	
				}
				case 16:
				{
					Format(itemName, sizeof(itemName), "Jump Suit (5 Sec CD)");
					return itemName;	
				}
				case 17:
				{
					Format(itemName, sizeof(itemName), "Bone Breaker");
					return itemName;	
				}
				
			}
		}
		case 1:
		{
			switch(iCustomItemSlot_1[iClient])
			{
				case -1:
				{
					Format(itemName, sizeof(itemName), "Nothing.");
					return itemName;	
				}
				case 0:
				{
					Format(itemName, sizeof(itemName), "Speed Shoes");
					return itemName;	
				}
				case 1:
				{
					Format(itemName, sizeof(itemName), "Bullet Damage Resistance");
					return itemName;	
				}
				case 2:
				{
					Format(itemName, sizeof(itemName), "Splash Damage Resistance");
					return itemName;	
				}
				case 3:
				{
					Format(itemName, sizeof(itemName), "Fire Damage Resistance");
					return itemName;	
				}
				case 4:
				{
					Format(itemName, sizeof(itemName), "Zapper");
					return itemName;	
				}
				case 5:
				{
					Format(itemName, sizeof(itemName), "Cauterize");
					return itemName;	
				}
				case 6:
				{
					Format(itemName, sizeof(itemName), "Oil It Up");
					return itemName;	
				}
				case 7:
				{
					Format(itemName, sizeof(itemName), "Deft hands");
					return itemName;	
				}
				case 8:
				{
					Format(itemName, sizeof(itemName), "Veteran");
					return itemName;	
				}
				case 9:
				{
					Format(itemName, sizeof(itemName), "Best Buddy");
					return itemName;	
				}
				case 10:
				{
					Format(itemName, sizeof(itemName), "Anger");
					return itemName;	
				}
				case 11:
				{
					Format(itemName, sizeof(itemName), "Aggression");
					return itemName;	
				}
				case 12:
				{
					Format(itemName, sizeof(itemName), "Jumper's dream");
					return itemName;	
				}
				case 13:
				{
					Format(itemName, sizeof(itemName), "Pocket Dispenser");
					return itemName;	
				}
				case 14:
				{
					Format(itemName, sizeof(itemName), "Secret Agent");
					return itemName;	
				}
				case 15:
				{
					Format(itemName, sizeof(itemName), "Pocket Medic");
					return itemName;	
				}
				case 16:
				{
					Format(itemName, sizeof(itemName), "Jump Suit (5 Sec CD)");
					return itemName;	
				}
				case 17:
				{
					Format(itemName, sizeof(itemName), "Bone Breaker");
					return itemName;	
				}
				
			}
		}
		case 2:
		{
			switch(iCustomItemSlot_2[iClient])
			{
				case -1:
				{
					Format(itemName, sizeof(itemName), "Nothing.");
					return itemName;	
				}
				case 0:
				{
					Format(itemName, sizeof(itemName), "Speed Shoes");
					return itemName;	
				}
				case 1:
				{
					Format(itemName, sizeof(itemName), "Bullet Damage Resistance");
					return itemName;	
				}
				case 2:
				{
					Format(itemName, sizeof(itemName), "Splash Damage Resistance");
					return itemName;	
				}
				case 3:
				{
					Format(itemName, sizeof(itemName), "Fire Damage Resistance");
					return itemName;	
				}
				case 4:
				{
					Format(itemName, sizeof(itemName), "Zapper");
					return itemName;	
				}
				case 5:
				{
					Format(itemName, sizeof(itemName), "Cauterize");
					return itemName;	
				}
				case 6:
				{
					Format(itemName, sizeof(itemName), "Oil It Up");
					return itemName;	
				}
				case 7:
				{
					Format(itemName, sizeof(itemName), "Deft hands");
					return itemName;	
				}
				case 8:
				{
					Format(itemName, sizeof(itemName), "Veteran");
					return itemName;	
				}
				case 9:
				{
					Format(itemName, sizeof(itemName), "Best Buddy");
					return itemName;	
				}
				case 10:
				{
					Format(itemName, sizeof(itemName), "Anger");
					return itemName;	
				}
				case 11:
				{
					Format(itemName, sizeof(itemName), "Aggression");
					return itemName;	
				}
				case 12:
				{
					Format(itemName, sizeof(itemName), "Jumper's dream");
					return itemName;	
				}
				case 13:
				{
					Format(itemName, sizeof(itemName), "Pocket Dispenser");
					return itemName;	
				}
				case 14:
				{
					Format(itemName, sizeof(itemName), "Secret Agent");
					return itemName;	
				}
				case 15:
				{
					Format(itemName, sizeof(itemName), "Pocket Medic");
					return itemName;	
				}
				case 16:
				{
					Format(itemName, sizeof(itemName), "Jump Suit (5 Sec CD)");
					return itemName;	
				}
				case 17:
				{
					Format(itemName, sizeof(itemName), "Bone Breaker");
					return itemName;	
				}
				
			}
		}
		//return Plugin_Handled;
	}
	return itemName;
}
//

public void SpawnStartTouch(int spawn, int iClient)
{
	if (iClient > 33 || iClient < 1)
	{
		return;	// Not a client
	}
	else bInSpawn[iClient] = true;
	if(bInSpawn[iClient] && iPlayerIsClassID[iClient] == 6)
	{
		TF2_RemoveCondition(iClient, TFCond_CritOnFirstBlood); //fuck you abusing heavy
		
	}
}

public void SpawnEndTouch(int spawn, int iClient)
{
	if (iClient > 33 || iClient < 1)
	{
		return;	// Not a client
	} 
	else bInSpawn[iClient] = false;
}


public void CreateSentryGun(int iClient, int createEntityByNameINT, float vector3PlrOrigin[3], float eyeangles[3], int iTeam)
{
	
	float fBuildMaxs[3];
	fBuildMaxs[0] = 24.0;
	fBuildMaxs[1] = 24.0;
	fBuildMaxs[2] = 66.0;
	
	float fMdlWidth[3];
	fMdlWidth[0] = 1.0;
	fMdlWidth[1] = 0.5;
	fMdlWidth[2] = 0.0;
	
	char sModel[64];
	
	
	
	int iShells, iHealth, iRockets;
	
	sModel = "models/kirillian/buildables/drone.mdl";
	iShells = 500;
	iHealth = 60;
	
	DispatchSpawn(createEntityByNameINT);
	
	TeleportEntity(createEntityByNameINT, vector3PlrOrigin, eyeangles, NULL_VECTOR);
	
	SetEntityModel(createEntityByNameINT,sModel);
	
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_flAnimTime"),                 51, 4 , true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_nNewSequenceParity"),         4, 4 , true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_nResetEventsParity"),         4, 4 , true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iAmmoShells") ,                 iShells, 4, true);
		//SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iMaxHealth"),                 iHealth, 4, true);
		//SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iHealth"),                     iHealth, 4, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_bBuilding"),                 0, 1, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_bPlacing"),                     0, 2, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_bDisabled"),                 0, 2, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iObjectType"),                 3, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iState"),                     1, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_bHasSapper"),                 0, 2, false);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_nSkin"),                     (iTeam-2), 1, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_bServerOverridePlacement"),     1, 1, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iUpgradeLevel"),             1, 4, true);
	SetEntData(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_iAmmoRockets"),                 iRockets, 4, true);
	SetEntDataEnt2(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_hBuilder"),     iClient, true);
	SetEntDataFloat(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_flCycle"),                     0.0, true);
	SetEntDataFloat(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_flPlaybackRate"),             1.0, true);
	SetEntDataFloat(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_flPercentageConstructed"),     1.0, true);
	SetEntDataVector(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_vecOrigin"),             vector3PlrOrigin, true);
	SetEntDataVector(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_angRotation"),         eyeangles, true);
	SetEntDataVector(createEntityByNameINT, FindSendPropInfo("CObjectSentrygun","m_vecBuildMaxs"),         fBuildMaxs, true);
	
	SetVariantInt(iTeam);
	AcceptEntityInput(createEntityByNameINT, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(createEntityByNameINT, "SetTeam", -1, -1, 0); 
	
	g_aClientSentries[iClient].Push(EntIndexToEntRef(createEntityByNameINT));
	SetEntProp(createEntityByNameINT, Prop_Send, "m_iHealth", iHealth);
	SetEntProp(createEntityByNameINT, Prop_Send, "m_iMaxHealth", iHealth);
         //kend
	
	
}

void GenerateHint(int iClient, int hintID)
{
    switch(hintID)
    {
        case 0:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Near edges, Pyro's ultimate can be very nasty. Be wary of deadly pits!");
        }
        case 1:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Sniper's ultimate is a great way to check for the nearby spies.");
        }
        case 2:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Even though heavy is quite scary, you can still easily backstab him during his ultimate.");
        }
        case 3:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Use items to counter the enemy team! You don't have to stick with your current loadout, feel free to swap it out.");
        }
        case 4:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Medic is extremely important. Use his combat shotgun to gain 4% ubercharge per each shot hit.");
        }
        case 5:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Engineer's drones are not invincible! Shoot them down or sap them!");
        }
        case 6:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Spy's ultimate weapon is extremely good at close range. If you failed a stab, don't be afraid to use it!");
        }
        case 7:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Soldier's ultimate might be scary, but you can still reflect his rockets. Show him who's the boss!");
        }
        case 8:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}Capture the objective to give your team a 100 credit boost!");
        }
        case 9:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}You can carry only one type of consumable. Choose wisely!");
        }
        case 10:
        {
            CPrintToChat(iClient, "{yellow}Hint: {default}You can only carry 3 items. Choose wisely!");
        }
        case 11:
		{
            CPrintToChat(iClient, "{yellow}Hint: {default}Help fellow engineers by using your consumable ammo packs near them!");
        }
    }
}
void hf_func_AddConsumableItemToPlayer(int iClient, int iItemID)
{
	if(iPlayerHasConsumableType[iClient] != iItemID) 
	{
		iPlayerHasConsumableType[iClient] = iItemID;
		iPlayerHasConsumableAmount[iClient] = 1;
	}
	else if(iPlayerHasConsumableType[iClient] == iItemID)
	{
		iPlayerHasConsumableAmount[iClient]++;
	} 
}

void hf_func_AddItemToPlayer(int iClient, int iItemID, int iSlotDecider, int iItemPrice)
{
	
	if(iCredits[iClient] >= iItemPrice)
	{
		iCredits[iClient] -= iItemPrice;
		switch(iSlotDecider)
		{
			case 0:
			{
				iCustomItemSlot_0[iClient] = iItemID;
			}
			case 1:
			{
				iCustomItemSlot_1[iClient] = iItemID;
			}
			case 2:
			{
				iCustomItemSlot_2[iClient] = iItemID;
			}
		}
		switch(iItemID)
		{
			case 0:
			{
				CPrintToChat(iClient,"{green}Speed Shoes bought!");
			}
			case 1:
			{
				CPrintToChat(iClient,"{green}Bullet Damage Resistance bought!");
			}
			case 2:
			{
				CPrintToChat(iClient,"{green}Explosive Damage Resistance bought!");
			}
			case 3:
			{
				CPrintToChat(iClient,"{green}Fire Damage Resistance bought!");
			}
			case 4:
			{
				CPrintToChat(iClient,"{green} Zapper bought!");
			}
			case 5:
			{
				CPrintToChat(iClient,"{green}Cauterize bought!");
			}
			case 6:
			{
				CPrintToChat(iClient,"{green}Oil It Up bought!");
			}
			case 7:
			{
				CPrintToChat(iClient,"{green}Deft hands bought!");
			}
			case 8:
			{
				CPrintToChat(iClient,"{green}Veteran bought!");
			}
			case 9:
			{
				CPrintToChat(iClient,"{green}Best Buddy bought!");
			}
			case 10:
			{
				CPrintToChat(iClient,"{green}Anger bought!");
			}
			case 11:
			{
				CPrintToChat(iClient,"{green}Aggression bought!");
			}
			case 12:
			{
				CPrintToChat(iClient,"{green}Jumper's dream bought!");
			}
			case 13:
			{
				CPrintToChat(iClient,"{green}Pocket Dispenser bought!");
			}
			case 14:
			{
				CPrintToChat(iClient,"{green}The Secret Agent bought!");
			}
			case 15:
			{
				CPrintToChat(iClient,"{green}Pocket Medic bought!");
			}
			case 16:
			{
				CPrintToChat(iClient,"{green}Jump Suit bought!");
			}
			case 17:
			{
				CPrintToChat(iClient,"{green}Bone Breaker bought!");
			}
		}
		
	}
	else if(iCredits[iClient] < iItemPrice)
	{
		CPrintToChat(iClient,"{fullred}You don't have enough credits! Wait or kill someone to get more!");
	}
}



void hf_func_SpawnConsumableItem(int iClient, int iConsumableID)
{
	switch(iConsumableID)
	{
		case 0:
		{
			SpawnPack(iClient, "item_healthkit_small", true, 0);
		}
		case 1:
		{
			SpawnPack(iClient, "item_healthkit_medium", true, 0);
		}
		case 2:
		{
			SpawnPack(iClient, "item_healthkit_full", true, 0);
		}
		
		case 3:
		{
			SpawnPack(iClient, "item_ammopack_small", true, 1);
		}
		case 4:
		{
			SpawnPack(iClient, "item_ammopack_medium", true, 1);
		}
		case 5:
		{
			SpawnPack(iClient, "item_ammopack_full", true, 1);
		}
	}
}