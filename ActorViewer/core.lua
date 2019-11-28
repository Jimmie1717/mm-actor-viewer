-- Global
version=nil;
list={
	["NZSE0"]={
		["ActorList"]=0x3E87D0,
		["Load"]=0x3FF395,
	},
	["NZSJ0"]={
		["ActorList"]=0x3E89A0,
		["Load"]=0x3FF545,
	},
	["NZSJ1"]={
		["ActorList"]=0x3E8C60,
		["Load"]=0x3FF805,
	}
};

local core={};
local names={
	[0x0000]="Link",
	[0x0005]="Door",
	[0x0006]="Chest",
	[0x0008]="Octorok",
	[0x000A]="Wallmaster",
	[0x000B]="Dodongo",
	[0x000B]="Keese",
	[0x000E]="Collectable Item",
	[0x0010]="Fairy/Tatl",
	[0x0018]="Loading Plane",
	[0x001E]="Door (Dungeon)",
	[0x0020]="Zora Fins",
	[0x0022]="Frog",
	[0x0026]="Sign (Arrow)",
	[0x002F]="Bomb Flower",
	[0x0033]="Deku Baba",
	[0x0038]="Warp (Blue/Pad)",
	[0x0039]="Torch",
	[0x003A]="Heart Container",
	[0x003B]="Mad Scrub",
	[0x003C]="Red Bubble",
	[0x003E]="Blue Bubble",
	[0x004A]="Floormaster",
	[0x004C]="ReDead",
	[0x004F]="Fish, Bugs, or Butterflies",
	[0x0050]="Skullwalltula",
	[0x0054]="Epona",
	[0x0055]="Grotto",
	[0x0066]="Mini Baba",
	[0x0090]="Grass",
	[0x0093]="Switch",
	[0x00A8]="Sign (Square)",
	[0x00E4]="Beehive",
	[0x010D]="Grass Patch",
	[0x012F]="Majora/Remains",
	[0x015A]="Three Day Timer",
	[0x018B]="Spring Water",
	[0x019E]="Monkey",
	[0x01A8]="Big Octo",
	[0x01B9]="Lilypad",
	[0x01D1]="Dexihand",
	[0x0223]="Owl Statue",
	[0x023B]="Magical Mushroom",
};

function getActorListAddress(actor_type)
	return list[version]["ActorList"]+(actor_type*0xC);
end

function getActorListAmount(actor_type)
	return memory.read_u32_be(getActorListAddress(actor_type));
end

function getPointerAddress(pointer)
	return bit.band(memory.read_u32_be(pointer),0xFFFFFF);
end

function core.getActorsByID(actor_id)
	local pointers={};
	for i=0,11,1 do
		local addr=getPointerAddress(getActorListAddress(i)+4);
		for j=1,getActorListAmount(i),1 do
			if(addr~=0)then
				if(memory.read_u16_be(addr)==actor_id)then
					table.insert(pointers,addr);
				end
				addr=getPointerAddress(addr+0x12C);
			end
		end
		if(table.getn(pointers)~=0)then break; end
	end
	return pointers;
end

function core.getActorsByList(actor_type)
	local pointers={};
	local addr=getPointerAddress(getActorListAddress(actor_type)+4);
	for i=1,getActorListAmount(actor_type),1 do
		if(addr~=0)then
			table.insert(pointers,addr);
			addr=getPointerAddress(addr+0x12C);
		end
	end
	return pointers;
end

function core.getAllActors()
	local pointers={};
	for i=0,11,1 do
		local addr=getPointerAddress(getActorListAddress(i)+4);
		for j=1,getActorListAmount(i),1 do
			if(addr~=0)then
				table.insert(pointers,addr);
				addr=getPointerAddress(addr+0x12C);
			end
		end
	end
	return pointers;
end

function core.getActorName(actor_id)
	if(names[actor_id]~=nil)then
		return names[actor_id];
	else
		return "Unknown";
	end
end

function core.getVersion()
	hash=gameinfo.getromhash();
	if(hash=="D6133ACE5AFAA0882CF214CF88DABA39E266C078")then
		version="NZSE0";
		gui.addmessage("Majora's Mask (USA)");
	elseif(hash=="5FB2301AACBF85278AF30DCA3E4194AD48599E36")then
		version="NZSJ0";
		gui.addmessage("Majora's Mask (Japan)");
	elseif(hash=="41FDB879AB422EC158B4EAFEA69087F255EA8589")then
		version="NZSJ1";
		gui.addmessage("Majora's Mask (Japan) (Rev A)");
	end
end

return core;