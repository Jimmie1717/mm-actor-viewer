local core={};
-- Version
local id=nil;
local version={
	["NZSE0"]={
		["ActorList"]=0x3E87D0,
		["Load"]=0x3FF395,
		["Room"]=0x3FF200
	},
	["NZSJ0"]={
		["ActorList"]=0x3E89A0,
		["Load"]=0x3FF545,
		["Room"]=0x3FF3B0
	},
	["NZSJ1"]={
		["ActorList"]=0x3E8C60,
		["Load"]=0x3FF805,
		["Room"]=0x3FF670
	}
};
-- Actor Names
local names={
	[0x0000]="Link",
	[0x0004]="Colored Flame",
	[0x0005]="Door",
	[0x0006]="Chest",
	[0x0008]="Octorok",
	[0x0009]="Explosive",
	[0x000A]="Wallmaster",
	[0x000B]="Dodongo",
	[0x000B]="Keese",
	[0x000E]="Collectable Item",
	[0x0010]="Fairy/Tatl",
	[0x0018]="Loading Plane",
	[0x001E]="Door (Dungeon)",
	[0x0020]="Zora Fins",
	[0x0022]="Frog",
	[0x0024]="Skulltula",
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
	[0x0081]="Wooden Box",
	[0x0082]="Pot",
	[0x0090]="Grass",
	[0x0093]="Switch",
	[0x0096]="Hookshot Target",
	[0x00A8]="Sign (Square)",
	[0x00E4]="Beehive",
	[0x00E5]="Wooden Crate",
	[0x010D]="Grass Patch",
	[0x012F]="Majora/Remains",
	[0x015A]="Three Day Timer",
	[0x0164]="Boe",
	[0x0183]="Deku Flower",
	[0x018B]="Spring Water",
	[0x019E]="Monkey",
	[0x01A8]="Big Octo",
	[0x01B9]="Lilypad",
	[0x01D1]="Dexihand",
	[0x01E7]="Bonk Activator?",
	[0x01F4]="Spider Web",
	[0x020B]="Ocean Spider House Guy",
	[0x0210]="Skull Kid Picture",
	[0x0223]="Owl Statue",
	[0x023B]="Magical Mushroom",
	[0x0265]="Invisible Rupees",
	[0x02A5]="Stalchild",
};
-- For Reloading list.
local last={
	["Room"]=0x00,
	["Scene"]=0x00
}

function getROMID()
	local id="";
	for i=0,3,1 do
		id=string.format("%s%s",id,string.char(memory.read_u8(0x3B+i,"ROM")));
	end
	id=id..memory.read_u8(0x3F,"ROM");
	return id;
end

function getActorListAddress(actor_type)
	return version[id]["ActorList"]+(actor_type*0xC);
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

function core.roomChanged()
	local current=memory.read_u8(version[id]["Room"]);
	if(current~=last["Room"])then
		last["Room"]=current;
		return true;
	else
		return false;
	end
end

function core.sceneChanged()
	local current=memory.read_u8(version[id]["Load"]);
	if(current==0x00 and last["Scene"]==0xEC)then
		last["Scene"]=current;
		return true;
	else
		last["Scene"]=current;
		return false;
	end
end

function core.init()
	id=getROMID();
	if(bizstring.substring(id,1,2)=="ZS")then
		-- init room.
		last["Room"]=memory.read_u8(version[id]["Room"]);
		return true;
	else
		gui.addmessage("Invalid ROM ID: "..id);
		gui.addmessage("This Script will only work with Majora's Mask.");
		gui.addmessage("");
	end
	return nil;
end

return core;