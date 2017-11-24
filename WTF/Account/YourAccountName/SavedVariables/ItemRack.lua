
ItemRack_Users = {
	["Mcg of Kronos"] = {
		["Visible"] = "OFF",
		["MainScale"] = 1,
		["XPos"] = 400,
		["Sets"] = {
		},
		["Ignore"] = {
		},
		["Inv"] = {
		},
		["Events"] = {
		},
		["MainOrient"] = "HORIZONTAL",
		["Locked"] = "OFF",
		["YPos"] = 350,
		["Spaces"] = {
		},
		["Bar"] = {
		},
	},
	}
ItemRack_Settings = {
	["Notify"] = "OFF",
	["AllowHidden"] = "OFF",
	["Minimap"] = {
	},
	["LargeFont"] = "OFF",
	["Soulbound"] = "OFF",
	["MenuShift"] = "OFF",
	["RotateMenu"] = "OFF",
	["AutoToggle"] = "OFF",
	["BigCooldown"] = "OFF",
	["ShowAllEvents"] = "OFF",
	["Bindings"] = "OFF",
	["EnableEvents"] = "OFF",
	["TooltipFollow"] = "OFF",
	["ShowIcon"] = "ON",
	["SetLabels"] = "ON",
	["DisableToggle"] = "ON",
	["RightClick"] = "OFF",
	["FlipBar"] = "OFF",
	["FlipMenu"] = "OFF",
	["TinyTooltip"] = "OFF",
	["ShowTooltips"] = "ON",
	["NotifyThirty"] = "ON",
	["CompactList"] = "OFF",
	["CooldownNumbers"] = "OFF",
	["SquareMinimap"] = "OFF",
	["ShowEmpty"] = "ON",
}
ItemRack_Events = {
	["Druid:Caster Form"] = {
		["script"] = "if not ItemRack_GetForm() and IR_FORM then EquipSet() IR_FORM=nil end --[[Equip a set when not in an animal form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Aquatic Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Aquatic Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in aquatic form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Moonkin Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Moonkin Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in moonkin form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["events_version"] = 1.975,
	["Plaguelands"] = {
		["script"] = "local zone = GetRealZoneText(),0\nif (zone==\"Western Plaguelands\" or zone==\"Eastern Plaguelands\" or zone==\"Scholomance\" or zone==\"Stratholme\") and not IR_PLAGUE then\n    EquipSet() IR_PLAGUE=1\nelseif IR_PLAGUE then\n    LoadSet() IR_PLAGUE=nil\nend\n--[[Equips set to be worn while in plaguelands.]]",
		["trigger"] = "ZONE_CHANGED_NEW_AREA",
		["delay"] = 1,
	},
	["About Town"] = {
		["script"] = "if IsResting() and not IR_TOWN then EquipSet() IR_TOWN=1 elseif IR_TOWN then LoadSet() IR_TOWN=nil end\n--[[Equips a set while in a city or inn.]]",
		["trigger"] = "PLAYER_UPDATE_RESTING",
		["delay"] = 0,
	},
	["Druid:Cat Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Cat Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in cat form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Low Mana"] = {
		["script"] = "local mana = UnitMana(\"player\") / UnitManaMax(\"player\")\nif mana < .5 and not IR_OOM then\n  SaveSet()\n  EquipSet()\n  IR_OOM = 1\nelseif IR_OOM and mana > .75 then\n  LoadSet()\n  IR_OOM = nil\nend\n--[[Equips a set when mana is below 50% and re-equips previous gear at 75% mana. Remember: You can't swap non-weapons in combat.]]",
		["trigger"] = "UNIT_MANA",
		["delay"] = 0.5,
	},
	["Rogue:Stealth"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(1)\nif isActive and not IR_FORM then\n  EquipSet() IR_FORM=1\nelseif not isActive and IR_FORM then\n  LoadSet() IR_FORM=nil\nend\n--[[Equips set to be worn while stealthed.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Mage:Evocation"] = {
		["script"] = "local evoc=arg1[\"Interface\\\\Icons\\\\Spell_Nature_Purge\"]\nif evoc and not IR_EVOC then\n  EquipSet() IR_EVOC=1\nelseif not evoc and IR_EVOC then\n  LoadSet() IR_EVOC=nil\nend\n--[[Equips a set to wear while channeling Evocation.]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0.25,
	},
	["Warrior:Berserker"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(3) if isActive and IR_FORM~=\"Berserker\" then EquipSet() IR_FORM=\"Berserker\" end --[[Equips set to be worn in Berserker stance.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Bear Form"] = {
		["script"] = "local form = ItemRack_GetForm()\nif (form==\"Dire Bear Form\" or form==\"Bear Form\") and IR_FORM~=\"Bear Form\" then EquipSet() IR_FORM=\"Bear Form\" end --[[Equip a set when in bear form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Warrior:Battle"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(1) if isActive and IR_FORM~=\"Battle\" then EquipSet() IR_FORM=\"Battle\" end --[[Equips set to be worn in battle stance.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Skinning"] = {
		["script"] = "if UnitIsDead(\"mouseover\") and GameTooltipTextLeft3:GetText()==UNIT_SKINNABLE then\n  local r,g,b = GameTooltipTextLeft3:GetTextColor()\n  if r>.9 and g<.2 and b<.2 and not IR_SKIN then\n    EquipSet() IR_SKIN=1\n  end\nelseif IR_SKIN then\n  LoadSet() IR_SKIN=nil\nend\n--[[Equips a set when you mouseover something that can be skinned but you have insufficient skill.]]\n",
		["trigger"] = "UPDATE_MOUSEOVER_UNIT",
		["delay"] = 0,
	},
	["Warrior:Overpower End"] = {
		["script"] = "--[[Equip a set five seconds after opponent dodged: your normal weapons. ]]\nif IR_OVERPOWER==1 then\nEquipSet()\nIR_OVERPOWER=nil\nend",
		["trigger"] = "CHAT_MSG_COMBAT_SELF_MISSES",
		["delay"] = 5,
	},
	["Warrior:Overpower Begin"] = {
		["script"] = "--[[Equip a set when the opponent dodges.  Associate a heavy-hitting 2h set with this event. ]]\nlocal _,_,i = GetShapeshiftFormInfo(1)\nif string.find(arg1 or \"\",\"^You.+dodge[sd]\") and i then\nEquipSet()\nIR_OVERPOWER=1\nend",
		["trigger"] = "CHAT_MSG_COMBAT_SELF_MISSES",
		["delay"] = 0,
	},
	["Insignia Used"] = {
		["script"] = "if arg1==\"Insignia of the Alliance\" or arg1==\"Insignia of the Horde\" then EquipSet() end --[[Equips a set when the Insignia of the Alliance/Horde has been used.]]",
		["trigger"] = "ITEMRACK_ITEMUSED",
		["delay"] = 0.5,
	},
	["Swimming"] = {
		["script"] = "local i,found\nfor i=1,3 do\n  if getglobal(\"MirrorTimer\"..i):IsVisible() and getglobal(\"MirrorTimer\"..i..\"Text\"):GetText() == BREATH_LABEL then\n    found = 1\n  end\nend\nif found then\n  EquipSet()\nend\n--[[Equips a set when the breath gauge appears. NOTE: This will not re-equip gear when you leave water.  There's no reliable way to know when you leave water. Also note: Won't work with eCastingBar.]]",
		["trigger"] = "MIRROR_TIMER_START",
		["delay"] = 0,
	},
	["Warrior:Defensive"] = {
		["script"] = "local _,_,isActive = GetShapeshiftFormInfo(2) if isActive and IR_FORM~=\"Defensive\" then EquipSet() IR_FORM=\"Defensive\" end --[[Equips set to be worn in Defensive stance.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Priest:Spirit Tap Begin"] = {
		["script"] = "local found=ItemRack.Buffs[\"Interface\\\\Icons\\\\Spell_Shadow_Requiem\"]\nif not IR_SPIRIT and found then\nEquipSet() IR_SPIRIT=1\nend\n--[[Equips a set when you leave combat with Spirit Tap. Associate a set of spirit gear to this event.]]",
		["trigger"] = "PLAYER_REGEN_ENABLED",
		["delay"] = 0.25,
	},
	["Insignia"] = {
		["script"] = "if arg1==\"Insignia of the Alliance\" or arg1==\"Insignia of the Horde\" then EquipSet() end --[[Equips a set when the Insignia of the Alliance/Horde finishes cooldown.]]",
		["trigger"] = "ITEMRACK_NOTIFY",
		["delay"] = 0,
	},
	["Eating-Drinking"] = {
		["script"] = "local found=arg1[\"Interface\\\\Icons\\\\INV_Misc_Fork&Knife\"] or arg1[\"Drink\"]\nif not IR_DRINK and found then\nEquipSet() IR_DRINK=1\nelseif IR_DRINK and not found then\nLoadSet() IR_DRINK=nil\nend\n--[[Equips a set while eating or drinking.]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0,
	},
	["Mount"] = {
		["script"] = "local mount\nif UnitIsMounted then mount = UnitIsMounted(\"player\") else mount = ItemRack_PlayerMounted() end\nif not IR_MOUNT and mount then\n  EquipSet()\nelseif IR_MOUNT and not mount then\n  LoadSet()\nend\nIR_MOUNT=mount\n--[[Equips set to be worn while mounted.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Druid:Travel Form"] = {
		["script"] = "local form=ItemRack_GetForm() if form==\"Travel Form\" and IR_FORM~=form then EquipSet() IR_FORM=form end --[[Equip a set when in travel form.]]",
		["trigger"] = "PLAYER_AURAS_CHANGED",
		["delay"] = 0,
	},
	["Priest:Shadowform"] = {
		["script"] = "local f=arg1[\"Interface\\\\Icons\\\\Spell_Shadow_Shadowform\"]\nif not IR_Shadowform and f then\n  EquipSet() IR_Shadowform=1\nelseif IR_Shadowform and not f then\n  LoadSet() IR_Shadowform=nil\nend\n--[[Equips a set while under Shadowform]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0,
	},
	["Priest:Spirit Tap End"] = {
		["script"] = "local found=arg1[\"Interface\\\\Icons\\\\Spell_Shadow_Requiem\"]\nif IR_SPIRIT and not found then\nLoadSet() IR_SPIRIT = nil\nend\n--[[Returns to normal gear when Spirit Tap ends. Associate the same spirit set as Spirit Tap Begin.]]",
		["trigger"] = "ITEMRACK_BUFFS_CHANGED",
		["delay"] = 0.5,
	},
}
Rack_User = {
}
