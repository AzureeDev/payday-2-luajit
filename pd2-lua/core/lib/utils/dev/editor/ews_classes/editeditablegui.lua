core:import("CoreEditorUtils")
core:import("CoreEws")

EditUnitEditableGui = EditUnitEditableGui or class(EditUnitBase)

function EditUnitEditableGui:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Gui Text",
		class = self
	})
	self._panel = panel
	self._ctrls = {}
	self._element_guis = {}
	self._fonts = {
		"core/fonts/diesel",
		"fonts/font_medium_shadow_mf",
		"fonts/font_small_shadow_mf",
		"fonts/font_eroded",
		"fonts/font_large_mf",
		"fonts/font_medium_mf",
		"fonts/font_small_mf"
	}
	self._aligns = {
		horizontal = {
			"left",
			"center",
			"right",
			"justified"
		},
		vertical = {
			"top",
			"center",
			"bottom"
		}
	}
	self._blend_modes = {
		"normal",
		"add",
		"mul",
		"mulx2",
		"sub",
		"darken",
		"lighten"
	}
	self._render_templates = {
		"diffuse_vc_decal",
		"Text",
		"TextDistanceField",
		"diffuse_vc_decal_distance_field"
	}
	local ctrlrs_sizer = EWS:BoxSizer("VERTICAL")

	self:_create_color_button(panel, ctrlrs_sizer)
	self:_create_text_box(panel, ctrlrs_sizer)
	self:_create_font_combobox(panel, ctrlrs_sizer)
	self:_create_font_size_slider(panel, ctrlrs_sizer)
	self:_create_text_aligns_combobox(panel, ctrlrs_sizer)
	self:_create_text_wrap_checkbox(panel, ctrlrs_sizer)
	self:_create_render_template_blend_mode_combobox(panel, ctrlrs_sizer)
	self:_create_alpha_slider(panel, ctrlrs_sizer)
	self:_create_shape_sliders(panel, ctrlrs_sizer)
	sizer:add(ctrlrs_sizer, 1, 1, "EXPAND")
	panel:layout()
	panel:set_enabled(false)
end

function EditUnitEditableGui:_create_color_button(panel, sizer)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 0, "")
	horizontal_sizer:add(EWS:StaticText(panel, "Color:", 0, ""), 0.5, 1, "EXPAND")

	local color_button = EWS:Button(panel, "", "", "BU_EXACTFIT")

	color_button:set_min_size(Vector3(18, 23, 0))
	color_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "show_color_dialog"), "")
	horizontal_sizer:add(color_button, 0, 0, "LEFT")

	self._ctrls.color_button = color_button
end

function EditUnitEditableGui:_create_text_box(panel, sizer)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 1, 1, "EXPAND,BOTTOM")
	horizontal_sizer:add(EWS:StaticText(panel, "Text:", 0, ""), 0.5, 1, "EXPAND")

	local gui_text = EWS:TextCtrl(panel, "none", "", "TE_MULTILINE,TE_WORDWRAP")

	gui_text:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_gui_text"), gui_text)
	horizontal_sizer:add(gui_text, 1, 1, "EXPAND")

	self._ctrls.gui_text = gui_text
end

function EditUnitEditableGui:_create_font_size_slider(panel, sizer)
	local horizontal_sizer = sizer
	self._font_size_params = {
		name_proportions = 1,
		name = "Font size:",
		ctrlr_proportions = 3,
		slider_ctrlr_proportions = 4,
		value = 1,
		tooltip = "Set the font size using the slider",
		min = 0.1,
		floats = 2,
		max = 10,
		panel = panel,
		sizer = horizontal_sizer
	}

	CoreEws.slider_and_number_controller(self._font_size_params)
	self._font_size_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_font_size"), nil)
	self._font_size_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_font_size"), nil)
	self._font_size_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_font_size"), nil)
	self._font_size_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "update_font_size"), nil)
end

function EditUnitEditableGui:_create_font_combobox(panel, sizer)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 1, "EXPAND")

	self._font_params = {
		name = "Font:",
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select a font from the combobox",
		sorted = false,
		ctrlr_proportions = 1,
		panel = panel,
		sizer = horizontal_sizer,
		options = self._fonts,
		value = self._fonts[1]
	}
	local ctrlr = CoreEws.combobox(self._font_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "update_font"), nil)

	self._ctrls.font_list = ctrlr
end

function EditUnitEditableGui:_create_text_aligns_combobox(panel, sizer)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 1, "EXPAND")

	self._aligns_horizontal_params = {
		name = "Horizontal:",
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select an align from the combobox",
		sorted = false,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = horizontal_sizer,
		options = self._aligns.horizontal,
		value = self._aligns.horizontal[1]
	}
	local ctrlr = CoreEws.combobox(self._aligns_horizontal_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "update_align"), nil)

	self._ctrls.align_horizontal = ctrlr
	self._aligns_vertical_params = {
		name = " Vertical:",
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select an align from the combobox",
		sorted = false,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = horizontal_sizer,
		options = self._aligns.vertical,
		value = self._aligns.vertical[1]
	}
	local ctrlr = CoreEws.combobox(self._aligns_vertical_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "update_vertical"), nil)

	self._ctrls.align_vertical = ctrlr
