----------------------------------
--      Module Declaration      --
----------------------------------

local myname = "Horsemen Strategy"
local bossName = "The Four Horsemen"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..myname)
local module = BigWigs:NewModule(myname, "AceConsole-2.0")
local boss = AceLibrary("Babble-Boss-2.2")[bossName]
local thane = AceLibrary("Babble-Boss-2.2")["Thane Korth'azz"]
local mograine = AceLibrary("Babble-Boss-2.2")["Highlord Mograine"]
local zeliek = AceLibrary("Babble-Boss-2.2")["Sir Zeliek"]
local blaumeux = AceLibrary("Babble-Boss-2.2")["Lady Blaumeux"]
module.bossSync = myname
module.synctoken = myname
module.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
module.translatedName = boss
module.external = true


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {

	cmd = "HorsemenStrategy",
	
	map_cmd = "map",
	map_name = "Display map",
	map_desc = "Display a map",
	
	lock_cmd = "lock",
	lock_name = "Unlock map",
	lock_desc = "Allow map to be moved",
	
	role_cmd = "role",
	role_name = "Raid Role",
	role_desc = "Choose your role in the raid",
	role_validate = { "Tank", "Healer", "DPS" },
	
	tankStrategy_cmd = "tankStrategy",
	tankStrategy_name = "Tank Strategy",
	tankStrategy_desc = "Choose a strategy for tanking",
	tankStrategy_validate = { "8 tank rotation, rotate after 2nd mark" },
	
	tankNumber_cmd = "tankNumber",
	tankNumber_name = "Tank Number",
	tankNumber_desc = "Choose your tank number",
	tankNumber_validate = { "1", "2", "3", "4", "5", "6", "7", "8" },
	
	healerStrategy_cmd = "healerStrategy",
	healerStrategy_name = "Healer Strategy",
	healerStrategy_desc = "Choose a strategy for healing",
	healerStrategy_validate = { --[["Healers rotate on 2nd mark",]] "Healers rotate after 3rd mark", "Healers rotate after 3rd mark, with safespots" },
	
	healerNumber_cmd = "healerNumber",
	healerNumber_name = "Healer Number",
	healerNumber_desc = "Choose your healer number",
	healerNumber_validate = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" },
	
	dpsStrategy_cmd = "dpsStrategy",
	dpsStrategy_name = "DPS Strategy",
	dpsStrategy_desc = "Choose a strategy for dpsing",
	dpsStrategy_validate = { "DPS rotate after 3rd mark, 5 groups" },
	
	dpsNumber_cmd = "dpsNumber",
	dpsNumber_name = "DPS Number",
	dpsNumber_desc = "Choose your DPS number",
	dpsNumber_validate = { "1", "2", "3", "4", "5", "6" },
	
	tankNumberMessage = "You are tank number %d!",
	tankNumberError = "Invalid tank number for this strategy, resetting to default.",
	
	healerNumberMessage = "You are healer number %d!",
	healerNumberError = "Invalid healer number for this strategy, resetting to default.",
	
	dpsNumberMessage = "You are DPS number %d!",
	dpsNumberError = "Invalid DPS number for this strategy, resetting to default.",
	
	["Lock"] = true,
	["Toggle map lock."] = true,
	
	moveMessage = "Move to %s!",
	safeSpot = "Safe spot",
	
	slash_cmd = "/BWHS",
	
	["<strat number>"] = true,
	["<name1><number>, <name2><number>, <name3><number>"] = true,
	
	slashTankStrategy_cmd = "tank strategy",
	slashTankStrategy_desc = "Tank Strategy",
	["Tank strategy set to %s (changed by %s)."] = true,
	["Invalid tank strategy received from %s."] = true,
	
	slashTankNumbers_cmd = "tank numbers",
	slashTankNumbers_desc = "Tank Numbers",
	["Tank number set to %d (changed by %s)."] = true,
	["Invalid tank number received from %s."] = true,
	
	slashHealerStrategy_cmd = "healer strategy",
	slashHealerStrategy_desc = "Healer Strategy",
	["Healer strategy set to %s (changed by %s)."] = true,
	["Invalid healer strategy received from %s."] = true,
	
	slashHealerNumbers_cmd = "healer numbers",
	slashHealerNumbers_desc = "Healer Numbers",
	["Healer number set to %d (changed by %s)."] = true,
	["Invalid healer number received from %s."] = true,
	
	slashDpsStrategy_cmd = "dps strategy",
	slashDpsStrategy_desc = "DPS Strategy",
	["DPS strategy set to %s (changed by %s)."] = true,
	["Invalid DPS strategy received from %s."] = true,
	
	slashDpsNumbers_cmd = "dps numbers",
	slashDpsNumbers_desc = "DPS Numbers",
	["DPS number set to %d (changed by %s)."] = true,
	["Invalid DPS number received from %s."] = true,
	
} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.enabletrigger = { thane, mograine, zeliek, blaumeux }
module.toggleoptions = { "role", -1, "tankNumber", "healerNumber", "dpsNumber", "tankStrategy", "healerStrategy", "dpsStrategy", -1, "map", "lock" }
module.revision = 20003
	
