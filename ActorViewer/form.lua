local form={};
local pointers={};
local index=nil;
local lastList="ALL";
local reload=false;

function getAllActors()
	lastList="ALL";
	index=nil;
	pointers=nil;
	pointers=core.getAllActors();
	forms.settext(labels["ActorsFound"],string.format("%d Actor(s) found.",table.getn(pointers)));
	setAddressList(pointers);
	--setActorList(pointers);
end

function getActorsByList()
	lastList="LIST";
	index=nil;
	pointers=nil;
	local list=getDropdownIndex(dropdowns["ActorTypes"]);
	pointers=core.getActorsByList(list);
	forms.settext(labels["ActorsFound"],string.format("%d Actor(s) found in List %d.",table.getn(pointers),list));
	setAddressList(pointers);
end

function getActorsByID()
	lastList="ID";
	index=nil;
	pointers=nil;
	local id=getTextboxNumber(textboxes["ActorID"],16);
	pointers=core.getActorsByID(id);
	forms.settext(labels["ActorsFound"],string.format("%d Actor(s) found.",table.getn(pointers)));
	setAddressList(pointers);
end

function reloadActors()
	if(lastList=="ALL")then
		getAllActors();
	elseif(lastList=="LIST")then
		getActorsByList();
	elseif(lastList=="ID")then
		getActorsByID();
	end
end

-- getters
function getDropdownIndex(dropdown)
	return forms.getproperty(dropdown,"SelectedIndex");
end

function getTextboxNumber(textbox,base)
	local number=tonumber(forms.gettext(textbox),base);
	if(number>0xFFFF)then
		print("Invalid ID");
		forms.settext(textbox,"FFFF");
		return 0xFFFF;
	else
		forms.settext(textbox,string.format("%04s",bizstring.hex(number)));
		return number;
	end
end

-- setters
function setAddressList(pointers)
	local s="";
	for i=1,table.getn(pointers),1 do
		local id=memory.read_u16_be(pointers[i]);
		s=string.format("%s%04s @ 80%06s\n",s,bizstring.hex(id),bizstring.hex(pointers[i]));
	end
	forms.settext(textboxes["ActorAddresses"],s);
end

function setNextActor()
	if(index~=nil)then
		index=index+1;
		if(index>table.getn(pointers))then
			index=1;
		end
	end
end

function setPreviousActor()
	if(index~=nil)then
		index=index-1;
		if(index<1)then
			index=table.getn(pointers);
		end
	end
end



-- Form Functions

-- Update Actor Display
function form.updateActor()
	event.onloadstate(reloadActors);
	if(memory.read_u8(list[version]["Load"])==0xEC and reload==false)then
		reload=true;
	elseif(memory.read_u8(list[version]["Load"])==0x00 and reload==true)then
		reloadActors();
		reload=false;
	end
	if(table.getn(pointers)~=0 and index==nil)then index=1; end
	if(index~=nil)then
		local id=memory.read_u16_be(pointers[index]);
		local name=core.getActorName(id);
		local room=memory.read_s8(pointers[index]+0x3);
		local variable=memory.read_u16_be(pointers[index]+0x1C);
		forms.settext(labels["ActorData"]["Info"]["Current"],string.format("Current Actor: %s",name));
		forms.settext(textboxes["ActorData"]["Info"]["Address"],string.format("%06s",bizstring.hex(pointers[index])));
		forms.settext(textboxes["ActorData"]["Info"]["ID"],string.format("%04s",bizstring.hex(id)));
		forms.settext(textboxes["ActorData"]["Info"]["Room"],string.format("%d",room));
		forms.settext(textboxes["ActorData"]["Info"]["Variable"],string.format("%04s",bizstring.hex(variable)));
		forms.settext(labels["ActorData"]["Position"]["X"],string.format("% 5.3f",memory.readfloat(pointers[index]+0x24,true)));
		forms.settext(labels["ActorData"]["Position"]["Y"],string.format("% 5.3f",memory.readfloat(pointers[index]+0x28,true)));
		forms.settext(labels["ActorData"]["Position"]["Z"],string.format("% 5.3f",memory.readfloat(pointers[index]+0x2C,true)));
		forms.settext(labels["ActorData"]["Rotation"]["X"],string.format("% 3.2f°",memory.read_u16_be(pointers[index]+0xBC)/182.04));
		forms.settext(labels["ActorData"]["Rotation"]["Y"],string.format("% 3.2f°",memory.read_u16_be(pointers[index]+0xBE)/182.04));
		forms.settext(labels["ActorData"]["Rotation"]["Z"],string.format("% 3.2f°",memory.read_u16_be(pointers[index]+0xC0)/182.04));
		
		--0x70 float	linear velocity
		--0xB7 byte		health
	end
end

