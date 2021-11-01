#define CHOICE1 "#choice1"
#define CHOICE2 "#choice2"
#define CHOICE3 "#choice3"
#define CHOICE4 "#choice4"
#define CHOICE5 "#choice5"
#define CHOICE6 "#choice6"
#define CHOICE7 "#choice7"
#define CHOICE8 "#choice8"
#define CHOICE9 "#choice9"
#define CHOICE10 "#choice10"
#define CHOICE11 "#choice11"
#define CHOICE12 "#choice12"
#define CHOICE13 "#choice13"
#define CHOICE14 "#choice14"
#define CHOICE15 "#choice15"
#define CHOICE16 "#choice16"
#define CHOICE17 "#choice17"
#define CHOICE18 "#choice18"
#define CHOICE19 "#choice19" //sell all
#define CHOICE20 "#choice20" //sell 1
#define CHOICE21 "#choice21" //sell 2
#define CHOICE22 "#choice22" //sell 3

#define CHOICE1C "#choice1c"
#define CHOICE2C "#choice2c"
#define CHOICE3C "#choice3c"
#define CHOICE4C "#choice4c"
#define CHOICE5C "#choice5c"
#define CHOICE6C "#choice6c"

bool bPlayerHudPreference[TF_MAXPLAYERS + 1];
bool bPlayerBuyMenuPreference[TF_MAXPLAYERS + 1];

//I suggest you to not touch this for your own bloody sanity.

int itemPricing[32] =
{
	450, //speed shoes
	350, //bullet
	350, //explosion damage resistance
	350, //fier damage resistance
	200, //zapper 
	350, //cauterize
	500, //oil it up
	350, //deft hands
	350, //veteran
	450, //best buddy
	200, //anger
	250, //aggression
	200, //jumper's dream'
	200, //the pocket dispenser
	250, //the secret agent
	200, //pocket medic
	400, //jump suit
	350 //Bone breaker
};

int consumablePricing[32] =
{
	200, //hp pack Small -
	300, //hp pack Medium - 
	500, //hp pack Max -
	150, //ammo pack Small - 
	250, //ammo pack Medium - 
	500 //ammot pack Max - 
}; //spells might be too stronk. so i'll keep to ammo and stuff for now.'


