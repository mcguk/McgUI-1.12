IMBA_BossFrame_CurrentAddon=nil
IMBA_BossFrame_CurrentBoss=nil
IMBA_BossFrame_LastFrame=nil

IMBA_BOSSFRAME_MAXTITLES=4
IMBA_BOSSFRAME_MAXTEXTS=10
IMBA_BOSSFRAME_MAXTIMERS=10
IMBA_BOSSFRAME_MAXUNITHEALTH=5
IMBA_BOSSFRAME_MAXNAMEHEALTH=5

function IMBA_InitBossFrame()
	local children = {IMBA_BossFrame:GetChildren()};
	for k,v in pairs(children) do
		v:Hide()
	end

	if not IMBA_SavedVariables.HideClose then
		IMBA_BossFrame_Close:Show()
	end
	
	IMBA_BossFrame_CurrentSize=18;

	IMBA_BossFrame_TitlesUsed=0
	IMBA_BossFrame_TimersUsed=0
	IMBA_BossFrame_TextUsed=0
	IMBA_BossFrame_UnitHealthUsed=0
	IMBA_BossFrame_NameHealthUsed=0

	IMBA_BossFrame:Hide()
end

function IMBA_SetupBossFrame(Addon,Title,BossNames,EventHandler,EventRegister,EventUnregister,UpdateFunc)
	IMBA_InitBossFrame()

	IMBA_BossFrame_CurrentAddon=Addon
	IMBA_BossFrame_CurrentBoss=BossNames

	IMBA_BossFrame_MainTitle:Show()
	IMBA_BossFrame_CurrentSize=IMBA_BossFrame_CurrentSize+IMBA_BossFrame_MainTitle:GetHeight()
	IMBA_BossFrame_LastFrame=IMBA_BossFrame_MainTitle
	IMBA_BossFrame_MainTitle:SetText(Title)
	IMBA_BossFrame_OnEvent=EventHandler
	IMBA_BossFrame_RegisterEvents=EventRegister
	IMBA_BossFrame_UnregisterEvents=EventUnregister
	IMBA_BossFrame_OnUpdate=UpdateFunc

	IMBA_BossFrame:SetHeight(IMBA_BossFrame_CurrentSize)
end

function IMBA_AddTitle()
	if IMBA_BossFrame_TitlesUsed>=IMBA_BOSSFRAME_MAXTITLES then
		DEFAULT_CHAT_FRAME:AddMessage("IMBA ERROR: Max Titles already reached! ("..IMBA_BOSSFRAME_MAXTITLES.." Max)",1.0,1.0,0.0)
		return nil
	end
	IMBA_BossFrame_TitlesUsed=IMBA_BossFrame_TitlesUsed+1
	
	local title = getglobal("IMBA_BossFrame_Title"..IMBA_BossFrame_TitlesUsed)
	
	title:ClearAllPoints()
	title:SetPoint("TOP",IMBA_BossFrame_LastFrame,"BOTTOM",0,-4)
	title:Show()

	IMBA_BossFrame_LastFrame=title

	IMBA_BossFrame_CurrentSize=IMBA_BossFrame_CurrentSize+title:GetHeight()+4
	IMBA_BossFrame:SetHeight(IMBA_BossFrame_CurrentSize)

	return title
end

function IMBA_AddText()
	if IMBA_BossFrame_TextUsed>=IMBA_BOSSFRAME_MAXTEXTS then
		DEFAULT_CHAT_FRAME:AddMessage("IMBA ERROR: Max Texts already reached! ("..IMBA_BOSSFRAME_MAXTEXTS.." Max)",1.0,1.0,0.0)
		return nil
	end
	IMBA_BossFrame_TextUsed=IMBA_BossFrame_TextUsed+1
	
	local text = getglobal("IMBA_BossFrame_Text"..IMBA_BossFrame_TextUsed)
	
	text:ClearAllPoints()
	text:SetPoint("TOP",IMBA_BossFrame_LastFrame,"BOTTOM",0,-4)
	text:Show()

	IMBA_BossFrame_LastFrame=text

	IMBA_BossFrame_CurrentSize=IMBA_BossFrame_CurrentSize+text:GetHeight()+4
	IMBA_BossFrame:SetHeight(IMBA_BossFrame_CurrentSize)

	return text