--locals
local markRevisionSync = BigWigs:GetModule("The Four Horsemen").revision

local bosses = {
	L["safeSpot"],
	thane,
	mograine,
	blaumeux,
	zeliek,
}

local positionImage = {
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-s",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-t",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-m",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-z",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-l",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-s2",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-t2",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-m2",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-z2",
	"Interface\\AddOns\\BigWigs_HorsemenStrategy\\textures\\horseman-l2",
}

local syncName = {
	tankStrategy = "BWHSTankStrategy"..module.revision,
	tankNumber = "BWHSTankNumber"..module.revision,
	healerStrategy = "BWHSHealerStrategy"..module.revision,
	healerNumber = "BWSHHealerNumber"..module.revision,
	dpsStrategy = "BWHSDpsStrategy"..module.revision,
	dpsNumber = "BWHSDpsNumber"..module.revision,
	mark = "HorsemenMark"..markRevisionSync,
}

--example: rotation length 8marks, where to rotate
--{start, after mark8, after mark1, after mark2, after mark3, after mark4, after mark5, after mark6, after mark7}
local tankPositions = {
	--Tanks rotate after 2nd mark, 8 tanks, full room rotation
	{
		{1, 1, 1, 0, 0, 2, 2, 0, 0, 3, 3, 0, 0, 4, 4, 0, 0 }, --korthazz
		{2, 2, 2, 0, 0, 3, 3, 0, 0, 4, 4, 0, 0, 1, 1, 0, 0 }, --mograine
		{3, 3, 3, 0, 0, 4, 4, 0, 0, 1, 1, 0, 0, 2, 2, 0, 0 }, --zeliek
		{4, 4, 4, 0, 0, 1, 1, 0, 0, 2, 2, 0, 0, 3, 3, 0, 0 }, --blaumeux
		{0, 0, 0, 1, 1, 0, 0, 2, 2, 0, 0, 3, 3, 0, 0, 4, 4 }, --middle -> korthazz
		{0, 0, 0, 2, 2, 0, 0, 3, 3, 0, 0, 4, 4, 0, 0, 1, 1 }, --middle -> mograine
		{0, 0, 0, 3, 3, 0, 0, 4, 4, 0, 0, 1, 1, 0, 0, 2, 2 }, --middle -> zeliek
		{0, 0, 0, 4, 4, 0, 0, 1, 1, 0, 0, 2, 2, 0, 0, 3, 3 }, --middle -> blaumeux
	},
}

