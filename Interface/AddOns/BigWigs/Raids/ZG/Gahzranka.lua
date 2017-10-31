
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Gahz'ranka", "Zul'Gurub")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Gahzranka",

	frostbreath_trigger = "Gahz\'ranka begins to perform Frost Breath\.",
	frostbreath_bar = "Frost Breath CD",
	frostbreathcast_bar = "Frost Breath CAST",
	massivegeyser_trigger = "Gahz\'ranka begins to cast Massive Geyser\.",
	massivegeyser_bar = "Massive Geyser",
	slam_trigger = "Gahz'ranka's Gahz'ranka Slam",
	slam_bar = "Slam CD",
	
	frostbreath_cmd = "frostbreath",
	frostbreath_name = "Frost Breath alert",
	frostbreath_desc = "Warn when the boss is casting Frost Breath.",

	massivegeyser_cmd = "massivegeyser",
	massivegeyser_name = "Massive Geyser alert",
	massivegeyser_desc = "Warn when the boss is casting Massive Geyser.",
	
	slam_cmd = "slam",
	slam_name = "Gahz'ranka Slam alert",
	slam_desc = "Timer for Gahz'ranka Slam.",
} end )

L:RegisterTranslations("deDE", function() return {
	--cmd = "Gahzranka",

	frostbreath_trigger = "Gahz\'ranka beginnt Frostatem auszuf\195\188hren\.",
	frostbreath_bar = "Frostatem",
	massivegeyser_trigger = "Gahz\'ranka beginnt Massiver Geysir zu wirken\.",
	massivegeyser_bar = "Massiver Geysir",

	--frostbreath_cmd = "frostbreath",
	frostbreath_name = "Alarm f\195\188r Frostatem",
	frostbreath_desc = "Warnen wenn Gahz'ranka beginnt Frostatem zu wirken.",

	--massivegeyser_cmd = "massivegeyser",
	massivegeyser_name = "Alarm f\195\188r Massiver Geysir",
	massivegeyser_desc = "Warnen wenn Gahz'ranka beginnt Massiver Geysir zu wirken.",
} end )


---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20005 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
module.toggleoptions = {"frostbreath", "massivegeyser", "bosskill"}

-- locals
local timer = {
	breathCast = 2,
	firstBreath = 15,
	breathInterval = 17,
	
	firstSlam = 3,
	slamInterval = 10,
	
	geyser = 1.5,
}
local icon = {
	breath = "Spell_Frost_FrostNova",
	geyser = "Spell_Frost_SummonWaterElemental",
	slam = "Ability_Devour"
}

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

function module:OnEngage()
	self:Bar(L["frostbreath_bar"], timer.firstBreath, icon.breath, true, "Cyan")
	self:Bar(L["slam_bar"], timer.firstSlam, icon.slam)
end

function module:OnSetup()
end

function module:OnDisengage()
end

------------------------------
--      Event Handlers	    --
------------------------------

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["frostbreath_trigger"] and self.db.profile.frostbreath then
		self:Bar(L["frostbreathcast_bar"], timer.breathCast, icon.breath, true, "Blue")
		self:DelayedBar(timer.breathCast, L["frostbreath_bar"], timer.breathInterval-timer.breathCast, icon.breath, true, "Cyan")
	elseif msg == L["massivegeyser_trigger"] and self.db.profile.massivegeyser then
		self:Bar(L["massivegeyser_bar"], timer.geyser, icon.geyser, true, "White")
	elseif string.find(msg, L["slam_trigger"]) then
		self:Bar(L["slam_bar"], timer.slamInterval, icon.slam)
	end
end
