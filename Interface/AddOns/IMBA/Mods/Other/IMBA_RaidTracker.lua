IMBA_RaidTracker_Zone=IMBA_LOCATIONS_NAXX;

IMBA_RaidTracker_Players={}

IMBA_MapsSorted=false;

function IMBA_RaidTracker_MapImageSort(v1,v2)
	return v1.name<v2.name;
end

function IMBA_RaidTracker_SortMaps()
	if not IMBA_MapsSorted then
		sort(IMBA_MapImages,IMBA_RaidTracker_MapImageSort);
		sort(IMBA_MapZones);
		IMBA_MapsSorted=true;
	end
end

function IMBA_RaidTracker_OnLoad()
	this:SetBackdropBorderColor(1, 1, 1, 1);
	this:SetBackdropColor(0.0,0.0,0.0,0.6);

	 
	IMBA_RaidTracker_Title:SetText("Raid Tracker");
	IMBA_AddAddon("Raid Tracker", "Allows to track player positions and status", IMBA_LOCATIONS_OTHER, nil, nil,nil,"IMBA_RaidTracker");
	

	
	IMBA_RaidTracker_Zone=IMBA_MapImages[1].zone;
	this:RegisterEvent("CHAT_MSG_ADDON");
end


function IMBA_RaidTracker_MapImageDropDown_OnLoad()
	IMBA_RaidTracker_SortMaps();
	UIDropDownMenu_Initialize(this, IMBA_RaidTracker_MapImageDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(IMBA_RaidTracker_MapImageDropDown,1);
end

function IMBA_RaidTracker_MapImageDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(IMBA_RaidTracker_MapImageDropDown, this.value);
	--UIDropDownMenu_SetSelectedID(IMBA_RaidTracker_MapImageDropDown,this.value);
	IMBA_RaidTracker_Canvas_BG:SetTexture(IMBA_MapImages[this.value].image);
	
	IMBA_RaidTracker_MapImageDropDownText:SetText(IMBA_MapImages[this.value].name);
	IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,10);
	if IMBA_RaidTracker_MapImageDropDownText:GetStringWidth()>100 then
		IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,9);
		if IMBA_RaidTracker_MapImageDropDownText:GetStringWidth()>100 then
			IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,8);
			if IMBA_RaidTracker_MapImageDropDownText:GetStringWidth()>100 then
				IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,7.5);
			end
		end
	end
end

function IMBA_RaidTracker_MapImageDropDown_Initialize()	
	for k,v in pairs(IMBA_MapImages) do
		if v.zone==IMBA_RaidTracker_Zone then
			info = {};
			info.text = v.name;
			info.value = k;
			info.func = IMBA_RaidTracker_MapImageDropDown_OnClick;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function IMBA_RaidTracker_MapZoneDropDown_OnLoad()
	IMBA_RaidTracker_SortMaps();
	UIDropDownMenu_Initialize(this, IMBA_RaidTracker_MapZoneDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(IMBA_RaidTracker_MapZoneDropDown,1);

	IMBA_RaidTracker_Zone=IMBA_MapZones[1];
	for k,v in pairs(IMBA_MapImages) do
		if v.zone==IMBA_RaidTracker_Zone then
			--IMBA_RaidTracker_Canvas_BG:SetTexture(v.image);
			return;
		end
	end
end

function IMBA_RaidTracker_MapZoneDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(IMBA_RaidTracker_MapZoneDropDown, this.value);
	UIDropDownMenu_SetSelectedID(IMBA_RaidTracker_MapZoneDropDown,this.value);

	IMBA_RaidTracker_Zone=IMBA_MapZones[this.value]

	IMBA_RaidTracker_MapZoneDropDownText:SetFont(STANDARD_TEXT_FONT,10);
	if IMBA_RaidTracker_MapZoneDropDownText:GetStringWidth()>100 then
		IMBA_RaidTracker_MapZoneDropDownText:SetFont(STANDARD_TEXT_FONT,9);
		if IMBA_RaidTracker_MapZoneDropDownText:GetStringWidth()>100 then
			IMBA_RaidTracker_MapZoneDropDownText:SetFont(STANDARD_TEXT_FONT,8);
			if IMBA_RaidTracker_MapZoneDropDownText:GetStringWidth()>100 then
				IMBA_RaidTracker_MapZoneDropDownText:SetFont(STANDARD_TEXT_FONT,7.5);
			end
		end
	end


	UIDropDownMenu_Initialize(IMBA_RaidTracker_MapImageDropDown, IMBA_RaidTracker_MapImageDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(IMBA_RaidTracker_MapImageDropDown,1);

	for k,v in pairs(IMBA_MapImages) do
		if v.zone==IMBA_RaidTracker_Zone then
			IMBA_RaidTracker_Canvas_BG:SetTexture(v.image);

			IMBA_RaidTracker_MapImageDropDownText:SetText(v.name);
			IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,10);
			if IMBA_RaidTracker_MapImageDropDownText:GetStringWidth()>100 then
				IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,9);
				if IMBA_RaidTracker_MapImageDropDownText:GetStringWidth()>100 then
					IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,8);
					if IMBA_RaidTracker_MapImageDropDownText:GetStringWidth()>100 then
						IMBA_RaidTracker_MapImageDropDownText:SetFont(STANDARD_TEXT_FONT,7.5);
					end
				end
			end
			return;
		end
	end
	
	
end

function IMBA_RaidTracker_MapZoneDropDown_Initialize()	
	for k,v in pairs(IMBA_MapZones) do
		info = {};
		info.text = v;
		info.value = k;
		info.func = IMBA_RaidTracker_MapZoneDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end



function IMBA_RaidTracker_OnEvent(event)
	if event=="CHAT_MSG_ADDON" then	
		if arg1=="IMBA_TRACKER_DATA" then
			local _, _, x, y, ang, health, healthMax, mana, manaMax, powerType, class, armor, defense = string.find(arg2, "(-?%d+%.?%d*) (-?%d+%.?%d*) (-?%d+%.?%d*) (%d+) (%d+) (%d+) (%d+) (%d+) (%a+) (%d+) (%d+)")

			if not IMBA_RaidTracker_Players[arg4] then
				IMBA_RaidTracker_Players[arg4]={}
			end
			IMBA_RaidTracker_Players[arg4].x=tonumber(x);
			IMBA_RaidTracker_Players[arg4].y=tonumber(y);
			IMBA_RaidTracker_Players[arg4].ang=tonumber(ang);
			IMBA_RaidTracker_Players[arg4].health=tonumber(health);
			IMBA_RaidTracker_Players[arg4].healthMax=tonumber(healthMax);
			IMBA_RaidTracker_Players[arg4].mana=tonumber(mana);
			IMBA_RaidTracker_Players[arg4].manaMax=tonumber(manaMax);
			IMBA_RaidTracker_Players[arg4].powerType=tonumber(powerType);
			IMBA_RaidTracker_Players[arg4].class=class;
			IMBA_RaidTracker_Players[arg4].armor=tonumber(armor);
			IMBA_RaidTracker_Players[arg4].defense=tonumber(defense);
			IMBA_RaidTracker_Players[arg4].timeUpdated=GetTime();

			
		end
	end
end

function IMBA_RaidTracker_Canvas_OnUpdate()
end