local healerPositions = {
	--[[
	--Healers rotate after 2nd mark
	{
		{ 1, 1, 1, 2, 2, 3, 3, 4, 4 }, --korthazz
		{ 2, 2, 2, 3, 3, 4, 4, 1, 1 }, --mograine
		{ 3, 3, 3, 4, 4, 1, 1, 2, 2 }, --zeliek
		{ 4, 4, 4, 1, 1, 2, 2, 3, 3 }, --blaumeux
		{ 0, 4, 1, 1, 2, 2, 3, 3, 4 }, --middle -> korthazz
		{ 0, 1, 2, 2, 3, 3, 4, 4, 1 }, --middle -> mograine
		{ 0, 2, 3, 3, 4, 4, 1, 1, 2 }, --middle -> zeliek
		{ 0, 3, 4, 4, 1, 1, 2, 2, 3 }, --middle -> blaumeux

	},
	]]
	--Healers rotate after 3rd mark
	{
		{ 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 1, 1 }, --korthazz(1) -> mograine
		{ 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 1 }, --korthazz(2) -> mograine
		{ 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4 }, --korthazz normal
		{ 2, 2, 3, 3, 3, 4, 4, 4, 1, 1, 1, 2, 2 }, --mograine(1) -> zeliek
		{ 2, 2, 2, 3, 3, 3, 4, 4, 4, 1, 1, 1, 2 }, --mograine(2) -> zeliek
		{ 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 1, 1, 1 }, --mograine normal
		{ 3, 3, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3 }, --zeliek(1) -> blaumeux
		{ 3, 3, 3, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3 }, --zeliek(2) -> blaumeux
		{ 3, 3, 3, 3, 4, 4, 4, 1, 1, 1, 2, 2, 2 }, --zeliek normal
		{ 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4 }, --blaumeux(1) -> korthazz
		{ 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4 }, --blaumeux(2) -> korthazz
		{ 4, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3 }, --blaumeux normal
	},
	--Healers rotate after 3rd mark, with safespots
	{
		{ 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 1, 1 }, --korthazz(1) -> mograine
		{ 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 1 }, --korthazz(2) -> mograine
		{ 2, 2, 3, 3, 3, 4, 4, 4, 1, 1, 1, 2, 2 }, --mograine(1) -> zeliek
		{ 2, 2, 2, 3, 3, 3, 4, 4, 4, 1, 1, 1, 2 }, --mograine(2) -> zeliek
		{ 3, 3, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3 }, --zeliek(1) -> blaumeux
		{ 3, 3, 3, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3 }, --zeliek(2) -> blaumeux
		{ 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4 }, --blaumeux(1) -> korthazz
		{ 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4 }, --blaumeux(2) -> korthazz
		{ 1, 1, 1, 1, 2, 2, 2, 0, 0, 0, 0, 0, 0 }, --korthazz -> mograine -> safespot
		{ 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 1, 1, 1 }, --mograine -> safespot -> korthazz
		{ 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 0, 0, 0 }, --safespot(3) -> korthazz -> mograine
		{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2 }, --safespot(6) -> korthazz -> mograine
	},
}

local dpsPositions = {
	--DPS rotate after 3rd mark, 5 groups
	{
		{1, 1, 1, 1, 0, 2, 2, 2, 0, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 2, 2, 2, 0},
		{2, 2, 0, 0, 0, 1, 1, 1, 0, 2, 2},
		{2, 2, 2, 2, 0, 0, 0, 1, 1, 1, 0},
		{1, 1, 0, 2, 2, 2, 0, 0, 0, 1, 1},
	},
}

local marks
local deaths
local position
local tankStrategies
local healerStrategies
local dpsStrategies

------------------------------
--      Initialization      --
------------------------------

