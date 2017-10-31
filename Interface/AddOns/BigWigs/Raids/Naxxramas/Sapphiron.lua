
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Sapphiron", "Naxxramas")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Sapphiron",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath alert",
	deepbreath_desc = "Warn when Sapphiron begins to cast Deep Breath.",

	lifedrain_cmd = "lifedrain",
	lifedrain_name = "Life Drain",
	lifedrain_desc = "Warns about the Life Drain curse.",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for berserk.",

	icebolt_cmd = "icebolt",
	icebolt_name = "Announce Ice Block",
	icebolt_desc = "Yell when you become an Ice Block.",
	
	blizzard_cmd = "blizzard",
	blizzard_name = "Icon for blizzard",
	blizzard_desc = "Display an icon when you are standing in blizzard.",

	berserk_bar = "Berserk",

	lifedrain_message = "Life Drain! New one in 24sec!",
	lifedrain_bar = "Life Drain",

	lifedrain_trigger = "afflicted by Life Drain",
	lifedrain_trigger2 = "Life Drain was resisted by",
	icebolt_trigger = "You are afflicted by Icebolt",

	deepbreath_incoming_bar = "Ice Bomb Cast",
	deepbreath_trigger = "%s takes in a deep breath...",
	deepbreath_warning = "Ice Bomb Incoming!",
	deepbreath_bar = "Ice Bomb Lands!",
	flight_message = "Air phase! Ice Bomb in 32 seconds!",
	
	icebolt_yell = "I'm an Ice Block!",
	icebolt_bar = "Ice bolt %d",
	
	flight_emote = "%s lifts off into the air!",
	resume_emote = "%s resumes his attacks!",
	
	blizzardGained = "You are afflicted by Chill.",
	blizzardLost = "Chill fades from you.",
	
	proximity_cmd = "proximity",
	proximity_name = "Proximity Warning",
	proximity_desc = "Show Proximity Warning Frame",
} end )


---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
--module.wipemobs = { L["add_name"] } -- adds which will be considered in CheckForEngage
module.toggleoptions = {"berserk", "proximity", "lifedrain", "deepbreath", "icebolt", "blizzard", "bosskill"}

-- Proximity Plugin
module.proximityCheck = function(unit) return CheckInteractDistance(unit, 2) end
module.proximitySilent = true


-- locals
local timer = {
	berserk = 900,
	deepbreathAfterLift = 26,
	deepbreath = 7,
	firstLifedrain = 14,
	lifedrainAfterFlight = 6,
	lifedrain = 24,
	iceboltAfterFlight = 11,
	iceboltInterval = 4,
}
local icon = {
	deepbreath = "Spell_Frost_FrostShock",
	deepbreathInc = "Spell_Arcane_PortalIronForge",
	lifedrain = "Spell_Shadow_LifeDrain02",
	berserk = "INV_Shield_01",
	icebolt = "Spell_Frost_FrostBolt02",
	blizzard = "Spell_Frost_IceStorm",
}
local syncName = {
	lifedrain = "SapphironLifeDrain"..module.revision,
}

local timeLifeDrain = nil

------------------------------
--      Initialization      --
------------------------------

--module:RegisterYellEngage(L["start_trigger"])

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "CheckForDeepBreath")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckForLifeDrain")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckForLifeDrain")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckForLifeDrain")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")

	self:ThrottleSync(4, syncName.lifedrain)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self.started = nil
	timeLifeDrain = nil
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.berserk then
		self:Bar(L["berserk_bar"], timer.berserk, icon.berserk)
	end
	if self.db.profile.lifedrain then
		self:Bar(L["lifedrain_bar"], timer.firstLifedrain, icon.lifedrain)
	end
	if self.db.profile.proximity then
		self:Proximity()
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
	self:RemoveProximity()
end


------------------------------
--      Event Handlers      --
------------------------------

function module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["blizzardLost"]) and self.db.profile.blizzard then
		self:RemoveWarningSign(icon.blizzard)
	end
end


function module:CheckForLifeDrain(msg)
	if string.find(msg, L["lifedrain_trigger"]) or string.find(msg, L["lifedrain_trigger2"]) then
		if not timeLifeDrain or (timeLifeDrain + 2) < GetTime() then
			self:Sync(syncName.lifedrain)
			timeLifeDrain = GetTime()
		end
	elseif string.find(msg, L["icebolt_trigger"]) and self.db.profile.icebolt then
		SendChatMessage(L["icebolt_yell"], "YELL")
	elseif string.find(msg, L["blizzardGained"]) and self.db.profile.blizzard then
		self:WarningSign(icon.blizzard, 6)
	end
end

function module:CheckForDeepBreath(msg)
	if msg == L["deepbreath_trigger"] then
		if self.db.profile.deepbreath then
			self:Message(L["deepbreath_warning"], "Important")
			self:Bar(L["deepbreath_bar"], timer.deepbreath, icon.deepbreath)
		end
	elseif msg == L["flight_emote"] then
		self:Flight()
	elseif msg == L["resume_emote"] then
		self:Ground()
	end
end


------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.lifedrain then
		self:LifeDrain()
	end
end

------------------------------
--      Sync Handlers	    --
------------------------------

function module:LifeDrain()
	if self.db.profile.lifedrain then
		self:Message(L["lifedrain_message"], "Urgent")
		self:Bar(L["lifedrain_bar"], timer.lifedrain, icon.lifedrain)
	end
end

------------------------------
--      	Utility		    --
------------------------------

function module:Flight()
	self:RemoveBar(L["lifedrain_bar"])
	if self.db.profile.deepbreath then
		self:Message(L["flight_message"], "Urgent")
		self:Bar(L["deepbreath_incoming_bar"], timer.deepbreathAfterLift, icon.deepbreathInc)
	end
	if self.db.profile.icebolt then
		self:Bar(string.format(L["icebolt_bar"], 1), timer.iceboltAfterFlight, icon.icebolt)
		self:DelayedBar(timer.iceboltAfterFlight, string.format(L["icebolt_bar"], 2), timer.iceboltInterval, icon.icebolt)
		self:DelayedBar(timer.iceboltAfterFlight + timer.iceboltInterval, string.format(L["icebolt_bar"], 3), timer.iceboltInterval, icon.icebolt)
		self:DelayedBar(timer.iceboltAfterFlight + 2 * timer.iceboltInterval, string.format(L["icebolt_bar"], 4), timer.iceboltInterval, icon.icebolt)
		self:DelayedBar(timer.iceboltAfterFlight + 3 * timer.iceboltInterval, string.format(L["icebolt_bar"], 5), timer.iceboltInterval, icon.icebolt)
	end
end

function module:Ground()
	if self.db.profile.lifedrain then
		self:Bar(L["lifedrain_bar"], timer.lifedrainAfterFlight, icon.lifedrain)
	end
end