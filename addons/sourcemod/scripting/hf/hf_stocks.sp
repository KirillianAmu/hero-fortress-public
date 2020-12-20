
int g_FilteredEntity = -1;

stock bool IsValidClient(int iClient) //check if client is real.
{
	return (0 < iClient && iClient <= MaxClients && IsClientInGame(iClient) && !IsClientReplay(iClient) && !IsClientSourceTV(iClient) && !GetEntProp(iClient, Prop_Send, "m_bIsCoaching"));
}
stock int TF2_GetHealingTarget(int iClient)
{
	char classname[64];
	TF2_GetCurrentWeaponClass(iClient, classname, sizeof(classname));
	if(StrEqual(classname, "CWeaponMedigun"))
	{
		int index = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		if(GetEntProp(index, Prop_Send, "m_bHealing") == 1)
		{
			return GetEntPropEnt(index, Prop_Send, "m_hHealingTarget");
		}
	}
	return -1;
}

stock int SetAmmo(int client,int wepslot,int newAmmo)
{
	int weapon = GetPlayerWeaponSlot(client, wepslot);
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, newAmmo, 4, true);
	}
}

stock bool IsWeaponSlotActive(int iClient, int iSlot)
{	
	return GetPlayerWeaponSlot(iClient, iSlot) == GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
}

stock int TF2_GetCurrentWeaponClass(int iClient, char name[64], int maxlength)
{
	int index;
	if( iClient > 0 )
	{
		index = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
	}
	if (index > 0)
	{
		GetEntityNetClass(index, name, maxlength);
	}
}

stock int TF2_GetPlayerMaxHealth(int client)
{
	return GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, client);
}

stock void AddModelToDownloadsTable(const char[] sModel)
{
	static const char sFileType[][] = {
		"dx80.vtx",
		"dx90.vtx",
		"mdl",
		"phy",
		"sw.vtx",
		"vvd",
	};
	
	char sRoot[PLATFORM_MAX_PATH];
	strcopy(sRoot, sizeof(sRoot), sModel);
	ReplaceString(sRoot, sizeof(sRoot), ".mdl", "");
	
	for (int i = 0; i < sizeof(sFileType); i++)
	{
		char sBuffer[PLATFORM_MAX_PATH];
		Format(sBuffer, sizeof(sBuffer), "%s.%s", sRoot, sFileType[i]);
		if (FileExists(sBuffer))
		AddFileToDownloadsTable(sBuffer);
	}
}


stock bool IsEntLimitReached()
{
    if (GetEntityCount() >= (GetMaxEntities()-64))
    {
        PrintToChatAll("Warning: Entity limit is nearly reached! Please switch or reload the map!");
        LogError("Entity limit is nearly reached: %d/%d", GetEntityCount(), GetMaxEntities());
        return true;
    }
    else
        return false;
}

public bool TraceFilter(int ent, int contentMask)
{
	return (ent != g_FilteredEntity);
}


stock void SpawnPack(int iClient, char[] name, bool cmd, int objectType)
{
	float PlayerPosition[3];
	if (cmd)
	{
		GetClientAbsOrigin(iClient, PlayerPosition);
	}
	else
	{
        //PlayerPosition = g_MedicPosition[iClient];
	}
	
	if (PlayerPosition[0] != 0.0 && PlayerPosition[1] != 0.0 && PlayerPosition[2] != 0.0 && IsEntLimitReached() == false)
	{
		PlayerPosition[2] += 4;
		g_FilteredEntity = iClient;
		if (cmd)
		{
			float PlayerPosEx[3];
			float PlayerAngle[3];
			float PlayerPosAway[3];
			GetClientEyeAngles(iClient, PlayerAngle);
			PlayerPosEx[0] = Cosine((PlayerAngle[1]/180)*FLOAT_PI);
			PlayerPosEx[1] = Sine((PlayerAngle[1]/180)*FLOAT_PI);
			PlayerPosEx[2] = 0.0;
			ScaleVector(PlayerPosEx, 75.0);
			AddVectors(PlayerPosition, PlayerPosEx, PlayerPosAway);
			
			Handle TraceEx = TR_TraceRayFilterEx(PlayerPosition, PlayerPosAway, MASK_SOLID, RayType_EndPoint, TraceFilter);
			TR_GetEndPosition(PlayerPosition, TraceEx);
			CloseHandle(TraceEx);
		}
		
		float Direction[3];
		Direction[0] = PlayerPosition[0];
		Direction[1] = PlayerPosition[1];
		Direction[2] = PlayerPosition[2]-1024;
		Handle Trace = TR_TraceRayFilterEx(PlayerPosition, Direction, MASK_SOLID, RayType_EndPoint, TraceFilter);
		
		float ObjectPosition[3];
		TR_GetEndPosition(ObjectPosition, Trace);
		CloseHandle(Trace);
		ObjectPosition[2] += 4;
		
		switch(objectType)
		{
			case 0: //medpacks
			{
				int Medipack = CreateEntityByName(name);
				DispatchKeyValue(Medipack, "OnPlayerTouch", "!self,Kill,,0,-1");
				if (DispatchSpawn(Medipack))
				{
					SetEntProp(Medipack, Prop_Send, "m_iTeamNum", 0, 4);
					TeleportEntity(Medipack, ObjectPosition, NULL_VECTOR, NULL_VECTOR);
					EmitSoundToAll("items/spawn_item.wav", Medipack, _, _, _, 0.75);
		            //SetArrayCell(g_MedipacksTime, Medipack, GetTime());
				}
			}
			case 1: //ammopacks
			{
					int Ammopack = CreateEntityByName(name);
					DispatchKeyValue(Ammopack, "OnPlayerTouch", "!self,Kill,,0,-1");
					if (DispatchSpawn(Ammopack))
					{
						int team = 0;
						SetEntProp(Ammopack, Prop_Send, "m_iTeamNum", team, 4);
						TeleportEntity(Ammopack, ObjectPosition, NULL_VECTOR, NULL_VECTOR);
					}
			}
			case 2: //spells
			{
				
			}
		}
		
	}
}
	
