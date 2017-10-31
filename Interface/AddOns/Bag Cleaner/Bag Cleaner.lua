BC_bagbankevent=0
BC_tobank=false
BC_frombank=false
BC_graydell=false
BC_singledel=false
BC_singledone=false
BC_muorder=false
BC_junkdel=false
BC_memclear=false
BC_saorder=false
BC_junk_check=false
BC_saorder=false
BC_holdidle=true
BC_semicount=0
BC_semicount_clone=0
BC_prehold=0
BC_holdslots=0
BC_muordercount=0
BC_alarm=0
BC_memcount=0
BC_mem_n={}
BC_mem_d={}
BC_ilinks={}


BC_btype={"","","","","","","","","","","",""}
BC_btype_ammo={"Quiver","Ammo","Bandolier","Lamina"}
BC_btype_ench={"Enchant"}
BC_btype_herb={"Herb","Cenarius"}
BC_btype_soul={"Felcloth","Soul"}

function DCF(vk01)	
	return DEFAULT_CHAT_FRAME:AddMessage(vk01)
end

function BagCLeanerFrame_OnLoad() 
	BagCleanerFrame:RegisterEvent("MERCHANT_SHOW")
	BagCleanerFrame:RegisterEvent("MERCHANT_CLOSED")
	BagCleanerFrame:RegisterEvent("BANKFRAME_OPENED")
	BagCleanerFrame:RegisterEvent("BANKFRAME_CLOSED")
	BagCleanerFrame:RegisterEvent("ADDON_LOADED")
end

function BC_massdefine(BC_btype_x,BC_btype_check)
	for i=1,table.getn(BC_btype_x)do
		if string.find(GetBagName(BC_bag),BC_btype_x[i])then
			BC_btype[BC_bag+2]=BC_btype_check
		end
	end
end

function BC_colorset(BC_f_ilink) ----------------------------------------------------------------BC_colorset(BC_f_ilink)
	BC_icolor=0
	
	if string.find(BC_f_ilink,"cff9d9d9d")then
		BC_icolor="GRAY"
	elseif string.find((BC_f_ilink),"cffffffff")then
		BC_icolor="WHITE"
	elseif string.find((BC_f_ilink),"cff1eff00")then
		BC_icolor="GREEN"
	elseif string.find((BC_f_ilink),"cff0070dd")then
		BC_icolor="BLUE"				
	elseif string.find((BC_f_ilink),"cffa335ee")then
		BC_icolor="EPIC"					
	end
end

function BC_bagindex() ----------------------------------------------------------------BC_bagindex()
	if CursorHasItem()then 
		PutItemInBackpack()
		i=20
		while i<=23 or CursorHasItem()do
			PutItemInBag(i)
			i=i+1			
		end
	end

	BC_btype={"","","","","","","","","","","",""}
	BC_bnumslots={"","","","","","","","","","","",""}
	BC_bag=BC_bagbankevent
	
	while BC_bag<=10 do
		if GetBagName(BC_bag)then
			BC_massdefine(BC_btype_ammo,"ammo")
			BC_massdefine(BC_btype_ench,"ench")
			BC_massdefine(BC_btype_herb,"herb")
			BC_massdefine(BC_btype_soul,"soul")
			if not(BC_btype[BC_bag+2]=="ammo" or BC_btype[BC_bag+2]=="ench" or BC_btype[BC_bag+2]=="herb" or BC_btype[BC_bag+2]=="soul")then
				BC_btype[BC_bag+2]="common"
			end
			BC_bnumslots[BC_bag+2]=GetContainerNumSlots(BC_bag)
		else
			BC_btype[BC_bag+2]="NO"
			BC_bnumslots[BC_bag+2]=0
		end
		BC_bag=BC_bag+1
	end
	
	if BC_bagbankevent==-1 then
		BC_btype[1]="common"
		BC_bnumslots[1]=24
	else
		BC_btype[1]="NO"
		BC_bnumslots[1]=0
	end
	
	BC_gap=0
	BC_bslotsdata={}

	for i=1,12 do
		if BC_bnumslots[i]~=0 then
			for BC_bslot=1,BC_bnumslots[i] do
				if GetContainerItemInfo((i-2),BC_bslot)then
					_,BC_icount=GetContainerItemInfo((i-2),BC_bslot)
					BC_colorset(GetContainerItemLink((i-2),BC_bslot))
					BC_ilinks[BC_gap+BC_bslot]=GetContainerItemLink((i-2),BC_bslot)
					BC_iname=gsub((GetContainerItemLink((i-2),BC_bslot)),".*%[(.*)%].*","%1")
					BC_bslotsdata[BC_gap+BC_bslot]=BC_iname.."_"..BC_icolor.."#-#"..BC_icount
				else
					BC_bslotsdata[BC_gap+BC_bslot]="CLEAR"
				end
			end
		end
		BC_gap=BC_gap+BC_bnumslots[i]
	end
