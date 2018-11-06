require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = CoreMaterialEditorParameter or class()

function CoreMaterialEditorParameter:init(parent, editor, parameter_info, parameter_node)
	self:set_params(parent, editor, parameter_info, parameter_node)

	self._panel = EWS:Panel(parent, "", "")
	self._box = EWS:BoxSizer("HORIZONTAL")
	self._left_panel = EWS:Panel(self._panel, "", "")
	self._left_box = EWS:BoxSizer("VERTICAL")

	self._left_panel:set_sizer(self._left_box)
	self._box:add(self._left_panel, 0, 4, "RIGHT,EXPAND")

	local panel = EWS:Panel(self._panel, "", "")

	self._left_box:add(panel, 1, 0, "EXPAND")

	self._parent_btn = EWS:Button(self._left_panel, "+", "", "NO_BORDER")

	self._parent_btn:set_min_size(Vector3(15, 15, 0))
	self._parent_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", editor._on_parameter_popup, self)
	self._left_box:add(self._parent_btn, 0, 0, "ALIGN_CENTER_HORIZONTAL")

	panel = EWS:Panel(self._panel, "", "")

	self._left_box:add(panel, 1, 0, "EXPAND")

	self._right_panel = EWS:Panel(self._panel, "", "")
	self._right_box = EWS:StaticBoxSizer(self._right_panel, "HORIZONTAL", parameter_info.ui_name:s())

	self._right_panel:set_sizer(self._right_box)
	self._box:add(self._right_panel, 1, 4, "LEFT,EXPAND")
	self._panel:set_sizer(self._box)

	self._customize = (self._editor._current_material_node:parameter("src") == nil or not self._parent_node or self._node) ~= nil

	self._right_panel:set_enabled(self._customize)
	self:_load_value()
	self._editor:_update_output()
end

function CoreMaterialEditorParameter:set_params(parent, editor, parameter_info, parameter_node)
	self._parent = parent
	self._editor = editor
	self._parameter_info = parameter_info
	self._parameter_node = parameter_node
	self._node = parameter_node
	self._value = parameter_info.ui_type:s() == "intensity" and "sun" or parameter_info.default or "[NONE]"
	self._parent_node = self._editor._parent_materials[self._editor._parent_combo_box:get_value()]

	if self._parent_node then
		for param in self._parent_node:children() do
			if self._parameter_info.type == "texture" and param:name() == self._parameter_info.name:s() then
				self._parent_param_node = param

				break
			elseif param:parameter("name") == self._parameter_info.name:s() then
				self._parent_param_node = param

				break
			end
		end

		if not self._parent_param_node then
			self._parent_node = nil
		end
	end
end

function CoreMaterialEditorParameter:on_copy_to_parent()
	if self._editor._parent_combo_box:get_value() ~= "[NONE]" then
		self:_copy_to_parent()
	else
		local name = EWS:get_text_from_user(self._editor._main_frame, "Name: ", "Create New Parent", "", Vector3(-1, -1, 0), true)

		if name ~= "" then
			if self._editor:_find_node(self._editor._material_config_node, "name", name) then
				EWS:MessageDialog(self._editor._main_frame, "A parent with that name already exists!", "Create New Parent", "OK,ICON_ERROR"):show_modal()
			else
				self:_copy_to_parent(name)
			end
		end
	end

	self._editor:_create_parameter_panel()
end

function CoreMaterialEditorParameter:update_live()
	self._editor:live_update_parameter(self._parameter_info.name:s(), self._parameter_info.type, self._parameter_info.ui_type:s(), self._value)
end

function CoreMaterialEditorParameter:update(t, dt)
end

function CoreMaterialEditorParameter:destroy()
	self._panel:destroy()
end

function CoreMaterialEditorParameter:panel()
	return self._panel
end

function CoreMaterialEditorParameter:get_value()
	return self._value
end

function CoreMaterialEditorParameter:to_slider_range(v, min, step)
	return (v - min) / step
end

function CoreMaterialEditorParameter:from_slider_range(v, min, step)
	return v * step + min
end

function CoreMaterialEditorParameter:_create_node()
	if self._parameter_info.type == "vector3" then
		self._parameter_node = self._editor._current_material_node:make_child("variable")

		self._parameter_node:set_parameter("name", self._parameter_info.name:s())
		self._parameter_node:set_parameter("type", self._parameter_info.type)

		local str = math.vector_to_string(self._value)

		self._parameter_node:set_parameter("value", str)
	elseif self._parameter_info.type == "texture" then
		self._parameter_node = self._editor._current_material_node:make_child(self._parameter_info.name:s())
		local str = tostring(self._value)
		self._global_texture = false

		self._parameter_node:set_parameter("file", str)
	else
		self._parameter_node = self._editor._current_material_node:make_child("variable")

		self._parameter_node:set_parameter("name", self._parameter_info.name:s())
		self._parameter_node:set_parameter("type", self._parameter_info.type)

		local str = tostring(self._value)

		self._parameter_node:set_parameter("value", str)
	end
end

function CoreMaterialEditorParameter:_load_value()
	if self._editor._current_material_node:parameter("src") and not self._customize then
		self._node = self._parent_param_node

		if self._parameter_node then
			self._editor._current_material_node:remove_child_at(self._editor._current_material_node:index_of_child(self._parameter_node))

			self._parameter_node = nil
		end
	end

	if not self._editor._current_material_node:parameter("src") or self._customize then
		if not self._parameter_node then
			self:_create_node()
		end

		self._node = self._parameter_node
	end

	if self._parameter_info.type == "vector3" then
		self._value = math.string_to_vector(self._node:parameter("value"))
	elseif self._parameter_info.type == "texture" then
		self._value = self._node:parameter("file")
		self._global_texture = false

		if not self._value then
			self._global_texture = true
			self._value = self._node:parameter("global_texture")
			self._global_texture_type = "cube"
		end
	elseif self._parameter_info.ui_type:s() == "intensity" then
		self._value = self._node:parameter("value")
	else
		self._value = tonumber(self._node:parameter("value"))
	end
end

function CoreMaterialEditorParameter:_copy_to_parent(name)
	local material_node = nil

	if name then
		material_node = self._editor._global_material_config_node:make_child("material")

		material_node:set_parameter("name", name)
	else
		material_node = self._editor:_find_node(self._editor._global_material_config_node, "material", "name", self._editor._parent_combo_box:get_value())
	end

	local parent_param_node = nil

	if self._parameter_info.type == "texture" then
		parent_param_node = self._editor:_get_node(material_node, self._parameter_info.name:s())
	else
		parent_param_node = self._editor:_find_node(material_node, "variable", "name", self._parameter_info.name:s())
	end

	parent_param_node = parent_param_node or material_node:add_child(self._parameter_node)

	if self._parameter_info.type == "texture" then
		if self._global_texture then
			parent_param_node:set_parameter("global_texture", self._value)

			if self._global_texture_type then
				parent_param_node:set_parameter("type", self._global_texture_type)
			end
		else
			parent_param_node:set_parameter("file", self._value)
		end
	elseif self._parameter_info.type == "vector3" then
		parent_param_node:set_parameter("value", math.vector_to_string(self._value))
	else
		parent_param_node:set_parameter("value", tostring(self._value))
	end

	local parent = self._editor._parent_combo_box:get_value()

	self._editor:_load_parent_dropdown()
	self._editor._parent_combo_box:set_value(parent)
end

return CoreMaterialEditorParameter