end

function IMBA_AddTimer()
	if IMBA_BossFrame_TimersUsed>=IMBA_BOSSFRAME_MAXTIMERS then
		DEFAULT_CHAT_FRAME:AddMessage("IMBA ERROR: Max Timers already reached! ("..IMBA_BOSSFRAME_MAXTIMERS.." Max)",1.0,1.0,0.0)
		return nil
	end
	IMBA_BossFrame_TimersUsed=IMBA_BossFrame_TimersUsed+1
	
	local timer = getglobal("IMBA_BossFrame_Timer"..IMBA_BossFrame_TimersUsed)
	
	timer:ClearAllPoints()
	timer:SetPoint("TOP",IMBA_BossFrame_LastFrame,"BOTTOM",0,-4)
	timer:Show()
	timer.timeEnd=0;

	IMBA_BossFrame_LastFrame=timer

	IMBA_BossFrame_CurrentSize=IMBA_BossFrame_CurrentSize+timer:GetHeight()+4
	IMBA_BossFrame:SetHeight(IMBA_BossFrame_CurrentSize)

	return timer
end

function IMBA_AddUnitHealth()
	if IMBA_BossFrame_UnitHealthUsed>=IMBA_BOSSFRAME_MAXUNITHEALTH then
		DEFAULT_CHAT_FRAME:AddMessage("IMBA ERROR: Max Unit Health Bars already reached! ("..IMBA_BOSSFRAME_MAXUNITHEALTH.." Max)",1.0,1.0,0.0)
		return nil
	end
	IMBA_BossFrame_UnitHealthUsed=IMBA_BossFrame_UnitHealthUsed+1
	
	local health = getglobal("IMBA_BossFrame_UnitHealth"..IMBA_BossFrame_UnitHealthUsed)
	
	health:ClearAllPoints()
	health:SetPoint("TOP",IMBA_BossFrame_LastFrame,"BOTTOM",0,-4)
	health:Show()

	IMBA_BossFrame_LastFrame=health

	IMBA_BossFrame_CurrentSize=IMBA_BossFrame_CurrentSize+health:GetHeight()+4
	IMBA_BossFrame:SetHeight(IMBA_BossFrame_CurrentSize)

	return health
end

function IMBA_AddNameHealth()
	if IMBA_BossFrame_NameHealthUsed>=IMBA_BOSSFRAME_MAXNAMEHEALTH then
		DEFAULT_CHAT_FRAME:AddMessage("IMBA ERROR: Max Name Health Bars already reached! ("..IMBA_BOSSFRAME_MAXNAMEHEALTH.." Max)",1.0,1.0,0.0)
		return nil
	end
	IMBA_BossFrame_NameHealthUsed=IMBA_BossFrame_NameHealthUsed+1
	
	local health = getglobal("IMBA_BossFrame_NameHealth"..IMBA_BossFrame_NameHealthUsed)
	
	health:ClearAllPoints()
	health:SetPoint("TOP",IMBA_BossFrame_LastFrame,"BOTTOM",0,-4)
	health:Show()

	IMBA_BossFrame_LastFrame=health

	IMBA_BossFrame_CurrentSize=IMBA_BossFrame_CurrentSize+health:GetHeight()+4
	IMBA_BossFrame:SetHeight(IMBA_BossFrame_CurrentSize)

	return health
end

function IMBA_BossFrame_OnLoad()
	IMBA_InitBossFrame()
	IMBA_BossFrame:Hide()
end

function IMBA_BossFrame_HuhuTest()
	IMBA_SetupBossFrame("Princess Huhuran","Huhuran Timers",{"Princess Huhuran"},nil,nil,nil)

	local IMBA_Huhu_TimerFrenzy=IMBA_AddTimer()
	local IMBA_Huhu_TimerNoxiousPoison=IMBA_AddTimer()
	local IMBA_Huhu_TimerWyvernSting=IMBA_AddTimer()

	IMBA_Huhu_TimerFrenzy:SetBarText("Frenzy");
	IMBA_Huhu_TimerNoxiousPoison:SetBarText("Noxious Poison");
	IMBA_Huhu_TimerWyvernSting:SetBarText("Wyvern Sting");

	IMBA_BossFrame:Show()
end