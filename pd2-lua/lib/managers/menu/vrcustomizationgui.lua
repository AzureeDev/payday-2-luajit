require("lib/managers/HUDManager")
require("lib/managers/HUDManagerVR")
require("lib/utils/VRBodyCalibrator")

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local PADDING = 16
local OBJECT_LAYER = 100
local BG_LAYER = 0
local BG_LAYER1 = 1
local TEXT_LAYER = 50
local TEXT_LAYER1 = 51
VRGuiObject = VRGuiObject or class()

function VRGuiObject:init(panel, id, params)
	self._id = id
	self._panel = panel:panel({
		w = params.w,
		h = params.h,
		x = params.x,
		y = params.y,
		layer = OBJECT_LAYER
	})
	self._parent_menu = params.parent_menu
	self._enabled = true
	self._desc_data = params.desc_data
end

function VRGuiObject:id()
	return self._id
end

function VRGuiObject:parent_menu()
	return self._parent_menu
end

function VRGuiObject:set_enabled(enabled)
	self._enabled = enabled

	self._panel:set_visible(enabled)
end

function VRGuiObject:enabled()
	return self._enabled
end

function VRGuiObject:set_selected(selected)
	if self._selected == selected then
		return
	end

	self._selected = selected

	if selected then
		managers.menu:post_event("highlight")
	end

	return true
end

function VRGuiObject:moved(x, y)
end

function VRGuiObject:pressed(x, y)
end

function VRGuiObject:released(x, y)
end

function VRGuiObject:desc_data()
	return self._desc_data
end

local overrides = {
	"inside",
	"x",
	"y",
	"w",
	"h",
	"left",
	"right",
	"top",
	"bottom",
	"set_x",
	"set_y",
	"set_w",
	"set_h",
	"set_left",
	"set_right",
	"set_top",
	"set_bottom",
	"set_visible",
	"center_x",
	"center_y",
	"center",
	"set_center_x",
	"set_center_y",
	"set_center"
}

for _, func in ipairs(overrides) do
	VRGuiObject[func] = function (self, ...)
		return self._panel[func](self._panel, ...)
	end
end

local unselected_color = Color.black:with_alpha(0.5)
local selected_color = Color.black:with_alpha(0.7)
local text_padding = 8
VRButton = VRButton or class(VRGuiObject)

function VRButton:init(panel, id, params)
	params.w = params.w or 170
	params.h = params.h or 43

	VRButton.super.init(self, panel, id, params)

	self._bg = self._panel:rect({
		name = "bg",
		color = unselected_color
	})
	self._text = self._panel:text({
		font_size = 30,
		text = not params.skip_localization and managers.localization:to_upper_text(params.text_id) or params.text_id,
		font = tweak_data.menu.pd2_massive_font,
		x = text_padding,
		y = text_padding,
		layer = TEXT_LAYER
	})

	make_fine_text(self._text)

	if params.date_updated then
		local current_date = {
			tonumber(os.date("%Y")),
			tonumber(os.date("%m")),
			tonumber(os.date("%d"))
		}
		local date_value = current_date[1] * 12 * 30 + current_date[2] * 30 + current_date[3]
		local release_window = 30
		date_value = params.date_updated[1] * 12 * 30 + params.date_updated[2] * 30 + params.date_updated[3] - date_value

		if date_value >= -release_window then
			self._sub_panel = panel:panel({
				w = 100,
				h = params.w,
				x = params.x - 45,
				y = params.y + self._text:top(),
				layer = OBJECT_LAYER
			})
			local new_name = self._sub_panel:text({
				alpha = 1,
				vertical = "top",
				align = "left",
				halign = "left",
				valign = "top",
				text = managers.localization:to_upper_text("menu_new"),
				font = tweak_data.menu.pd2_large_font,
				font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
				color = Color(255, 105, 254, 59) / 255,
				layer = TEXT_LAYER + 1
			})

			make_fine_text(new_name)
		end
	end
end

function VRButton:set_selected(selected)
	if VRButton.super.set_selected(self, selected) then
		self._bg:set_color(selected and selected_color or unselected_color)
	end
end

function VRButton:set_text(text_id, skip_localization)
	self._text:set_text(not skip_localization and managers.localization:to_upper_text(text_id) or text_id)
	make_fine_text(self._text)
end

VRSlider = VRSlider or class(VRGuiObject)

function VRSlider:init(panel, id, params)
	params.w = params.w or 294
	params.h = params.h or 43

	VRSlider.super.init(self, panel, id, params)

	self._value = params.value or 0
	self._max = params.max or 1
	self._min = params.min or 0
	self._snap = params.snap or 1
	self._value_clbk = params.value_clbk
	self._line = self._panel:rect({
		h = 4,
		name = "line"
	})

	self._line:set_center_y(self._panel:h() / 2)

	self._mid_piece = self._panel:panel({
		w = 92,
		name = "mid_piece",
		layer = OBJECT_LAYER
	})

	self._mid_piece:set_center_x(self._panel:w() / 2)

	self._bg = self._mid_piece:rect({
		name = "bg",
		color = unselected_color
	})
	self._text = self._mid_piece:text({
		font_size = 30,
		text = tostring(math.floor(self._value)),
		font = tweak_data.menu.pd2_massive_font,
		layer = TEXT_LAYER
	})

	make_fine_text(self._text)
	self._text:set_center(self._mid_piece:w() / 2, self._mid_piece:h() / 2)
	self:_update_position()
end

function VRSlider:value()
	return self._value
end

function VRSlider:value_ratio()
	return (self._value - self._min) / (self._max - self._min)
end

function VRSlider:value_from_ratio(ratio)
	return math.clamp((self._max - self._min) * ratio + self._min, self._min, self._max)
end

function VRSlider:set_value(value)
	self._value = math.clamp(value, self._min, self._max)

	self:set_text(math.floor(self._value))
	self:_update_position()
end

function VRSlider:_update_position()
	local value_ratio = self:value_ratio()
	local w = self._panel:w() - self._mid_piece:w()

	self._mid_piece:set_center_x(value_ratio * w + self._mid_piece:w() / 2)
end

function VRSlider:set_selected(selected)
	if VRButton.super.set_selected(self, selected) then
		self._bg:set_color(selected and selected_color or unselected_color)
	end
end

function VRSlider:set_text(text)
	self._text:set_text(tostring(text))
	make_fine_text(self._text)
	self._text:set_center_x(self._mid_piece:w() / 2)
end

function VRSlider:pressed(x, y)
	if not self._selected then
		return
	end

	self._start_x = x
	self._start_ratio = self:value_ratio()
	self._pressed = true
end

function VRSlider:released(x, y)
	if self._pressed and self._value_clbk then
		self._value_clbk(self._value)
	end

	self._pressed = nil
end

function VRSlider:moved(x, y)
	if self._pressed then
		local diff = x - self._start_x
		local diff_ratio = diff / (self._panel:w() - self._mid_piece:w())

		if self._snap <= math.abs(diff_ratio) * self._max then
			self:set_value(math.floor(self:value_from_ratio(diff_ratio + self._start_ratio) / self._snap) * self._snap)

			self._start_ratio = self:value_ratio()
			self._start_x = self._panel:world_x() + self._mid_piece:w() / 2 + (self._panel:w() - self._mid_piece:w()) * self._start_ratio
		end
	end
end

VRSettingButton = VRSettingButton or class(VRGuiObject)

