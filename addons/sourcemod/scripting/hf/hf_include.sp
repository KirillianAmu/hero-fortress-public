static GlobalForward fOnClientUseUltimate;
static GlobalForward fOnSniperUseUltimate;

void RegInclude()
{
	fOnClientUseUltimate = new GlobalForward("HF_OnClientUseUltimate", ET_Ignore, Param_Cell);
	fOnSniperUseUltimate = new GlobalForward("HF_OnSniperUseUltimate", ET_Ignore, Param_Cell, Param_Array, Param_Cell);
	
	CreateNative("HF_IsClientInUltimate", Native_IsClientInUltimate);
	
	RegPluginLibrary("hero_fortress");
}

void Forward_OnClientUseUltimate(int client)
{
	Call_StartForward(fOnClientUseUltimate);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnSniperUseUltimate(int client, int coveredPlayers[MAXPLAYERS], int count)
{
	Call_StartForward(fOnSniperUseUltimate);
	Call_PushCell(client);
	Call_PushArray(coveredPlayers, MAXPLAYERS);
	Call_PushCell(count);
	Call_Finish();
}

public any Native_IsClientInUltimate(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client <= 0 || client > MaxClients)
		return false;
	
	return iUltimateSecondsLeft[client] > 0;
}