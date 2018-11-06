require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreDiscontinuityCutsceneKey = CoreDiscontinuityCutsceneKey or class(CoreCutsceneKeyBase)
CoreDiscontinuityCutsceneKey.ELEMENT_NAME = "discontinuity"
CoreDiscontinuityCutsceneKey.NAME = "Discontinuity"

CoreDiscontinuityCutsceneKey:register_control("description")

CoreDiscontinuityCutsceneKey.refresh_control_for_description = CoreCutsceneKeyBase.VOID
CoreDiscontinuityCutsceneKey.label_for_description = CoreCutsceneKeyBase.VOID
CoreDiscontinuityCutsceneKey.is_valid_description = CoreCutsceneKeyBase.TRUE

function CoreDiscontinuityCutsceneKey:__tostring()
	return "Notifies a discontinuity in linear time."
end

function CoreDiscontinuityCutsceneKey:play(player, undo, fast_forward)
	player:_notify_discontinuity()
end

function CoreDiscontinuityCutsceneKey:control_for_description(parent_frame)
	local text = "Discontinuity keys signify a break in linear time. They enable us to dampen physics, etc. during rapid actor movement.\n\nDiscontinuity keys are inserted by the optimizer as the cutscene is exported to the game, but you can also insert them yourself."
	local control = EWS:TextCtrl(parent_frame, text, "", "NO_BORDER,TE_RICH,TE_MULTILINE,TE_READONLY")

	control:set_min_size(control:get_min_size():with_y(160))
	control:set_background_colour(parent_frame:background_colour():unpack())

	return control
end

function CoreDiscontinuityCutsceneKey:validate_control_for_attribute(attribute_name)
	if attribute_name ~= "description" then
		return self.super.validate_control_for_attribute(self, attribute_name)
	end

	return true
end