end

function BC_gttcheck() ----------------------------------------------------------------BC_gttcheck()
	BC_holdidle=true
	
	if BC_semicount>0 and BC_saorder==false then 
		BC_memclear=true 
	end
	
	if BC_gtt~=nil then
		for i=1,table.getn(BC_bslotsdata)do
			if string.find(BC_bslotsdata[i],BC_gtt)then
				BC_holdidle=false
			end
		end
	end	
	
end

function BC_holdpos() ----------------------------------------------------------------BC_holdpos()
	BC_gttcheck()
	local BC_holdpos_iname=""
	if BC_muorder==true and BC_muordercount>0 and BC_memclear==false then
		for i=1,BC_memcount do			
			BC_holdpos_iname=gsub(BC_mem_n[i],"(.*)_.*","%1")
			if not(string.find(BC_bslotsdata[BC_mem_d[i]],BC_holdpos_iname))then							
				BC_memclear=true
			end
		end
	end
	
	if BC_holdidle==false then
		BC_prehold=BC_prehold+BC_holdslots
	end
			
	if BC_muorder==false or BC_memclear==true or BC_muordercount==0 then
		BC_muordercount=0
		BC_memcount=0
		BC_mem_d={}
		BC_mem_n={}
		BC_prehold=0
		BC_semicount=0
		BC_memclear=false
	end
end

function BC_holdcount() ----------------------------------------------------------------BC_holdcount()
	if BC_holdidle==false then
		BC_holdslots=0
		for i=1,table.getn(BC_bslotsdata) do
			if string.find(BC_bslotsdata[i],BC_gtt) then
				BC_holdslots=BC_holdslots+1
			end
		end

		if BC_muorder then
			BC_muordercount=BC_muordercount+1
		end
	end
end

function BC_repcount() ----------------------------------------------------------------BC_repcount()
	local BC_names,BC_names_clone,BC_repeats,BC_repeats_clone,BC_uncommons={},{},{},{},{}
	
	for i=1,table.getn(BC_bslotsdata) do
		BC_names[i]=gsub(BC_bslotsdata[i],"(.*)_.*","%1")
	end

	for i=1,table.getn(BC_names)do
		for k=1,table.getn(BC_names)do
			if BC_names[i]==BC_names[k] and i~=k then
				BC_names[k]="CLEAR"
			end
		end
	end

	for i=1,table.getn(BC_names)do
		BC_rep=0
		BC_uncommon=false
		
		local BC_gap=0
		
		for BC_bag=1,12 do
			for BC_slot=1,BC_bnumslots[BC_bag] do
				if BC_names[i]==gsub(BC_bslotsdata[BC_gap+BC_slot],"(.*)_.*","%1")then
					BC_rep=BC_rep+1
					if BC_btype[BC_bag]~="common" then
						BC_uncommon=true
					end
				end
			end
			BC_gap=BC_gap+BC_bnumslots[BC_bag]
		end
		
		if BC_uncommon==false then
			BC_repeats[i]=BC_rep
		else
			BC_names[i]="uncom"
			BC_repeats[i]=0		
		end		
	end
	
	for i=1,table.getn(BC_names)do
		for k=1,table.getn(BC_names)do
			if BC_repeats[i]>BC_repeats[k] then
				BC_temp=BC_repeats[i]
				BC_repeats[i]=BC_repeats[k]
				BC_repeats[k]=BC_temp
				BC_temp=BC_names[i]
				BC_names[i]=BC_names[k]
				BC_names[k]=BC_temp
			end
		end
	end	

	for i=1,table.getn(BC_names)do
		for k=1,table.getn(BC_names)do
			if BC_repeats[k]==0 or BC_repeats[k]==1 or BC_repeats[k]==2 or BC_names[k]=="CLEAR" then
			--if i~=k and(BC_names[i]==BC_names[k] or BC_names[k]=="CLEAR" or BC_repeats[k]==1 or BC_repeats[k]==2)then 
				table.remove(BC_names,k)
				table.remove(BC_repeats,k)
			end
		end
	end

	local BC_semicount,BC_semicount_clone=0,0

	for i=1,table.getn(BC_names)do
		if BC_repeats[i]>2 then
			BC_semicount=BC_semicount+1
		end
	end

	return BC_semicount,BC_semicount_clone,BC_names,BC_repeats
