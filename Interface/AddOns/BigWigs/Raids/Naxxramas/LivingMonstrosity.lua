----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Living Monstrosity", "Naxxramas")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Monstrosity",
	
	lightningtotem_cmd = "lightningtotem",
	lightningtotem_name = "Lightning Totem Alert",
	lightningtotem_desc = "Warn for Lightning Totem summon",
	
	lightningtotem_trigger = "Living Monstrosity begins to cast Lightning Totem",
	lightningtotem_trigger2 = "Living Monstrosity casts Lightning Totem.",
	lightningtotem_bar = "SUMMON LIGHTNING TOTEM",
	lightningtotem_message = "LIGHTNING TOTEM INC",
} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20001 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
--module.wipemobs = { L["add_name"] } -- adds which will be considered in CheckForEngage
module.toggleoptions = { "lightningtotem" }

-- locals
local timer = {
	lightningTotem = {0.5, 2} --we want to use intervalbar so ppl don't miss such a fast cast
}

local icon = {
	lightningTotem = "Spell_Nature_Lightning"
}

local syncName = {
}

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE") --lightningtotem_trigger
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF") --lightningtotem_trigger2
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

-- called after boss is engaged
function module:OnEngage()
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end

------------------------------
--      Event Handlers	    --
------------------------------

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["lightningtotem_trigger"]) and self.db.profile.lightningtotem then
		self:Message(L["lightningtotem_message"], "Urgent")
		self:IntervalBar(L["lightningtotem_bar"], timer.lightningTotem[1], timer.lightningTotem[2], icon.lightningTotem)
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if string.find(msg, L["lightningtotem_trigger2"]) and self.db.profile.lightningtotem then
		self:Message(L["lightningtotem_message"], "Urgent")
		self:WarningSign(icon.lightningTotem, 5)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if (msg == string.format(UNITDIESOTHER, "Lightning Totem")) then
		self:RemoveWarningSign(icon.lightningTotem)
	end
end