--
-- Cursor Control
-- Utility functions for handling all mouse-related visual controls
--

function ModelCitizen_CursorControl_IsEnabled(obj)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	return ModelCitizen_SessionProfile[id].cursorControls.isEnabled;
end

function ModelCitizen_CursorControl_Enable(obj, state)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	if (state) then
		ModelCitizen_GetBoundingBox(obj):EnableMouse(true);
		ModelCitizen_SessionProfile[id].cursorControls.isEnabled = true;
		ModelCitizen_SpecialEvent("CURSORCONTROL_ENABLED", obj);
	else
		ModelCitizen_GetBoundingBox(obj):EnableMouse(false);
		ModelCitizen_SessionProfile[id].cursorControls.isEnabled = false;
		ModelCitizen_SpecialEvent("CURSORCONTROL_DISABLED", obj);
	end
end

function ModelCitizen_CursorControl_GetButton(obj, mouseButton, keyModifier)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	if (  mouseButton == "LeftButton" or mouseButton == "RightButton" or
	      mouseButton == "MiddleButton" or mouseButton == "ScrollWheel"  ) then
		if (keyModifier == nil) then
			keyModifier = "NOKEY";
		end
		return ModelCitizen_SessionProfile[id].cursorControls[mouseButton][keyModifier];
	end
end

function ModelCitizen_CursorControl_SetButton(obj, controlName, mouseButton, keyModifier)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	cc = ModelCitizen_SessionProfile[id].cursorControls;
	if (keyModifier == nil) then
		keyModifier = "NOKEY";
	end
	if (controlName ~= nil) then
		cc[mouseButton][keyModifier] = { ["name"] = controlName, ["isAvatar"] = obj.isAvatar };
		if (ModelCitizen_CursorControl_IsEnabled(obj)) then
			ModelCitizen_GetBoundingBox(obj):EnableMouse(true);
		end
		cc.count = cc.count + 1;
		ModelCitizen_SpecialEvent("CURSORCONTROL_ADDED", obj, controlName, mouseButton, keyModifier);
	else
		cc[mouseButton][keyModifier] = nil;
		cc.count = cc.count - 1;
		if (cc.count < 0) then
			ModelCitizen_GetBoundingBox(obj):EnableMouse(false);
			cc.count = 0;
		end
		ModelCitizen_SpecialEvent("CURSORCONTROL_REMOVED", obj, controlName, mouseButton, keyModifier);
	end
end

function ModelCitizen_CursorControl_SetActiveButton(obj, mouseButton)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	cc = ModelCitizen_SessionProfile[id].cursorControls;
	if (mouseButton == nil) then
		cc.active = nil;
		return;
	end
	if (IsAltKeyDown()) then
		keyModifier = "ALT";
	elseif (IsControlKeyDown()) then
		keyModifier = "CTRL";
	elseif (IsShiftKeyDown()) then
		keyModifier = "SHIFT";
	else
		keyModifier = "NOKEY";
	end
	if (cc[mouseButton][keyModifier] ~= nil) then
		cc.active = cc[mouseButton][keyModifier];
	else
		cc.active = nil;
	end
end

function ModelCitizen_CursorControl_GetActiveName(obj)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	return ModelCitizen_SessionProfile[id].cursorControls.active;
end

function ModelCitizen_CursorControl_IsActive(obj, controlName)
	local active = ModelCitizen_CursorControl_GetActiveName(obj);
	if (controlName ~= nil and active ~= nil and controlName == active.name) then
		return true;
	end
	return false;
end






--
-- BOUNDING BOX VISUAL CONTROLS
--

--
-- Bounding Box Dragging
-- Allows movement of the bounding box.
--

function ModelCitizen_BoundingBox_Drag()
	if (ModelCitizen_CursorControl_IsActive(this, "Drag")) then
		changeX, changeY = ModelCitizen_GetCursorMovement();
		if (changeX ~= 0 or changeY ~= 0) then
			ModelCitizen_BoundingBox_SetPosition(this, this:GetLeft() + changeX, this:GetBottom() + changeY);
		end
	end
end

--
-- Bounding Box Resizing
-- Allows the bounding box to be resized.
--

function ModelCitizen_BoundingBox_Resize()
	if (ModelCitizen_CursorControl_IsActive(this, "Resize")) then
		changeX, changeY = ModelCitizen_GetCursorMovement();
		if (changeX ~= 0 or changeY ~= 0) then
			ModelCitizen_BoundingBox_SetScale(this, this:GetWidth() + changeX, this:GetHeight() + changeY);
		end
	end
end




--
-- AVATAR CURSOR CONTROLS
--
-- Avatar Common Interaction
-- Most visual controls use the same basic logic, these utility functions save redundancy.
--

function ModelCitizen_Avatar_GetControlIntensity(bBox, modAmountPerUnit)
	boundryWidth = this:GetParent():GetWidth();
	boundryHeight = this:GetParent():GetHeight();
	if (boundryHeight == nil) then
		boundryHeight = boundryWidth;
	end
	local modAmount;
	if (modAmountPerUnit == nil) then
		modAmountPerUnit = 0;
	elseif (boundryWidth > boundryHeight) then
		modAmount = modAmountPerUnit / (boundryWidth / 100);
	elseif (boundryHeight <= 0) then
		-- Shouldn't be able (or want) to size to 0, but just in case.
		modAmount = modAmountPerUnit;
	else
		modAmount = modAmountPerUnit / (boundryHeight / 100);
	end
	return modAmount;
