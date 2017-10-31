
function AddonActive(addname)
	local _, _, _, addon = GetAddOnInfo(addname)
	if addon == nil or addon == 0 then addon = false; end
	return addon
end

function MSG(text)
	UIErrorsFrame:Clear()
	UIErrorsFrame:AddMessage(text)
end

function SendChat(text)
	DEFAULT_CHAT_FRAME:AddMessage(text);
end