function module:OnRegister()
	self:RegisterChatCommand({ L["slash_cmd"] }, {
		type = "group",
		args = {
			tankstrat = {
				type = "text", name = L["slashTankStrategy_cmd"],
				desc = L["slashTankStrategy_desc"],
				set = function(v)
					if (IsRaidLeader() or IsRaidOfficer()) and tonumber(v) and tonumber(v) > 0 and table.getn(tankStrategies) >= tonumber(v) then
						self:Sync(syncName.tankStrategy.." "..tankStrategies[tonumber(v)])
					end
				end,
				get = false,
				usage = L["<strat number>"],
			},
			tankroles = {
				type = "text", name = L["slashTankNumbers_cmd"],
				desc = L["slashTankNumbers_desc"],
				set = function(v)
					if (IsRaidLeader() or IsRaidOfficer()) then
						self:Sync(syncName.tankNumber.." "..v)
					end
				end,
				get = false,
				usage = L["<name1><number>, <name2><number>, <name3><number>"],
			},
			healerstrat = {
				type = "text", name = L["slashHealerStrategy_cmd"],
				desc = L["slashHealerStrategy_desc"],
				set = function(v)
					if (IsRaidLeader() or IsRaidOfficer()) and tonumber(v) and tonumber(v) > 0 and table.getn(healerStrategies) >= tonumber(v) then
						self:Sync(syncName.healerStrategy.." "..healerStrategies[tonumber(v)])
					end
				end,
				get = false,
				usage = L["<strat number>"],
			},
			healerroles = {
				type = "text", name = L["slashHealerNumbers_cmd"],
				desc = L["slashHealerNumbers_desc"],
				set = function(v)
					if (IsRaidLeader() or IsRaidOfficer()) then
						self:Sync(syncName.healerNumber.." "..v)
					end
				end,
				get = false,
				usage = L["<name1><number>, <name2><number>, <name3><number>"],
			},
			dpsstrat = {
				type = "text", name = L["slashDpsStrategy_cmd"],
				desc = L["slashDpsStrategy_desc"],
				set = function(v)
					if (IsRaidLeader() or IsRaidOfficers()) and tonumber(v) and tonumber(v) > 0 and table.getn(dpsStrategies) >= tonumber(v) then
						self:Sync(syncName.dpsStrategy.." "..dpsStrategies[tonumber(v)])
					end
				end,
				get = false,
				usage = L["<strat number>"],
			},
			dpsroles = {
				type = "text", name = L["slashDpsNumbers_cmd"],
				desc = L["slashDpsNumbers_desc"],
				set = function(v)
					if (IsRaidLeader() or IsRaidOfficer()) then
						self:Sync(syncName.dpsNumber.." "..v)
					end
				end,
				get = false,
				usage = L["<name1><number>, <name2><number>, <name3><number>"],
			},
		},
	})
end

-- called after module is enabled
function module:OnEnable()
	healerStrategies = L["healerStrategy_validate"]
	tankStrategies = L["tankStrategy_validate"]
	dpsStrategies = L["dpsStrategy_validate"]
	
	--set strategies if not set
	if not self:TableContains(tankStrategies, self.db.profile.tankStrategy) then
		self.db.profile.tankStrategy = tankStrategies[1]
	end
	if not self:TableContains(healerStrategies, self.db.profile.healerStrategy) then
		self.db.profile.healerStrategy = healerStrategies[1]
	end
	if not self:TableContains(dpsStrategies, self.db.profile.dpsStrategy) then
		self.db.profile.dpsStrategy = dpsStrategies[1]
	end
	
	--set number if not set
	if not self.db.profile.tankNumber or type(self.db.profile.tankNumber) ~= "string" then
		self.db.profile.tankNumber = "1"
	end
	if not self.db.profile.healerNumber or type(self.db.profile.healerNumber) ~= "string" then
		self.db.profile.healerNumber = "1"
	end
	if not self.db.profile.dpsNumber or type(self.db.profile.dpsNumber) ~= "string" then
		self.db.profile.dpsNumber = "1"
	end
	
	--set role if not set
	if not self.db.profile.role or type(self.db.profile.role) ~= "string" then
		local _, playerClass = UnitClass("player")
		if playerClass == "WARRIOR" then
			self.db.profile.role = "Tank"
		elseif playerClass == "PRIEST" or playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "SHAMAN" then
			self.db.profile.role = "Healer"
		else
			self.db.profile.role = "DPS"
		end
	end
	
	--display number in chat and set initial position on map
	if self.db.profile.role == "Tank" then
		self:Print(string.format( L["tankNumberMessage"], tonumber(self.db.profile.tankNumber) ))
		position = self:TankPosition(0)
	elseif self.db.profile.role == "Healer" then
		self:Print(string.format( L["healerNumberMessage"], tonumber(self.db.profile.healerNumber) ))
		position = self:HealerPosition(0)
	elseif self.db.profile.role == "DPS" then
		self:Print(string.format( L["dpsNumberMessage"], tonumber(self.db.profile.dpsNumber) ))
		position = self:DpsPosition(0)
	end
	
	--create map
	self:Map()
	
	
	
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	if not self:IsEventScheduled("BWHSMapUpdate") then
		self:ScheduleRepeatingEvent("BWHSMapUpdate", self.RefreshMap, 2, self)
	end
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	marks = 0
	deaths = 0
	if self.Mapframe then
		if self.db.profile.map then
			self.Mapframe:Show()
		else
			self.Mapframe:Hide()
		end
	end
