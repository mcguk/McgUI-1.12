--
-- BOUNDING BOX API
-- 

--
-- Bounding Box Scale
-- Sets the width and height. Can not exceed UIParent or 20x20
--

function ModelCitizen_BoundingBox_Enable(bBox, isEnabled)
	if (isEnabled) then
		ModelCitizen_SessionProfile[bBox:GetID()].isEnabled = true;
		bBox:Show();
		ModelCitizen_SpecialEvent("BOUNDINGBOX_ENABLED", avatar);
	else
		ModelCitizen_SessionProfile[bBox:GetID()].isEnabled = false;
		bBox:Hide();
		ModelCitizen_SpecialEvent("BOUNDINGBOX_DISABLED", avatar);
	end
end

function ModelCitizen_BoundingBox_IsEnabled(bBox)
	return ModelCitizen_SessionProfile[bBox:GetID()].isEnabled;
end

function ModelCitizen_BoundingBox_SetTitle(bBox, title)
	if (title ~= nil) then
		ModelCitizen_SessionProfile[bBox:GetID()].title = title;
		ModelCitizen_SpecialEvent("BOUNDINGBOX_TITLE_CHANGED", avatar);
	end
end

function ModelCitizen_BoundingBox_GetTitle(bBox)
	return ModelCitizen_SessionProfile[bBox:GetID()].title;
end

function ModelCitizen_BoundingBox_SetScale(bBox, width, height)
	local changed = false;
	width = ModelCitizen_BoundingBox_GetWidthConstraint(bBox, width);
	if (width ~= nil and width ~= bBox:GetWidth()) then
		bBox:SetWidth(width);
		ModelCitizen_SessionProfile[bBox:GetID()].scale.width = width;
		changed = true;
	end
	height = ModelCitizen_BoundingBox_GetHeightConstraint(bBox, height);
	if (height ~= nil and height ~= bBox:GetHeight()) then
		bBox:SetHeight(height);
		ModelCitizen_SessionProfile[bBox:GetID()].scale.height = height;
		changed = true;
	end
	if (changed) then
		-- Make sure the new bounding box size doesn't exceed its borders.
		local x, y = ModelCitizen_BoundingBox_GetPositionConstraint(bBox);
		bBox:SetPoint("BOTTOMLEFT", x, y);
		ModelCitizen_SessionProfile[bBox:GetID()].anchor.x = x;
		ModelCitizen_SessionProfile[bBox:GetID()].anchor.y = y;
		ModelCitizen_SpecialEvent("BOUNDINGBOX_SCALE_CHANGED", bBox);
	end
end

function ModelCitizen_BoundingBox_GetScale(bBox)
	-- Mostly useless function, but I'm a completist
	return bBox:GetWidth(), bBox:GetHeight();
end

function ModelCitizen_BoundingBox_GetWidthConstraint(bBox, width)
	if (width == nil) then
		return nil
	elseif (width > UIParent:GetWidth() / UIParent:GetEffectiveScale()) then
		return UIParent:GetWidth() / UIParent:GetEffectiveScale();
	elseif (width < 20) then
		return 20;
	end
	return width;
end

function ModelCitizen_BoundingBox_GetHeightConstraint(bBox, height)
	if (height == nil) then
		return nil
	elseif (height > UIParent:GetHeight() / UIParent:GetEffectiveScale()) then
		return UIParent:GetHeight() / UIParent:GetEffectiveScale();
	elseif (height < 20) then
		return 20;
	end
	return height;
end

--
-- Bounding Box Position
-- Sets the anchor position. Can not exceed UIParent.
--

function ModelCitizen_BoundingBox_SetPosition(bBox, x, y)
	if (x == nil) then
		x = bBox:GetLeft();
	end
	if (y == nil) then
		y = bBox:GetBottom();
	end
	if (x ~= bBox:GetLeft() or y ~= bBox:GetBottom()) then
		-- Anchor points have changed.
		bBox:SetPoint("BOTTOMLEFT", ModelCitizen_BoundingBox_GetPositionConstraint(bBox, x, y));
		ModelCitizen_SessionProfile[bBox:GetID()].anchor.x = x;
		ModelCitizen_SessionProfile[bBox:GetID()].anchor.y = y;
		ModelCitizen_SpecialEvent("BOUNDINGBOX_POSITION_CHANGED", bBox);
	end
end

function ModelCitizen_BoundingBox_GetPosition(bBox)
	return bBox:GetLeft(), bBox:GetBottom();
end

function ModelCitizen_BoundingBox_GetPositionConstraint(bBox, x, y)
	if (x == nil) then
		x = bBox:GetLeft();
	end
	if (y == nil) then
		y = bBox:GetBottom();
	end
	-- Determine left and right boundries
	local parentBoundry = UIParent:GetWidth() / UIParent:GetEffectiveScale();
	if (x < 0 and x + bBox:GetWidth() > parentBoundry) then
		bBox:SetWidth(parentBoundry);
		ModelCitizen_SessionProfile[bBox:GetID()].scale.width = parentBoundry;
	elseif (x < 0) then
		x = 0;
	elseif (x + bBox:GetWidth() > parentBoundry) then
		x = parentBoundry - bBox:GetWidth();
	end
	-- Determine top and bottom boundries
	parentBoundry = UIParent:GetHeight() / UIParent:GetEffectiveScale();
	if (y < 0 and y + bBox:GetHeight() > parentBoundry) then
		bBox:SetHeight(parentBoundry);
		ModelCitizen_SessionProfile[bBox:GetID()].scale.height = parentBoundry;
	elseif (y < 0) then
		y = 0;
	elseif (y + bBox:GetHeight() > parentBoundry) then
		y = parentBoundry - bBox:GetHeight();
	end
	return x, y;
end

--
-- Bounding Box Backdrop Color
-- Sets the background colors and opacity.
--

function ModelCitizen_BoundingBox_SetBackdropColor(bBox, red, green, blue, alpha)
	local bgColor = ModelCitizen_SessionProfile[bBox:GetID()].bgColor;
	if (red == nil) then
		red = bgColor.red;
	end
	if (green == nil) then
		green = bgColor.green;
	end
	if (blue == nil) then
		blue = bgColor.blue;
	end
	if (alpha == nil) then
		alpha = bgColor.alpha;
	end
	if (red ~= bgColor.red or green ~= bgColor.green or blue ~= bgColor.blue or alpha ~= bgColor.alpha) then
		-- Colors or alpha setting has changed.
		bBox:SetBackdropColor(red, green, blue, alpha);
		bgColor.red   = red;
		bgColor.green = green;
		bgColor.blue  = blue;
		bgColor.alpha = alpha;
		ModelCitizen_SpecialEvent("BOUNDINGBOX_BACKDROP_CHANGED", bBox);
	end
end

function ModelCitizen_BoundingBox_GetBackdropColor(bBox)
	bgColor = ModelCitizen_SessionProfile[bBox:GetID()].bgColor;
	return bgColor.red, bgColor.green, bgColor.blue, bgColor.alpha;
end