end

function EditUnitEditableGui:_create_text_wrap_checkbox(panel, sizer)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 0, "TOP,BOTTOM,RIGHT")

	local checkbox = EWS:CheckBox(panel, "Text Wrap ", "")

	checkbox:set_value(false)
	checkbox:set_tool_tip("Click to toggle")
	checkbox:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "update_text_wrap"), nil)
	horizontal_sizer:add(checkbox, 0, 1, "EXPAND,LEFT")

	self._ctrls.text_wrap = checkbox
	local checkbox = EWS:CheckBox(panel, "Text Word Wrap", "")

	checkbox:set_value(false)
	checkbox:set_tool_tip("Click to toggle")
	checkbox:set_enabled(false)
	checkbox:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "update_text_word_wrap"), nil)
	horizontal_sizer:add(checkbox, 0, 1, "EXPAND,LEFT")

	self._ctrls.text_word_wrap = checkbox

	horizontal_sizer:add_spacer(2, 0, 1, "")

	local checkbox = EWS:CheckBox(panel, "Debug", "")

	checkbox:set_value(false)
	checkbox:set_tool_tip("Click to toggle")
	checkbox:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "update_debug"), nil)
	horizontal_sizer:add(checkbox, 1, 1, "EXPAND,LEFT")

	self._ctrls.debug = checkbox
end

function EditUnitEditableGui:_create_render_template_blend_mode_combobox(panel, sizer)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 1, "EXPAND")

	self._render_template_params = {
		name = "Render Template:",
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select a Render Template from the combobox",
		sorted = false,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = horizontal_sizer,
		options = self._render_templates,
		value = self._render_templates[1]
	}
	local ctrlr = CoreEws.combobox(self._render_template_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "update_render_template"), nil)

	self._ctrls.render_list = ctrlr
	self._blend_mode_params = {
		name = " Blend Mode:",
		enabled = false,
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select a Blend Mode from the combobox",
		sorted = false,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = horizontal_sizer,
		options = self._blend_modes,
		value = self._blend_modes[1]
	}
	local ctrlr = CoreEws.combobox(self._blend_mode_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "update_blend_mode"), nil)

	self._ctrls.blend_list = ctrlr
end

function EditUnitEditableGui:_create_alpha_slider(panel, sizer)
	local horizontal_sizer = sizer
	self._alpha_params = {
		name_proportions = 1,
		name = "Alpha:",
		ctrlr_proportions = 3,
		slider_ctrlr_proportions = 4,
		value = 1,
		tooltip = "Set the alpha using the slider",
		min = 0,
		floats = 2,
		max = 1,
		panel = panel,
		sizer = horizontal_sizer
	}

	CoreEws.slider_and_number_controller(self._alpha_params)
	self._alpha_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_alpha"), nil)
	self._alpha_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_alpha"), nil)
	self._alpha_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_alpha"), nil)
	self._alpha_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "update_alpha"), nil)
end

function EditUnitEditableGui:_create_shape_sliders(panel, sizer)
	local horizontal_sizer = sizer

	sizer:add_spacer(0, 2, 0, "TOP")

	self._shape_params = {}

	for i, shape in ipairs({
		"x",
		"y",
		"w",
		"h"
	}) do
		self._shape_params[i] = {
			name_proportions = 1,
			ctrlr_proportions = 3,
			slider_ctrlr_proportions = 4,
			value = 1,
			tooltip = "Set shape using the slider",
			min = 0,
			floats = 2,
			max = 1,
			name = "Shape " .. shape .. ":",
			panel = panel,
			sizer = horizontal_sizer
		}

		CoreEws.slider_and_number_controller(self._shape_params[i])
		self._shape_params[i].slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_shape"), nil)
		self._shape_params[i].slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_shape"), nil)
		self._shape_params[i].number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_shape"), nil)
		self._shape_params[i].number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "update_shape"), nil)
	end
end

function EditUnitEditableGui:show_color_dialog()
	local colordlg = EWS:ColourDialog(Global.frame, true, self._ctrls.color_button:background_colour() / 255)

	if colordlg:show_modal() then
		self._ctrls.color_button:set_background_colour(colordlg:get_colour().x * 255, colordlg:get_colour().y * 255, colordlg:get_colour().z * 255)

		for _, unit in ipairs(self._ctrls.units) do
			if alive(unit) and unit:editable_gui() then
				unit:editable_gui():set_font_color(Vector3(colordlg:get_colour().x, colordlg:get_colour().y, colordlg:get_colour().z))
			end
		end
	end