public int MenuHandler1(Menu menu, MenuAction action, int iClient, int iChoise)
{
	if(iClient > 0)
	{
		
		switch(action)
		{
			case MenuAction_Start:
			{
				//PrintToServer("Displaying menu");
			}
			
			case MenuAction_Display:
			{
				
			}
			
			case MenuAction_Select:
			{
				
				char info[32];
				menu.GetItem(iChoise, info, sizeof(info));
				if (StrEqual(info, CHOICE3))
				{
					//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				}
				else
				{
					//PrintToServer("Client %d selected %s", iClient, info);
				}
				int itemPrice;
				
				int slotDecider;
				
				if(iCustomItemSlot_0[iClient] == -1)
				{
					slotDecider = 0;
				}
				else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] == -1)
				{
					slotDecider = 1;
				}
				else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] == -1)
				{
					slotDecider = 2;
				}
				if(bInSpawn[iClient] == true)
				{
					char sPath[64];
					Format(sPath, sizeof(sPath), "mvm/mvm_bought_upgrade.wav");
					EmitSoundToAll(sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
					itemPrice = itemPricing[iChoise];
					
					if(iChoise < 18)
					{
						hf_func_AddItemToPlayer(iClient, iChoise, slotDecider, itemPrice);
					}
					else if(iChoise > 18){
						switch(iChoise){
							case 19: //slot 0
							{
								int sum;
								sum = 200;
								iCredits[iClient] += sum;
								CPrintToChat(iClient,"{green}Refunded %u.", sum);
								iCustomItemSlot_0[iClient] = -1;
								CheckItems(iClient, 0);
							}
							
							case 20: //slot 1
							{
								int sum;
								sum = 200;
								iCredits[iClient] += sum;
								CPrintToChat(iClient,"{green}Refunded %u.", sum);
								iCustomItemSlot_1[iClient] = -1;
								CheckItems(iClient, 0);
							}
							
							
							case 21: //slot 0
							{
								int sum;
								sum = 200;
								iCredits[iClient] += sum;
								CPrintToChat(iClient,"{green}Refunded %u.", sum);
								iCustomItemSlot_2[iClient] = -1;
								CheckItems(iClient, 0);
							}
							case 32:
							{
								int sum;
								switch(slotDecider)
								{
									case 1:
									{
										sum = 200;
										iCredits[iClient] += sum;
										CPrintToChat(iClient,"{green}Refunded %u.", sum);
									}
									case 2:
									{
										sum = 400;
										iCredits[iClient] += sum;
										CPrintToChat(iClient,"{green}Refunded %u.", sum);
									}
									case 0:
									{
										sum = 600;
										iCredits[iClient] += sum;
										CPrintToChat(iClient,"{green}Refunded %u.", sum);
									}
									
								}
								iCustomItemSlot_0[iClient] = -1;
								iCustomItemSlot_1[iClient] = -1;
								iCustomItemSlot_2[iClient] = -1;
								CheckItems(iClient, 0);
								
							}
						}
					}
					
					CheckItems(iClient, 0);
					TF2_RemoveAllWeapons(iClient);
					TF2_RespawnPlayer(iClient);
					if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] != -1)
					{
						CPrintToChat(iClient,"{yellow}You have used all of your three item slots with this purchase! Sell your items to be able to buy items again!");
					}
				}
				else if(bInSpawn[iClient] == false)
				{
					switch(iChoise)
					{
						case 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,32:
						{
							CPrintToChat(iClient, "You must be in spawn to purchase/sell items.");
						}
					}
				}
			}
			
			case MenuAction_Cancel:
			{
				//PrintToServer("Client %d's menu was cancelled for reason %d", iClient, iChoise);
			}
			
			case MenuAction_End:
			{
				delete menu;
			}
			
			case MenuAction_DrawItem:
			{
				int style;
				char info[32];
				menu.GetItem(iChoise, info, sizeof(info), style);
				for(int i = 0; i < 18; i++)
				{
					if(iCustomItemSlot_0[iClient] == i || iCustomItemSlot_1[iClient] == i || iCustomItemSlot_2[iClient] == i)
					{
						char stuff[64];
						Format(stuff, sizeof(stuff), "#choice%u", i+1);
						if (StrEqual(info, stuff))
						{
							return ITEMDRAW_DISABLED;
						}
					}
				}
				if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] != -1)
				{
					for(int i = 0; i < 18; i++)
					{
						
						char stuff[64];
						Format(stuff, sizeof(stuff), "#choice%u", i+1);
						if (StrEqual(info, stuff))
						{
							return ITEMDRAW_DISABLED;
						}
						
					}
				}
				
				if(iCustomItemSlot_0[iClient] == -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] == -1 )
				{
					if (StrEqual(info, CHOICE19))
					{
						return ITEMDRAW_DISABLED;
					}
				}
				
				if(iCustomItemSlot_0[iClient] == -1)
				{
					if (StrEqual(info, CHOICE20))
					{
						return ITEMDRAW_DISABLED;
					}
				}
				if(iCustomItemSlot_1[iClient] == -1)
				{
					if (StrEqual(info, CHOICE21))
					{
						return ITEMDRAW_DISABLED;
					}
				}
				if(iCustomItemSlot_2[iClient] == -1 )
				{
					if (StrEqual(info, CHOICE22))
					{
						return ITEMDRAW_DISABLED;
					}
				}
			}
			
		}
	}
	return 0;
}

