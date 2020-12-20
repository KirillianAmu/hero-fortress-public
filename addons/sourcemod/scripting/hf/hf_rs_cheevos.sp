bool[8][TF_MAXPLAYERS + 1] cheevos;
//use this if your server has some kind of achievement system.
int playerDamageTotal[33];
int killedPlayersDuringUltimate[33];
int coveredPlayersInPiss[33];

void CheckCheevos(int iClient, int cheevoID)
{
	switch(cheevoID)
	{
		case 0:
		{
			//Heroes never die. (Common)  //should work
			//Activate either Heavy or Engineer or Medic's ultimate while under 25 hp. 
			if(cheevos[0][iClient] == false)
			{
				cheevos[0][iClient] = true;
				//CPrintToChatAll("%i , {green}Earned : Heroes Never Die Achievement!", iClient);
			}
		}
		case 1:
		{
			//TAAAAAAANK..? (Rare)  //should work
			//Kill the ulting Heavy up close.
			if(cheevos[1][iClient] == false)
			{
				cheevos[1][iClient] = true;
				//CPrintToChatAll("%i , {green}Earned : TAAAAAAANK..? Achievement!", iClient);
			}
		}
		case 2:
		{
			//That's how we do it in the bush! (Common) //works
			//Cover more than 8 enemies in jarate with Sniper's ultimate.
			if(cheevos[2][iClient] == false && coveredPlayersInPiss[iClient] >= 8)
			{
				cheevos[2][iClient] = true;
				//CPrintToChatAll("%i , {green}Earned : That's How We Do It In The Bush Achievement!", iClient);
			}
		}
		case 3:
		{
			//Champion of the Fort: (Rare) //works
			//Kill 8 players during an ultimate.
			if(cheevos[3][iClient] == false && killedPlayersDuringUltimate[iClient] >= 8 )
			{
				cheevos[3][iClient] = true;
				
			}
			
		}
		case 4:
		{
		}
		case 5:
		{
			//C'mon, ragequit. (Uncommon) //TODO
			//Kill a player that almost captured the control point during your Ultimate.
			if(cheevos[5][iClient] == false)
			{
				cheevos[5][iClient] = true;
			//	PrintToServer("Can't wait to see them ragequit");
			}
		}
		case 6:
		{
			//That wasn't supposed to happen. (Rare) //works
			///As a Demoman, during your ultimate kill the enemy with either hazardous area or fall damage.
			if(cheevos[6][iClient] == false)
			{
				cheevos[6][iClient] = true;
			//	CPrintToChatAll("%i , {green}Earned : That wasn't supposed to happen. Achievement!", iClient);
			}
		}
		case 7:
		{
			//Now that's a lot of damage.(Rare) //Works
			//Deal over 10000 damage in a single match as any class.
			if(playerDamageTotal[iClient] > 10000 && cheevos[7][iClient] == false)
			{
				cheevos[7][iClient] = true;
			//	CPrintToChatAll("%i , {green}Earned : Now that's a lot of damage! Achievement!", iClient);
			}
			
		}
	}
}