end

function BC_mem_record(BC_mem_record_gap,BC_mem_record_slot) ----------------------------------------------------------------BC_mem_record()
	if BC_muorder then
		local BC_mem_record_temp=BC_mem_record_gap+BC_mem_record_slot
		BC_mem_tally=false
		for BC_mem_record_i=1,BC_memcount do
			if BC_mem_record_temp==BC_mem_d[BC_mem_record_i] then
				BC_mem_tally=true
			end
		end

		if BC_mem_tally==false then
			BC_memcount=BC_memcount+1
			BC_mem_d[BC_memcount]=BC_mem_record_temp
			BC_mem_n[BC_memcount]=BC_bslotsdata[BC_mem_record_gap+BC_mem_record_slot]
		end
	end
end

function BC_order() ----------------------------------------------------------------BC_order()
	local BC_alarm=0
	
	repeat
		BC_alarm=BC_alarm+1
		BC_bagindex()
		BC_holdpos()
		
		if BC_saorder then--and BC_semicount_clone<=BC_semicount then	
			if BC_muordercount>0 and BC_semicount==0 then			
				BC_memclear=true
				BC_holdpos()
			end
		
			if BC_semicount==0 then	
				BC_semicount,BC_semicount_clone,BC_names,BC_repeats=BC_repcount()
			end
			
			if BC_semicount_clone<BC_semicount then			
				BC_semicount_clone=BC_semicount_clone+1			
				DCF("|CFFFFFF33Stage|CFF9999FF "..BC_semicount_clone.." |CFFFFFF33of|CFF9999FF "..BC_semicount)
				BC_gtt=BC_names[BC_semicount_clone]
				BC_gttcheck()
				BC_holdcount()
				if BC_semicount_clone==BC_semicount then
					DCF("|CFF9999FFDone")
				end
			elseif (BC_semicount_clone==BC_semicount and BC_saorder==true)then			
				BC_gtt=nil
				BC_holdidle=true
				BC_end_semicount,BC_end_semicount_clone,BC_end_names,BC_end_repeats=BC_repcount()
				if (table.getn(BC_names)~=table.getn(BC_end_names)) or (BC_semicount~=BC_end_semicount)then
					BC_memclear=true
				else
					local BC_repeats_check,BC_end_repeats_check=0,0
					for i=1,table.getn(BC_names)do		
						if BC_repeats[i]>2 then
							BC_repeats_check=BC_repeats_check+BC_repeats[i]					
						end					
						if BC_end_repeats[i]>2 then
							BC_end_repeats_check=BC_end_repeats_check+BC_end_repeats[i]
						end
					end

					if BC_repeats_check~=BC_end_repeats_check then
						BC_memclear=true
					end				
				end
			end
		else
			BC_gtt=GameTooltipTextLeft1:GetText()
			BC_gttcheck()
		end
	until BC_memclear==false or BC_alarm>99
	
	if BC_alarm>99 then 
		DCF("|cffff0000Loop exit by alarm")
	end
	
	if BC_holdidle==false then
		if not BC_saorder then
			BC_holdcount()
		end
		
		if BC_bagbankevent==-1 then 
			BC_oth_gap=24
		else
			BC_oth_gap=0
		end
		
		BC_gap=0
		BC_oth_bag=0
		k=BC_oth_bag+2
		BC_oth_bslot=1
		BC_oth_rev_bslot=BC_bnumslots[k]
		i=1

		while i<=12 do	
			BC_bag=i-2
			BC_bslot=1
			BC_rev_bslot=BC_bnumslots[i]
			while BC_bslot<=BC_bnumslots[i] do
				BC_iname=gsub(BC_bslotsdata[BC_gap+BC_bslot],"(.*)_.*","%1")
				BC_comp=BC_gap+BC_rev_bslot
				
				if BC_iname==BC_gtt then
					if (not(BC_prehold+BC_holdslots+24>=BC_comp and BC_comp>BC_prehold+24) and BC_bagbankevent==-1)or(not(BC_prehold+BC_holdslots>=BC_comp and BC_comp>BC_prehold) and BC_bagbankevent==0)then
						BC_replaced=false
						while k<=6 and BC_btype[k]=="common" and BC_replaced==false do						
							BC_oth_iname=gsub(BC_bslotsdata[BC_oth_gap+BC_oth_rev_bslot],"(.*)_.*","%1")
							BC_oth_comp=BC_oth_gap+BC_oth_bslot							
							if (BC_prehold+BC_holdslots>=BC_oth_comp and BC_oth_comp>BC_prehold and BC_bagbankevent==0)or(BC_prehold+BC_holdslots+24>=BC_oth_comp and BC_oth_comp>BC_prehold+24 and BC_bagbankevent==-1) then
								if BC_oth_iname~=BC_gtt then
									PickupContainerItem(BC_bag,BC_bslot)
									BC_temp=BC_bslotsdata[BC_gap+BC_bslot]
									BC_bslotsdata[BC_gap+BC_bslot]=BC_bslotsdata[BC_oth_gap+BC_oth_rev_bslot]									
									BC_bslotsdata[BC_oth_gap+BC_oth_rev_bslot]=BC_temp
									PickupContainerItem(BC_oth_bag,BC_oth_rev_bslot)
									BC_mem_record(BC_oth_gap,BC_oth_rev_bslot)
									BC_replaced=true									
								else
									BC_mem_record(BC_oth_gap,BC_oth_rev_bslot)										
								end
							end

							BC_oth_bslot=BC_oth_bslot+1
							BC_oth_rev_bslot=BC_bnumslots[k]-BC_oth_bslot+1
			
							if BC_oth_bslot>BC_bnumslots[k] then	
								BC_oth_gap=BC_oth_gap+BC_bnumslots[k]
								k=k+1
								BC_oth_bag=k-2
								BC_oth_bslot=1
								BC_oth_rev_bslot=BC_bnumslots[k]
							end
						
						end
					else 
						BC_mem_record(BC_gap,BC_bslot)						
					end
				end
				
				BC_bslot=BC_bslot+1
				BC_rev_bslot=BC_bnumslots[i]-BC_bslot+1
			end
			
			BC_gap=BC_gap+BC_bnumslots[i]
			i=i+1
		end
	end

	BC_saorder=false
	BC_muorder=false