public int MenuHandler_Consumables(Menu menu, MenuAction action, int iClient, int iChoise)
{
	if(iClient > 0)
	{
		
		switch(action)
		{
			case MenuAction_Start:
			{
				//PrintToServer("Displaying menu");
			}
			
			case MenuAction_Display:
			{
				
			}
			
			case MenuAction_Select:
			{
				int itemPrice;
				char info[32];
				menu.GetItem(iChoise, info, sizeof(info));
				if (StrEqual(info, CHOICE3))
				{
					//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				}
				else
				{
					//PrintToServer("Client %d selected %s", iClient, info);
				}
				if(bInSpawn[iClient] == true)
				{
					char sPath[64];
					Format(sPath, sizeof(sPath), "mvm/mvm_bought_upgrade.wav");
					EmitSoundToAll(sPath, iClient, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
					
					switch(iChoise)
					{
						case 0:
						{
							itemPrice = consumablePricing[0];
							//PrintToServer("Client %d selected %s", iClient, info);
							
							if(iCredits[iClient] >= itemPrice)
							{
								int itemID = 0;
								hf_func_AddConsumableItemToPlayer(iClient, itemID);
								
								iCredits[iClient] -= itemPrice;
								CPrintToChat(iClient,"{green}Hp pack - Small bought!");
							}
							else if(iCredits[iClient] < itemPrice)
							{
								CPrintToChat(iClient,"{fullred}You don't have enough iCredits! Wait or kill someone to get more!");
							}
						}
						case 1:
						{
							itemPrice = consumablePricing[1];
							//PrintToServer("Client %d selected %s", iClient, info);
							
							if(iCredits[iClient] >= itemPrice)
							{
								int itemID = 1;
								hf_func_AddConsumableItemToPlayer(iClient, itemID);
								iCredits[iClient] -= itemPrice;
								CPrintToChat(iClient,"{green}Hp pack - Medium bought!");
							}
							else if(iCredits[iClient] < itemPrice)
							{
								CPrintToChat(iClient,"{fullred}You don't have enough iCredits! Wait or kill someone to get more!");
							}
						}
						case 2:
						{
							itemPrice = consumablePricing[2];
							//PrintToServer("Client %d selected %s", iClient, info);
							
							if(iCredits[iClient] >= itemPrice)
							{
								int itemID = 2;
								hf_func_AddConsumableItemToPlayer(iClient, itemID);
								iCredits[iClient] -= itemPrice;
								CPrintToChat(iClient,"{green}Hp pack - Large bought!");
							}
							else if(iCredits[iClient] < itemPrice)
							{
								CPrintToChat(iClient,"{fullred}You don't have enough iCredits! Wait or kill someone to get more!");
							}
						}
						case 3:
						{
							itemPrice = consumablePricing[3];
							//PrintToServer("Client %d selected %s", iClient, info);
							
							if(iCredits[iClient] >= itemPrice)
							{
								int itemID = 3;
								hf_func_AddConsumableItemToPlayer(iClient, itemID);
								iCredits[iClient] -= itemPrice;
								CPrintToChat(iClient,"{green}Ammo pack - Small bought!");
							}
							else if(iCredits[iClient] < itemPrice)
							{
								CPrintToChat(iClient,"{fullred}You don't have enough iCredits! Wait or kill someone to get more!");
							}
						}
						case 4:
						{
							if(iCredits[iClient] >= itemPrice)
							{
								int itemID = 4;
								hf_func_AddConsumableItemToPlayer(iClient, itemID);
								iCredits[iClient] -= itemPrice;
								CPrintToChat(iClient,"{green}Ammo pack - Medium bought!");
							}
						}
						case 5:
						{
							itemPrice = consumablePricing[5];
							//PrintToServer("Client %d selected %s", iClient, info);
							
							if(iCredits[iClient] >= itemPrice)
							{
								int itemID = 5;
								hf_func_AddConsumableItemToPlayer(iClient, itemID);
								iCredits[iClient] -= itemPrice;
								CPrintToChat(iClient,"{green}Ammo pack - Large bought!");
							}
							else if(iCredits[iClient] < itemPrice)
							{
								CPrintToChat(iClient,"{fullred}You don't have enough iCredits! Wait or kill someone to get more!");
							}
						}
					}
				}
			}
		}
	}
	
	return 0;
}

char[] ItemPriceToString(int convertItemID)
{
	char itemPricingStr[64];
	switch(convertItemID)
	{
		case 0:
		{	
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Speed Shoes %i | Get infinite speed increase for yourself.", itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 1:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Bullet DR %i | 10% bullet resistance.", 					itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 2:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Splash DR %i | 10% explosion resistance.",  				itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 3:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Fire DR %i | 10% fire resistance.",  						itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 4:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy A Zapper %i | Deal 25% more damage to buildings.",  		itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 5:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Cauterize %i | Heal debuff on enemy for 1 sec  per hit.",  	itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 6:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Oil It Up %i | Gas effect on enemy for 1 sec  per hit.",  	itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 7:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Deft Hands %i | Increase your reload speed by 50%.",  		itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 8:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Veteran %i | Gain passive HP regeneration.",  				itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 9:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Best Buddy %i | Increases your capture rate by 2.",  		itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 10:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Anger %i | Your bullets go through enemies.", 		 		itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 11:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Aggression %i | Increase your damage output by 10%.",  		itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 12:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Jumper's Dream %i | You take no fall damage.",  			itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 13:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Pocket Dispenser %i |  Ammo regeneration.",  				itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 14:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Secret Agent %i | You switch weapons 50% faster.",  		itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 15:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Pocket Medic %i |  Your kills drop medpacks.",  			itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 16:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Jump Suit %i | Get extra jump height.",  					itemPricing[convertItemID]);
			return itemPricingStr;
		}
		case 17:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Bone Breaker %i | Your shots slow down your enemies for 1 sec.",  	itemPricing[convertItemID]);
			return itemPricingStr;
		}
	}
	return itemPricingStr;
}

char[] ConsumableItemPriceToString(int convertItemID)
{
	char itemPricingStr[64];
	switch(convertItemID)
	{
		case 0:
		{	
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Hp Pack Small %i ", 						consumablePricing[convertItemID]);
			return itemPricingStr;
		}
		case 1:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Hp Pack Medium %i ", 					consumablePricing[convertItemID]);
			return itemPricingStr;
		}
		case 2:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Hp Pack Large %i  ",  					consumablePricing[convertItemID]);
			return itemPricingStr;
		}
		case 3:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Ammo Pack Small %i ",  				consumablePricing[convertItemID]);
			return itemPricingStr;
		}
		case 4:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Ammo Pack Medium %i ",  				consumablePricing[convertItemID]);
			return itemPricingStr;
		}
		case 5:
		{
			Format(itemPricingStr, sizeof(itemPricingStr), "Buy Ammo Pack Large %i ",  				consumablePricing[convertItemID]);
			return itemPricingStr;
		}
	}
	return itemPricingStr;
}


