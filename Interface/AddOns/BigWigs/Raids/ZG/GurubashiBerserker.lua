
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Gurubashi Berserker", "Zul'Gurub")

module.revision = 20003
module.enabletrigger = module.translatedName
module.toggleoptions = {"bars"--[[, "bosskill"]]}

------------------------------
--      Locals 			    --
------------------------------

local timer = {
	fear = 15,
	firstThunderClap = 4,
	thunderClap = 16,
	firstKnockBack = 8,
	knockBack = 12.5,
}
local icon = {
	fear = "Ability_GolemThunderClap",
	thunderClap = "Ability_ThunderClap",
	knockBack = "INV_Gauntlets_05"
}
local syncName = {
	debuff = "BerserkerDebuff"..module.revision,
	knockBack = "BerserkerKnockBack"..module.revision
}


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	ThunderClap = "ThunderClap CD",
	KnockBack = "KnockBack CD",
	Fear = "Fear CD",

	trigger1 = "afflicted by Intimidating Roar",
	trigger2 = "Intimidating Roar fail(.+) immune.",
	trigger3 = "Intimidating Roar was resisted",

	-- AceConsole strings
	cmd = "Berserker",

	bars_cmd = "bars",
	bars_name = "Toggle bars",
	bars_desc = "Toggles showing bars for timers.",

} end )

L:RegisterTranslations("deDE", function() return {
	ThunderClap = "ThunderClap",
	KnockBack = "KnockBack",
	Fear = "Fear",

	trigger1 = "afflicted by Intimidating Roar",
	trigger2 = "Intimidating Roar fail(.+) immune.",
	trigger3 = "Intimidating Roar was resisted",

	-- AceConsole strings
	cmd = "Berserker",

	bars_cmd = "bars",
	bars_name = "Toggle bars",
	bars_desc = "Toggles showing bars for timers.",

} end )

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Debuff")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Debuff")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Debuff")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Debuff")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Debuff")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Debuff")


	self:ThrottleSync(2, syncName.debuff)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self.started = false
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.bars then
		self:DelayedSync(timer.firstKnockBack, syncName.knockBack)
		self:Bar(L["ThunderClap"], timer.firstThunderClap, icon.thunderClap)
		--first fear comes when it comes
		--self:Bar(L["Fear"], timer.firstFear, icon.fear)
		self:Bar(L["KnockBack"], timer.firstKnockBack, icon.knockBack)
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()

end

------------------------------
--      Event Handlers	    --
------------------------------

function module:Debuff(msg)
	if ((string.find(msg, L["trigger1"])) or (string.find(msg, L["trigger2"])) or (string.find(msg, L["trigger3"]))) then
		self:Sync(syncName.debuff)
	end
end

------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.debuff then
		if self.db.profile.bars then
			self:Bar(L["Fear"], timer.fear, icon.fear)
		end
	elseif sync == syncName.knockBack then
		if self.db.profile.bars then
			self:Bar(L["KnockBack"], timer.knockBack, icon.knockBack)
		end
		self:DelayedSync(timer.knockBack, syncName.knockBack)
	end
end