end

function ModelCitizen_Avatar_GetControlConstraint(modify, min, max, loop)
	if (min ~= nil) then
		if (modify < min and not loop) then
			modify = min;
		elseif (modify < min and loop and max ~= nil) then
			modify = max;
		end
	end
	if (max ~= nil) then
		if (modify > max and not loop) then
			modify = max;
		elseif (modify > max and loop and min ~= nil) then
			modify = min;
		end
	end
	return modify;
end

--
-- Avatar Rotate & Zoom
-- Allows 3D model to be turned left or right and zoomed in or out.
-- Requires: ModelCitizen_Avatar_Rotate() and ModelCitizen_Avatar_Zoom()
--

function ModelCitizen_Avatar_RotateAndZoom()
	if (ModelCitizen_CursorControl_IsActive(this, "RotateAndZoom")) then
		-- Complementary visual controls, trigger both.
		ModelCitizen_Avatar_Rotate();
		ModelCitizen_Avatar_Zoom();
	end
end

--
-- Avatar Rotate & Shrink
-- Allows 3D model to shrink or grow and be turned left or right
-- Requires: ModelCitizen_Avatar_Rotate() and ModelCitizen_Avatar_Shrink()
--

function ModelCitizen_Avatar_RotateAndShrink()
	if (ModelCitizen_CursorControl_IsActive(this, "RotateAndShrink")) then
		-- Complementary visual controls, trigger both.
		ModelCitizen_Avatar_Rotate();
		ModelCitizen_Avatar_Shrink();
	end
end

--
-- Avatar Rotate
-- Allows 3D model to be turned left or right.
-- Dependancy: ModelCitizen_Avatar_RotateAndZoom*() functions use this.
--

function ModelCitizen_Avatar_Rotate()
	if (  ModelCitizen_CursorControl_IsActive(this, "RotateAndZoom") or 
	      ModelCitizen_CursorControl_IsActive(this, "RotateAndShrink") or 
		  ModelCitizen_CursorControl_IsActive(this, "Rotate")  ) then
		changeX, changeY = ModelCitizen_GetCursorMovement();
		if (changeX ~= 0) then
			local mod = ModelCitizen_Avatar_GetControlIntensity(this:GetParent(), 0.033);
			local rotation = ModelCitizen_Avatar_GetRotation(this);
			rotation = ModelCitizen_Avatar_GetControlConstraint(rotation + (mod * changeX), -3.1, 3.099999999999, true);
			ModelCitizen_Avatar_SetRotation(this, rotation);
		end
	end
end

--
-- Avatar Zoom
-- Allows 3D model to zoom in and out.
-- Dependancy: ModelCitizen_Avatar_RotateAndZoom*() functions use this.
--

function ModelCitizen_Avatar_Zoom()
	if (  ModelCitizen_CursorControl_IsActive(this, "RotateAndZoom") or 
	      ModelCitizen_CursorControl_IsActive(this, "Zoom")  ) then
		changeX, changeY = ModelCitizen_GetCursorMovement();
		if (changeY ~= 0) then
			local mod = ModelCitizen_Avatar_GetControlIntensity(this:GetParent(), 0.035);
			local zoom = ModelCitizen_Avatar_GetZoom(this);
			zoom = ModelCitizen_Avatar_GetControlConstraint(zoom + (mod * changeY), -20, 5, false);
			ModelCitizen_Avatar_SetZoom(this, zoom);
		end
	end
end

--
-- Avatar Shrink
-- Allows 3D model to shrink and grow in size.
--

function ModelCitizen_Avatar_Shrink()
	if (  ModelCitizen_CursorControl_IsActive(this, "RotateAndShrink") or 
	      ModelCitizen_CursorControl_IsActive(this, "Shrink")  ) then
		changeX, changeY = ModelCitizen_GetCursorMovement();
		if (changeY ~= 0) then
			local mod = ModelCitizen_Avatar_GetControlIntensity(this:GetParent(), 0.0055);
			local scale = ModelCitizen_Avatar_GetScale(this);
			scale = ModelCitizen_Avatar_GetControlConstraint(scale + (mod * changeY), 0.10, 10, false);
			ModelCitizen_Avatar_SetZoom(this, scale);
		end
	end
end

--
-- Avatar Pan
-- Allows 3D model to be positioned on a 2D plane within the bounding box.
--

function ModelCitizen_Avatar_Pan()
	if (ModelCitizen_CursorControl_IsActive(this, "Pan")) then
		changeX, changeY = ModelCitizen_GetCursorMovement();
		if (changeX ~= 0 or changeY ~= 0) then
			local mod = ModelCitizen_Avatar_GetControlIntensity(this:GetParent(), 0.03075);
			local h, v = ModelCitizen_Avatar_GetPosition(this);
			h = ModelCitizen_Avatar_GetControlConstraint(h + (mod * changeX), -50, 50, true);
			v = ModelCitizen_Avatar_GetControlConstraint(v + (mod * changeY), -50, 50, true);
			ModelCitizen_Avatar_SetPosition(this, h, v);
		end
	end
end