public Action Item_Shop_Consumable(int iClient, int args)
{
	if(iClient > 0)
	{
		if(bInSpawn[iClient] == true)
		{
			Menu menu = new Menu(MenuHandler_Consumables, MENU_ACTIONS_ALL);
			
			menu.SetTitle("Can hold one consumable type. Can be stacked.");
			menu.AddItem(CHOICE1C,	 	(ConsumableItemPriceToString(0)));
			menu.AddItem(CHOICE2C,		(ConsumableItemPriceToString(1)));
			menu.AddItem(CHOICE3C,		(ConsumableItemPriceToString(2)));
			menu.AddItem(CHOICE4C, 		(ConsumableItemPriceToString(3)));
			menu.AddItem(CHOICE5C, 		(ConsumableItemPriceToString(4)));
			menu.AddItem(CHOICE6C, 		(ConsumableItemPriceToString(5)));
			
			menu.ExitButton = true;
			menu.Display(iClient, 320);
			
			return Plugin_Handled;
		}
		else CPrintToChat(iClient, "You must be in spawn to purchase/sell items.");
	}
	return Plugin_Handled;
}


public Action Item_Shop_Offense(int iClient, int args)
{
	if(iClient > 0)
	{
		if(bInSpawn[iClient] == true)
		{
			Menu menu = new Menu(MenuHandler1, MENU_ACTIONS_ALL);
			
			menu.AddItem(CHOICE1,	 	(ItemPriceToString(0)));
			menu.AddItem(CHOICE2,		(ItemPriceToString(1)));
			menu.AddItem(CHOICE3,		(ItemPriceToString(2)));
			menu.AddItem(CHOICE4, 		(ItemPriceToString(3)));
			menu.AddItem(CHOICE5, 		(ItemPriceToString(4)));
			menu.AddItem(CHOICE6, 		(ItemPriceToString(5)));
			menu.AddItem(CHOICE7,		(ItemPriceToString(6)));
			menu.AddItem(CHOICE8, 		(ItemPriceToString(7)));
			menu.AddItem(CHOICE9, 		(ItemPriceToString(8)));
			menu.AddItem(CHOICE10,		(ItemPriceToString(9)));
			menu.AddItem(CHOICE11, 		(ItemPriceToString(10)));
			menu.AddItem(CHOICE12, 		(ItemPriceToString(11)));
			menu.AddItem(CHOICE13, 		(ItemPriceToString(12)));
			menu.AddItem(CHOICE14, 		(ItemPriceToString(13)));
			menu.AddItem(CHOICE15, 		(ItemPriceToString(14)));
			menu.AddItem(CHOICE16, 		(ItemPriceToString(15)));
			menu.AddItem(CHOICE17, 		(ItemPriceToString(16)));
			menu.AddItem(CHOICE18, 		(ItemPriceToString(17)));

	//switch cant do it like that sorryF
			if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] != -1)
			{
				menu.SetTitle("Item Shop. (0 Slots Left.)");
			}
			if(iCustomItemSlot_0[iClient] == -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] == -1)
			{
				menu.SetTitle("Item Shop. (3 Slots Left)");
			}
			else if((iCustomItemSlot_0[iClient] == -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] != -1) 
				|| (iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] == -1)
				|| (iCustomItemSlot_0[iClient] == -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] != -1))
			{
				menu.SetTitle("Item Shop. (2 Slots Left)");
			}
			else if((iCustomItemSlot_0[iClient] == -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] != -1) 
				|| (iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] != -1)
				|| (iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] == -1))
			{
				menu.SetTitle("Item Shop. (1 Slots Left)");
			}
			
			menu.ExitButton = true;
			menu.Display(iClient, 320);
			
			return Plugin_Handled;
		}
		else CPrintToChat(iClient, "You must be in spawn to purchase/sell items.");
	}
	return Plugin_Handled;
}

