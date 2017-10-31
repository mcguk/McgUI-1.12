--
-- Profile Settings
--

function ModelCitizen_Settings_RefreshProfile()
	for i = 0, 14 do
		bBox = getglobal("ModelCitizen_Camera"..i);
		ModelCitizen_Settings_RefreshBoundingBox(bBox);
	end
end

function ModelCitizen_Settings_RefreshBoundingBox(bBox)
	profile = ModelCitizen_SessionProfile[bBox:GetID()];
	if (bBox:GetID() < 6) then
		if (bBox:GetID() == 0) then
			profile.avatar.unitType = "player";
		elseif (bBox:GetID() == 1) then
			profile.avatar.unitType = "target";
		elseif (bBox:GetID() == 2) then
			profile.avatar.unitType = "party1";
		elseif (bBox:GetID() == 3) then
			profile.avatar.unitType = "party2";
		elseif (bBox:GetID() == 4) then
			profile.avatar.unitType = "party3";
		elseif (bBox:GetID() == 5) then
			profile.avatar.unitType = "party4";
		end
		ModelCitizen_SessionProfile[bBox:GetID()].isEnabled = true;
		
		bBox:Show();
		bBox:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", profile.anchor.x, profile.anchor.y);
		bBox:SetWidth(profile.scale.width);
		bBox:SetHeight(profile.scale.height);
		bBox:SetBackdropColor(profile.bgColor.red, profile.bgColor.green, profile.bgColor.blue, profile.bgColor.alpha);
		if (profile.cursorControls.count > 0) then
			bBox:EnableMouse(true);
		else
			bBox:EnableMouse(false);
		end
		ModelCitizen_Avatar_SetUnitType(bBox:GetChildren(), profile.avatar.unitType);
		ModelCitizen_Settings_RefreshCamera(bBox:GetChildren());
	end
end

function ModelCitizen_Settings_SaveProfile(saveAs)
	ModelCitizen_Profiles[saveAs] = ModelCitizen_SessionProfile;
end

function ModelCitizen_Settings_LoadProfile(layoutName, overwriteCursorControls)
	if (ModelCitizen_Profiles[layoutName] ~= nil) then
		if (overwriteCursorControls) then
			-- Copy everything
			ModelCitizen_SessionProfile = ModelCitizen_Profiles[layoutName];
		else
			-- Copy everything except cursorControls
			ModelCitizen_SessionProfile.isEnabled = ModelCitizen_Profiles[layoutName].isEnabled;
			ModelCitizen_SessionProfile.title     = ModelCitizen_Profiles[layoutName].title;
			ModelCitizen_SessionProfile.scale     = ModelCitizen_Profiles[layoutName].scale;
			ModelCitizen_SessionProfile.anchor    = ModelCitizen_Profiles[layoutName].anchor;
			ModelCitizen_SessionProfile.bgColor   = ModelCitizen_Profiles[layoutName].bgColor;
			ModelCitizen_SessionProfile.avatar    = ModelCitizen_Profiles[layoutName].avatar;
		end
		ModelCitizen_Settings_RefreshProfile();
	end
end

function ModelCitizen_Settings_CreateProfile()
	return {
		[0]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[1]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[2]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[3]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[4]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[5]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[6]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[7]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[8]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[9]  = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[10] = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[11] = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[12] = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[13] = ModelCitizen_Settings_CreateProfile_BoundingBox(),
		[14] = ModelCitizen_Settings_CreateProfile_BoundingBox(),
	};
end

function ModelCitizen_Settings_CreateProfile_BoundingBox()
	return {
		["isEnabled"] = false,
		["title"] = "Untitled",
		["scale"] = {
			["width"] = 200,
			["height"] = 200,
		},
		["anchor"] = {
			["x"] = 200,
			["y"] = 200,
		},
		["bgColor"] = {
			["red"] = 0,
			["green"] = 0,
			["blue"] = 0,
			["alpha"] = 0,
		},
		["avatar"] = {
			["unitType"] = "target",
			["isRendered"] = false,
			["camera"] = ModelCitizen_Settings_CreateCamera(),
		},
		["cursorControls"] = ModelCitizen_Settings_CreateProfile_CursorControls(),
	};
end

function ModelCitizen_Settings_CreateProfile_CursorControls()
	return {
		["isEnabled"] = true,
		["active"] = nil,
		["count"] = 0,
		["LeftButton"]   = ModelCitizen_Settings_CreateProfile_CursorControlButton(),
		["RightButton"]  = ModelCitizen_Settings_CreateProfile_CursorControlButton(),
		["MiddleButton"] = ModelCitizen_Settings_CreateProfile_CursorControlButton(),
		["ScrollWheel"]  = ModelCitizen_Settings_CreateProfile_CursorControlButton(),
	};
end

function ModelCitizen_Settings_CreateProfile_CursorControlButton()
	return {
		["NOKEY"] = nil,
		["ALT"]   = nil,
		["CTRL"]  = nil,
		["SHIFT"] = nil,
	};
end

function ModelCitizen_Settings_DeleteProfile(layoutName)
	ModelCitizen_Profiles[layoutName] = nil;
end

--
-- Camera Settings
--

function ModelCitizen_Settings_SaveCamera(obj, saveAs)
	local id = ModelCitizen_GetBoundingBox(obj):GetID();
	ModelCitizen_Cameras[saveAs] = ModelCitizen_SessionProfile[id].camera;
end

function ModelCitizen_Settings_RefreshCamera(avatar)
	camera = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera;
	avatar:SetModelScale(camera.scale);
	avatar:SetPosition(camera.zoom, camera.position.panH, camera.position.panV);
	avatar:SetRotation(camera.rotation);
	--avatar:SetLight(camera.light.isEnabled, camera.light.omni, camera.light.zoom,
	--	camera.light.position.panH, camera.light.position.panV, camera.light.ambient.alpha,
	--	camera.light.ambient.red, camera.light.ambient.green, camera.light.ambient.blue,
	--	camera.light.direct.alpha, camera.light.direct.red, camera.light.direct.green,
	--	camera.light.direct.blue);
end

function ModelCitizen_Settings_LoadCamera(obj, cameraName)
	if (ModelCitizen_Cameras[cameraName] ~= nil) then
		ModelCitizen_SessionProfile[ModelCitizen_GetBoundingBox(obj):GetID()].camera = ModelCitizen_Cameras[cameraName];
		ModelCitizen_Settings_RefreshCamera(ModelCitizen_GetAvatar(obj));
	end
end

function ModelCitizen_Settings_CreateCamera(copyFrom)
	return {
		["scale"] = 1,
		["zoom"]  = 0,
		["position"] = {
			["panH"] = 0,
			["panV"] = 0,
		},
		["rotation"] = 0,
		["light"] = {
			["isEnabled"] = false,
			["omni"] = 1,
			["zoom"] = 0,
			["position"] = {
				["panH"] = 0,
				["panV"] = 0,
			},
			["ambient"] = {
				["red"]   = 0,
				["green"] = 0,
				["blue"]  = 0,
				["alpha"] = 0,
			},
			["direct"] = {
				["red"]   = 0,
				["green"] = 0,
				["blue"]  = 0,
				["alpha"] = 0,
			},
		},
	};
end

function ModelCitizen_Settings_DeleteCamera(cameraName)
	ModelCitizen_Cameras[cameraName] = nil;
end