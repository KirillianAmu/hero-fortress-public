#if defined _hero_fortress_included
	#endinput
#endif
#define _hero_fortress_included

/**
 * Forward called when client used ultimate
 *
 * @param	client			Client whose used ultimate
 * @noreturn
 */
forward void HF_OnClientUseUltimate(int client);

/**
 * Forward called when a sniper used ultimate
 *
 * @param	client			Sniper whose used ultimate
 * @param	coveredPlayers	Array of clients whose covered from jarate
 * @param	count			Amount of clients covered from jarate
 * @noreturn
 */
forward void HF_OnSniperUseUltimate(int client, int coveredPlayers[MAXPLAYERS], int count);

/**
 * Returns whenever if client is currently in ultimate
 *
 * @param	client			Client whose to check
 * @error	True if client is currently in ultimate, false otherwise
 */
native bool HF_IsClientInUltimate(int client);

public SharedPlugin __pl_hero_fortress =
{
	name = "hero_fortress",
	file = "hero_fortress.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public void __pl_hero_fortress_SetNTVOptional()
{
	MarkNativeAsOptional("HF_IsClientInUltimate");
}