function VRSettingButton:init(panel, id, params)
	if not params.setting then
		Application:error("Tried to add a setting button without a setting!")
	end

	params.w = params.w or 170
	params.h = params.h or 43

	VRSettingButton.super.init(self, panel, id, params)

	self._bg = self._panel:rect({
		name = "bg",
		halign = "scale",
		color = unselected_color
	})
	local w = text_padding
	local last_text = nil
	self._option_texts = {}
	params.options = params.options or {
		true,
		false
	}

	for _, option in ipairs(params.options) do
		local x = (last_text and last_text:right() + text_padding or 0) + text_padding
		local text_id, skip_localization = self:_get_setting_text(option)
		local text = self._panel:text({
			font_size = 30,
			text = not skip_localization and managers.localization:to_upper_text(text_id) or text_id,
			font = tweak_data.menu.pd2_massive_font,
			x = x,
			y = text_padding,
			layer = TEXT_LAYER
		})

		make_fine_text(text)

		self._option_texts[tostring(option)] = text
		last_text = text
		w = w + text:w() + text_padding * 2
	end

	if w < params.w and #params.options == 2 then
		local center = self:center_x()

		self._option_texts[tostring(params.options[1])]:set_right(center - text_padding)
		self._option_texts[tostring(params.options[2])]:set_x(center + text_padding)
	end

	w = math.max(w, params.w)

	self:set_w(w)

	self._setting = params.setting

	self:setting_changed()
end

function VRSettingButton:_get_setting_text(value)
	if type(value) == "boolean" then
		return value and "menu_vr_on" or "menu_vr_off"
	elseif type(value) == "number" then
		return tostring(value), true
	else
		return "menu_vr_" .. tostring(value)
	end
end

function VRSettingButton:setting_changed()
	local new_value = managers.vr:get_setting(self._setting)

	for option, text in pairs(self._option_texts) do
		text:set_alpha(option == tostring(new_value) and 1 or 0.5)
	end

	self._parent_menu:update_desc()
end

function VRSettingButton:set_selected(selected)
	if VRButton.super.set_selected(self, selected) then
		self._bg:set_color(selected and selected_color or unselected_color)
	end
end

function VRSettingButton:desc_data()
	if self._desc_data and self._desc_data.use_setting then
		local ret = clone(self._desc_data)
		local value = managers.vr:get_setting(self._setting)
		ret.text_id = self._desc_data.text_id .. "_" .. tostring(value)

		return ret
	else
		return self._desc_data
	end
end

VRSettingSlider = VRSettingSlider or class(VRSlider)

function VRSettingSlider:init(panel, id, params)
	if not params.setting then
		Application:error("Tried to add a setting slider without a setting!")
	end

	params.value = managers.vr:get_setting(params.setting)
	params.value_clbk = params.value_clbk or function (value)
		managers.vr:set_setting(params.setting, value)
	end
	params.min, params.max = managers.vr:setting_limits(params.setting)

	if not params.max then
		Application:error("Tried to add a setting slider without limits: " .. params.setting)
	end

	VRSettingSlider.super.init(self, panel, id, params)

	self._setting = params.setting
end

function VRSettingSlider:setting_changed()
	local new_value = managers.vr:get_setting(self._setting)

	self:set_value(new_value)
end

VRSettingTrigger = VRSettingTrigger or class(VRButton)

function VRSettingTrigger:init(panel, id, params)
	VRSettingTrigger.super.init(self, panel, id, params)

	self._setting = params.setting
	self._change_clbk = params.change_clbk
end

function VRSettingTrigger:setting_changed()
	if self._change_clbk then
		self:_change_clbk(managers.vr:get_setting(self._setting))
	end
end

VRMenu = VRMenu or class()

function VRMenu:init()
	self._buttons = {}
	self._button_sets = {
		main = {}
	}
	self._sub_menus = {}
	self._objects = {}
end

function VRMenu:set_selected(index)
	if self._selected and self._selected ~= index then
		self._buttons[self._selected].button:set_selected(false)
	end

	if index then
		self._buttons[index].button:set_selected(true)
	end

	self._selected = index
end

function VRMenu:selected()
	return self._selected and self._buttons[self._selected]
end

function VRMenu:mouse_moved(o, x, y)
	if self:enabled() then
		local selected = nil

		for i, button in ipairs(self._buttons) do
			if button.button:inside(x, y) and button.button:enabled() then
				selected = i
			end

			button.button:moved(x, y)
		end

		self:set_selected(selected)
	end

	if self._open_menu then
		self._open_menu:mouse_moved(o, x, y)
	end
end

function VRMenu:mouse_pressed(o, button, x, y)
	if button ~= Idstring("0") then
		return
	end

	if self:enabled() then
		for _, button in ipairs(self._buttons) do
			button.button:pressed(x, y)
		end
	end

	if self._open_menu then
		self._open_menu:mouse_pressed(o, button, x, y)
	end
end

function VRMenu:mouse_released(o, button, x, y)
	if button ~= Idstring("0") then
		return
	end

	if self:enabled() then
		for _, button in ipairs(self._buttons) do
			button.button:released(x, y)
		end
	end

	if self._open_menu then
		self._open_menu:mouse_released(o, button, x, y)
	end
end

function VRMenu:mouse_clicked(o, button, x, y)
	if self:enabled() and self:selected() and self:selected().clbk then
		self:selected().clbk(self:selected().button)
		managers.menu:post_event("menu_enter")
	end

	if self._open_menu then
		self._open_menu:mouse_clicked(o, button, x, y)
	end
end

function VRMenu:add_object(id, obj)
	self._objects[id] = obj
end

function VRMenu:remove_object(id)
	if self._objects[id].destroy then
		self._objects[id]:destroy()
	end

	self._objects[id] = nil
end

function VRMenu:object(id)
	return self._objects[id]
end

function VRMenu:clear_objects()
	for id in pairs(self._objects) do
		self:remove_object(id)
	end
end

function VRMenu:update(t, dt)
	for id, obj in pairs(self._objects) do
		obj:update(t, dt)
	end
end

function VRMenu:set_enabled(enabled)
	if not enabled then
		self:set_selected(nil)
	end

	self._enabled = enabled
end

function VRMenu:enabled()
	return self._enabled
end

VRSubMenu = VRSubMenu or class(VRMenu)

function VRSubMenu:init(parent, panel, id)
	VRSubMenu.super.init(self)

	self._parent = parent
	self._id = id
	self._enabled = false
	self._panel = panel:panel({
		visible = false,
		layer = OBJECT_LAYER
	})
	local title_text = managers.localization:to_upper_text("menu_vr_settings") .. ": " .. managers.localization:to_upper_text("menu_vr_open_" .. id)
	self._title = self._panel:text({
		name = "title",
		font_size = 48,
		text = title_text,
		font = tweak_data.menu.pd2_massive_font,
		x = PADDING * 5,
		y = PADDING * 5,
		layer = TEXT_LAYER
	})

	make_fine_text(self._title)
end

function VRSubMenu:add_desc(desc_data)
	self:clear_desc()

	self._desc_panel = self._panel:panel({
		w = 512,
		x = self._panel:w() / 2 + PADDING
	})
	local desc = desc_data.text_id
	local title = desc .. "_title"

	if desc_data.oculus and managers.vr:is_oculus() then
		desc = desc .. "_oculus"
	end

	local desc_title = self._desc_panel:text({
		font_size = 32,
		text = managers.localization:to_upper_text(title),
		font = tweak_data.menu.pd2_large_font,
		y = self._title:bottom() + PADDING,
		layer = TEXT_LAYER
	})

	make_fine_text(desc_title)

	local desc = self._desc_panel:text({
		word_wrap = true,
		wrap = true,
		font_size = 22,
		text = managers.localization:to_upper_text(desc),
		font = tweak_data.menu.pd2_large_font,
		y = desc_title:bottom() + PADDING,
		layer = TEXT_LAYER
	})

	make_fine_text(desc)

	local desc_image = desc_data.image and self._desc_panel:bitmap({
		texture = desc_data.image,
		y = desc:bottom() + PADDING,
		layer = OBJECT_LAYER
	})
end

function VRSubMenu:clear_desc()
	if alive(self._desc_panel) then
		self._panel:remove(self._desc_panel)

		self._desc_panel = nil
	end
end

function VRSubMenu:setting(id)
	return self._settings and self._settings[id]
end

