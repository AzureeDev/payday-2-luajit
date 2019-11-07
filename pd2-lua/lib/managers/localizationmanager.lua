core:import("CoreLocalizationManager")
core:import("CoreClass")

LocalizationManager = LocalizationManager or class(CoreLocalizationManager.LocalizationManager)

function LocalizationManager:init()
	LocalizationManager.super.init(self)

	self._input_translations = {}

	self:_setup_macros()
	Application:set_default_letter(95)
end

function LocalizationManager:_setup_macros()
	local btn_a = utf8.char(57344)
	local btn_b = utf8.char(57345)
	local btn_x = utf8.char(57346)
	local btn_y = utf8.char(57347)
	local btn_back = utf8.char(57348)
	local btn_start = utf8.char(57349)
	local stick_l = utf8.char(57350)
	local stick_r = utf8.char(57351)
	local btn_top_l = utf8.char(57352)
	local btn_top_r = utf8.char(57353)
	local btn_bottom_l = utf8.char(57354)
	local btn_bottom_r = utf8.char(57355)
	local btn_stick_l = utf8.char(57356)
	local btn_stick_r = utf8.char(57357)
	local btn_dpad_u = utf8.char(57358)
	local btn_dpad_d = utf8.char(57358)
	local btn_dpad_l = utf8.char(57358)
	local btn_dpad_r = utf8.char(57358)
	local btn_inv_new = utf8.char(57362)
	local btn_ghost = utf8.char(57363)
	local btn_skull = utf8.char(57364)
	local btn_padlock = utf8.char(57365)
	local btn_stat_boost = utf8.char(57366)
	local btn_team_boost = utf8.char(57367)
	local btn_spree_ticket = utf8.char(57368)
	local btn_spree_short = utf8.char(57369)
	local btn_spree_medium = utf8.char(57370)
	local btn_spree_long = utf8.char(57371)
	local btn_spree_stealth = utf8.char(57372)
	local btn_continental_coins = utf8.char(57373)

	if SystemInfo:platform() ~= Idstring("PS3") then
		btn_top_l = utf8.char(57354)
		btn_bottom_l = utf8.char(57352)
		btn_top_r = utf8.char(57355)
		btn_bottom_r = utf8.char(57353)
	end

	local btn_accept = btn_a
	local btn_cancel = btn_b
	local btn_attack = btn_a
	local btn_block = btn_b
	local btn_interact = btn_bottom_r
	local btn_primary = btn_top_r
	local btn_use_item = btn_bottom_l
	local btn_secondary = btn_top_l
	local btn_reload = btn_x
	local btn_jump = btn_a
	local btn_change_equipment = btn_top_l
	local btn_change_profile_right = btn_top_r
	local btn_change_profile_left = btn_top_l
	local swap_accept = false

	if SystemInfo:platform() == Idstring("PS3") and PS3:pad_cross_circle_inverted() then
		swap_accept = true
	end

	if swap_accept then
		local btn_tmp = btn_a
		btn_a = btn_b
		btn_b = btn_tmp
		btn_accept = btn_a
		btn_cancel = btn_b
	end

	if SystemInfo:platform() == Idstring("WIN32") then
		btn_stick_r = stick_r
		btn_stick_l = stick_l
	end

	self:set_default_macro("BTN_BACK", btn_back)
	self:set_default_macro("BTN_START", btn_start)
	self:set_default_macro("BTN_A", btn_a)
	self:set_default_macro("BTN_B", btn_b)
	self:set_default_macro("BTN_X", btn_x)
	self:set_default_macro("BTN_Y", btn_y)
	self:set_default_macro("BTN_TOP_L", btn_top_l)
	self:set_default_macro("BTN_TOP_R", btn_top_r)
	self:set_default_macro("BTN_BOTTOM_L", btn_bottom_l)
	self:set_default_macro("BTN_BOTTOM_R", btn_bottom_r)
	self:set_default_macro("BTN_STICK_L", btn_stick_l)
	self:set_default_macro("BTN_STICK_R", btn_stick_r)
	self:set_default_macro("STICK_L", stick_l)
	self:set_default_macro("STICK_R", stick_r)
	self:set_default_macro("BTN_INTERACT", btn_interact)
	self:set_default_macro("BTN_USE_ITEM", btn_use_item)
	self:set_default_macro("BTN_PRIMARY", btn_primary)
	self:set_default_macro("BTN_SECONDARY", btn_secondary)
	self:set_default_macro("BTN_RELOAD", btn_reload)
	self:set_default_macro("BTN_JUMP", btn_jump)
	self:set_default_macro("BTN_SKILLSET", btn_x)
	self:set_default_macro("BTN_ACCEPT", btn_accept)
	self:set_default_macro("BTN_CANCEL", btn_cancel)
	self:set_default_macro("BTN_ATTACK", btn_attack)
	self:set_default_macro("BTN_BLOCK", btn_block)
	self:set_default_macro("CONTINUE", btn_a)
	self:set_default_macro("BTN_GADGET", btn_dpad_d)
	self:set_default_macro("BTN_BIPOD", btn_dpad_d)
	self:set_default_macro("BTN_INV_NEW", btn_inv_new)
	self:set_default_macro("BTN_GHOST", btn_ghost)
	self:set_default_macro("BTN_SKULL", btn_skull)
	self:set_default_macro("BTN_PADLOCK", btn_padlock)
	self:set_default_macro("BTN_SPREE_SHORT", btn_spree_short)
	self:set_default_macro("BTN_SPREE_MEDIUM", btn_spree_medium)
	self:set_default_macro("BTN_SPREE_LONG", btn_spree_long)
	self:set_default_macro("BTN_SPREE_TICKET", btn_spree_ticket)
	self:set_default_macro("BTN_CONTINENTAL_COINS", btn_continental_coins)
	self:set_default_macro("BTN_SPREE_STEALTH", btn_spree_stealth)
	self:set_default_macro("BTN_STAT_BOOST", btn_stat_boost)
	self:set_default_macro("BTN_TEAM_BOOST", btn_team_boost)
	self:set_default_macro("BTN_SWITCH_WEAPON", btn_y)
	self:set_default_macro("BTN_STATS_VIEW", btn_back)
	self:set_default_macro("BTN_RESET_SKILLS", btn_back)
	self:set_default_macro("BTN_RESET_ALL_SKILLS", btn_start)
	self:set_default_macro("BTN_CHANGE_EQ", btn_change_equipment)
	self:set_default_macro("BTN_CHANGE_PROFILE_RIGHT", btn_change_profile_right)
	self:set_default_macro("BTN_CHANGE_PROFILE_LEFT", btn_change_profile_left)

	self._input_translations.xbox360 = {
		a = btn_a,
		b = btn_b,
		x = btn_x,
		y = btn_y,
		back = btn_back,
		start = btn_start,
		left = stick_l,
		right = stick_r,
		left_shoulder = btn_bottom_l,
		right_shoulder = btn_bottom_r,
		left_trigger = btn_top_l,
		right_trigger = btn_top_r,
		left_thumb = btn_stick_l,
		right_thumb = btn_stick_r,
		d_up = btn_dpad_u,
		d_down = btn_dpad_d,
		d_left = btn_dpad_l,
		d_right = btn_dpad_r
	}
	self._input_translations.xb1 = table.map_copy(self._input_translations.xbox360)
	self._input_translations.ps3 = table.map_copy(self._input_translations.xbox360)

	table.map_append(self._input_translations.ps3, {
		cross = btn_a,
		circle = btn_b,
		square = btn_x,
		triangle = btn_y,
		r1_trigger = btn_top_r,
		l1_trigger = btn_top_l,
		l2_trigger = btn_bottom_l,
		r2_trigger = btn_bottom_r,
		select = btn_back
	})

	self._input_translations.ps4 = table.map_copy(self._input_translations.ps3)
