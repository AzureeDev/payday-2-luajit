require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")
core:import("CoreColorPickerDialog")

CoreOverlayFXCutsceneKey = CoreOverlayFXCutsceneKey or class(CoreCutsceneKeyBase)
CoreOverlayFXCutsceneKey.ELEMENT_NAME = "overlay_fx"
CoreOverlayFXCutsceneKey.NAME = "Overlay Effect"
CoreOverlayFXCutsceneKey.VALID_BLEND_MODES = {
	"normal",
	"add"
}

CoreOverlayFXCutsceneKey:register_serialized_attribute("blend_mode", CoreOverlayFXCutsceneKey.VALID_BLEND_MODES[1])
CoreOverlayFXCutsceneKey:register_serialized_attribute("color", Color.white, CoreCutsceneKeyBase.string_to_color)
CoreOverlayFXCutsceneKey:register_serialized_attribute("fade_in", 0, tonumber)
CoreOverlayFXCutsceneKey:register_serialized_attribute("sustain", 0, tonumber)
CoreOverlayFXCutsceneKey:register_serialized_attribute("fade_out", 0, tonumber)

CoreOverlayFXCutsceneKey.control_for_blend_mode = CoreCutsceneKeyBase.standard_combo_box_control
CoreOverlayFXCutsceneKey.refresh_control_for_blend_mode = CoreCutsceneKeyBase:standard_combo_box_control_refresh("blend_mode", CoreOverlayFXCutsceneKey.VALID_BLEND_MODES)

function CoreOverlayFXCutsceneKey:__tostring()
	return "Trigger overlay effect."
end

function CoreOverlayFXCutsceneKey:preroll(player)
	if self:fade_in() == 0 then
		local effect_data = self:_effect_data()
		effect_data.fade_in = 0
		effect_data.sustain = nil
		effect_data.fade_out = 0

		managers.cutscene:play_overlay_effect(effect_data)
	end
end

function CoreOverlayFXCutsceneKey:skip(player)
	local full_intensity_start = self:time() + self:fade_in()
	local full_intensity_end = full_intensity_start + self:sustain()
	local cutscene_end = player:cutscene_duration()

	if full_intensity_start <= cutscene_end and cutscene_end <= full_intensity_end then
		local effect_data = self:_effect_data()
		effect_data.fade_in = 0
		effect_data.sustain = math.max(full_intensity_end - cutscene_end, 0)

		managers.cutscene:play_overlay_effect(effect_data)
	end
end

function CoreOverlayFXCutsceneKey:evaluate(player, fast_forward)
	local effect_data = table.remap(self:attribute_names(), function (_, attribute_name)
		return attribute_name, self:attribute_value(attribute_name)
	end)

	managers.cutscene:play_overlay_effect(effect_data)
end

function CoreOverlayFXCutsceneKey:revert(player)
	self:_stop()
end

function CoreOverlayFXCutsceneKey:update_gui(time, delta_time, player)
	if self.__color_picker_dialog then
		self.__color_picker_dialog:update(time, delta_time)
	end
end

function CoreOverlayFXCutsceneKey:is_valid_blend_mode(value)
	return table.contains(self.VALID_BLEND_MODES, value)
end

function CoreOverlayFXCutsceneKey:is_valid_fade_in(value)
	return value >= 0
end

function CoreOverlayFXCutsceneKey:is_valid_sustain(value)
	return value >= 0
end

function CoreOverlayFXCutsceneKey:is_valid_fade_out(value)
	return value >= 0
end

function CoreOverlayFXCutsceneKey:control_for_color(parent_frame)
	local control = EWS:ColorWell(parent_frame, "")

	control:set_tool_tip("Open Color Picker")
	control:set_background_colour(255, 20, 255)
	control:set_color(self:color())
	control:connect("EVT_LEFT_UP", callback(self, self, "_on_pick_color"), control)

	return control
end

function CoreOverlayFXCutsceneKey:_on_pick_color(sender)
	if self.__color_picker_dialog == nil then
		local cutscene_editor_window = self:_top_level_window(sender)
		self.__color_picker_dialog = CoreColorPickerDialog.ColorPickerDialog:new(cutscene_editor_window, true, "HORIZONTAL", true)

		self.__color_picker_dialog:connect("EVT_CLOSE_WINDOW", function ()
			self.__color_picker_dialog = nil
		end)
		self.__color_picker_dialog:connect("EVT_COLOR_CHANGED", function ()
			local color = self.__color_picker_dialog:color()

			sender:set_color(color)
			self:set_color(color)
		end)
		self.__color_picker_dialog:center(cutscene_editor_window)
		self.__color_picker_dialog:set_color(self:color())
		self.__color_picker_dialog:set_visible(true)
	end
end

function CoreOverlayFXCutsceneKey:_effect_data()
	return table.remap(self:attribute_names(), function (_, attribute_name)
		return attribute_name, self:attribute_value(attribute_name)
	end)
end

function CoreOverlayFXCutsceneKey:_stop()
	managers.cutscene:stop_overlay_effect()
end

function CoreOverlayFXCutsceneKey:_top_level_window(window)
	return (type_name(window) == "EWSFrame" or type_name(window) == "EWSDialog") and window or self:_top_level_window(assert(window:parent()))
end