function VRSubMenu:add_setting(type, text_id, setting, params)
	local y_offset = self._title:bottom() + PADDING
	self._settings = self._settings or {}
	local num_settings = table.size(self._settings)
	params = params or {}
	local setting_text = self._panel:text({
		font_size = 32,
		text = managers.localization:to_upper_text(text_id),
		font = tweak_data.menu.pd2_large_font,
		x = PADDING * 5,
		y = num_settings * (32 + PADDING) + y_offset
	})
	local setting_item, clbk = nil

	if type == "button" then
		setting_item = VRSettingButton:new(self._panel, setting, table.map_append({
			setting = setting,
			parent_menu = self
		}, params))

		function clbk(btn)
			local new_value = not managers.vr:get_setting(setting)

			managers.vr:set_setting(setting, new_value)
			btn:setting_changed()

			if params.clbk then
				params.clbk(new_value)
			end
		end
	elseif type == "slider" then
		local function clbk(value)
			managers.vr:set_setting(setting, value)
		end

		setting_item = VRSettingSlider:new(self._panel, setting, table.map_append({
			setting = setting,
			parent_menu = self
		}, params))
	elseif type == "multi_button" then
		if not params.options then
			Application:error("Tried to add a multi_button setting without options: " .. setting)

			params.options = {
				"error"
			}
		end

		local option_count = #params.options
		setting_item = VRSettingButton:new(self._panel, setting, table.map_append({
			setting = setting,
			parent_menu = self
		}, params))

		function clbk(btn)
			local current_index = table.index_of(params.options, managers.vr:get_setting(setting))
			local new_index = current_index % option_count + 1
			local new_value = params.options[new_index]

			managers.vr:set_setting(setting, new_value)
			btn:setting_changed()

			if params.clbk then
				params.clbk(new_value)
			end
		end
	elseif type == "trigger" then
		params.text_id = params.trigger_text_id
		setting_item = VRSettingTrigger:new(self._panel, setting, table.map_append({
			setting = setting,
			parent_menu = self
		}, params))

		function clbk(btn)
			local value = params.value_clbk(btn)

			managers.vr:set_setting(setting, value)
		end
	end

	setting_item:set_y(setting_text:y())
	setting_item:set_right(self._panel:w() / 2 - PADDING)
	setting_text:set_w(self._panel:w() - setting_item:w() - PADDING * 2)
	make_fine_text(setting_text)
	table.insert(self._buttons, {
		button = setting_item,
		clbk = clbk,
		custom_params = {
			x = setting_item:x(),
			y = setting_item:y()
		}
	})

	self._settings[setting] = {
		text = setting_text,
		button = setting_item
	}
end

function VRSubMenu:set_setting_enabled(setting, enabled)
	local item = self:setting(setting)

	if item then
		item.text:set_visible(enabled)
		item.button:set_visible(enabled)
		item.button:set_enabled(enabled)
	end
end

function VRSubMenu:add_button_set(id, text_id, buttons)
	local y_offset = self._title:bottom() + PADDING
	self._settings = self._settings or {}
	local num_settings = table.size(self._settings)
	local set_text = self._panel:text({
		font_size = 32,
		text = managers.localization:to_upper_text(text_id),
		font = tweak_data.menu.pd2_large_font,
		x = PADDING * 5,
		y = num_settings * (32 + PADDING) + y_offset
	})
	local button_set = {}
	self._button_sets[id] = button_set
	local start_x = self._panel:w() / 2

	for _, btn_data in ipairs(buttons) do
		local btn = self:add_button(btn_data.id, btn_data.text, btn_data.clbk, table.map_append({
			set = id,
			y = set_text:y(),
			start_x = start_x
		}, btn_data.params))

		if btn_data.enabled ~= nil then
			btn:set_enabled(btn_data.enabled)
		end
	end

	self._settings[id] = {
		text = set_text,
		buttons = button_set
	}
end

