--
-- Avatar API
--

function ModelCitizen_Avatar_Refresh(avatar)
	-- For some reason, you have to destroy all the previous values first.
	-- I assume this is because each of these functions check for the offset
	-- change rather than raw values.
	avatar:SetModelScale(1);
	avatar:SetPosition(0, 0, 0);
	--	avatar:SetRotation(0); -- rotation doesn't seem to need it.
	avatar:ClearModel();
	avatar:SetUnit(ModelCitizen_Avatar_GetUnitType(avatar));
	ModelCitizen_Settings_RefreshCamera(avatar);
	ModelCitizen_SpecialEvent("AVATAR_REFRESHED", avatar);
end

function ModelCitizen_Avatar_SetUnitType(avatar, unitType)
	if (unitType ~= nil) then
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.unitType = unitType;
		if (unitType == "player" or unitType == "playerpet") then
			avatar:UnregisterEvent("PARTY_MEMBERS_CHANGED");
			avatar:UnregisterEvent("PLAYER_TARGET_CHANGED");
			ModelCitizen_Avatar_SetRendered(this, false); -- Force a refresh
			if (ModelCitizen_BoundingBox_IsEnabled(avatar:GetParent())) then
				avatar:GetParent():Show();
			else
				avatar:GetParent():Hide();
			end
			
		elseif (unitType == "target" or unitType == "targettarget") then
			
			avatar:UnregisterEvent("PARTY_MEMBERS_CHANGED");
			
			avatar:RegisterEvent("PLAYER_TARGET_CHANGED");
			if (ModelCitizen_BoundingBox_IsEnabled(avatar:GetParent())) then
				if (UnitExists(unitType)) then
					avatar:GetParent():Show();
				else
					avatar:GetParent():Hide();
				end
			end
				
			
		elseif (  unitType == "party1" or unitType == "party1pet" or 
		          unitType == "party2" or unitType == "party2pet" or 
		          unitType == "party3" or unitType == "party3pet" or 
		          unitType == "party4" or unitType == "party4pet"  ) then
			
			avatar:UnregisterEvent("PLAYER_TARGET_CHANGED");
			
			avatar:RegisterEvent("PARTY_MEMBERS_CHANGED");
			
			if (ModelCitizen_BoundingBox_IsEnabled(avatar:GetParent())) then
				if (UnitExists(unitType)) then
					avatar:GetParent():Show();
				else
					avatar:GetParent():Hide();
				end
			end
			
		end
		ModelCitizen_SpecialEvent("AVATAR_UNITTYPE_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetUnitType(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.unitType;
end

function ModelCitizen_Avatar_SetRendered(avatar, state)
	if (state) then
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.isRendered = true;
	else
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.isRendered = false;
	end
end

function ModelCitizen_Avatar_IsRendered(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.isRendered;
end

function ModelCitizen_Avatar_AttemptToRender(avatar, tick)
	-- The rendering tick, in practice, only effects joining a party where
	-- the members are too far away to be rendered. This will continue to
	-- refresh the party member until it ticks while within dueling range.
	if (avatar.renderTick < 4000) then
		avatar.renderTick = avatar.renderTick + 1;
	else
		avatar.renderTick = 0;
		tick = true;
	end
	if (tick) then
		avatar.renderTick = 0;
		if (not ModelCitizen_Avatar_IsRendered(avatar)) then
			ModelCitizen_Avatar_Refresh(avatar);
			if (ModelCitizen_UnitIsRenderable(ModelCitizen_Avatar_GetUnitType(avatar))) then
				ModelCitizen_Avatar_SetRendered(avatar, true);
				ModelCitizen_SpecialEvent("AVATAR_RENDERED", avatar);
			else
				-- Model *might* have rendered, until the target is within
				-- dueling range, we can't be sure. Continue to attempt
				-- rendering until we're sure.
				ModelCitizen_SpecialEvent("AVATAR_ATTEMPTED_TO_RENDER", avatar);
			end
		end
	end
end

function ModelCitizen_Avatar_SetScale(avatar, scale)
	camera = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera;
	if (scale ~= nil and scale ~= camera.scale) then
		avatar:SetModelScale(scale);
		camera.scale = scale;
		ModelCitizen_SpecialEvent("AVATAR_SCALE_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetScale(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.scale;
end

function ModelCitizen_Avatar_SetZoom(avatar, zoom)
	camera = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera;
	if (zoom ~= nil and zoom ~= camera.zoom) then
		avatar:SetPosition(zoom, camera.position.panH, camera.position.panV);
		camera.zoom = zoom;
		ModelCitizen_SpecialEvent("AVATAR_ZOOM_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetZoom(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.zoom;
end

function ModelCitizen_Avatar_SetPosition(avatar, panH, panV)
	camera = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera;
	if (panH == nil) then
		panH = camera.position.panH;
	end
	if (panV == nil) then
		panV = camera.position.panV;
	end
	if (panH ~= camera.position.panH or panV ~= camera.position.panV) then
		avatar:SetPosition(camera.zoom, panH, panV);
		camera.position.panH = panH;
		camera.position.panV = panV;
		ModelCitizen_SpecialEvent("AVATAR_POSITION_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetPosition(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.position.panH,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.position.panV;
end

function ModelCitizen_Avatar_SetRotation(avatar, rotation)
	camera = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera;
	if (rotation ~= nil and rotation > 3.099999999999) then
		rotation = -3.1;
	elseif (rotation ~= nil and rotation < -3.1) then
		rotation = 3.099999999999;
	end
	if (rotation ~= nil and rotation ~= camera.rotation) then
		avatar:SetRotation(rotation);
		camera.rotation = rotation;
		ModelCitizen_SpecialEvent("AVATAR_ROTATION_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetRotation(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.rotation;
end

function ModelCitizen_Avatar_SetLightState(avatar, isEnabled, omni)
	light = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light;
	if (isEnabled == nil) then
		isEnabled = light.isEnabled;
	elseif (isEnabled) then
		isEnabled = 1;
	else
		isEnabled = 0;
	end
	if (omni == nil) then
		omni = light.omni;
	elseif (omni) then
		omni = 1;
	else
		omni = 0;
	end
	if (isEnabled ~= light.isEnabled or omni ~= light.omni) then
		light.isEnabled = isEnabled;
		light.omni  = omni;
		ModelCitizen_Avatar_RefreshLight();
		ModelCitizen_SpecialEvent("AVATAR_LIGHT_STATE_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetLightState(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.isEnabled,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.omni;
end

function ModelCitizen_Avatar_SetLightZoom(avatar, zoom)
	light = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light;
	if (zoom ~= nil and zoom ~= light.zoom) then
		light.zoom = zoom;
		ModelCitizen_Avatar_RefreshLight();
		ModelCitizen_SpecialEvent("AVATAR_LIGHT_ZOOM_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetLightZoom(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.zoom;
end

function ModelCitizen_Avatar_SetLightPosition(avatar, panH, panV)
	light = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light;
	if (panH == nil) then
		panH = light.position.panH;
	end
	if (panV == nil) then
		panV = light.position.panV;
	end
	if (panH ~= light.position.panH or panV ~= light.position.panV) then
		light.position.panH = panH;
		light.position.panV = panV;
		ModelCitizen_Avatar_RefreshLight();
		ModelCitizen_SpecialEvent("AVATAR_LIGHT_POSITION_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetLightPosition(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.position.panH,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.position.panV;
end

function ModelCitizen_Avatar_SetLightAmbient(avatar, red, green, blue, alpha)
	ambientLight = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.ambient;
	if (alpha == nil) then
		alpha = ambientLight.alpha;
	end
	if (red == nil) then
		red = ambientLight.red;
	end
	if (green == nil) then
		green = ambientLight.green;
	end
	if (blue == nil) then
		blue = ambientLight.blue;
	end
	if (  alpha ~= ambientLight.alpha or red ~= ambientLight.red or
	      green ~= ambientLight.green or blue ~= ambientLight.blue  ) then
		ambientLight.alpha  = alpha;
		ambientLight.red    = red;
		ambientLight.green  = green;
		ambientLight.blue   = blue;
		ModelCitizen_Avatar_RefreshLight();
		ModelCitizen_SpecialEvent("AVATAR_LIGHT_AMBIENT_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetLightAmbient(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.ambient.red,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.ambient.green,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.ambient.blue,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.ambient.alpha;
end

function ModelCitizen_Avatar_SetLightDirect(avatar, red, green, blue, alpha)
	directLight = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.direct;
	if (alpha == nil) then
		alpha = directLight.alpha;
	end
	if (red == nil) then
		red = directLight.red;
	end
	if (green == nil) then
		green = directLight.green;
	end
	if (blue == nil) then
		blue = directLight.blue;
	end
	if (  alpha ~= directLight.alpha or red ~= directLight.red or
	      green ~= directLight.green or blue ~= directLight.blue  ) then
		directLight.alpha  = alpha;
		directLight.red    = red;
		directLight.green  = green;
		directLight.blue   = blue;
		ModelCitizen_Avatar_RefreshLight();
		ModelCitizen_SpecialEvent("AVATAR_LIGHT_DIRECT_CHANGED", avatar);
	end
end

function ModelCitizen_Avatar_GetLightDirect(avatar)
	return ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.direct.red,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.direct.green,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.direct.blue,
		ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light.direct.alpha;
end

function ModelCitizen_Avatar_RefreshLight()
	--light = ModelCitizen_SessionProfile[avatar:GetParent():GetID()].avatar.camera.light;
	-- Haven't tested light sourcing yet.
	--avatar:SetLight(  light.isEnabled, light.omni,
	--                  light.zoom,
	--                  light.position.panH, light.position.panV,
	--                  light.ambient.alpha, light.ambient.red, light.ambient.green, light.ambient.blue,
	--                  light.direct.alpha, light.direct.red, light.direct.green, light.direct.blue  );
end