end

function BC_junkmark() ----------------------------------------------------------------BC_junkmark
	BC_gtt=GameTooltipTextLeft1:GetText()
	if BC_gtt then
		BC_tempdata=0
		BC_templink=0	
		BC_bagindex()
		
		for i=1,table.getn(BC_bslotsdata)do
			if string.find(BC_bslotsdata[i],BC_gtt)then
				if string.find(BC_bslotsdata[i],"WHITE")or(string.find(BC_bslotsdata[i],"GREEN")and BC_var.greenselloption)then
					BC_templink=BC_ilinks[i]
					BC_tempdata=gsub(BC_bslotsdata[i],"(.*)_.*","%1")
				elseif string.find(BC_bslotsdata[i],"GRAY")then
					DCF("|CFFFFFF33all |CFFCCCCCCgray|CFFFFFF33 items are always a junk")
				elseif string.find(BC_bslotsdata[i],"GREEN") and BC_var.greenselloption==false then
					DCF("|CFFFFFF33you can't mark |cff00ff00green|CFFFFFF33 as a junk until |cffffffff'GreenSell'|CFFFFFF33 option will not be |cffffffffON")
				end
			end
		end
		
		if BC_tempdata~=0 then
			for i=1,table.getn(BC_junk)do			
				if BC_tempdata==BC_junk[i] then
					table.remove(BC_junk,i)
					BC_junk_check=true
					DCF(BC_templink.." |CFFFFFF33was |cffff0000removed|CFFFFFF33 from junk list")
				end
			end
			if BC_junk_check==false then
				table.insert(BC_junk,BC_tempdata)
				DCF(BC_templink.." |CFFFFFF33was |cff00ff00marked|CFFFFFF33 as a junk")
			end
		end
	end
end