function VRSubMenu:add_button(id, text, clbk, custom_params)
	custom_params = custom_params or {}
	local buttons = custom_params.set and self._button_sets[custom_params.set] or self._button_sets.main
	local button = VRButton:new(self._panel, id, table.map_append({
		text_id = text,
		parent_menu = self
	}, custom_params))
	local start_x = custom_params.start_x or self._panel:w()

	button:set_x(custom_params.x or (buttons[#buttons] and buttons[#buttons].button:left() or start_x) - button:w() - PADDING)
	button:set_y(custom_params.y or self._panel:h() - button:h() - PADDING)

	local button_data = {
		button = button,
		clbk = clbk,
		custom_params = custom_params
	}

	table.insert(buttons, button_data)
	table.insert(self._buttons, button_data)

	return button
end

function VRSubMenu:set_button_enabled(id, enabled)
	for _, button in ipairs(self._buttons) do
		if button.button:id() == id then
			button.button:set_enabled(enabled)
		end
	end

	self:layout_buttons()
end

function VRSubMenu:layout_buttons()
	for _, button_set in pairs(self._button_sets) do
		local last_x = nil

		for _, button in ipairs(button_set) do
			last_x = last_x or button.custom_params.start_x or self._panel:w()

			if button.button:enabled() and not button.custom_params.x then
				button.button:set_x(last_x - button.button:w() - PADDING)

				last_x = button.button:x()
			end
		end
	end
end

function VRSubMenu:add_image(params)
	if not params or not params.texture then
		Application:error("[VRSubMenu:add_image] tried to add missing image!")

		return
	end

	local image = self._panel:bitmap({
		texture = params.texture,
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h
	})

	if params.fit then
		if params.fit == "height" then
			local h = self._panel:h()
			local dh = h / image:texture_height()

			image:set_size(image:texture_width() * dh, h)
		elseif params.fit == "width" then
			local w = self._panel:w()
			local dw = w / image:texture_width()

			image:set_size(w, image:texture_height() * dw)
		else
			image:set_size(self._panel:w(), self._panel:h())
		end
	end
end

function VRSubMenu:id()
	return self._id
end

function VRSubMenu:add_back_button()
	self:add_button("back", "menu_vr_back", callback(self._parent, self._parent, "close_sub_menu"))
end

function VRSubMenu:set_enabled_clbk(clbk)
	self._enabled_clbk = clbk
end

function VRSubMenu:set_enabled(enabled)
	if self._enabled_clbk then
		self:_enabled_clbk(enabled)
	end

	VRSubMenu.super.set_enabled(self, enabled)
	self._panel:set_visible(enabled)
end

function VRSubMenu:set_selected(index)
	local prev_selection = self._selected

	VRSubMenu.super.set_selected(self, index)

	if self._selected and prev_selection ~= self._selected then
		self:update_desc()
	end
end

function VRSubMenu:update_desc()
	if not self._selected then
		return
	end

	local button = self._buttons[self._selected]
	local desc_data = button.button:desc_data()

	if desc_data then
		self:add_desc(desc_data)
	end
end

VRCustomizationGui = VRCustomizationGui or class(VRMenu)

function VRCustomizationGui:init(is_start_menu)
	VRCustomizationGui.super.init(self)

	self._is_start_menu = is_start_menu
	self._ws = managers.gui_data:create_fullscreen_workspace("left")

	managers.menu:player():register_workspace({
		ws = self._ws,
		activate = callback(self, self, "activate"),
		deactivate = callback(self, self, "deactivate")
	})

	self._id = "vr_customization"

	if not is_start_menu then
		self:initialize()
	else
		self._ws:hide()
	end
end

function VRCustomizationGui:_calibrate_height()
	local hmd_pos = VRManager:hmd_position()

	managers.vr:set_setting("height", hmd_pos.z)
end

function VRCustomizationGui:initialize()
	if not self._initialized then
		self:_setup_gui()
		managers.vr:show_notify_procedural_animation()

		if not managers.vr:has_set_height() then
			managers.menu:show_vr_settings_dialog({
				ok_func = callback(self, self, "_calibrate_height")
			})
		end

		self._ws:show()

		self._initialized = true
	end
end

function VRCustomizationGui:_setup_gui()
	if alive(self._panel) then
		self._panel:clear()
	end

	self._panel = self._ws:panel():panel({
		layer = BG_LAYER
	})
	self._main_buttons_panel = self._panel:panel({
		w = 342,
		name = "main_buttons"
	})
	self._buttons = {}
	self._bg = self._panel:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/bg",
		name = "bg"
	})
	local h = self._panel:h()
	local dh = h / self._bg:texture_height()

	self._bg:set_size(self._bg:texture_width() * dh, h)

	local title_text = managers.localization:to_upper_text("menu_vr_settings")
	self._title = self._panel:text({
		name = "title",
		font_size = 48,
		text = title_text,
		font = tweak_data.menu.pd2_massive_font,
		x = PADDING * 5,
		y = PADDING * 5,
		layer = TEXT_LAYER
	})

	make_fine_text(self._title)
	self:_setup_sub_menus()

	local controls_image_paths = {
		touch_dash_walk = "guis/dlcs/vr/textures/pd2/menu_controls_touch_dash_walk",
		vive_dash_walk = "guis/dlcs/vr/textures/pd2/menu_controls_vive_dash_walk",
		touch_dash = "guis/dlcs/vr/textures/pd2/menu_controls_touch_dash",
		vive_dash = "guis/dlcs/vr/textures/pd2/menu_controls_vive_dash"
	}
	self._controls_images = {}

	for key, path in pairs(controls_image_paths) do
		local controls_image = self._panel:bitmap({
			texture = path,
			x = self._panel:w() * 0.2 + PADDING,
			y = PADDING,
			layer = BG_LAYER1
		})
		local h = self._panel:h() - PADDING * 2
		local dh = h / controls_image:texture_height()

		controls_image:set_size(controls_image:texture_width() * dh, h)
		controls_image:set_visible(false)

		self._controls_images[key] = controls_image
	end

	local calibration_steps = {
		"guis/dlcs/vr/textures/pd2/menu_controls_vive_calibrate_01",
		"guis/dlcs/vr/textures/pd2/menu_controls_vive_calibrate_02",
		"guis/dlcs/vr/textures/pd2/menu_controls_vive_calibrate_03"
	}
	self._calibration_step_images = {}

	for _, path in ipairs(calibration_steps) do
		local image = self._panel:bitmap({
			visible = false,
			h = 720,
			y = 0,
			w = 720,
			x = 0,
			texture = path,
			layer = BG_LAYER1
		})
		local width = image:width()

		image:set_x((self._panel:w() - width) * 0.5)

		local height = image:height()

		image:set_y((self._panel:h() - height) * 0.5 + 20)
		table.insert(self._calibration_step_images, image)
	end

	self:_show_main()
end

function VRCustomizationGui:show_calibration_step(step)
	for i, image in ipairs(self._calibration_step_images) do
		image:set_visible(i == step)
	end
end

function VRCustomizationGui:_hide_main()
	self._main_buttons_panel:set_visible(false)

	for _, image in pairs(self._controls_images) do
		image:set_visible(false)
	end

	self:set_enabled(false)
end

function VRCustomizationGui:_show_main()
	self._main_buttons_panel:set_visible(true)

	local image_key = nil
	local movement_type = managers.vr:get_setting("movement_type") or "warp"

	if managers.vr:is_oculus() then
		if movement_type == "warp_walk" then
			image_key = "touch_dash_walk"
		else
			image_key = "touch_dash"
		end
	elseif movement_type == "warp_walk" then
		image_key = "vive_dash_walk"
	else
		image_key = "vive_dash"
	end

	for key, image in pairs(self._controls_images) do
		image:set_visible(image_key == key)
	end

	self:set_enabled(true)
end

function VRCustomizationGui:_setup_sub_menus()
	self._sub_menus = {}
	self._open_menu = nil
	local is_start_menu = self._is_start_menu

	self:add_settings_menu("interface", {
		{
			setting = "height",
			type = "trigger",
			text_id = "menu_vr_set_height",
			params = {
				trigger_text_id = "menu_vr_calibrate",
				value_clbk = function (btn)
					managers.system_menu:close("vr_settings")

					local hmd_pos = VRManager:hmd_position()

					return hmd_pos.z
				end,
				clbk = function (new_setting)
					local hmd_pos = VRManager:hmd_position()

					managers.vr:set_setting("height", hmd_pos.z)
				end,
				desc_data = {
					text_id = "menu_vr_height_desc"
				}
			}
		},
		{
			setting = "belt_snap",
			type = "slider",
			text_id = "menu_vr_belt_snap",
			params = {
				snap = 15,
				desc_data = {
					text_id = "menu_vr_belt_snap_desc"
				}
			}
		},
		{
			id = "belt_settings",
			text_id = "menu_vr_belt_settings",
			buttons = {
				{
					text = "menu_vr_belt_reset_grid",
					enabled = false,
					id = "reset_grid",
					clbk = function (btn)
						local belt = btn:parent_menu():object("belt")

						if belt then
							belt:reset_grid()
						end
					end,
					params = {
						desc_data = {
							text_id = "menu_vr_belt_layout_desc"
						}
					}
				},
				{
					text = "menu_vr_belt_grid_mode",
					id = "grid_mode",
					clbk = function (btn)
						local belt = btn:parent_menu():object("belt")

						if belt then
							belt:set_mode("grid")
							btn:parent_menu():set_button_enabled("save_grid", true)
							btn:parent_menu():set_button_enabled("reset_grid", true)
							btn:parent_menu():set_button_enabled("grid_mode", false)
							btn:parent_menu():set_button_enabled("reset_belt", false)
						end
					end,
					params = {
						desc_data = {
							text_id = "menu_vr_belt_layout_desc"
						}
					}
				},
				{
					text = "menu_vr_belt_save_grid",
					enabled = false,
					id = "save_grid",
					clbk = function (btn)
						local belt = btn:parent_menu():object("belt")

						if belt then
							belt:save_grid()
							belt:set_mode("adjuster")
							btn:parent_menu():set_button_enabled("save_grid", false)
							btn:parent_menu():set_button_enabled("reset_grid", false)
							btn:parent_menu():set_button_enabled("grid_mode", true)
							btn:parent_menu():set_button_enabled("reset_belt", true)
						end
					end,
					params = {
						desc_data = {
							text_id = "menu_vr_belt_layout_desc"
						}
					}
				}
			}
		}
	}, function (menu, enabled)
		if enabled then
			if not menu:object("belt") then
				menu:add_object("belt", VRBeltCustomization:new(is_start_menu))
			end

			menu:set_button_enabled("save_grid", false)
			menu:set_button_enabled("reset_grid", false)
			menu:set_button_enabled("grid_mode", true)
		elseif menu:object("belt") then
			menu:remove_object("belt")
		end
	end)
	self:add_settings_menu("gameplay", {
		{
			setting = "auto_reload",
			type = "button",
			text_id = "menu_vr_auto_reload_text",
			params = {
				desc_data = {
					text_id = "menu_vr_auto_reload_desc"
				}
			}
		},
		{
			setting = "default_weapon_hand",
			type = "multi_button",
			text_id = "menu_vr_default_weapon_hand",
			params = {
				options = {
					"left",
					"right"
				},
				clbk = function (value)
					managers.menu:set_primary_hand(value)
				end,
				desc_data = {
					text_id = "menu_vr_default_weapon_hand_desc"
				}
			}
		},
		{
			setting = "default_tablet_hand",
			type = "multi_button",
			text_id = "menu_vr_default_tablet_hand",
			params = {
				options = {
					"left",
					"right"
				},
				desc_data = {
					text_id = "menu_vr_default_tablet_hand_desc"
				}
			}
		},
		{
			setting = "weapon_precision_mode",
			type = "button",
			text_id = "menu_vr_weapon_precision_mode",
			params = {
				desc_data = {
					text_id = "menu_vr_weapon_precision_mode_desc"
				}
			}
		},
		{
			type = "multi_button",
			setting = "rotate_player_angle",
			text_id = "menu_vr_rotate_player_angle",
			visible = function ()
				return managers.vr:is_oculus()
			end,
			params = {
				options = {
					45,
					90
				},
				desc_data = {
					text_id = "menu_vr_rotate_player_angle_desc"
				}
			}
		},
		{
			setting = "keep_items_in_hand",
			type = "button",
			text_id = "menu_vr_keep_items_in_hand",
			params = {
				desc_data = {
					text_id = "menu_vr_keep_items_in_hand_desc"
				}
			}
		}
	})
	self:add_settings_menu("controls", {
		{
			setting = "movement_type",
			type = "multi_button",
			text_id = "menu_vr_movement_type",
			params = {
				options = {
					"warp",
					"warp_walk"
				},
				desc_data = {
					oculus = true,
					use_setting = true,
					text_id = "menu_vr_movement_type_desc"
				}
			}
		},
		{
			type = "slider",
			setting = "warp_zone_size",
			text_id = "menu_vr_warp_zone_size",
			visible = function ()
				return managers.vr:is_default_hmd()
			end,
			params = {
				snap = 5,
				desc_data = {
					text_id = "menu_vr_warp_zone_size_desc"
				}
			}
		},
		{
			setting = "dead_zone_size",
			type = "slider",
			text_id = "menu_vr_dead_zone_size",
			params = {
				snap = 5,
				desc_data = {
					oculus = true,
					text_id = "menu_vr_dead_zone_size_desc"
				}
			}
		},
		{
			setting = "enable_dead_zone_warp",
			type = "button",
			text_id = "menu_vr_enable_dead_zone_warp",
			params = {
				desc_data = {
					text_id = "menu_vr_enable_dead_zone_warp_desc"
				}
			}
		},
		{
			setting = "autowarp_length",
			type = "multi_button",
			text_id = "menu_vr_autowarp_length",
			params = {
				options = {
					"off",
					"long",
					"short"
				},
				desc_data = {
					oculus = true,
					text_id = "menu_vr_autowarp_length_desc"
				}
			}
		},
		{
			setting = "grip_toggle",
			type = "button",
			text_id = "menu_vr_grip_toggle",
			params = {
				desc_data = {
					text_id = "menu_vr_enable_grip_toggle_desc"
				}
			}
		}
	})
	self:add_settings_menu("arm_animation", {
		{
			setting = "arm_length",
			type = "slider",
			text_id = "menu_vr_arm_length",
			params = {
				snap = 1,
				desc_data = {
					text_id = "menu_vr_arm_length_desc"
				}
			}
		},
		{
			setting = "head_to_shoulder",
			type = "slider",
			text_id = "menu_vr_head_to_shoulder",
			params = {
				snap = 1,
				desc_data = {
					text_id = "menu_vr_head_to_shoulder_desc"
				}
			}
		},
		{
			setting = "shoulder_width",
			type = "slider",
			text_id = "menu_vr_shoulder_width",
			params = {
				snap = 1,
				desc_data = {
					text_id = "menu_vr_shoulder_width_desc"
				}
			}
		},
		{
			id = "menu_vr_calibrate_body",
			text_id = "menu_vr_calibrate_body",
			buttons = {
				{
					text = "menu_vr_start_calibrate",
					enabled = true,
					id = "calibrate",
					clbk = function (btn)
						self:open_sub_menu("arm_animation_calibrate")
					end,
					params = {
						w = 200,
						desc_data = {
							text_id = "menu_vr_calibrate_body_desc"
						}
					}
				}
			}
		},
		{
			setting = "arm_animation",
			type = "button",
			text_id = "menu_vr_arm_animation",
			params = {
				desc_data = {
					text_id = "menu_vr_arm_animation_desc"
				}
			}
		},
		date_updated = {
			2019,
			1,
			16
		}
	}, function (menu, enabled)
		if enabled then
			for _, menu in pairs(self._sub_menus) do
				if menu._settings then
					for setting, item in pairs(menu._settings) do
						if item.button then
							item.button:setting_changed()
						end
					end
				end
			end
		end
	end)

	local calibrate_menu = self:add_sub_menu("arm_animation_calibrate", function (menu, enabled)
	end)

	calibrate_menu:add_object("calibrator", VRCalibrator:new(self, calibrate_menu, function (succeeded)
		self:open_sub_menu("arm_animation")
	end))
	calibrate_menu:add_button("back", "menu_vr_back", function ()
		self:open_sub_menu("arm_animation")
	end)
	calibrate_menu:set_enabled_clbk(function (menu, enabled)
		if enabled then
			calibrate_menu:object("calibrator"):start()
		else
			calibrate_menu:object("calibrator"):stop()
		end
	end)
	self:add_settings_menu("advanced", {
		{
			setting = "zipline_screen",
			type = "button",
			text_id = "menu_vr_zipline_screen",
			params = {
				desc_data = {
					text_id = "menu_vr_zipline_screen_desc"
				}
			}
		},
		{
			setting = "fadeout_type",
			type = "multi_button",
			text_id = "menu_vr_fadeout_type",
			params = {
				options = {
					"fadeout_instant",
					"fadeout_smooth",
					"fadeout_stepped"
				},
				desc_data = {
					use_setting = true,
					text_id = "menu_vr_fadeout_type_desc"
				}
			}
		},
		{
			setting = "collision_instant_teleport",
			type = "button",
			text_id = "menu_vr_collision_instant_teleport",
			params = {
				desc_data = {
					text_id = "menu_vr_collision_instant_teleport_desc"
				}
			}
		}
	})
end

function VRCustomizationGui:sub_menu(id)
	return self._sub_menus[id]
end

function VRCustomizationGui:add_settings_menu(id, settings, clbk)
	local menu = VRSubMenu:new(self, self._panel, id)

	menu:set_enabled_clbk(clbk)
	menu:add_back_button()
	menu:add_button("reset_" .. id, "menu_vr_reset_all", function ()
		for setting, item in pairs(menu._settings) do
			managers.vr:reset_setting(setting)

			if item.button then
				item.button:setting_changed()
			end
		end

		for _, setting in ipairs(settings) do
			if setting.params and setting.params.clbk then
				setting.params.clbk(managers.vr:get_setting(setting.setting))
			end
		end

		for _, object in pairs(menu._objects) do
			if object.reset then
				object:reset()
			end
		end
	end)

	for _, setting in ipairs(settings) do
		local visible = setting.visible == nil
		visible = visible or (type(setting.visible) ~= "function" or setting.visible()) and not not setting.visible

		if visible then
			if setting.setting then
				menu:add_setting(setting.type, setting.text_id, setting.setting, setting.params)
			elseif setting.buttons then
				menu:add_button_set(setting.id, setting.text_id, setting.buttons)
			else
				local btn = menu:add_button(setting.id, setting.text, setting.clbk, setting.params)

				if setting.enabled ~= nil then
					btn:set_enabled(setting.enabled)
				end
			end
		end
	end

	self._sub_menus[id] = menu

	self:add_menu_button(id, settings.date_updated)
end

function VRCustomizationGui:add_sub_menu(id, clbk)
	local menu = VRSubMenu:new(self, self._panel, id)

	menu:set_enabled_clbk(clbk)

	self._sub_menus[id] = menu

	return menu
end

function VRCustomizationGui:add_image_menu(id, params, clbk)
	local menu = VRSubMenu:new(self, self._panel, id)

	menu:set_enabled_clbk(clbk)
	menu:add_image(params)

	self._sub_menus[id] = menu

	self:add_menu_button(id)
end

function VRCustomizationGui:open_sub_menu(id)
	self:close_sub_menu()
	self:_hide_main()

	if not self._sub_menus[id] then
		Application:error("No sub menu named " .. tostring(id) .. " exists")
	end

	self._open_menu = self._sub_menus[id]

	self._open_menu:set_enabled(true)
end

function VRCustomizationGui:close_sub_menu()
	if self._open_menu then
		self._open_menu:set_enabled(false)

		self._open_menu = nil

		self:_show_main()
	end
end

function VRCustomizationGui:add_menu_button(id, date_updated)
	local x = PADDING * 5
	local last_y = self._buttons[#self._buttons] and self._buttons[#self._buttons].button:bottom() or self._title:bottom() + PADDING
	local y = last_y + PADDING
	local button = VRButton:new(self._main_buttons_panel, id, {
		text_id = "menu_vr_open_" .. id,
		x = x,
		y = y,
		date_updated = date_updated
	})

	table.insert(self._buttons, {
		button = button,
		clbk = callback(self, self, "open_sub_menu", id)
	})
end

function VRCustomizationGui:update(t, dt)
	if self._open_menu then
		self._open_menu:update(t, dt)
	end
end

function VRCustomizationGui:activate()
	local clbks = {
		mouse_move = callback(self, self, "mouse_moved"),
		mouse_click = callback(self, self, "mouse_clicked"),
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_released"),
		id = self._id
	}

	managers.mouse_pointer:use_mouse(clbks)

	self._active = true
end

function VRCustomizationGui:deactivate()
	managers.mouse_pointer:remove_mouse(self._id)

	self._active = false
end

function VRCustomizationGui:exit_menu()
	for _, menu in pairs(self._sub_menus) do
		menu:clear_objects()
	end

	if self._active then
		self:deactivate()
	end

	self:_setup_gui()
end

VRBeltAdjuster = VRBeltAdjuster or class()

function VRBeltAdjuster:init(scene, belt, params)
	local offset = params.offset or Vector3()
	local up = params.up or math.Z
	self._obj = belt:orientation_object()
	offset = offset:rotate_with(self._obj:rotation())

	if params.horizontal then
		self._ws = scene:gui():create_linked_workspace(512, 128, self._obj, belt:position() + offset, math.X * 40, -up * 10)
	else
		self._ws = scene:gui():create_linked_workspace(256, 300, self._obj, belt:position() + offset, math.X * 20, -up * 24.5)
	end

	local panel = self._ws:panel()
	self._up_arrow = panel:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/icon_belt_arrow",
		name = "up_arrow",
		texture_rect = {
			128,
			0,
			128,
			128
		}
	})

	if params.horizontal then
		self._up_arrow:set_right(panel:w())
		self._up_arrow:set_rotation(90)
	else
		self._up_arrow:set_center_x(panel:w() / 2)
	end

	self._down_arrow = panel:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/icon_belt_arrow",
		name = "down_arrow",
		rotation = 180,
		texture_rect = {
			128,
			0,
			128,
			128
		}
	})

	if params.horizontal then
		self._down_arrow:set_rotation(-90)
	else
		self._down_arrow:set_center_x(panel:w() / 2)
		self._down_arrow:set_bottom(panel:h())
	end

	self._text_id = params.text_id
	self._text = panel:text({
		name = "text",
		text = managers.localization:to_upper_text(self._text_id),
		font = tweak_data.hud.medium_font_noshadow,
		font_size = tweak_data.hud.default_font_size
	})

	make_fine_text(self._text)
	self._text:set_center(panel:w() / 2, panel:h() / 2)

	self._offset = offset

	if params.horizontal then
		self._center = self._offset + Vector3(20, 0, 0) - up * 5
	else
		self._center = self._offset + Vector3(10, 0, 0) - up * 12.25
	end

	self:set_help_state("inactive")

	self._stationary = params.stationary
	self._update_func = params.update_func
	self._save_func = params.save_func
