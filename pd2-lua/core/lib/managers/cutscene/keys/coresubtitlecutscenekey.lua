require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreSubtitleCutsceneKey = CoreSubtitleCutsceneKey or class(CoreCutsceneKeyBase)
CoreSubtitleCutsceneKey.ELEMENT_NAME = "subtitle"
CoreSubtitleCutsceneKey.NAME = "Subtitle"

CoreSubtitleCutsceneKey:register_serialized_attribute("category", "")
CoreSubtitleCutsceneKey:register_serialized_attribute("string_id", "")
CoreSubtitleCutsceneKey:register_serialized_attribute("duration", 3, tonumber)
CoreSubtitleCutsceneKey:register_control("divider")
CoreSubtitleCutsceneKey:register_control("localized_text")
CoreSubtitleCutsceneKey:attribute_affects("category", "string_id")
CoreSubtitleCutsceneKey:attribute_affects("string_id", "localized_text")

CoreSubtitleCutsceneKey.control_for_category = CoreCutsceneKeyBase.standard_combo_box_control
CoreSubtitleCutsceneKey.control_for_string_id = CoreCutsceneKeyBase.standard_combo_box_control
CoreSubtitleCutsceneKey.control_for_divider = CoreCutsceneKeyBase.standard_divider_control

function CoreSubtitleCutsceneKey:__tostring()
	return "Display subtitle \"" .. self:string_id() .. "\"."
end

function CoreSubtitleCutsceneKey:can_evaluate_with_player(player)
	return true
end

function CoreSubtitleCutsceneKey:unload(player)
	managers.subtitle:clear_subtitle()
end

function CoreSubtitleCutsceneKey:play(player, undo, fast_forward)
	if undo then
		managers.subtitle:clear_subtitle()
	elseif not fast_forward then
		managers.subtitle:show_subtitle(self:string_id(), self:duration())
	end
end

function CoreSubtitleCutsceneKey:is_valid_category(value)
	return value and value ~= ""
end

function CoreSubtitleCutsceneKey:is_valid_string_id(value)
	return value and value ~= ""
end

function CoreSubtitleCutsceneKey:is_valid_duration(value)
	return value and value > 0
end

function CoreSubtitleCutsceneKey:control_for_localized_text(parent_frame)
	local control = EWS:TextCtrl(parent_frame, "", "", "NO_BORDER,TE_RICH,TE_MULTILINE,TE_READONLY")

	control:set_min_size(control:get_min_size():with_y(160))
	control:set_background_colour(parent_frame:background_colour():unpack())

	return control
end

function CoreSubtitleCutsceneKey:refresh_control_for_category(control)
	control:freeze()
	control:clear()

	local categories = managers.localization:xml_names()

	if table.empty(categories) then
		control:set_enabled(false)
	else
		control:set_enabled(true)

		local value = self:category()

		for _, category in ipairs(categories) do
			control:append(category)

			if category == value then
				control:set_value(value)
			end
		end
	end

	control:thaw()
end

function CoreSubtitleCutsceneKey:refresh_control_for_string_id(control)
	control:freeze()
	control:clear()

	local string_ids = self:category() ~= "" and managers.localization:string_map(self:category()) or {}

	if table.empty(string_ids) then
		control:set_enabled(false)
	else
		control:set_enabled(true)

		local value = self:string_id()

		for _, string_id in ipairs(string_ids) do
			control:append(string_id)

			if string_id == value then
				control:set_value(value)
			end
		end
	end

	control:thaw()
end

function CoreSubtitleCutsceneKey:refresh_control_for_localized_text(control)
	if self:is_valid_category(self:category()) and self:is_valid_string_id(self:string_id()) then
		control:set_value(managers.localization:text(self:string_id()))
	else
		control:set_value("<No String Id>")
	end
end

function CoreSubtitleCutsceneKey:validate_control_for_attribute(attribute_name)
	if attribute_name ~= "localized_text" then
		return self.super.validate_control_for_attribute(self, attribute_name)
	end

	return true
end
