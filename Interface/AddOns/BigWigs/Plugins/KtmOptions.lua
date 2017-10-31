assert( BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsKtm")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["KTM Options"] = true,
	["bwktm"] = true,
	["Options for KTM"] = true,
	["Enable resetting"] = true,
	["Reset KTM for the raid when asked by bossmods."] = true,
} end)


----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsKtm = BigWigs:NewModule(L["KTM Options"])
BigWigsKtm.revision = 20001
BigWigsKtm.defaultDB = {
	enable = false,
}
BigWigsKtm.consoleCmd = L["bwktm"]
BigWigsKtm.consoleOptions = {
	type = "group",
	name = L["KTM Options"],
	desc = L["Options for KTM"],
	args = {
		enable = {
			type = "toggle",
			name = L["Enable resetting"],
			desc = L["Reset KTM for the raid when asked by bossmods."],
			order = 1,
			get = function() return BigWigsKtm.db.profile.enable end,
			set = function(v) BigWigsKtm.db.profile.enable = v end,
		},
	}
}

------------------------------
--      Utility 	        --
------------------------------

function BigWigsKtm:KTM_Reset()
	if self.db.profile.enable then
		klhtm.net.clearraidthreat()
	end
end