end

function EditUnitEditableGui:update_debug()
	if self._no_event or not Application:production_build() then
		return
	end

	local enabled = self._ctrls.debug:get_value()

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_debug(enabled)
		end
	end
end

function EditUnitEditableGui:update_shape()
	if self._no_event then
		return
	end

	local shape = {
		self._shape_params[1].value,
		self._shape_params[2].value,
		self._shape_params[3].value,
		self._shape_params[4].value
	}

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_shape(shape)
		end
	end
end

function EditUnitEditableGui:update_alpha()
	if self._no_event then
		return
	end

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_alpha(self._alpha_params.value)
		end
	end
end

function EditUnitEditableGui:update_render_template()
	if self._no_event then
		return
	end

	local render_template = self._render_template_params.value

	self._ctrls.blend_list:set_enabled(render_template == "Text")

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_render_template(render_template)
		end
	end
end

function EditUnitEditableGui:update_blend_mode()
	if self._no_event then
		return
	end

	local blend_mode = self._blend_mode_params.value

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_blend_mode(blend_mode)
		end
	end
end

function EditUnitEditableGui:update_text_wrap()
	if self._no_event then
		return
	end

	local enabled = self._ctrls.text_wrap:get_value()

	self._ctrls.text_word_wrap:set_enabled(enabled)

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_wrap(enabled)
		end
	end
end

function EditUnitEditableGui:update_text_word_wrap()
	if self._no_event then
		return
	end

	local enabled = self._ctrls.text_word_wrap:get_value()

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_word_wrap(enabled)
		end
	end
end

function EditUnitEditableGui:update_align()
	if self._no_event then
		return
	end

	local align = self._aligns_horizontal_params.value

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_align(align)
		end
	end
end

function EditUnitEditableGui:update_vertical()
	if self._no_event then
		return
	end

	local align = self._aligns_vertical_params.value

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_vertical(align)
		end
	end
end

function EditUnitEditableGui:update_font()
	if self._no_event then
		return
	end

	local font = self._font_params.value

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_font(font)
		end
	end
end

function EditUnitEditableGui:update_gui_text(gui_text)
	if self._no_event then
		return
	end

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_text(utf8.from_latin1(gui_text:get_value()))
		end
	end
end

function EditUnitEditableGui:update_font_size()
	if self._no_event then
		return
	end

	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) and unit:editable_gui() then
			unit:editable_gui():set_font_size(self._font_size_params.value)
		end
	end
end

function EditUnitEditableGui:is_editable(unit, units)
	if alive(unit) and unit:editable_gui() then
		self._ctrls.unit = unit
		self._ctrls.units = units
		local font_options = clone(self._fonts)
		local default_font = self._ctrls.unit:editable_gui():default_font()

		if not table.contains(font_options, default_font) then
			table.insert(font_options, default_font)
		end

		CoreEws.update_combobox_options(self._font_params, font_options)

		self._no_event = true

		self._ctrls.gui_text:set_value(utf8.to_latin1(self._ctrls.unit:editable_gui():text()))

		local font_color = self._ctrls.unit:editable_gui():font_color()

		self._ctrls.color_button:set_background_colour(font_color.x * 255, font_color.y * 255, font_color.z * 255)
		CoreEws.change_slider_and_number_value(self._font_size_params, self._ctrls.unit:editable_gui():font_size())
		CoreEws.change_combobox_value(self._font_params, self._ctrls.unit:editable_gui():font())
		CoreEws.change_combobox_value(self._aligns_horizontal_params, self._ctrls.unit:editable_gui():align())
		CoreEws.change_combobox_value(self._aligns_vertical_params, self._ctrls.unit:editable_gui():vertical())
		CoreEws.change_combobox_value(self._blend_mode_params, self._ctrls.unit:editable_gui():blend_mode())
		CoreEws.change_combobox_value(self._render_template_params, self._ctrls.unit:editable_gui():render_template())
		CoreEws.change_slider_and_number_value(self._alpha_params, self._ctrls.unit:editable_gui():alpha())

		local shape = self._ctrls.unit:editable_gui():shape()

		for i, value in ipairs(shape) do
			CoreEws.change_slider_and_number_value(self._shape_params[i], value)
		end

		self._ctrls.text_wrap:set_value(self._ctrls.unit:editable_gui():wrap())
		self._ctrls.text_word_wrap:set_value(self._ctrls.unit:editable_gui():word_wrap())
		self._ctrls.text_word_wrap:set_enabled(self._ctrls.unit:editable_gui():wrap())
		self._ctrls.blend_list:set_enabled(self._ctrls.unit:editable_gui():render_template() == "Text")

		self._no_event = false

		return true
	end

	return false
end