end

function VRBeltAdjuster:destroy()
	self._ws:gui():destroy_workspace(self._ws)
end

function VRBeltAdjuster:center()
	return self._obj:position() + self._center:rotate_with(self._obj:rotation())
end

function VRBeltAdjuster:stationary()
	return self._stationary
end

function VRBeltAdjuster:update(pos)
	if self._update_func then
		self._update_func(pos)
	end
end

function VRBeltAdjuster:save()
	if self._save_func then
		self._save_func()
	end
end

function VRBeltAdjuster:set_help_state(state)
	if state == self._state then
		return
	end

	self._state = state
	local grip = state == "grip"
	local inactive = state == "inactive"
	local x = grip and 0 or 128

	self._up_arrow:set_texture_rect(x, 0, 128, 128)
	self._up_arrow:set_alpha(inactive and 0.2 or 1)
	self._down_arrow:set_texture_rect(x, 0, 128, 128)
	self._down_arrow:set_alpha(inactive and 0.2 or 1)
	self._text:set_alpha(inactive and 0.5 or 1)
	self._text:set_text(managers.localization:to_upper_text(grip and "menu_vr_belt_release" or self._text_id))
	make_fine_text(self._text)
	self._text:set_center_x(self._ws:panel():w() / 2)
end

function VRBeltAdjuster:set_visible(visible)
	self._ws[visible and "show" or "hide"](self._ws)
