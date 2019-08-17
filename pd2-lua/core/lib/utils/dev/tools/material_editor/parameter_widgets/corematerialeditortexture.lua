require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

local CoreMaterialEditorParameter = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorParameter")
local CoreMaterialEditorTexture = CoreMaterialEditorTexture or class(CoreMaterialEditorParameter)

function CoreMaterialEditorTexture:init(parent, editor, parameter_info, parameter_node)
	CoreMaterialEditorParameter.init(self, parent, editor, parameter_info, parameter_node)

	local text = self._value .. (self._global_texture and " (Global)" or "")
	self._text = EWS:TextCtrl(self._right_panel, text, "", "TE_READONLY")

	self._text:set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	self._text:set_font_weight("FONTWEIGHT_BOLD")
	self._right_box:add(self._text, 1, 4, "ALL,EXPAND")

	self._button = EWS:Button(self._right_panel, "Browse", "", "NO_BORDER")

	self._button:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._on_browse, self)
	self._right_box:add(self._button, 0, 4, "ALL")
end

function CoreMaterialEditorTexture:update(t, dt)
end

function CoreMaterialEditorTexture:destroy()
	CoreMaterialEditorParameter.destroy(self)
end

function CoreMaterialEditorTexture:on_toggle_customize()
	self._customize = not self._customize

	self:_load_value()
	self._editor:_update_output()
	self._right_panel:set_enabled(self._customize)
	self._text:set_value(self._value)

	if self._customize then
		self:_on_browse()
	end
end

function CoreMaterialEditorTexture:on_open_texture()
	local str = os.getenv("MATEDOPEN")
	local s, e = string.find(str, "$FILE")

	if s and e then
		local first_part = string.sub(str, 1, s - 1)
		local last_part = string.sub(str, e + 1)

		if DB:has("texture", self._value) then
			str = "start " .. first_part .. "\"" .. Application:nice_path(managers.database:base_path() .. self._value .. ".dds\"", false) .. last_part

			os.execute(str)
		else
			EWS:MessageDialog(self._editor._main_frame, "Could not find texture entry: " .. self._value, "Open Texture", "OK,ICON_ERROR"):show_modal()
		end
	end
end

function CoreMaterialEditorTexture:on_pick_global_texture()
	local texture_list = {}

	for _, texture_id in ipairs(GlobalTextureManager:list_textures()) do
		table.insert(texture_list, texture_id:t())
	end

	local dialog = EWS:SingleChoiceDialog(self._editor._main_frame, "Pick a global texture.", "Global Textures", texture_list, "")

	dialog:show_modal()

	local str = dialog:get_string_selection()

	if str ~= "" then
		self._value = str
		self._global_texture = true
		self._global_texture_type = str == "current_global_texture" and "cube" or "texture"

		self._node:clear_parameter("file")
		self._node:set_parameter("global_texture", self._value)
		self._node:set_parameter("type", self._global_texture_type)
		self._text:set_value(self._value .. " (Global)")
		self._editor:_update_output()
		self:update_live()
	end
end

function CoreMaterialEditorTexture:_on_browse()
	local current_path = nil

	if self._value then
		current_path = string.match(self._value, ".*/")

		if current_path then
			current_path = string.gsub(current_path, "/", "\\")
			current_path = managers.database:base_path() .. current_path
		end
	end

	local node, path = managers.database:load_node_dialog(self._right_panel, "Textures (*.dds)|*.dds", current_path)

	if path then
		self._global_texture = false
		self._value = managers.database:entry_path(path)

		self._node:clear_parameter("global_texture")
		self._node:clear_parameter("type")
		self._node:set_parameter("file", self._value)

		if self._parameter_info.name:s() == "reflection_texture" then
			self._node:set_parameter("type", "cubemap")
		end

		self._text:set_value(self._value)
		self._editor:_update_output()
		self:update_live()
	end
end

return CoreMaterialEditorTexture
