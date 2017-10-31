if not (GetLocale() == "enUS" or GetLocale() == "enGB") then
	DEFAULT_CHAT_FRAME:AddMessage("Disabled ColorGuildFrame due to non english client.")
	return
end
local _, _, _, _, _, reason = GetAddOnInfo("XPerl")
if not (reason == "MISSING" or reason == "DISABLED") then
	DEFAULT_CHAT_FRAME:AddMessage("Disabled ColorGuildFrame due to X-Perl being present.")
	return
end

local ClassColors = {	WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
						MAGE = {r = 0.41, g = 0.8, b = 0.94},
						ROGUE = {r = 1, g = 0.96, b = 0.41},
						DRUID = {r = 1, g = 0.49, b = 0.04},
						HUNTER = {r = 0.67, g = 0.83, b = 0.45},
						SHAMAN = {r = 0.14, g = 0.35, b = 1.0},
						PRIEST = {r = 1, g = 1, b = 1},
						WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
						PALADIN = {r = 0.96, g = 0.55, b = 0.73}
						}

function New_GuildStatusUpdate()
	oldGuildStatus_Update()

	local myZone = GetRealZoneText()

	local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
	for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
		local guildIndex = guildOffset + i

		local button = getglobal("GuildFrameButton"..i);
		button.guildIndex = guildIndex;
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex)
		if (not name) then
			break
		end

		class = string.upper(class)

		if (class) then
			local color = ClassColors[class]
			if (color) then
				if (online) then
					getglobal("GuildFrameButton"..i.."Class"):SetTextColor(color.r, color.g, color.b)
				else
					getglobal("GuildFrameButton"..i.."Class"):SetTextColor(color.r / 2, color.g / 2, color.b / 2)
				end
			end
		end

		if (zone == myZone) then
			if (online) then
				getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(0, 1, 0)
			else
				getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(0, 0.5, 0)
			end
		end

		local color = GetDifficultyColor(level)
		if (online) then
			getglobal("GuildFrameButton"..i.."Level"):SetTextColor(color.r, color.g, color.b)
		else
			getglobal("GuildFrameButton"..i.."Level"):SetTextColor(color.r / 2, color.g / 2, color.b / 2)
		end
	end
end

if (GuildStatus_Update ~= New_GuildStatusUpdate) then
	oldGuildStatus_Update = GuildStatus_Update
	GuildStatus_Update = New_GuildStatusUpdate
end

-- XPerl_WhoList_Update
function New_WhoList_Update()
	oldWhoList_Update()

	local numWhos, totalCount = GetNumWhoResults()
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)

	local myZone = GetRealZoneText()
	local myRace = UnitRace("player")
	local myGuild = GetGuildInfo("player")

	for i=1, WHOS_TO_DISPLAY, 1 do
		local name, guild, level, race, class, zone = GetWhoInfo(whoOffset + i)
		local color
		if (not name) then
			break
		end

		getglobal("WhoFrameButton"..i.."Name"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

		if (UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 1) then
			-- Zone
			if (zone == myZone) then
				getglobal("WhoFrameButton"..i.."Variable"):SetTextColor(0, 1, 0)
			else
				getglobal("WhoFrameButton"..i.."Variable"):SetTextColor(1, 1, 1)
			end
		elseif (UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 2) then
			if (guild == myGuild) then
				getglobal("WhoFrameButton"..i.."Variable"):SetTextColor(0, 1, 0)
			else
				getglobal("WhoFrameButton"..i.."Variable"):SetTextColor(1, 1, 1)
			end

		elseif (UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 3) then
			if (race == myRace) then
				getglobal("WhoFrameButton"..i.."Variable"):SetTextColor(0, 1, 0)
			else
				getglobal("WhoFrameButton"..i.."Variable"):SetTextColor(1, 1, 1)
			end
		end

		getglobal("WhoFrameButton"..i.."Class"):SetTextColor(1, 1, 1)
		class = string.upper(class)
		if (class) then
			local color = ClassColors[class]
			if (color) then
				getglobal("WhoFrameButton"..i.."Class"):SetTextColor(color.r, color.g, color.b)
			end
		end

		local color = GetDifficultyColor(level)
		getglobal("WhoFrameButton"..i.."Level"):SetTextColor(color.r, color.g, color.b)
	end
end

if (WhoList_Update ~= New_WhoList_Update) then
	oldWhoList_Update = WhoList_Update
	WhoList_Update = New_WhoList_Update
end