#define CHOICE1S "#choice1s"
#define CHOICE2S "#choice2s"
#define CHOICE3S "#choice3s"
#define CHOICE4S "#choice4s"
#define CHOICE5S "#choice5s"
#define CHOICE6S "#choice6s"
#define CHOICE7S "#choice7s"
#define CHOICE8S "#choice8s"
#define CHOICE9S "#choice9s"

public int hf_main_menu_handler(Menu menu, MenuAction action, int iClient, int iChoise)
{
	
	switch(action)
	{
		case MenuAction_Start:
		{
			//PrintToServer("Displaying menu");
		}
		
		case MenuAction_Display:
		{
			
		}
		
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(iChoise, info, sizeof(info));
			if (StrEqual(info, CHOICE1S))
			{
				ClientCommand(iClient, "hf_cl");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE2S)) //buy
			{
				ClientCommand(iClient, "hf_shop");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE3S)) //buy
			{
				ClientCommand(iClient, "hf_shop_consumable");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE4S)) //sell
			{
				menu.SetTitle("SHOP GOES HERE.");
				ClientCommand(iClient, "hf_sell");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE5S)) //Commands
			{
				menu.SetTitle("SHOP GOES HERE.");
				ClientCommand(iClient, "hf_co");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE6S))//settings
			{
				menu.SetTitle("CHANGELOG GOES HERE");
				ClientCommand(iClient, "hf_se");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE7S)) //Changelog
			{
				menu.SetTitle("CHANGELOG GOES HERE"); 
				ClientCommand(iClient, "hf_ch");
				menu.RemoveItem(0);
				menu.RemoveItem(1);
				menu.RemoveItem(2);
				menu.RemoveItem(3);
				//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
				
				menu.ExitButton = true;
			}
			if (StrEqual(info, CHOICE8S))
			{
				SetPlayerHUDPref(iClient);
			}
			if (StrEqual(info, CHOICE9S))
			{
				SetPlayerBuyPref(iClient);
			}
			else
			{
				//PrintToServer("Client %d selected %s", iClient, info);
			}
			switch(iChoise)
			{
				
			}
			//ClientCommand(iClient, "hf_shop");
		}
		
		case MenuAction_Cancel:
		{
			//PrintToServer("Client %d's menu was cancelled for reason %d", iClient, iChoise);
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
		
		case MenuAction_DrawItem:
		{
			
			
		}
	}
	
	return 0;
}


