#if defined _hero_fortress_included
	#endinput
#endif
#define _hero_fortress_included

/**
 * Forward called when survivor is about to pick up a weapon
 *
 * @param	iClient		Client whose picked up the weapon
 * @param	iTarget		Prop entity whose picked up
 * @param	rarity		Rarity of the weapon
 * @return	Plugin_Handled to prevent picking up the weapon, Plugin_Stop to also prevent calling out rare weapons, Plugin_Continue otherwise
 */
forward void HF_OnClientUseUltimate(int client);

/**
 * Forward called when a boomer explodes
 *
 * @param	iBoomer		Client whose the boomer explode
 * @param	iClients	Array of clients whose jarated from boomer
 * @param	iLength		Amount of clients jarated from boomer
 * @noreturn
 */
forward void HF_OnSniperUseUltimate(int client, int coveredPlayers[MAXPLAYERS], int count);

/**
 * Gets client total weapon callout counts stored in cookies
 *
 * @param	iClient		Client whose to get weapon callout counts
 * @return	Weapon callout counts
 * @error	Invalid client or client not in game
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