end

-- called after boss is engaged
function module:OnEngage()
	self:CancelScheduledEvent("BWHSMapUpdate")
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end

function module:OnDisable()
	if self.Mapframe then
		self.Mapframe:Hide()
	end
end

------------------------------
--      Event Handlers	    --
------------------------------

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, thane) or
		msg == string.format(UNITDIESOTHER, zeliek) or
		msg == string.format(UNITDIESOTHER, mograine) or
		msg == string.format(UNITDIESOTHER, blaumeux) then
		deaths = deaths + 1
		if deaths == 4 then
			self.core:ToggleModuleActive(self, false)
		end
	end
end

------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mark then
		self:CancelScheduledEvent("BWHSMapUpdate")
		marks = marks + 1
		if self.db.profile.role == "Tank" then
			position = self:TankPosition(marks)
			self.Maptexture:SetTexture(positionImage[position])
		elseif self.db.profile.role == "Healer" then
			position = self:HealerPosition(marks)
			self.Maptexture:SetTexture(positionImage[position])
		elseif self.db.profile.role == "DPS" then
			position = self:DpsPosition(marks)
			self.Maptexture:SetTexture(positionImage[position])
		end
	
	--tank strategy
	elseif sync == syncName.tankStrategy and rest then
		if not self:TableContains(tankStrategies, rest) then
			self:Print(string.format(L["Invalid tank strategy received from %s."], nick))
			return
		end
		if self.db.profile.tankStrategy ~= rest then
			self.db.profile.tankStrategy = rest
			self:Print(string.format(L["Tank strategy set to %s (changed by %s)."], rest, nick))
			return
		end
	
	--healer strategy
	elseif sync == syncName.healerStrategy and rest then
		if not self:TableContains(healerStrategies, rest) then
			self:Print(string.format(L["Invalid healer strategy received from %s."], nick))
			return
		end
		if self.db.profile.healerStrategy ~= rest then
			self.db.profile.healerStrategy = rest
			self:Print(string.format(L["Healer strategy set to %s (changed by %s)."], rest, nick))
			return
		end
	
	--dps strategy
	elseif sync == syncName.dpsStrategy and rest then
		if not self:TableContains(dpsStrategies, rest) then
			self:Print(string.format(L["Invalid DPS strategy received from %s."], nick))
			return
		end
		if self.db.profile.dpsStrategy ~= rest then
			self.db.profile.dpsStrategy = rest
			self:Print(string.format(L["DPS strategy set to %s (changed by %s)."], rest, nick))
			return
		end
	
	--tank number
	elseif sync == syncName.tankNumber and rest then
		local tanks = self:strsplit(",%s", rest)
		local found = nil
		local number = nil
		for k, v in pairs(tanks) do
			if type(v) == "string" then
				if string.find(v, UnitName("player").."%d+") then
					number = string.sub(v, string.find(v, "%d"), string.len(v))
					if tonumber(number) then
						found = true
					end
				end
			end
		end
		if found and number then
			if tonumber(number) < 1 or tonumber(number) > table.getn(L["tankNumber_validate"]) then
				self:Print(string.format( L["Invalid tank number received from %s."], nick ))
				return
			end
			self.db.profile.role = "Tank"
			self.db.profile.tankNumber = tostring(number)
			self:Print(string.format( L["tankNumberMessage"], tonumber(number) ))
			position = self:TankPosition(0)
		end
	
	--healer number
	elseif sync == syncName.healerNumber and rest then
		local healers = self:strsplit(",%s", rest)
		local found = nil
		local number = nil
		for k, v in pairs(healers) do
			if type(v) == "string" then
				if string.find(v, UnitName("player").."%d+") then
					number = string.sub(v, string.find(v, "%d"), string.len(v))
					if tonumber(number) then
						found = true
					end
				end
			end
		end
		if found and number then
			if tonumber(number) < 1 or tonumber(number) > table.getn(L["healerNumber_validate"]) then
				self:Print(string.format( L["Invalid healer number received from %s."], nick ))
				return
			end
			self.db.profile.role = "Healer"
			self.db.profile.healerNumber = tostring(number)
			self:Print(string.format( L["Healer number set to %d (changed by %s)."], tonumber(number), nick ))
			self:Print(string.format( L["healerNumberMessage"], tonumber(number) ))
			position = self:HealerPosition(0)
		end
	
	--dps number
	elseif sync == syncName.dpsNumber and rest then
		local dpsers = self:strsplit(",%s", rest)
		local found = nil
		local number = nil
		for k, v in pairs(dpsers) do
			if type(v) == "string" then
				if string.find(v, UnitName("player").."%d+") then
					number = string.sub(v, string.find(v, "%d"), string.len(v))
					if tonumber(number) then
						found = true
					end
				end
			end
		end
		if found and number then
			if tonumber(number) < 1 or tonumber(number) > table.getn(L["dpsNumber_validate"]) then
				self:Print(string.format( L["Invalid DPS number received from %s."], nick ))
				return
			end
			self.db.profile.role = "DPS"
			self.db.profile.dpsNumber = tostring(number)
			self:Print(string.format( L["dpsNumberMessage"], tonumber(number) ))
			position = self:DpsPosition(0)
		end
	end