public Action hf_main_menu(int iClient, int args)
{
	if(iClient > 0)
	{
		if(bInSpawn[iClient] == true)
		{
		//	int slotDecider;
			
			Menu menu = new Menu(hf_main_menu_handler, MENU_ACTIONS_ALL);
			
			menu.SetTitle("You can open this menu in spawn. Type /hf or press TAB + R to open this menu.");
			menu.AddItem(CHOICE1S, "Class Info");
			menu.AddItem(CHOICE2S, "Buy");
			menu.AddItem(CHOICE3S, "Buy Consumable");
			menu.AddItem(CHOICE4S, "Sell");
			menu.AddItem(CHOICE5S, "Commands");
			menu.AddItem(CHOICE6S, "Settings");
			menu.AddItem(CHOICE7S, "Credits");
	//todo sell items
			menu.ExitButton = true;
			menu.Display(iClient, 320);
			
			return Plugin_Handled;
		}
		else CPrintToChat(iClient, "You must be in spawn to open this menu.");
		
	}
	return Plugin_Handled;
}

public Action hf_main_menu_classes(int iClient, int args)
{
	//int slotDecider;
	
	Menu menu = new Menu(hf_main_menu_handler, MENU_ACTIONS_ALL);
	
	menu.SetTitle("Info Printed To Chat");
	GetClassInformation(iClient, iPlayerIsClassID[iClient]);
	//menu.AddItem(CHOICE6S, "OK");
	//todo sell items
	menu.ExitButton = true;
	menu.Display(iClient, 320);
	
	return Plugin_Handled;
}

public Action hf_main_menu_changelog(int iClient, int args)
{
//	int slotDecider;
	
	Menu menu = new Menu(hf_main_menu_handler, MENU_ACTIONS_ALL);
	
	menu.SetTitle("HF v1.2.\nMade by Kirillian. \nWith help of Redsun.tf developers. \nSpecial thanks to: Kenzzer/Benoist for helping with sentry spawning. \nPubScrubLord for checking grammar. \nAnd thanks to 15.ai for miss pauling lines!");
	menu.AddItem(CHOICE7S, "OK.");
	//todo sell items
	menu.ExitButton = true;
	menu.Display(iClient, 320);
	
	return Plugin_Handled;
}

public Action hf_main_menu_settings(int iClient, int args)
{
//	int slotDecider;
	
	Menu menu = new Menu(hf_main_menu_handler, MENU_ACTIONS_ALL);
	
	menu.SetTitle("Player Preferences.");
	if(bPlayerHudPreference[iClient] == false)
	{
		menu.AddItem(CHOICE7S, "Owned Items UI: (Enabled)");
	}
	else if(bPlayerHudPreference[iClient] == true)
	{
		menu.AddItem(CHOICE7S, "Owned Items UI: (Disabled)");
	}
	
	if(bPlayerBuyMenuPreference[iClient] == false)
	{
		menu.AddItem(CHOICE8S, "Automatically close menu when leaving spawn: (Enabled)");
	}
	else if(bPlayerBuyMenuPreference[iClient] == true)
	{
		menu.AddItem(CHOICE8S, "Automatically close menu when leaving spawn: (Disabled)");
	}
	//todo sell items
	
	menu.ExitButton = true;
	menu.Display(iClient, 320);
	
	return Plugin_Handled;
}

