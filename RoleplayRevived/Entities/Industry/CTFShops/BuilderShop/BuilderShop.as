﻿// Builder Workshop

#include "RP_Costs.as";

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");
	
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::sponge);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::trampoline_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		//AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CRATE);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood * 2);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::saw_stone);
		//AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW * 2 );
	}
	{
		ShopItem@ s = addShopItem( this, "Chainsaw", "$chainsaw$", "chainsaw", "A chainsaw for cutting down trees and other... things.", false );
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WORKSHOP_CHAINSAW_WOOD_COST);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", WORKSHOP_CHAINSAW_STONE_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Drill", "$drill$", "drill", Descriptions::drill, false );
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::drill_stone);
		//AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::drill);
		//AddRequirement(s.requirements, "blob", "mat_stone", "Stone", COST_STONE_DRILL);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}

			if (name == "filled_bucket")
			{
				CBlob@ b = server_CreateBlobNoInit("bucket");
				b.setPosition(callerBlob.getPosition());
				b.server_setTeamNum(callerBlob.getTeamNum());
				b.Tag("_start_filled");
				b.Init();
				callerBlob.server_Pickup(b);
			}
		}
	}
}
