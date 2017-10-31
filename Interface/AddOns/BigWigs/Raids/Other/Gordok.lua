-- King Gordok by Dekos --
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("King Gordok", "Dire Maul")

module.revision = 20001
module.enabletrigger = module.translatedName
module.toggleoptions = {"stomp", "ms", "charge", "bosskill"}

------------------------------
--      Locals 			    --
------------------------------

local timer = {
	firstWarStomp = 7,
	secondWarStomp = 27,
	secondWarStompMax = 38,
	warStomp = 20,
	warStompMax = 30,

	firstMortalStrike = 15,
	firstMortalStrikeMax = 25,
	mortalStrike = 12,
	mortalStrikeMax = 20,

	secondCharge = 34,
	secondChargeMax = 42,
	charge = 25,
	chargeMax = 30,
}

local icon = {
	warStomp = "Ability_WarStomp",
	mortalStrike = "Ability_Warrior_SavageBlow",
	charge = "Ability_Warrior_Charge",
}

local lastWarStomp = 0
local lastMortalStrike = 0
local lastCharge = 0


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	ms_cmd = "ms",
	ms_name = "Mortal Strike",
	ms_desc = "Warn when someone gets Mortal Strike",

	stomp_cmd = "stomp",
	stomp_name = "War Stomp",
	stomp_desc = "Warn when someone gets War Stomp",

	charge_cmd = "charge",
	charge_name = "Charge",
	charge_desc = "Warn when someone gets Charge",

	-- AceConsole strings
	cmd = "Gordok",

} end )

L:RegisterTranslations("deDE", function() return {
	ms_cmd = "ms",
	ms_name = "Mortal Strike",
	ms_desc = "Warn when someone gets Mortal Strike",

	stomp_cmd = "stomp",
	stomp_name = "War Stomp",
	stomp_desc = "Warn when someone gets War Stomp",

	charge_cmd = "charge",
	charge_name = "Charge",
	charge_desc = "Warn when someone gets Charge",

	-- AceConsole strings
	cmd = "Gordok",

} end )

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	--self:ThrottleSync(2, syncName.debuff)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self.started = false
	lastWarStomp = 0
	lastMortalStrike = 0
	lastCharge = 0
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.stomp then
		self:Bar("1st War Stomp (+1s)", timer.firstWarStomp, icon.warStomp, true, "Red")
	end
	if self.db.profile.stomp then
		self:Bar("2nd War Stomp", timer.secondWarStomp, icon.warStomp, true, "Red")
		self:Bar("2nd War Stomp MAX", timer.secondWarStompMax, icon.warStomp, true, "Red")
	end
	if self.db.profile.ms then
		self:Bar("1st Mortal Strike", timer.firstMortalStrike, icon.mortalStrike, true, "Black")
		self:Bar("1st Mortal Strike MAX", timer.firstMortalStrikeMax, icon.mortalStrike, true, "Black")
	end
	if self.db.profile.charge then
		self:Bar("OMG CHARGE SOON", timer.secondCharge, icon.charge, true, "Yellow") -- change name here and in event handlers (x2)
		self:Bar("Charge MAX", timer.secondChargeMax, icon.charge, true, "Yellow")
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end

------------------------------
--      Event Handlers	    --
------------------------------

function module:Event(msg)
	if string.find(msg, "War Stomp") and self.db.profile.stomp then
		if GetTime() - lastWarStomp > 5 then
			self:TriggerEvent("BigWigs_StopBar", self, "1st War Stomp (+1s)")
			self:TriggerEvent("BigWigs_StopBar", self, "War Stomp")
			self:TriggerEvent("BigWigs_StopBar", self, "War Stomp MAX")
			self:TriggerEvent("BigWigs_StopBar", self, "2nd War Stomp")
			self:TriggerEvent("BigWigs_StopBar", self, "2nd War Stomp MAX")
			self:Bar("War Stomp", timer.warStomp, icon.warStomp, true, "Red")
			self:Bar("War Stomp MAX", timer.warStompMax, icon.warStomp, true, "Red")
		end
		lastWarStomp = GetTime()
	elseif string.find(msg, "Mortal Strike") and self.db.profile.ms then
		if GetTime() - lastMortalStrike > 5 then
			self:TriggerEvent("BigWigs_StopBar", self, "1st Mortal Strike")
			self:TriggerEvent("BigWigs_StopBar", self, "1st Mortal Strike MAX")
			self:TriggerEvent("BigWigs_StopBar", self, "Mortal Strike ")
			self:TriggerEvent("BigWigs_StopBar", self, "Mortal Strike MAX")
			self:Bar("Mortal Strike", timer.mortalStrike, icon.mortalStrike, true, "Black")
			self:Bar("Mortal Strike MAX", timer.mortalStrikeMax, icon.mortalStrike, true, "Black")
		end
		lastMortalStrike = GetTime()
	elseif string.find(msg, "Charge") and self.db.profile.charge then
		if GetTime() - lastCharge > 5 then
			self:TriggerEvent("BigWigs_StopBar", self, "OMG CHARGE SOON")
			self:TriggerEvent("BigWigs_StopBar", self, "Charge MAX")
			self:Bar("OMG CHARGE SOON", timer.charge, icon.charge, true, "Yellow")
			self:Bar("Charge MAX", timer.chargeMax, icon.charge, true, "Yellow")
		end
		lastCharge = GetTime()
	end
end