end
		

------------------------------
--      Utility	Functions   --
------------------------------

-- Taken from HealbotAssist
-- Ninjaed from lua-users.org
function module:strsplit(delimiter, text)
	local list = {}
	local pos = 1
	if strfind("", delimiter, 1) then -- this would result in endless loops
		self.error("delimiter matches empty string!")
	end
	while 1 do
		local first, last = strfind(text, delimiter, pos)
		if first then -- found?
			tinsert(list, strsub(text, pos, first-1))
			pos = last+1
		else
			tinsert(list, strsub(text, pos))
			break
		end
	end
	return list
end

function module:TankPosition(mark)
	local tankNumber = tonumber(self.db.profile.tankNumber)
	local currentStrategy = nil
	for k, v in pairs(L["tankStrategy_validate"]) do
		if v == self.db.profile.tankStrategy then
		currentStrategy = k
		end
	end
	if tankNumber > table.getn(tankPositions[currentStrategy]) then
		self:Print(L["tankNumberError"])
		self.db.profile.tankNumber = "1"
		tankNumber = 1
	end
	local rotationLength = table.getn(tankPositions[currentStrategy][tankNumber])-1
	if mark == 0 then
		local currentPos = tankPositions[currentStrategy][tankNumber][1]+1
		local nextPos = tankPositions[currentStrategy][tankNumber][3]+1
		if currentPos ~= nextPos then
			return currentPos+5
		else
			return currentPos
		end
	else
		local currentPos = tankPositions[currentStrategy][tankNumber][mod(mark,rotationLength)+2]+1
		local nextPos = tankPositions[currentStrategy][tankNumber][mod((mark+1),rotationLength)+2]+1
		if currentPos ~= nextPos then
			return currentPos+5
		else
			return currentPos
		end
	end
end

function module:HealerPosition(mark)
	local healerNumber = tonumber(self.db.profile.healerNumber)
	local currentStrategy = nil
	for k, v in pairs(L["healerStrategy_validate"]) do
		if v == self.db.profile.healerStrategy then
		currentStrategy = k
		end
	end
	if healerNumber > table.getn(healerPositions[currentStrategy]) then
		self:Print(L["healerNumberError"])
		self.db.profile.healerNumber = "1"
		healerNumber = 1
	end
	local rotationLength = table.getn(healerPositions[currentStrategy][healerNumber])-1
	if mark == 0 then
		local currentPos = healerPositions[currentStrategy][healerNumber][1]+1
		local nextPos = healerPositions[currentStrategy][healerNumber][3]+1
		if currentPos ~= nextPos then
			return currentPos+5
		else
			return currentPos
		end
	else
		local currentPos = healerPositions[currentStrategy][healerNumber][mod(mark,rotationLength)+2]+1
		local nextPos = healerPositions[currentStrategy][healerNumber][mod((mark+1),rotationLength)+2]+1
		if currentPos ~= nextPos then
			return currentPos+5
		else
			return currentPos
		end
	end