public Action hf_main_menu_commands(int iClient, int args)
{
//	int slotDecider;
	
	Menu menu = new Menu(hf_main_menu_handler, MENU_ACTIONS_ALL);
	menu.SetTitle("Press Special Attack to use your Ultimate Ability.(Default: Mouse Wheel) \n Press TAB + R to open Hero Fortress menu. \n Crouch and press Spacebar to use your consumable item.");
	menu.AddItem(CHOICE7S, "OK.");
	//todo sell items
	
	menu.ExitButton = true;
	menu.Display(iClient, 320);
	
	return Plugin_Handled;
}




//selling

#define CHOICE1SS "#choice1ss"
#define CHOICE2SS "#choice2ss"
#define CHOICE3SS "#choice3ss"
#define CHOICE4SS "#choice4ss"
#define CHOICE5SS "#choice5ss"
#define CHOICE6SS "#choice6ss"
#define CHOICE7SS "#choice7ss"

public int Menu_Selling_Handler(Menu menu, MenuAction action, int iClient, int iChoise)
{
	if(iClient > 0){
		if(bInSpawn[iClient] == true)
		{
			switch(action)
			{
				case MenuAction_Start:
				{
					//PrintToServer("Displaying menu");
				}
				
				case MenuAction_Display:
				{
					
				}
				
				case MenuAction_Select:
				{
					char info[32];
					menu.GetItem(iChoise, info, sizeof(info));
					if (StrEqual(info, CHOICE3))
					{
						//PrintToServer("Client %d somehow selected %s despite it being disabled", iClient, info);
					}
					else
					{
						//PrintToServer("Client %d selected %s", iClient, info);
					}
					int slotDecider;
					
					if(iCustomItemSlot_0[iClient] == -1)
					{
						slotDecider = 0;
					}
					else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] == -1)
					{
						slotDecider = 1;
					}
					else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] == -1)
					{
						slotDecider = 2;
					}
					switch(iChoise)
					{
						case 4:
						{
							int sum;
							switch(slotDecider)
							{
								case 1:
								{
									sum = 200;
									iCredits[iClient] += sum;
									CPrintToChat(iClient,"{green}Refunded %u.", sum);
								}
								case 2:
								{
									sum = 400;
									iCredits[iClient] += sum;
									CPrintToChat(iClient,"{green}Refunded %u.", sum);
								}
								case 0:
								{
									sum = 600;
									iCredits[iClient] += sum;
									CPrintToChat(iClient,"{green}Refunded %u.", sum);
								}
							}
							iCustomItemSlot_0[iClient] = -1;
							iCustomItemSlot_1[iClient] = -1;
							iCustomItemSlot_2[iClient] = -1;
							CheckItems(iClient, 0);
						}
				//sell slot items
						case 0: //slot 0
						{
							int sum;
							sum = 200;
							iCredits[iClient] += sum;
							CPrintToChat(iClient,"{green}Refunded %u.", sum);
							iCustomItemSlot_0[iClient] = -1;
							CheckItems(iClient, 0);
					//	TF2_RespawnPlayer(iClient);
						}
						
						case 1: //slot 1
						{
							int sum;
							sum = 200;
							iCredits[iClient] += sum;
							CPrintToChat(iClient,"{green}Refunded %u.", sum);
							iCustomItemSlot_1[iClient] = -1;
							CheckItems(iClient, 0);
						//TF2_RespawnPlayer(iClient);
						}
						
						
						case 2: //slot 0
						{
							int sum;
							sum = 200;
							iCredits[iClient] += sum;
							CPrintToChat(iClient,"{green}Refunded %u.", sum);
							iCustomItemSlot_2[iClient] = -1;
							CheckItems(iClient, 0);
					//	TF2_RespawnPlayer(iClient);
						}
						case 3:
						{
							int sum;
							switch(slotDecider)
							{
								case 1:
								{
									sum = 200;
									iCredits[iClient] += sum;
									CPrintToChat(iClient,"{green}Refunded %u.", sum);
								}
								case 2:
								{
									sum = 400;
									iCredits[iClient] += sum;
									CPrintToChat(iClient,"{green}Refunded %u.", sum);
								}
								case 0:
								{
									sum = 600;
									iCredits[iClient] += sum;
									CPrintToChat(iClient,"{green}Refunded %u.", sum);
								}
								
							}
							iCustomItemSlot_0[iClient] = -1;
							iCustomItemSlot_1[iClient] = -1;
							iCustomItemSlot_2[iClient] = -1;
							CheckItems(iClient, 0);
							
						}
					}
					CheckItems(iClient, 0);
					TF2_RemoveAllWeapons(iClient);
					TF2_RespawnPlayer(iClient);
					if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] != -1)
					{
						CPrintToChat(iClient,"{yellow}You have used all of your three item slots with this purchase! Sell your items to buy again!");
					}
				}
				
				case MenuAction_Cancel:
				{
					//PrintToServer("Client %d's menu was cancelled for reason %d", iClient, iChoise);
				}
				
				case MenuAction_End:
				{
					delete menu;
				}
				
				case MenuAction_DrawItem:
				{
					char info[32];
					menu.GetItem(iChoise, info, sizeof(info));
					if(iCustomItemSlot_0[iClient] == -1 && iCustomItemSlot_1[iClient] == -1 && iCustomItemSlot_2[iClient] == -1 )
					{
						if (StrEqual(info, CHOICE4SS))
						{
							return ITEMDRAW_DISABLED;
						}
					}
					
					if(iCustomItemSlot_0[iClient] == -1)
					{
						if (StrEqual(info, CHOICE1SS))
						{
							return ITEMDRAW_DISABLED;
						}
					}
					if(iCustomItemSlot_1[iClient] == -1)
					{
						if (StrEqual(info, CHOICE2SS))
						{
							return ITEMDRAW_DISABLED;
						}
					}
					if(iCustomItemSlot_2[iClient] == -1 )
					{
						if (StrEqual(info, CHOICE3SS))
						{
							return ITEMDRAW_DISABLED;
						}
					}
				}
				
			}
		}
	}
	return 0;
}

