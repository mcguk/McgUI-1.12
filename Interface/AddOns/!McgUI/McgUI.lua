local swsnuked = false;

function MCGUI_OnLoad()

	MCGUI_BasicUpdates();
end


function MCGUI_OnEvent(event)
	MCGUI_BasicUpdates();

	if event == "VARIABLES_LOADED" then

		if AddonActive("SW_Stats") then SW_NukeDataCollection(); end
	elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" or event == "PARTY_MEMBERS_CHANGED" then end

end


function MCGUI_BasicUpdates()

local inRaid = GetNumRaidMembers() > 0
local inParty = GetNumPartyMembers() > 0

	if (inParty == true) or (inRaid == true) then
	if AddonActive("SW_Stats") then if SW_BarFrame1 ~= nil then SW_BarFrame1:Show() end end
	
	end
	
	if (inParty == false) and  (inRaid == false) then
	if AddonActive("SW_Stats") then if SW_BarFrame1 ~= nil then SW_BarFrame1:Hide() end end
	end

end

function MCGUI_IsInBG()
	local IsInBG = false;
	for i=1,80 do
		local bgname = GetBattlefieldScore(i)	
		if bgname then
			IsInBG = true
		end
	end
	return IsInBG
end

