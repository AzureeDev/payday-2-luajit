NetworkAccount = NetworkAccount or class()

function NetworkAccount:init()
	self._postprocess_username = callback(self, self, "_standard_username")

	self:set_lightfx()
end

function NetworkAccount:update()
end

function NetworkAccount:create_account(name, password, email)
end

function NetworkAccount:reset_password(name, email)
end

function NetworkAccount:login(name, password, cdkey)
end

function NetworkAccount:logout()
end

function NetworkAccount:register_callback(event, callback)
end

function NetworkAccount:register_post_username(cb)
	self._postprocess_username = cb
end

function NetworkAccount:username()
	return self._postprocess_username(self:username_id())
end

function NetworkAccount:username_id()
	return 0
end

function NetworkAccount:username_by_id()
	return ""
end

function NetworkAccount:signin_state()
	return "not signed in"
end

function NetworkAccount:set_lightfx()
	if SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end

	if managers.user:get_setting("use_lightfx") then
		print("[NetworkAccount:init] Initializing LightFX...")

		self._has_alienware = LightFX:initialize() and LightFX:has_lamps()

		if self._has_alienware then
			LightFX:set_lamps(0, 255, 0, 255)
		end
	else
		self._has_alienware = nil
	end
end

function NetworkAccount:has_alienware()
	return self._has_alienware
end

function NetworkAccount:clan_tag()
	if managers.save.get_profile_setting and managers.save:get_profile_setting("clan_tag") and string.len(managers.save:get_profile_setting("clan_tag")) > 0 then
		return "[" .. managers.save:get_profile_setting("clan_tag") .. "]"
	end

	return ""
end

function NetworkAccount:_standard_username(name)
	return name
end

function NetworkAccount:set_playing(state)
end

function NetworkAccount:_load_globals()
end

function NetworkAccount:_save_globals()
end

function NetworkAccount:inventory_load()
end

function NetworkAccount:inventory_is_loading()
end

function NetworkAccount:inventory_reward(item)
	return false
end

function NetworkAccount:inventory_reward_dlc()
end

function NetworkAccount:inventory_reward_unlock(box, key)
end

function NetworkAccount:inventory_reward_open(item)
end

function NetworkAccount:inventory_outfit_refresh()
end

function NetworkAccount:inventory_outfit_verify(id, outfit_data, outfit_callback)
end

function NetworkAccount:inventory_outfit_signature()
	return ""
end

function NetworkAccount:inventory_repair_list(list)
end

function NetworkAccount:is_ready_to_close()
	return true
end