function BC_DelGroup() ----------------------------------------------------------------BC_DelGroup()
	BC_bagindex()
	BC_gtt=GameTooltipTextLeft1:GetText()
	BC_nitems=0
	
	if BC_gtt or BC_merchsellevent or BC_graydell then
		BC_gap=0
		for i=1,12 do
			if BC_bnumslots[i]~=0 then
				for BC_bslot=1,BC_bnumslots[i] do
					if BC_singledone==false then
						BC_fordel=BC_bslotsdata[BC_gap+BC_bslot]						
						if BC_fordel~="CLEAR" then	
						
							for BC_i=1,table.getn(BC_junk)do
								if string.find(BC_fordel,BC_junk[BC_i])then									
									BC_junkdel=true								
								end
							end
							
							if BC_merchsellevent then								
								if BC_var.merchautosellgray and (string.find(BC_fordel,"GRAY")or BC_junkdel)then--AutoSellGray
									UseContainerItem((i-2),BC_bslot)
								end
								if BC_gtt and BC_graydell==false and string.find(BC_fordel,BC_gtt)and(string.find(BC_fordel,"GRAY")or string.find(BC_fordel,"WHITE")or (string.find(BC_fordel,"GREEN")and BC_var.greenselloption))then--SellGroup
									UseContainerItem((i-2),BC_bslot)	
								end
							else
								if BC_frombank==false and BC_tobank==false and BC_graydell and (string.find(BC_fordel,"GRAY")or BC_junkdel)then --GrayDel
									PickupContainerItem((i-2),BC_bslot)
									DeleteCursorItem()
									BC_nitems=BC_nitems+1
									if BC_singledel==true then BC_singledone=true end
								elseif BC_gtt and BC_graydell==false and(BC_frombank==false and BC_tobank==false)and((string.find(BC_fordel,BC_gtt))and (string.find(BC_fordel,"GRAY")or string.find(BC_fordel,"WHITE")or (string.find(BC_fordel,"GREEN")and BC_var.greendeloption)))then
									PickupContainerItem((i-2),BC_bslot)
									DeleteCursorItem()
									BC_nitems=BC_nitems+1
									if BC_singledel==true then BC_singledone=true end									
								elseif BC_gtt and BC_frombank and string.find(BC_fordel,BC_gtt)and(i==1 or i>=7)then --FromBank
									UseContainerItem((i-2),BC_bslot)									
								elseif BC_gtt and BC_tobank and string.find(BC_fordel,BC_gtt)and(i>1 and i<7)and BC_bagbankevent==-1 then --ToBank
									UseContainerItem((i-2),BC_bslot)																		
								end
							end							
						end
					end
					BC_junkdel=false
				end
			end
			BC_gap=BC_gap+BC_bnumslots[i]
		end
	end
	if BC_nitems>0 then
		DCF("|CFF9999FF"..BC_nitems.." |CFFFFFF33items were removed")
	end
	BC_singledel=false
	BC_singledone=false
	BC_graydell=false
	BC_frombank=false
	BC_tobank=false
end