public Action Item_Shop_Sell(int iClient, int args)
{
	if(iClient > 0)
	{
		if(bInSpawn[iClient] == true)
		{
			
			
			int slotDecider;
			
			if(iCustomItemSlot_0[iClient] == -1)
			{
				slotDecider = 0;
			}
			else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] == -1)
			{
				slotDecider = 1;
			}
			else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] == -1)
			{
				slotDecider = 2;
			}
			else if(iCustomItemSlot_0[iClient] != -1 && iCustomItemSlot_1[iClient] != -1 && iCustomItemSlot_2[iClient] != -1)
			{
				slotDecider = 3;
			}
			
			Menu menu = new Menu(Menu_Selling_Handler, MENU_ACTIONS_ALL);
			
			menu.SetTitle("Sell menu. Separate sales refund 200 creds.");
			menu.AddItem(CHOICE1SS, ("%s" ,GetEquippedItem(iClient, 0)));
			menu.AddItem(CHOICE2SS, ("%s" ,GetEquippedItem(iClient, 1)));
			menu.AddItem(CHOICE3SS, ("%s" ,GetEquippedItem(iClient, 2)));
			switch(slotDecider)
			{
				case 0:
				{
					
					menu.AddItem(CHOICE4SS, "Nothing to sell. ");
				}
				case 1:
				{
					menu.AddItem(CHOICE4SS, "Sell your items. Refund 200c. ");
				}
				case 2:
				{
					menu.AddItem(CHOICE4SS, "Sell your items. Refund 400c. ");
				}
				case 3:
				{
					menu.AddItem(CHOICE4SS, "Sell your items. Refund 600c. ");
				}
			}
			
			menu.ExitButton = true;
			menu.Display(iClient, 320);
		}
		else CPrintToChat(iClient, "You must be in spawn to purchase/sell items.");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}