end

function module:DpsPosition(mark)
	local dpsNumber = tonumber(self.db.profile.dpsNumber)
	local currentStrategy = nil
	for k, v in pairs(L["dpsStrategy_validate"]) do
		if v == self.db.profile.dpsStrategy then
		currentStrategy = k
		end
	end
	if dpsNumber > table.getn(dpsPositions[currentStrategy]) then
		self:Print(L["dpsNumberError"])
		self.db.profile.dpsNumber = "1"
		dpsNumber = 1
	end
	local rotationLength = table.getn(dpsPositions[currentStrategy][dpsNumber])-1
	if mark == 0 then
		local currentPos = dpsPositions[currentStrategy][dpsNumber][1]+1
		local nextPos = dpsPositions[currentStrategy][dpsNumber][3]+1
		if currentPos ~= nextPos then
			return currentPos+5
		else
			return currentPos
		end
	else
		local currentPos = dpsPositions[currentStrategy][dpsNumber][mod(mark,rotationLength)+2]+1
		local nextPos = dpsPositions[currentStrategy][dpsNumber][mod((mark+1),rotationLength)+2]+1
		if currentPos ~= nextPos then
			return currentPos+5
		else
			return currentPos
		end
	end
end
	
function module:Map()
	--Create map frame and texture
	self.Mapframe = CreateFrame("Frame", "BWHSMapFrame", UIParent)
	self.Maptexture = self.Mapframe:CreateTexture("BWHSMapTexture", "BACKGROUND")
	self.Mapframe:SetFrameStrata("MEDIUM")
	self.Mapframe:SetWidth(256)
	self.Mapframe:SetHeight(256)
	self.Maptexture:SetTexture(positionImage[position])
	self.Maptexture:SetAllPoints(self.Mapframe)
	self.Mapframe:SetAlpha(1)
	self.Mapframe:SetPoint("CENTER", 0, 0)
	if self.db.profile.mapx then
		self.Mapframe:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", self.db.profile.mapx, self.db.profile.mapy)
	end
	if self.db.profile.lock then
		self.Mapframe:SetMovable(true)
		self.Mapframe:EnableMouse(true)
	end
	self.Mapframe:SetScale(1)
	self.Mapframe:RegisterForDrag("LeftButton")
	self.Mapframe:SetScript("OnDragStart", function()
		if self.db.profile.lock then
			self.Mapframe:StartMoving()
		end
	end)
	self.Mapframe:SetScript("OnDragStop", function()
		if self.db.profile.lock then
			self.Mapframe:StopMovingOrSizing()
			self.db.profile.mapx, self.db.profile.mapy = self.Mapframe:GetCenter()
		end
	end)
	if self.db.profile.map then
		self.Mapframe:Show()
	else
		self.Mapframe:Hide()
	end
end

function module:RefreshMap()
	if not self.db.profile.map then
		self.Mapframe:Hide()
		return
	end
	if self.db.profile.role == "Tank" then
		position = self:TankPosition(0)
		self.Maptexture:SetTexture(positionImage[position])
		self.Mapframe:Hide()
		self.Mapframe:Show()
	elseif self.db.profile.role == "Healer" then
		position = self:HealerPosition(0)
		self.Maptexture:SetTexture(positionImage[position])
		self.Mapframe:Hide()
		self.Mapframe:Show()
	elseif self.db.profile.role == "DPS" then
		position = self:DpsPosition(0)
		self.Maptexture:SetTexture(positionImage[position])
		self.Mapframe:Hide()
		self.Mapframe:Show()
	end
end

function module:TableContains(table, value)
	local key = 1
	while table[key] do
		if value == table[key] then
			return true
		end
		key = key + 1
	end
	return false
end