end

local is_PS3 = SystemInfo:platform() == Idstring("PS3")

function LocalizationManager:btn_macro(button, to_upper, nil_if_empty)
	if not button then
		return
	end

	local type = managers.controller:get_default_wrapper_type()
	local key = managers.controller:get_settings(type):get_connection(button):get_input_name_list()[1]

	if nil_if_empty and not key then
		return
	end

	return self:key_to_btn_text(key, to_upper, type)
end

function LocalizationManager:key_to_btn_text(key, to_upper, type)
	if _G.IS_VR and not key then
		return ""
	end

	key = tostring(key)
	type = type or managers.controller:get_default_wrapper_type()
	local translations = self._input_translations[type]
	local res = translations and translations[key]

	if res then
		return to_upper and utf8.to_upper(res) or res
	elseif not managers.menu:is_pc_controller() then
		return
	end

	local text = "[" .. key .. "]"

	return to_upper and utf8.to_upper(text) or text
end

function LocalizationManager:ids(file)
	return Localizer:ids(Idstring(file))
end

function LocalizationManager:to_upper_text(string_id, macros)
	return utf8.to_upper(self:text(string_id, macros))
end

function LocalizationManager:steam_btn(button)
	return button
end

function LocalizationManager:debug_file(file)
	local t = {}
	local ids_in_file = self:ids(file)

	for i, ids in ipairs(ids_in_file) do
		local s = ids:s()
		local text = self:text(s, {
			BTN_INTERACT = self:btn_macro("interact")
		})
		t[s] = text
	end

	return t
end

function LocalizationManager:check_translation()
	local path = "g:/projects/payday2/trunk/assets/strings"
	local files = SystemFS:list(path)
	local p_files = {}
	local l_files = {}

	for i, file in ipairs(files) do
		local s_index = string.find(file, ".", 1, true)
		local e_index = string.find(file, ".", s_index + 1, true)
		local prename = string.sub(file, 1, s_index - 1)
		p_files[prename] = p_files[prename] or {}

		table.insert(p_files[prename], file)

		local language = not e_index and "english" or string.sub(file, s_index + 1, e_index - 1)
		l_files[language] = l_files[language] or {}

		table.insert(l_files[language], file)

		if e_index then
			-- Nothing
		end
	end

	local parsed = {}

	for language, files in pairs(l_files) do
		parsed[language] = parsed[language] or {}

		for _, file in ipairs(files) do
			for child in SystemFS:parse_xml(path .. "/" .. file):children() do
				parsed[language][child:parameter("id")] = child:parameter("value")
			end
		end
	end

	for language, ids in pairs(parsed) do
		if language ~= "english" then
			for id, value in pairs(ids) do
				if value == parsed.english[id] then
					print("same as english", language, id, value)
				end
			end
		end
	end
end

function LocalizationManager:set_input_translation(button_name, translation)
	self._input_translations[button_name] = translation
end

CoreClass.override_class(CoreLocalizationManager.LocalizationManager, LocalizationManager)
