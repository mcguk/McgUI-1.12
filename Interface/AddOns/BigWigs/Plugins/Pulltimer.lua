assert( BigWigs, "BigWigs not found!")

-----------------------------------------------------------------------
--      Are you local?
-----------------------------------------------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsPulltimer")

local timer = {
	pulltimer = 0,
}
local syncName = {
	pulltimer = "PulltimerSync",
	combat = "PulltimerCombatSync",
	stoppulltimer = "PulltimerStopSync",
}
local icon = {
	pulltimer = "RACIAL_ORC_BERSERKERSTRENGTH",
}
local started

-----------------------------------------------------------------------
--      Localization
-----------------------------------------------------------------------

L:RegisterTranslations("enUS", function() return {
	["Pull Timer"] = true,
	
	["pulltimer"] = true,
	["Options for Pull Timer"] = true,
	pullstart_message = "Pull in ",
	pull1_message = "Pull in 1",
	pull2_message = "Pull in 2",
	pull3_message = "Pull in 3",
	pull4_message = "Pull in 4",
	pull5_message = "Pull in 5",
	pull0_message = "Pull!",
	
	pull_bar = "Pull",
	slashpull_cmd = "/bwpt",
	slashpull2_cmd = "duration",
	slashpull2_desc = "Pull timer duration",
	["<duration>"] = true,
	["Enable"] = true,
	["Enable pulltimer."] = true,
} end )

-----------------------------------------------------------------------
--      Module Declaration
-----------------------------------------------------------------------

BigWigsPulltimer = BigWigs:NewModule(L["Pull Timer"], "AceConsole-2.0")
BigWigsPulltimer.revision = 20001
BigWigsPulltimer.defaultDB = {
	enable = true,
}
BigWigsPulltimer.consoleCmd = L["pulltimer"]
BigWigsPulltimer.consoleOptions = {
	type = "group",
	name = L["Pull Timer"],
	desc = L["Options for Pull Timer"],
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable pulltimer."],
			order = 1,
			get = function() return BigWigsPulltimer.db.profile.enable end,
			set = function(v) BigWigsPulltimer.db.profile.enable = v end,
		},
	},
}

-----------------------------------------------------------------------
--      Initialization
-----------------------------------------------------------------------

function BigWigsPulltimer:OnRegister()
	self:RegisterChatCommand({ L["slashpull_cmd"] }, {
		type = "group",
		args = {
			pull = {
				type = "text", name = L["slashpull2_cmd"],
				desc = L["slashpull2_desc"],
				set = function(v) self:BigWigs_PullCommand(v) end,
				get = false,
				usage = L["<duration>"],
			},
		},
	})
end

function BigWigsPulltimer:OnEnable()
	self:RegisterEvent("BigWigs_Pulltimer")
	self:RegisterEvent("BigWigs_PullCommand")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("BigWigs_RecvSync")
	self:ThrottleSync(0.5, syncName.pulltimer)
	self:ThrottleSync(3, syncName.combat)
end

function BigWigsPulltimer:OnSetup()
	started = nil
end

-----------------------------------------------------------------------
--      Event Handlers
-----------------------------------------------------------------------

function BigWigsPulltimer:PLAYER_REGEN_DISABLED()
	if UnitExists("target") and UnitAffectingCombat("target") and (UnitLevel("target") == -1 or UnitLevel("target") == 63 or UnitLevel("target") == 62) then
		self:Sync(syncName.combat)
	end
end

-----------------------------------------------------------------------
--      Synchronization
-----------------------------------------------------------------------

function BigWigsPulltimer:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.combat and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
		self:BigWigs_StopPulltimer()
	end
	if sync == syncName.pulltimer then
		self:BigWigs_Pulltimer(rest)
	end
	if sync == syncName.stoppulltimer then
		self:BigWigs_StopPulltimer()
	end
end

-----------------------------------------------------------------------
--      Utility
-----------------------------------------------------------------------

function BigWigsPulltimer:BigWigs_PullCommand(msg)
	if (IsRaidLeader() or IsRaidOfficer()) then
		if tonumber(msg) then
			timer.pulltimer = tonumber(msg)
		else
			self:Sync(syncName.stoppulltimer)
			return
		end
		if  timer.pulltimer == 0 then
			self:Sync(syncName.stoppulltimer)
			return
		elseif ((timer.pulltimer > 63) or (timer.pulltimer < 1))  then
			return
		end
		self:Sync("BWCustomBar "..timer.pulltimer.." ".."bwPullTimer")	--[[This triggers a pull timer for older versions of bigwigs.
																			Modified CustomBar.lua RecvSync to ignore sync calls with "bwPullTimer" string in them.
																		--]]
		self:Sync(syncName.pulltimer.." "..timer.pulltimer)
	end
end

function BigWigsPulltimer:BigWigs_StopPulltimer()
	self:TriggerEvent("BigWigs_StopBar", self, L["pull_bar"])
	self:CancelDelayedSound("One")
	self:CancelDelayedSound("Two")
	self:CancelDelayedSound("Three")
	self:CancelDelayedSound("Four")
	self:CancelDelayedSound("Five")
	self:CancelDelayedMessage(L["pull0_message"])
	self:CancelDelayedMessage(L["pull1_message"])
	self:CancelDelayedMessage(L["pull2_message"])
	self:CancelDelayedMessage(L["pull3_message"])
	self:CancelDelayedMessage(L["pull4_message"])
	self:CancelDelayedMessage(L["pull5_message"])
end

function BigWigsPulltimer:BigWigs_Pulltimer(duration)
	--cancel events from an ongoing pull timer in case a new one is initiated
	self:BigWigs_StopPulltimer()
	
	if tonumber(duration) then
		timer.pulltimer = tonumber(duration)
	else
		return
	end
	
	self:Message(L["pullstart_message"]..timer.pulltimer, "Attention", true, false)
	self:Bar(L["pull_bar"], timer.pulltimer, icon.pulltimer)
	self:DelayedSound(timer.pulltimer - 1, "One")
	self:DelayedMessage(timer.pulltimer, L["pull0_message"], "Attention", true, false)
	self:DelayedMessage(timer.pulltimer - 1, L["pull1_message"], "Attention", true, false)
	if not (timer.pulltimer < 2.2) then
		self:DelayedSound(timer.pulltimer - 2, "Two")
		self:DelayedMessage(timer.pulltimer - 2, L["pull2_message"], "Attention", true, false)
	end
	if not (timer.pulltimer < 3.2) then
		self:DelayedSound(timer.pulltimer - 3, "Three")
		self:DelayedMessage(timer.pulltimer - 3, L["pull3_message"], "Attention", true, false)
	end
	if not (timer.pulltimer < 4.2) then
		self:DelayedSound(timer.pulltimer - 4, "Four")
		self:DelayedMessage(timer.pulltimer - 4, L["pull4_message"], "Attention", true, false)
	end
	if not (timer.pulltimer < 5.2) then
		self:DelayedSound(timer.pulltimer - 5, "Five")
		self:DelayedMessage(timer.pulltimer - 5, L["pull5_message"], "Attention", true, false)
	end
end