end

VRBeltCustomization = VRBeltCustomization or class()

function VRBeltCustomization:init(is_start_menu)
	local scene = is_start_menu and World or MenuRoom
	local player = managers.menu:player()
	self._belt_unit = World:spawn_unit(Idstring("units/pd2_dlc_vr/player/vr_hud_belt"), Vector3(0, 0, 0), Rotation())

	self._belt_unit:set_visible(false)

	self._ws = scene:gui():create_world_workspace(1380, 880, Vector3(), math.X, math.Y)
	self._belt = HUDBelt:new(self._ws)

	HUDManagerVR.link_belt(self._ws, self._belt_unit)

	self._height = managers.vr:get_setting("height") * managers.vr:get_setting("belt_height_ratio")
	self._distance = managers.vr:get_setting("belt_distance")

	self._belt_unit:set_position(player:position():with_z(self._height) - Vector3(20, 0, 0))
	self._belt_unit:set_rotation(Rotation((VRManager:hmd_rotation() * player:base_rotation()):yaw()))

	self._belt_alpha = 0.4

	self._belt:set_alpha(self._belt_alpha)
	player._hand_state_machine:enter_hand_state(player:primary_hand_index(), "customization")
	player._hand_state_machine:enter_hand_state(3 - player:primary_hand_index(), "customization_empty")

	self._adjusters = {
		VRBeltAdjuster:new(scene, self._belt_unit, {
			text_id = "menu_vr_belt_grip_height",
			offset = Vector3(-10, 10, 24.5),
			up = math.Z,
			update_func = function (pos)
				local height = managers.vr:get_setting("height")
				local min, max = managers.vr:setting_limits("belt_height_ratio")
				local z = pos.z

				if min and max then
					z = math.clamp(z, height * min, height * max)
				end

				self._height = z
			end,
			save_func = function ()
				managers.vr:set_setting("belt_height_ratio", self._height / managers.vr:get_setting("height"))
			end
		}),
		VRBeltAdjuster:new(scene, self._belt_unit, {
			text_id = "menu_vr_belt_grip_distance",
			offset = Vector3(-10, 10, 0),
			up = math.Y,
			update_func = function (pos)
				local min, max = managers.vr:setting_limits("belt_distance")
				local relative_pos = (pos - managers.menu:player():position()):rotate_with(self._belt_unit:rotation():inverse())
				local y = relative_pos.y

				if min and max then
					y = math.clamp(y, min, max)
				end

				self._distance = y
			end,
			save_func = function ()
				managers.vr:set_setting("belt_distance", self._distance)
			end
		}),
		VRBeltAdjuster:new(scene, self._belt_unit, {
			horizontal = true,
			text_id = "menu_vr_belt_grip_radius",
			stationary = true,
			offset = Vector3(-20, -12, 0),
			up = math.Y,
			update_func = function (pos)
				local size = managers.vr:get_setting("belt_size")
				local min, max = managers.vr:setting_limits("belt_size")
				local x = (pos - self._grip_pos):rotate_with(self._belt_unit:rotation():inverse()).x
				size = size + x

				if min and max then
					size = math.clamp(size, min, max)
				end

				self._size = size

				HUDManagerVR.link_belt(self._ws, self._belt_unit, size)
			end,
			save_func = function ()
				managers.vr:set_setting("belt_size", self._size)
			end
		})
	}

	self:set_mode("adjuster")
end

