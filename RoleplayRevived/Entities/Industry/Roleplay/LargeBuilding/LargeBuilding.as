﻿/* LargeBuilding.as
 * author: Aphelion
 */

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit( CBlob@ this )
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(8, 4));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem( this, "Blacksmith Workshop", "$blacksmithworkshop$", "blacksmithworkshop", "A place for smelting ore into bars as well as smithing weapons and armour." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 200 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Armoury", "$armoury$", "armoury", "A place for changing your class as well as buying weapons and armour." );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 200 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.isOverlapping(caller))
		this.set_bool("shop available", !builder_only || caller.getName() == "builder" );
	else
		this.set_bool("shop available", false );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds
		
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		CBlob@ item = getBlobByNetworkID( params.read_netid() );
		if (item !is null && caller !is null)
		{
			this.getSprite().PlaySound("/ConstructDeep" ); 
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
}