function BagCleaner_SlashHandler(arg1)
	
	if arg1=="" then
		if(BC_var.bagcleaner_on==false)then
			DCF("|CFFFFFF33Bag Cleaner - |cffff0000off")
		else
			DCF("|CFFFFFF33Bag Cleaner - |cff00ff00on")
		end
		if BC_var.merchautosellgray==true then 
			DCF("|CFFFFFF33GrayAutoSell - |cff00ff00on")
		else
			DCF("|CFFFFFF33GrayAutoSell - |cffff0000off")
		end
		if BC_var.greenselloption==false then
			DCF("|CFFFFFF33GreenSell - |cffff0000off")
		else
			DCF("|CFFFFFF33GreenSell - |cff00ff00on")
		end
		if BC_var.greendeloption==false then
			DCF("|CFFFFFF33GreenDel - |cffff0000off")
		else
			DCF("|CFFFFFF33GreenDel - |cff00ff00on")
		end	
		DCF("Type |CFF9999FF/bc |CFFFFFF33list |cfffffffffor more commands")
		return
	end
				
	if(string.find(arg1,"[Oo][Ff][Ff]")~=nil)then --off
		BagCleanerFrame:UnregisterEvent("MERCHANT_SHOW")
		BagCleanerFrame:UnregisterEvent("MERCHANT_CLOSED")
		BagCleanerFrame:UnregisterEvent("BANKFRAME_OPENED")
		BagCleanerFrame:UnregisterEvent("BANKFRAME_CLOSED")
		DCF("|CFFFFFF33Bag Cleaner - |cffff0000off")
		BC_var.bagcleaner_on=false;
		return
	elseif(string.find(arg1,"[Oo][Nn]")~=nil)then --on
		BagCleanerFrame:RegisterEvent("MERCHANT_SHOW")
		BagCleanerFrame:RegisterEvent("MERCHANT_CLOSED")
		BagCleanerFrame:RegisterEvent("BANKFRAME_OPENED")
		BagCleanerFrame:RegisterEvent("BANKFRAME_CLOSED")
		DCF("|CFFFFFF33Bag Cleaner - |cff00ff00on")
		BC_var.bagcleaner_on=true
		return
	elseif(string.find(arg1,"[Dd][Ee][Ll][Gg][Rr][Aa][Yy]")~=nil)or(string.find(arg1,"[Dd][Ee][Ll][Gg][Rr][Ee][Yy]")~=nil)then --DelGray
		BC_graydell=true
		BC_DelGroup()
		return;
	elseif(string.find(arg1,"[Dd][Ee][Ll][Gg][Rr][Oo][Uu][Pp]")~=nil)then --DelGroup
		BC_DelGroup()
		return;
	elseif(string.find(arg1,"[Dd][Ee][Ll][Ss][Ii][Nn][Gg][Ll][Ee]")~=nil)then --DelSingle
		BC_singledel=true
		BC_singledone=false
		BC_DelGroup()
		return;
	elseif(string.find(arg1,"[Ss][Ii][Mm][Pp][Ll][Ee][Oo][Rr][Dd][Ee][Rr]")~=nil)then --SimpleOrder
		BC_order()
		return;
	elseif(string.find(arg1,"[Mm][Uu][Ll][Tt][Ii][Oo][Rr][Dd][Ee][Rr]")~=nil)then --MultiOrder
		BC_muorder=true
		BC_order()
		return;
	elseif(string.find(arg1,"[Ss][Ee][Mm][Ii][Aa][Uu][Tt][Oo][Oo][Rr][Dd][Ee][Rr]")~=nil)then --SemiAutoOrder
		BC_saorder=true
		BC_muorder=true
		BC_order()
		return;
	elseif(string.find(arg1,"[Ff][Rr][Oo][Mm][Bb][Aa][Nn][Kk]")~=nil)then --FromBank
		BC_frombank=true
		BC_DelGroup()
		return;
	elseif(string.find(arg1,"[Jj][Uu][Nn][Kk][Mm][Aa][Rr][Kk]")~=nil)then --JunkMark
		BC_junk_check=false
		BC_junkmark()
		return;
	elseif(string.find(arg1,"[Cc][Ll][Ee][Aa][Rr][Jj][Uu][Nn][Kk][Ll][Ii][Ss][Tt]")~=nil)then --ClearJunkList
		BC_junk={}
		DCF("|CFF9999FFJunk list was cleared")
		return;
	elseif(string.find(arg1,"[Tt][Oo][Bb][Aa][Nn][Kk]")~=nil)then --ToBank
		BC_tobank=true
		BC_DelGroup()
	elseif(string.find(arg1,"[Ll][Ii][Ss][Tt]")~=nil)and not((string.find(arg1,"[Cc][Ll][Ee][Aa][Rr][Jj][Uu][Nn][Kk][Ll][Ii][Ss][Tt]")~=nil))then --List
		DCF("|CFF9999FF/bc |CFFFFFF33DelGray |cffffffff-- delete all gray and marked as a junk items")
		DCF("|CFF9999FF/bc |CFFFFFF33JunkMark |cffffffff-- mark an item as a junk")
		DCF("|CFF9999FF/bc |CFFFFFF33ClearJunkList |cffffffff-- clear junk list")
		DCF("|CFF9999FF/bc |CFFFFFF33DelSingle |cffffffff-- delete one WHITE or GRAY item with the same Tooltip name from your bags also sell all WHITE or GRAY items under your cursor")
		DCF("|CFF9999FF/bc |CFFFFFF33DelGroup |cffffffff-- delete all parts of selected WHITE or GRAY or GREEN(optionally) items, also can sell them if merchant is active")
		DCF("|CFF9999FF/bc |CFFFFFF33GrayAutoSell (on/off) |cffffffff-- sell all your GRAY automaticaly on merchant talk")
		DCF("|CFF9999FF/bc |CFFFFFF33GreenSell (on/off) |cffffffff-- allow mass sell GREEN like GRAY or WHITE")
		DCF("|CFF9999FF/bc |CFFFFFF33GreenDel (on/off) |cffffffff-- allow mass del GREEN like GRAY or WHITE")
		DCF("|CFF9999FF/bc |CFFFFFF33SimpleOrder |cffffffff-- move one item group to the right bottom backpage slot ")
		DCF("|CFF9999FF/bc |CFFFFFF33MultiOrder |cffffffff-- move a few item groups to the right bottom backpage slot consequentially")
		DCF("|CFF9999FF/bc |CFFFFFF33SemiAutoOrder |cffffffff-- automatically search item groups (>3 items) and sort them - one group for each command run")
		DCF("|CFF9999FF/bc |CFFFFFF33ToBank |cffffffff-- put all parts of selected item to the bank")
		DCF("|CFF9999FF/bc |CFFFFFF33FromBank |cffffffff-- grab all parts of selected item from bank to bags")
		return
	elseif(string.find(arg1,"[Gg][Rr][Aa][Yy][Aa][Uu][Tt][Oo][Ss][Ee][Ll][Ll]")~=nil)then --GrayAutoSell
		if BC_var.merchautosellgray==true then 
			BC_var.merchautosellgray=false
			DCF("|CFFFFFF33GrayAutoSell - |cffff0000off")
		else
			BC_var.merchautosellgray=true
			DCF("|CFFFFFF33GrayAutoSell - |cff00ff00on")
		end
		return
	elseif(string.find(arg1,"index")~=nil)then
		BC_bagindex()
		return
	elseif(string.find(arg1,"[Gg][Rr][Ee][Ee][Nn][Ss][Ee][Ll][Ll]")~=nil)then --GreenSell
		if BC_var.greenselloption==false then
			BC_var.greenselloption=true
			DCF("|CFFFFFF33GreenSell - |cff00ff00on")
		else
			BC_var.greenselloption=false
			DCF("|CFFFFFF33GreenSell - |cffff0000off")
		end
		return
	elseif(string.find(arg1,"[Gg][Rr][Ee][Ee][Nn][Dd][Ee][Ll]")~=nil)then --GreenDel
		if BC_var.greendeloption==false then
			BC_var.greendeloption=true
			DCF("|CFFFFFF33GreenDel - |cff00ff00on")
		else
			BC_var.greendeloption=false
			DCF("|CFFFFFF33GreenDel - |cffff0000off")
		end
		return
	end