-- Create the Form Window
function form.createForm()
	local x=5;
	local y=5;
	local h=27;
	local th=14;
	FORM=forms.newform(377,395,"Actor Viewer");
	buttons={
		["GetAll"]=forms.button(FORM,"Get All Actors",getAllActors,x,y,100,22),
		["GetList"]=forms.button(FORM,"Get Actors by List",getActorsByList,x,y+(h*1),100,22),
		["GetID"]=forms.button(FORM,"Get Actors by ID",getActorsByID,x,y+(h*2),100,22),
		["PreviousActor"]=forms.button(FORM,"Previous",setPreviousActor,x,y+(h*12),100,22),
		["NextActor"]=forms.button(FORM,"Next",setNextActor,x+105,y+(h*12),100,22),
		--forms.button(FORM,"Documentation",docsForm,152,64,142,20)
	};
	labels={
		["ActorsFound"]=forms.label(FORM,"",x+210,y+10,280,14,false),
		--["ActorInfo"]=forms.label(FORM,"",x,y+(h*3),205,28,false),
		["ActorData"]={
			["Info"]={
				["Current"]=forms.label(FORM,"Current Actor:",x,y+(h*3)+(th*1),205,14,false),
				["Address"]=forms.label(FORM,"Address:",x,y+(h*4)+3,100,14,false),
				["ID"]=forms.label(FORM,"ID:",x,y+(h*4)+24,100,14,false),
				["Room"]=forms.label(FORM,"Room:",x,y+(h*4)+45,100,14,false),
				["Variable"]=forms.label(FORM,"Variable:",x,y+(h*4)+66,100,14,false),
			},
			["Orientation"]=forms.label(FORM,"Orientation",x,y+(h*8),205,14,false),
			["Position"]={
				["nX"]=forms.label(FORM,"X:",x+5,y+(h*8)+(th*1),20,14,false),
				["nY"]=forms.label(FORM,"Y:",x+5,y+(h*8)+(th*2),20,14,false),
				["nZ"]=forms.label(FORM,"Z:",x+5,y+(h*8)+(th*3),20,14,false),
				["X"]=forms.label(FORM,"",x+25,y+(h*8)+(th*1),65,14,false),
				["Y"]=forms.label(FORM,"",x+25,y+(h*8)+(th*2),65,14,false),
				["Z"]=forms.label(FORM,"",x+25,y+(h*8)+(th*3),65,14,false),
			},
			["Rotation"]={
				["nX"]=forms.label(FORM,"X:",x+105,y+(h*8)+(th*1),20,14,false),
				["nY"]=forms.label(FORM,"Y:",x+105,y+(h*8)+(th*2),20,14,false),
				["nZ"]=forms.label(FORM,"Z:",x+105,y+(h*8)+(th*3),20,14,false),
				["X"]=forms.label(FORM,"",x+125,y+(h*8)+(th*1),65,14,false),
				["Y"]=forms.label(FORM,"",x+125,y+(h*8)+(th*2),65,14,false),
				["Z"]=forms.label(FORM,"",x+125,y+(h*8)+(th*3),65,14,false),
			},
		},
	};
	textboxes={
		["ActorID"]=forms.textbox(FORM,"0000",100,22,"HEX",x+105,y+(h*2)+1,false,false),
		["ActorAddresses"]=forms.textbox(FORM,"",140,317,nil,x+210,y+(h*1)+1,true,true,"VERTICAL"),
		["ActorData"]={
			["Info"]={
				["Address"]=forms.textbox(FORM,"",100,22,"HEX",x+105,y+(h*4)+1,false,false),
				["ID"]=forms.textbox(FORM,"",100,22,"HEX",x+105,y+(h*4)+22,false,false),
				["Room"]=forms.textbox(FORM,"",100,22,"HEX",x+105,y+(h*4)+43,false,false),
				["Variable"]=forms.textbox(FORM,"",100,22,"HEX",x+105,y+(h*4)+64,false,false),
			},
			--["Position"]={
			--	["X"]=forms.label(FORM,"",x+5,y+(h*4)+(th*1),100,14,false),
			--	["Y"]=forms.label(FORM,"",x+5,y+(h*4)+(th*2),100,14,false),
			--	["Z"]=forms.label(FORM,"",x+5,y+(h*4)+(th*3),100,14,false),
			--},
			--["Rotation"]={
			--	["X"]=forms.label(FORM,"",x+105,y+(h*4)+(th*1),100,14,false),
			--	["Y"]=forms.label(FORM,"",x+105,y+(h*4)+(th*2),100,14,false),
			--	["Z"]=forms.label(FORM,"",x+105,y+(h*4)+(th*3),100,14,false),
			--},
		},
	};
	dropdowns={
		["ActorTypes"]=forms.dropdown(FORM,{"00 Switches","01 Prop (1)","02 Player","03 Bomb","04 NPC","05 Enemy","06 Prop","07 Item/Action","08 Misc","09 Boss","10 Door","11 Chests"},x+105,y+(h*1)+1,100,22),
	}
	
	-- Set Right aligned labels.
	forms.setproperty(labels["ActorData"]["Info"]["Address"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Info"]["ID"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Info"]["Room"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Info"]["Variable"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Position"]["X"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Position"]["Y"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Position"]["Z"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Rotation"]["X"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Rotation"]["Y"],"TextAlign","MiddleRight");
	forms.setproperty(labels["ActorData"]["Rotation"]["Z"],"TextAlign","MiddleRight");
	
	-- Get all loaded actors on init.
	getAllActors();
	
	
	--forms.addclick(cheats_cb[i],function() toggleCheat(cheats_cb[i],code[1],code[2],note[2],i); end);
end

return form;