function VRBeltCustomization:set_back_button_enabled(hand_id, enabled)
	if self._back_button_enabled == enabled then
		return
	end

	tag_print("VRBeltCustomization:set_back_button_enabled", hand_id, enabled)

	local player = managers.menu:player()

	if not enabled then
		player._hand_state_machine:enter_hand_state(hand_id, hand_id == player:primary_hand_index() and "customization" or "customization_empty")
	else
		player._hand_state_machine:enter_hand_state(hand_id, hand_id == player:primary_hand_index() and "laser" or "empty")
	end

	if managers.menu:active_menu() then
		managers.menu:active_menu().input:focus(false)
		managers.menu:active_menu().input:focus(true)
	end

	self._back_button_enabled = enabled
end

function VRBeltCustomization:reset()
	managers.vr:reset_setting("belt_height_ratio")
	managers.vr:reset_setting("belt_distance")
	managers.vr:reset_setting("belt_size")
	managers.vr:reset_setting("belt_layout")
	managers.vr:reset_setting("belt_box_sizes")

	self._height = managers.vr:get_setting("height")
	self._distance = managers.vr:get_setting("belt_distance")
	self._size = managers.vr:get_setting("belt_size")

	HUDManagerVR.link_belt(self._ws, self._belt_unit)
end

function VRBeltCustomization:update_height()
	self._height = managers.vr:get_setting("height")
end

function VRBeltCustomization:save_grid()
	local belt_layout = clone(managers.vr:get_setting("belt_layout"))

	for id in pairs(belt_layout) do
		local new_pos = {
			self._belt:pos_on_grid(id)
		}
		belt_layout[id] = new_pos
	end

	managers.vr:set_setting("belt_layout", belt_layout)

	local belt_box_sizes = clone(managers.vr:get_setting("belt_box_sizes"))

	for id in pairs(belt_box_sizes) do
		local new_size = {
			self._belt:grid_size(id)
		}
		belt_box_sizes[id] = new_size
	end

	managers.vr:set_setting("belt_box_sizes", belt_box_sizes)
end

function VRBeltCustomization:reset_grid()
	managers.vr:reset_setting("belt_layout")
	managers.vr:reset_setting("belt_box_sizes")
end

function VRBeltCustomization:destroy()
	self._ws:gui():destroy_workspace(self._ws)

	for _, adjuster in ipairs(self._adjusters) do
		adjuster:destroy()
	end

	if managers.menu:active_menu() then
		local player = managers.menu:player()

		player._hand_state_machine:enter_hand_state(player:primary_hand_index(), "laser")
		player._hand_state_machine:enter_hand_state(3 - player:primary_hand_index(), "empty")
		managers.menu:active_menu().input:focus(false)
		managers.menu:active_menu().input:focus(true)
	end

	self._belt:destroy()
	World:delete_unit(self._belt_unit)
end

function VRBeltCustomization:set_mode(mode)
	for _, adjuster in ipairs(self._adjusters) do
		adjuster:set_visible(mode == "adjuster")
	end

	self._belt:set_grid_display(mode == "grid")

	if mode ~= "grid" then
		self._belt:clear_help_texts()
	end

	if mode == "adjuster" then
		self._updator = self._update_adjuster
	elseif mode == "grid" then
		self._updator = self._update_grid

		for _, id in pairs(self._belt:interactions()) do
			self._belt:add_help_text(id, id, "menu_vr_belt_" .. id)
		end
	else
		self._updator = nil
	end
end

function VRBeltCustomization:_update_grid(t, dt)
	self:__update_grid(t, dt)
end

function VRBeltCustomization:__update_grid(t, dt)
	local player = managers.menu:player()
	local hands = {
		player:hand(1),
		player:hand(2)
	}

	for i, hand in ipairs(hands) do
		if not self._active_hand_id or i == self._active_hand_id and not self._sizing_hand_id then
			local interact_btn = "interact_" .. (i == 1 and "right" or "left")
			local held = managers.menu:get_controller():get_input_bool(interact_btn)
			local interaction = self._belt:get_closest_interaction(hand:position(), 200, true)

			if not self._current_interaction and interaction ~= self._selected_interaction then
				if self._selected_interaction then
					self._belt:remove_help_text(self._selected_interaction, "layout_help")
					self._belt:remove_help_text(self._selected_interaction, "size_help")
					self._belt:set_alpha(self._belt_alpha, self._selected_interaction)
					self:set_back_button_enabled(i, true)
				end

				if interaction then
					self._active_hand_id = i

					self._belt:add_help_text(interaction, "layout_help", "menu_vr_belt_grip_grid", "above")
					self._belt:add_help_text(interaction, "size_help", "menu_vr_belt_grip_grid_size", "below")
					self._belt:set_alpha(self._belt_alpha + 0.2, interaction)
					self:set_back_button_enabled(i, false)
				else
					self._active_hand_id = nil
				end

				self._selected_interaction = interaction
			end

			if managers.menu:get_controller():get_input_pressed(interact_btn) and interaction then
				self._current_interaction = interaction
				self._prev_grid_pos = {
					self._belt:pos_on_grid(self._current_interaction)
				}
				self._grip_offset = self._belt:world_pos(self._current_interaction) - hand:position()

				self._belt:set_alpha(self._belt_alpha + 0.4, self._current_interaction)
			end

			if self._current_interaction then
				if held then
					self._belt:move_interaction(self._current_interaction, self._ws:world_to_local(hand:position() + self._grip_offset), true)
				else
					if not self._belt:valid_grid_location(self._current_interaction) and self._prev_grid_pos then
						self._belt:set_grid_position(self._current_interaction, unpack(self._prev_grid_pos))

						if not self._belt:valid_grid_location(self._current_interaction) and self._prev_grid_size then
							self._belt:set_grid_size(self._current_interaction, unpack(self._prev_grid_size))
						end
					end

					self._belt:set_alpha(self._belt_alpha, self._current_interaction)

					self._current_interaction = nil
					self._prev_grid_pos = nil
				end
			end
		elseif self._active_hand_id and i ~= self._active_hand_id and self._current_interaction then
			local interact_btn = "interact_" .. (i == 1 and "right" or "left")

			if managers.menu:get_controller():get_input_pressed(interact_btn) then
				self._sizing_hand_id = i
				local size = self._belt:world_size(self._current_interaction)
				self._sizing_grip_offset = self._belt:world_pos(self._current_interaction) + size - self._grip_offset - hand:position()
				self._prev_grid_size = {
					self._belt:grid_size(self._current_interaction)
				}
			end

			local held = managers.menu:get_controller():get_input_bool(interact_btn)

			if self._sizing_hand_id == i then
				if held then
					self._belt:resize_interaction(self._current_interaction, self._ws:world_to_local(hand:position() + self._sizing_grip_offset), true)
				else
					if not self._belt:valid_grid_location(self._current_interaction) and self._prev_grid_size then
						self._belt:set_grid_size(self._current_interaction, unpack(self._prev_grid_size))
					end

					if self._grip_offset then
						self._grip_offset = self._belt:world_pos(self._current_interaction) - hands[3 - i]:position()
					end

					self._sizing_hand_id = nil
					self._sizing_grip_offset = nil
				end
			end
		end
	end
end

