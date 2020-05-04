TeammateCommentUnitElement = TeammateCommentUnitElement or class(MissionElement)

function TeammateCommentUnitElement:init(unit)
	TeammateCommentUnitElement.super.init(self, unit)

	self._hed.comment = "none"
	self._hed.close_to_element = false
	self._hed.use_instigator = false
	self._hed.radius = 0
	self._hed.test_robber = 1

	table.insert(self._save_values, "comment")
	table.insert(self._save_values, "close_to_element")
	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "radius")
end

function TeammateCommentUnitElement:post_init(...)
	TeammateCommentUnitElement.super.post_init(self, ...)
end

function TeammateCommentUnitElement:update_selected(t, dt)
	if self._hed.radius ~= 0 then
		local brush = Draw:brush()

		brush:set_color(Color(0.15, 1, 1, 1))

		local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

		brush:sphere(self._unit:position(), self._hed.radius, 4)
		pen:sphere(self._unit:position(), self._hed.radius)
	end
end

function TeammateCommentUnitElement:test_element()
	if self._hed.comment then
		managers.editor:set_wanted_mute(false)
		managers.editor:set_listener_enabled(true)

		if self._ss then
			self._ss:stop()
		end

		self._ss = SoundDevice:create_source(self._unit:unit_data().name_id)

		self._ss:set_position(self._unit:position())
		self._ss:set_orientation(self._unit:rotation())
		self._ss:set_switch("int_ext", "third")

		for i = self._hed.test_robber, 10 do
			self._ss:set_switch("robber", "rb" .. tostring(i))

			if self._ss:post_event(self._hed.comment) then
				break
			end
		end
	end
end

function TeammateCommentUnitElement:stop_test_element()
	managers.editor:set_wanted_mute(true)
	managers.editor:set_listener_enabled(false)

	if self._ss then
		self._ss:stop()
	end
end

function TeammateCommentUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "comment", table.list_add({
		"none"
	}, managers.groupai:state().teammate_comment_names), "Select a comment")
	self:_build_value_checkbox(panel, panel_sizer, "close_to_element", "Play close to element", "Play close to element")
	self:_build_value_checkbox(panel, panel_sizer, "use_instigator", "Play on instigator", "Play on instigator")
	self:_build_value_number(panel, panel_sizer, "radius", {
		floats = 0,
		min = 0
	}, "(Optional) Sets a distance to use with the check (in cm)")
	self:_build_value_number(panel, panel_sizer, "test_robber", {
		floats = 0,
		min = 0
	}, "Can be used to test different robber voice (not saved/loaded)")
	self:_add_help_text("If \"Play close to element\" is checked, the comment will be played on a teammate close to the element position, otherwise close to the player.")
end

function TeammateCommentUnitElement:destroy()
	self:stop_test_element()
	TeammateCommentUnitElement.super.destroy(self)
end
