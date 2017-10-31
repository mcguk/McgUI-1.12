-- SavedVariables
ModelCitizen_Profiles = {};
ModelCitizen_Cameras = {};

-- SavedVariablesPerCharacter
ModelCitizen_SessionProfile = ModelCitizen_Settings_CreateProfile();

-- Session Defaults
ModelCitizen_CursorX,     ModelCitizen_CursorY     = nil, nil;
ModelCitizen_CursorMoveX, ModelCitizen_CursorMoveY = nil, nil;

-- 
-- XML-LUA GLUE
--
-- Bounding Box
-- Focal point frame which encapsulates each camera. Responsible for rendering
-- the visibility border, any backdrop effects, and all mouse clicks.
--

function ModelCitizen_BoundingBox_OnLoad()
	this.isAvatar = false;
	this:RegisterEvent("VARIABLES_LOADED");
	ModelCitizen_SpecialEvent("BOUNDINGBOX_CREATED", this);
end

function ModelCitizen_BoundingBox_OnEvent()
	if (event == "VARIABLES_LOADED") then
		ModelCitizen_Settings_RefreshBoundingBox(this);
		ModelCitizen_SpecialEvent("BOUNDINGBOX_REFRESHED", this);
	end
end

function ModelCitizen_BoundingBox_OnMouseDown()
	if (ModelCitizen_CursorControl_IsEnabled(this) and (arg1 == "LeftButton" or arg1 == "RightButton" or arg1 == "MiddleButton")) then
		ModelCitizen_CursorControl_SetActiveButton(this, arg1);
	end
end

function ModelCitizen_BoundingBox_OnUpdate()
	ModelCitizen_Avatar_AttemptToRender(this:GetChildren());
	if (ModelCitizen_CursorControl_IsEnabled(this)) then
		activeControl = ModelCitizen_CursorControl_GetActiveName(this);
		if (activeControl ~= nil) then
			ModelCitizen_GetCursorMovement(); -- Calculate movement for controls
			if (activeControl.isAvatar) then
				ModelCitizen_SpecialEvent("CURSORCONTROL_ONMOUSEDOWN", this:GetChildren());
			else
				this:SetBackdropColor(0,0.5,1,0.5);
				ModelCitizen_SpecialEvent("CURSORCONTROL_ONMOUSEDOWN", this);
			end
			ModelCitizen_CursorMoveX, ModelCitizen_CursorMoveY = nil, nil;
		end
	end
end

function ModelCitizen_BoundingBox_OnMouseUp()
	this:SetBackdropColor(0,0,0,0);
	ModelCitizen_CursorControl_SetActiveButton(this);
	ModelCitizen_CursorX,     ModelCitizen_CursorY     = nil, nil;
	ModelCitizen_CursorMoveX, ModelCitizen_CursorMoveY = nil, nil;
end

function ModelCitizen_BoundingBox_OnReceiveDrag()
	ModelCitizen_BoundingBox_OnMouseUp();
end

function ModelCitizen_BoundingBox_OnShow()
end

function ModelCitizen_BoundingBox_OnHide()
	ModelCitizen_BoundingBox_OnMouseUp();
	this:GetChildren():ClearModel();
	ModelCitizen_Avatar_SetRendered(this:GetChildren(), false);
end



--
-- Avatar
-- Main 3D model layer which renders the unit. Responsible for engine aspects.
-- Should not be used for mouse clicks or backdrop effects.
-- 

function ModelCitizen_Avatar_OnLoad()
	this.isAvatar = true;
	this.renderTick = 0;
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	ModelCitizen_SpecialEvent("AVATAR_CREATED", this);
end

function ModelCitizen_Avatar_OnEvent()
	if (ModelCitizen_BoundingBox_IsEnabled(this:GetParent())) then
		if (event == "PLAYER_TARGET_CHANGED") then
			if (UnitExists(ModelCitizen_Avatar_GetUnitType(this))) then
				this:GetParent():Show();
				ModelCitizen_Avatar_SetRendered(this, false);
				ModelCitizen_Avatar_AttemptToRender(this, true);
			else
				this:GetParent():Hide();
			end
		elseif (event == "PARTY_MEMBERS_CHANGED") then
			if (UnitExists(ModelCitizen_Avatar_GetUnitType(this))) then
				this:GetParent():Show();
				ModelCitizen_Avatar_SetRendered(this, false);
				ModelCitizen_Avatar_AttemptToRender(this, true);
			else
				this:GetParent():Hide();
			end
		elseif (event == "UNIT_MODEL_CHANGED") then
			if (UnitExists(ModelCitizen_Avatar_GetUnitType(this))) then
				this:GetParent():Show();
				ModelCitizen_Avatar_SetRendered(this, false);
				ModelCitizen_Avatar_AttemptToRender(this, true);
			else
				this:GetParent():Hide();
			end
		end
	end
end

function ModelCitizen_Avatar_OnUpdate()
end

--
-- Special Events
-- To coordinate multiple GUI elements (or other AddOn's), I made many important
-- ModelCitizen events trigger this function. Use it creatively!
--

function ModelCitizen_SpecialEvent(event, ...)
	if (event == "BOUNDINGBOX_REFRESHED") then
		ModelCitizen_CursorControl_SetButton(this, "Drag", "LeftButton", "SHIFT");
		ModelCitizen_CursorControl_SetButton(this, "Resize", "RightButton", "SHIFT");
		ModelCitizen_CursorControl_SetButton(this:GetChildren(), "RotateAndZoom", "LeftButton", "CTRL");
		ModelCitizen_CursorControl_SetButton(this:GetChildren(), "Pan", "RightButton", "CTRL");
	elseif (event == "CURSORCONTROL_ONMOUSEDOWN") then
		this = arg[1];
		if (arg[1].isAvatar) then
			ModelCitizen_Avatar_RotateAndZoom();
			ModelCitizen_Avatar_RotateAndShrink();
			ModelCitizen_Avatar_Rotate();
			ModelCitizen_Avatar_Zoom();
			ModelCitizen_Avatar_Shrink();
			ModelCitizen_Avatar_Pan();
		else
			ModelCitizen_BoundingBox_Drag();
			ModelCitizen_BoundingBox_Resize();
		end
	end
end

function ModelCitizen_GetCursorMovement()
	if (ModelCitizen_CursorMoveX == nil or ModelCitizen_CursorMoveY == nil) then
		-- Update mouse coords
		local previousX, previousY = ModelCitizen_CursorX, ModelCitizen_CursorY;
		ModelCitizen_CursorX, ModelCitizen_CursorY = GetCursorPosition();
		if (previousX == nil or previousY == nil) then
			-- Initial mouse click, mouse has yet to move
			previousX, previousY = ModelCitizen_CursorX, ModelCitizen_CursorY;
		end
		-- Save movement
		ModelCitizen_CursorMoveX = (ModelCitizen_CursorX - previousX) / UIParent:GetEffectiveScale();
		ModelCitizen_CursorMoveY = (ModelCitizen_CursorY - previousY) / UIParent:GetEffectiveScale();
	end
	
	return ModelCitizen_CursorMoveX, ModelCitizen_CursorMoveY;
end

function ModelCitizen_GetBoundingBox(obj)
	if (obj.isAvatar) then
		return obj:GetParent();
	else
		return obj;
	end
end

function ModelCitizen_GetAvatar(obj)
	if (obj.isAvatar) then
		return obj;
	else
		return obj:GetChildren();
	end
end

function ModelCitizen_UnitIsRenderable(unitType)
	if (UnitExists(unitType) and UnitIsVisible(unitType)) then
		return true;
	else
		return false;
	end
end