function VRBeltCustomization:_update_adjuster(t, dt)
	local player = managers.menu:player()
	local hands = {
		player:hand(1),
		player:hand(2)
	}
	local adjusters = self._adjusters

	for i, hand in ipairs(hands) do
		if not self._active_hand_id or i == self._active_hand_id then
			local interact_btn = "interact_" .. (i == 1 and "right" or "left")
			local held = managers.menu:get_controller():get_input_bool(interact_btn)

			if self._active_adjuster then
				local adjuster = self._active_adjuster

				if mvector3.distance_sq(hand:position(), adjuster:center()) > 225 and (not adjuster:stationary() or not held) then
					adjuster:set_help_state("inactive")

					self._active_adjuster = nil

					self:set_back_button_enabled(i, true)
				else
					if managers.menu:get_controller():get_input_pressed(interact_btn) then
						self._grip_offset = hand:position() - self._belt_unit:position()
						self._grip_pos = hand:position() - self._grip_offset
					end

					if held and self._grip_offset then
						local new_pos = hand:position() - self._grip_offset

						adjuster:update(new_pos)
						adjuster:set_help_state("grip")

						break
					else
						adjuster:set_help_state("active")
					end
				end

				if managers.menu:get_controller():get_input_released(interact_btn) then
					adjuster:save()

					self._active_adjuster = nil

					self:set_back_button_enabled(i, true)
				end
			end

			if not held then
				local closest, new_adjuster = nil

				for _, adjuster in ipairs(adjusters) do
					local dis = mvector3.distance_sq(hand:position(), adjuster:center())

					if dis < 225 and (not closest or dis < closest) then
						closest = dis
						new_adjuster = adjuster
					end
				end

				if self._active_adjuster and self._active_adjuster ~= new_adjuster then
					self._active_adjuster:set_help_state("inactive")
				end

				self._active_adjuster = new_adjuster

				if not self._active_adjuster then
					self._active_hand_id = nil
				else
					self._active_hand_id = i

					self:set_back_button_enabled(i, false)
				end
			end
		end
	end

	self._belt_unit:set_position(player:position():with_z(self._height) + math.Y:rotate_with(self._belt_unit:rotation()) * self._distance)

	local hmd_rot = VRManager:hmd_rotation() * player:base_rotation()
	local snap_angle = managers.vr:get_setting("belt_snap")
	local yaw_rot = Rotation(hmd_rot:yaw())
	local angle = Rotation:rotation_difference(Rotation(self._belt_unit:rotation():yaw()), yaw_rot):yaw()
	angle = math.abs(angle)

	if snap_angle < angle then
		self._belt_unit:set_rotation(yaw_rot)
	end
end

function VRBeltCustomization:update(t, dt)
	if self._updator then
		self:_updator(t, dt)
	end
end

VRCalibrator = VRCalibrator or class()

function VRCalibrator:init(gui, menu, stop_clbk)
	self._body_calibrator = VRBodyCalibrator:new(managers.controller:get_vr_controller())
	self._gui = gui
	self._menu = menu
	self._stop_clbk = stop_clbk
	self._enabled = false
	self._step = 1
	self._step_t = nil
	local panel = menu._panel
	self._stats = {
		{
			name = "arm_length",
			caption = managers.localization:to_upper_text("menu_vr_calibrate_arm_length")
		},
		{
			name = "head_to_shoulder",
			caption = managers.localization:to_upper_text("menu_vr_calibrate_shoulder_to_head")
		},
		{
			name = "shoulder_width",
			caption = managers.localization:to_upper_text("menu_vr_calibrate_shoulder_width")
		}
	}
	local i = 0
	local w = self._menu._title:bottom()
	local x = self._menu._title:left()

	for _, stat in ipairs(self._stats) do
		stat.text = panel:text({
			font_size = 30,
			text = stat.caption,
			font = tweak_data.menu.pd2_massive_font,
			x = x,
			y = PADDING + w + 30 * i,
			layer = TEXT_LAYER
		})
		stat.text_value = panel:text({
			font_size = 30,
			text = tostring(0),
			font = tweak_data.menu.pd2_massive_font,
			x = x + 220,
			y = PADDING + w + 30 * i,
			layer = TEXT_LAYER
		})

		make_fine_text(stat.text)
		make_fine_text(stat.text_value)

		i = i + 1
	end

	local xpos = panel:w() * 0.5 + panel:w() / 18 * 2
	self._calibration_desc = panel:text({
		font_size = 30,
		name = "calibration_step",
		h = 300,
		wrap = true,
		word_wrap = true,
		text = managers.localization:to_upper_text("menu_vr_calibrate_instructions"),
		font = tweak_data.menu.pd2_massive_font,
		x = xpos,
		y = w + PADDING,
		w = panel:w() - xpos,
		layer = TEXT_LAYER
	})

	self._calibration_desc:set_visible(false)
	make_fine_text(self._calibration_desc)

	self._calibration_step = {}
	local ypos = math.max(panel:h() / 9.5 * 4, self._calibration_desc:y() + self._calibration_desc:h() + PADDING)
	local steps = {}

	for i = 1, 3 do
		local text = panel:text({
			font_size = 25,
			word_wrap = true,
			wrap = true,
			name = "calibration_step" .. tostring(i),
			text = managers.localization:to_upper_text("menu_vr_calibrate_step" .. tostring(i)),
			font = tweak_data.menu.pd2_massive_font,
			x = xpos,
			y = ypos,
			w = panel:w() - xpos,
			layer = TEXT_LAYER
		})

		make_fine_text(text)
		text:set_w(panel:w() - xpos)

		ypos = ypos + text:h() + PADDING

		table.insert(self._calibration_step, text)
	end

	local radius = 40
	local x = panel:left() + panel:w() * 0.5 - radius
	local h = 4 * (panel:bottom() - panel:top()) / 9.5
	local y = h - radius
	self._bitmap = panel:bitmap({
		texture = "guis/textures/pd2/hud_progress_active",
		blend_mode = "normal",
		layer = TEXT_LAYER,
		color = Color.white:with_alpha(0.2),
		x = x,
		y = y
	})

	self._bitmap:set_size(radius * 2, radius * 2)

	self._circle = CircleBitmapGuiObject:new(panel, {
		current = 1,
		total = 1,
		blend_mode = "normal",
		radius = radius,
		sides = radius / 10,
		color = Color.white:with_alpha(1),
		layer = TEXT_LAYER + 1,
		x = x,
		y = y
	})
end

function VRCalibrator:show_calibration_step(step)
	self._gui:show_calibration_step(step)

	if step > 0 then
		self._calibration_desc:set_visible(true)
	else
		self._calibration_desc:set_visible(false)
	end

	for i = 1, 3 do
		self._calibration_step[i]:set_visible(step > 0)
		self._calibration_step[i]:set_alpha(step == i and 1 or 0.4)
	end
end

function VRCalibrator:start()
	if managers.menu_scene then
		self._prev_scene_template = managers.menu_scene:get_current_scene_template()

		managers.menu_scene:set_scene_template("calibrate")

		self._machine = managers.menu_scene:character_unit():anim_state_machine()
		self._state = self._machine:play_redirect(Idstring("calibrate"))

		self._machine:set_parameter(self._state, "calibrate", 1)
	end

	self:show_calibration_step(1)

	self._enabled = true
	self._step = 1
	self._step_t = nil

	self._body_calibrator:start_calibration()
end

function VRCalibrator:stop(succeeded)
	if managers.menu_scene then
		managers.menu_scene:set_scene_template(self._prev_scene_template)
		self._machine:play_redirect(Idstring("idle_menu"))
	end

	if not self._enabled then
		return
	end

	self:show_calibration_step(0)
	self._body_calibrator:stop_calibration(succeeded)

	self._enabled = false

	if self._stop_clbk then
		self._stop_clbk(succeeded or false)
	end
end

function VRCalibrator:update(t, dt)
	if not self._enabled then
		return
	end

	self._body_calibrator:update(t, dt)

	if not self._step_t then
		self._step_t = t + 5
	end

	local config = self._body_calibrator:body_config()

	for _, stat in ipairs(self._stats) do
		local cm_value = math.round(config[stat.name] * 10) / 10
		local in_value = math.round(config[stat.name] * 0.393701 * 10) / 10

		stat.text_value:set_text(tostring(cm_value) .. "cm | " .. tostring(in_value) .. "in")
		make_fine_text(stat.text_value)
	end

	self._circle:set_current(1 - math.clamp(self._step_t - t, 0, 5) / 5)

	if self._step_t < t then
		if self._step < 3 then
			self._step_t = nil
			self._step = math.min(self._step + 1, 3)

			if self._machine then
				self._machine:set_parameter(self._state, "calibrate", self._step)
			end

			self:show_calibration_step(self._step)
		else
			self:stop(true)
		end
	end
end