end

function BagCleanerFrame_OnEvent(event,arg1)
	if(event~="MERCHANT_SHOW")and(event~="BANKFRAME_OPENED")and(event~="BANKFRAME_CLOSED")and(event~="ADDON_LOADED")and(event~="MERCHANT_CLOSED")then
		return;
	end
	if(event=="ADDON_LOADED" and arg1=="Bag Cleaner")then
		DCF("|CFFFFFF33Bag Cleaner |CFF9999FFv0.4|cffffffff Addon loaded: |cffffffff/|CFF9999FFbc |cffffffff/|CFF9999FFbagcleaner")
		SLASH_BagCleaner1 = "/bc"
		SLASH_BagCleaner2 = "/bagcleaner"
		SlashCmdList["BagCleaner"]=BagCleaner_SlashHandler
		
		if BC_var==nil then BC_var={} end
		if BC_junk==nil then BC_junk={} end
		if BC_var.bagcleaner_on==nil then BC_var.bagcleaner_on=true end
		if BC_var.merchautosellgray==nil then BC_var.merchautosellgray=true end
		if BC_var.greenselloption==nil then BC_var.greenselloption=false end
		if BC_var.greendeloption==nil then BC_var.greendeloption=false end
	elseif(event=="BANKFRAME_OPENED")then
		BC_bagbankevent=-1
	elseif(event=="BANKFRAME_CLOSED")then
		BC_bagbankevent=0
	elseif(event=="MERCHANT_SHOW")then
		BC_merchsellevent=true
		BC_DelGroup()
	elseif(event=="MERCHANT_CLOSED")then
		BC_merchsellevent=false
	end
end