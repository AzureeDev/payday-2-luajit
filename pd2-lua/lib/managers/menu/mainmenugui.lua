require("lib/managers/menu/PlayerInventoryGui")

local IS_WIN_32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not IS_WIN_32

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local function format_round(num, round_value)
	return round_value and tostring(math.round(num)) or string.format("%.1f", num):gsub("%.?0+$", "")
end

MainMenuGui = MainMenuGui or class(PlayerInventoryGui)

function MainMenuGui:init(ws, fullscreen_ws, node)
	self._ws = managers.gui_data:create_saferect_workspace()
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._node = node
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	self._boxes = {}
	self._boxes_by_name = {}
	self._boxes_by_layer = {}
	self._max_layer = 1
	self._enabled = true
	self._update_boxes = {}
	self._data = node:parameters().menu_component_data or {
		selected_box = "play",
		current_state = "default"
	}
	self._node:parameters().menu_component_data = self._data
	self._input_focus = 1
	local boxes, layout = self:_get_current_box_layout()

	for id, data in pairs(boxes) do
		self:create_box(data)
	end

	self:layout_boxes(layout)

	self._legends_panel = self._panel:panel({
		w = self._panel:w() * 0.75,
		h = tweak_data.menu.pd2_medium_font_size
	})

	self._legends_panel:set_rightbottom(self._panel:w(), self._panel:h())
	self._legends_panel:text({
		text = "",
		name = "text",
		vertical = "bottom",
		align = "right",
		blend_mode = "add",
		halign = "right",
		valign = "bottom",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})
	self:_round_everything()

	local box = self:_get_selected_box()

	if box then
		box.selected = true

		self:_update_box_status(box, true)
		self:_update_legends(box.name)

		if box.select_anim then
			box.panel:stop()
			box.panel:animate(box.select_anim, box, true)
		end
	end

	managers.menu:active_menu().renderer:disable_input(0.2)
	managers.challenge:fetch_challenges()
	MenuCallbackHandler:leave_blackmarket()
end

function MainMenuGui:_get_current_box_layout(override_layout)
	local layout_name = "new_menu"

	return tweak_data.gui:get_main_menu_layout_by_name("main_menu_layout_" .. layout_name, self._panel:w(), self._panel:h())
end

function MainMenuGui:layout_boxes(layout)
	local box, align_box, right_align, left_align, top_align, bottom_align, x_offset, y_offset = nil

	for _, data in ipairs(layout or {}) do
		box = data.box and self._boxes_by_name[data.box]
		align_box = data.align_box and self._boxes_by_name[data.align_box]

		if box and align_box then
			right_align = data.right_align
			left_align = data.left_align
			top_align = data.top_align
			bottom_align = data.bottom_align

			if right_align then
				if right_align == "left" then
					box.panel:set_right(align_box.panel:left())
				else
					box.panel:set_right(align_box.panel:right())
				end
			elseif left_align then
				if left_align == "left" then
					box.panel:set_left(align_box.panel:left())
				else
					box.panel:set_left(align_box.panel:right())
				end
			end

			if top_align then
				if top_align == "top" then
					box.panel:set_top(align_box.panel:top())
				else
					box.panel:set_top(align_box.panel:bottom())
				end
			elseif bottom_align then
				if bottom_align == "top" then
					box.panel:set_bottom(align_box.panel:top())
				else
					box.panel:set_bottom(align_box.panel:bottom())
				end
			end

			x_offset = data.x_offset or 0
			y_offset = data.y_offset or 0

			box.panel:move(x_offset, y_offset)
		end
	end
end

function MainMenuGui:set_state(state, selected)
	if state ~= self._data.current_state then
		self._data.current_state = state

		for _, box in pairs(self._boxes) do
			if alive(box.panel) then
				box.panel:set_visible(self:_box_in_state(box, state))
			end
		end

		self:set_selected_box(selected)
		managers.menu:active_menu().renderer:disable_input(0.2)
	end
end

local box_objects = {
	"text_object",
	"info_text_object",
	"image_objects",
	"borders_object",
	"bg_object"
}

function MainMenuGui:create_box(params, index)
	local x = params.x or 0
	local y = params.y or 0
	local w = math.max(params.w or params.width or 1, 1)
	local h = math.max(params.h or params.height or 1, 1)
	local alpha = params.alpha or params.a or 1
	local shrink_text = params.shrink_text == nil and true or params.shrink_text
	local adept_width = params.adept_width or false
	local keep_box_ratio = params.keep_box_ratio == nil and true or params.keep_box_ratio
	local box_halign = params.halign or "left"
	local box_valign = params.valign or "top"
	local border_padding = params.border_padding or params.padding or 5
	local padding = params.padding or 0
	local x_padding = params.x_padding or 0
	local y_padding = params.y_padding or 0
	local text = params.text or false
	local info_text = params.info_text or false
	local unselected_text = params.unselected_text or text
	local images = params.images or false
	local select_area = params.select_area or false
	local use_borders = params.use_borders == nil and true or params.use_borders
	local use_background = params.use_background or false
	local background_image = params.bg_image or false
	local clbks = params.callbacks or params.clbks or false
	local links = params.links or false
	local can_select = params.can_select == nil and true or params.can_select
	local wanted_states = params.states or false
	local wanted_state = params.state
	local states = {}

	if wanted_states then
		for _, state in ipairs(wanted_states) do
			states[state] = true
		end
	end

	if wanted_state then
		states[wanted_state] = true
	end

	if table.size(states) == 0 then
		states.default = true
	end

	local layer = params.layer or 1
	local enabled = params.enabled == nil and true or params.enabled
	local name = params.name or tostring(#self._boxes + 1)

	if self._boxes_by_name[name] then
		Application:error("[MainMenuGui:create_box] Failed creating box! Box with that name already exists", name)

		return
	end

	local select_anim = params.select_anim or false
	local unselect_anim = params.unselect_anim or false
	w = math.max(w, border_padding * 2 + 1)
	h = math.max(h, border_padding * 2 + 1)
	local panel = self._panel:panel({
		name = name,
		x = x,
		y = y,
		w = w,
		h = h,
		alpha = alpha,
		layer = layer * 10
	})
	local text_object, info_text_object, image_objects, borders_object, bg_object, select_object = nil

	if text then
		local align = params.text_align or false
		local vertical = params.text_vertical or false
		local selected_color = params.text_selected_color or params.text_color or tweak_data.screen_colors.text
		local unselected_color = params.text_unselected_color or params.text_color or tweak_data.screen_colors.button_stage_3:with_alpha(0.25)
		local blend_mode = params.text_blend_mode or params.blend_mode or "add"
		local rotation = params.text_rotation or nil
		local wrap = params.text_wrap or false
		local word_wrap = params.text_word_wrap or false
		local font = params.font or tweak_data.menu.pd2_small_font
		local font_size = params.font_size or tweak_data.menu.pd2_small_font_size
		local text_x = params.text_x or 0
		local text_y = params.text_y or 0
		local gui_object = panel:text({
			layer = 5,
			text = unselected_text,
			font = font,
			font_size = font_size,
			color = unselected_color,
			blend_mode = blend_mode,
			rotation = rotation
		})

		if wrap then
			gui_object:set_wrap(wrap)
			gui_object:set_word_wrap(word_wrap)
			gui_object:set_w(panel:w() - (border_padding * 2 + x_padding * 2 + text_x * 2))
			gui_object:set_h(panel:h() - (border_padding * 2 + y_padding * 2 + text_y * 2))
			gui_object:set_x(border_padding + x_padding)
			gui_object:set_y(border_padding + y_padding)
			gui_object:set_align(align or "center")
			gui_object:set_vertical(vertical or "center")
		else
			make_fine_text(gui_object)

			local needed_width = gui_object:w() + border_padding * 2 + x_padding * 2

			if w < needed_width then
				if shrink_text then
					gui_object:set_font_size(font_size * w / needed_width)
					make_fine_text(gui_object)
				elseif adept_width then
					w = needed_width

					panel:set_w(w)

					if keep_box_ratio then
						local ratio = w / h
						h = panel:w() / ratio

						panel:set_h(h)
					end
				end
			end

			if vertical == "top" then
				gui_object:set_top(border_padding)
			elseif vertical == "bottom" then
				gui_object:set_bottom(panel:h() - border_padding)
			else
				gui_object:set_center_y(panel:h() / 2)
			end

			if align == "left" then
				gui_object:set_left(border_padding)
			elseif align == "right" then
				gui_object:set_right(panel:w() - border_padding)
			else
				gui_object:set_center_x(panel:w() / 2)
			end
		end

		gui_object:set_position(math.round(gui_object:x() + text_x), math.round(gui_object:y() + text_y))

		text_object = {
			gui = gui_object,
			selected_text = text,
			unselected_text = unselected_text,
			selected_color = selected_color,
			unselected_color = unselected_color,
			shape = {
				gui_object:shape()
			}
		}
	end

	if info_text then
		local selected_color = params.text_selected_color or params.text_color or tweak_data.screen_colors.text
		local unselected_color = params.text_unselected_color or params.text_color or tweak_data.screen_colors.button_stage_3:with_alpha(0.25)
		local blend_mode = params.text_blend_mode or params.blend_mode or "add"
		local rotation = params.text_rotation or nil
		local font = params.font or tweak_data.menu.pd2_small_font
		local font_size = params.font_size or tweak_data.menu.pd2_small_font_size
		local text_x = params.text_x or 0
		local text_y = params.text_y or 0
		local gui_object = panel:text({
			layer = 5,
			text = info_text,
			font = font,
			font_size = font_size,
			color = unselected_color,
			blend_mode = blend_mode,
			rotation = rotation
		})

		gui_object:set_wrap(params.info_text_wrap or false)
		gui_object:set_word_wrap(params.info_text_word_wrap or false)
		gui_object:set_w(panel:w() - (border_padding * 2 + x_padding * 2 + text_x * 2))
		gui_object:set_h(panel:h() - (border_padding * 2 + y_padding * 2 + text_y * 2))
		gui_object:set_x(border_padding + x_padding)
		gui_object:set_y(border_padding + y_padding)
		gui_object:set_align(params.info_text_align or "center")
		gui_object:set_vertical(params.info_text_vertical or "center")
		gui_object:set_position(math.round(gui_object:x() + text_x), math.round(gui_object:y() + text_y))

		info_text_object = {
			gui = gui_object,
			selected_text = info_text,
			unselected_text = info_text,
			selected_color = selected_color,
			unselected_color = unselected_color,
			shape = {
				gui_object:shape()
			}
		}
	end

	if select_area then
		select_object = panel:panel(select_area)
	else
		select_object = panel:panel({
			halign = "scale",
			align = "scale",
			vertical = "scale",
			valign = "scale"
		})
	end

	if images then
		local text_vertical = params.text_vertical or "top"
		local async_loading = true
		image_objects = {}
		local requested_textures = {}
		local requested_indices = {}

		for _, data in ipairs(images) do
			local image = data.texture

			if image then
				local selected_color = data.selected_color or data.color or params.image_selected_color or params.image_color or Color.white
				local unselected_color = data.unselected_color or data.color or params.image_unselected_color or params.image_color or Color.white
				local render_template = data.render_template or params.image_render_template
				local animation_func = data.animation_func or data.anim_func or data.anim or nil
				local blend_mode = data.blend_mode or params.image_blend_mode or params.blend_mode or "normal"
				local texture_rect = data.texture_rect or nil
				local image_size_mul = data.size_mul or 1
				local layer = data.layer or 0
				local visible = data.visible ~= false and true or false
				local keep_aspect_ratio = data.keep_aspect_ratio ~= false and true or false
				local image_rotation = data.rotation or params.image_rotation or false
				local image_w = data.image_width or false
				local image_h = data.image_height or false
				local panel_move_x = data.panel_move_x or 0
				local panel_move_y = data.panel_move_y or 0
				local panel_grow_w = data.panel_grow_w or 0
				local panel_grow_h = data.panel_grow_h or 0
				local panel_width = panel:w() + panel_grow_w
				local panel_height = panel:h() + panel_grow_h
				local gui_object = panel:panel({
					w = panel_width,
					h = panel_height,
					layer = layer + 1,
					visible = visible
				})

				gui_object:set_center(panel:w() / 2, panel:h() / 2)
				gui_object:move(panel_move_x, panel_move_y)

				local image_panel = gui_object:panel({
					w = image_w or gui_object:w() * image_size_mul,
					h = image_h or gui_object:h() * image_size_mul
				})

				image_panel:set_center(gui_object:w() / 2, gui_object:h() / 2)

				local params = {
					box_name = name,
					panel = image_panel,
					selected_color = selected_color,
					unselected_color = unselected_color,
					render_template = render_template,
					blend_mode = blend_mode,
					texture_rect = texture_rect,
					animation = animation_func,
					keep_aspect_ratio = keep_aspect_ratio,
					rotation = image_rotation
				}

				if not async_loading then
					self:texture_loaded_clbk(Idstring(image), params)
				else
					local texture_loaded_clbk = callback(self, self, "texture_loaded_clbk", params)

					table.insert(requested_textures, image)
					table.insert(requested_indices, managers.menu_component:request_texture(image, texture_loaded_clbk))
				end

				table.insert(image_objects, {
					gui = image_panel,
					panel = gui_object,
					selected_color = selected_color,
					unselected_color = unselected_color,
					params = params,
					shape = {
						image_panel:shape()
					}
				})
			end
		end

		image_objects.requested_textures = requested_textures
		image_objects.requested_indices = requested_indices
	end

	if use_background then
		local selected_color = params.bg_selected_color or params.bg_color or Color.white
		local unselected_color = params.bg_unselected_color or params.bg_color or Color.white
		local selectable = params.bg_selectable or false
		local selected_blend_mode = params.bg_selected_blend_mode or params.bg_blend_mode or params.blend_mode or "add"
		local unselected_blend_mode = params.bg_unselected_blend_mode or params.bg_blend_mode or params.blend_mode or "add"
		local bg_select_area = params.bg_select_area or false
		local bg_rotation = params.bg_rotation or false
		local gui_object = nil

		if background_image then
			gui_object = (bg_select_area and select_object or panel):bitmap({
				layer = 0,
				texture = background_image,
				color = unselected_color,
				blend_mode = unselected_blend_mode,
				visible = not selectable
			})
		else
			gui_object = (bg_select_area and select_object or panel):rect({
				layer = 0,
				color = unselected_color,
				blend_mode = unselected_blend_mode,
				visible = not selectable
			})
		end

		if bg_rotation then
			gui_object:set_rotation(bg_rotation)
		end

		bg_object = {
			gui = gui_object,
			selected_color = selected_color,
			unselected_color = unselected_color,
			selected_blend_mode = selected_blend_mode,
			unselected_blend_mode = unselected_blend_mode
		}
	end

	if box_halign == "right" then
		panel:set_right(x)
	else
		panel:set_left(x)
	end

	if box_valign == "bottom" then
		panel:set_bottom(y)
	else
		panel:set_top(y)
	end

	local box = {
		selected = false,
		name = name,
		layer = layer,
		panel = panel,
		clbks = clbks,
		text_object = text_object,
		info_text_object = info_text_object,
		image_objects = image_objects,
		borders_object = borders_object,
		bg_object = bg_object,
		enabled = enabled,
		select_anim = select_anim,
		unselect_anim = unselect_anim,
		links = links,
		can_select = can_select,
		params = params,
		select_object = select_object,
		states = states
	}

	if unselect_anim then
		panel:animate(unselect_anim, box, true)
	end

	if index and not self._boxes[index] then
		self._boxes[index] = box
	else
		self._boxes[#self._boxes + 1] = box
	end

	if params.update_func then
		table.insert(self._update_boxes, name)
	end

	self._boxes_by_name[name] = box
	self._boxes_by_layer[layer] = self._boxes_by_layer[layer] or {}
	self._boxes_by_layer[layer][#self._boxes_by_layer[layer] + 1] = box
	self._max_layer = math.max(self._max_layer, layer)

	panel:set_visible(self:_box_in_state(box))

	return panel, box
end

function MainMenuGui:_box_in_state(box, state)
	state = state or self._data.current_state

	return box.states and not not box.states[state]
end

function MainMenuGui:update_box(box, params, skip_update_other)
	if not box or not box.params then
		return
	end

	local selected = box.selected
	local box_params = box.params
	box_params.links = box.links

	if params then
		for i, d in pairs(params) do
			box_params[i] = d
		end
	end

	local visible = box.panel:visible()

	self:unretrieve_box_textures(box)

	if box.panel then
		self._panel:remove(box.panel)
	end

	local box_index = 0

	for index, layer_box in ipairs(self._boxes_by_layer[box.layer] or {}) do
		if layer_box.name == box_params.name then
			box_index = index

			break
		end
	end

	if box_index ~= 0 then
		table.remove(self._boxes_by_layer[box.layer], box_index)
	end

	local box_index = 0

	for index, index_box in ipairs(self._boxes) do
		if index_box.name == box_params.name then
			box_index = index

			break
		end
	end

	self._boxes[box_index] = nil
	self._boxes_by_name[box_params.name] = nil
	local panel, new_box = self:create_box(box_params, box_index)

	panel:set_visible(visible)

	if selected then
		new_box.selected = true

		self:_update_box_status(new_box, true)

		if new_box.select_anim then
			new_box.panel:stop()
			new_box.panel:animate(new_box.select_anim, new_box, true)
		end
	end
end

function MainMenuGui:texture_loaded_clbk(params, texture_idstring)
	local box_name = params.box_name
	local box = self._boxes_by_name[box_name]
	local panel = params.panel
	local texture = texture_idstring
	local selected_color = params.selected_color
	local unselected_color = params.unselected_color
	local render_template = params.render_template
	local blend_mode = params.blend_mode
	local texture_rect = params.texture_rect
	local image_size_mul = params.image_size_mul or 1
	local animation = params.animation or nil
	local keep_aspect_ratio = params.keep_aspect_ratio
	local rotation = params.rotation
	local gui_object = panel:bitmap({
		halign = "scale",
		valign = "scale",
		texture = texture,
		color = box and box.selected and selected_color or unselected_color,
		render_template = render_template,
		blend_mode = blend_mode,
		texture_rect = texture_rect
	})
	local panel_width = panel:width()
	local panel_height = panel:height()
	local texture_width = texture_rect and texture_rect[3] or gui_object:texture_width()
	local texture_height = texture_rect and texture_rect[4] or gui_object:texture_height()

	if panel_height <= 0 then
		Application:error("[MainMenuGui:create_box] Failed creating image! Box not large enough")
		panel:remove(gui_object)

		gui_object = nil

		return
	elseif keep_aspect_ratio then
		local aspect = panel_width / panel_height
		local sw = math.max(texture_width, texture_height * aspect)
		local sh = math.max(texture_height, texture_width / aspect)
		local dw = texture_width / sw
		local dh = texture_height / sh

		gui_object:set_size(math.round(dw * panel_width * image_size_mul), math.round(dh * panel_height * image_size_mul))
		gui_object:set_center(panel_width / 2, panel_height / 2)
	else
		gui_object:set_size(panel_width, panel_height)
		gui_object:set_center(panel_width / 2, panel_height / 2)
	end

	if rotation then
		gui_object:set_rotation(rotation)
	end

	if animation then
		gui_object:animate(animation)
	end
end

function MainMenuGui:update(t, dt)
	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return
	end

	local box = nil

	for _, box_name in ipairs(self._update_boxes or {}) do
		box = self._boxes_by_name[box_name]

		if box and box.params.update_func then
			box.params.update_func(self, box, t, dt)
		end
	end
end

function MainMenuGui:next_page()
	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return
	end

	MainMenuGui.super.next_page(self)
end

function MainMenuGui:previous_page()
	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return
	end

	MainMenuGui.super.previous_page(self)
end

function MainMenuGui:confirm_pressed()
	if not self._panel:visible() then
		return false
	end

	if not self._enabled then
		return
	end

	local box = self:_get_selected_box()

	if box and box.panel:tree_visible() and box.clbks and box.clbks.left then
		managers.menu_component:post_event("menu_enter")
		box.clbks.left(box)
	end
end

function MainMenuGui:input_focus()
	return self._enabled and self._panel:visible() and self._input_focus
end

function MainMenuGui:_set_variables_on_gui_hierarchy(gui, variables)
	if not alive(gui) then
		return
	end

	if gui.children then
		for _, child in ipairs(gui:children()) do
			self:_set_variables_on_gui_hierarchy(child, variables)
		end
	end

	if variables.color and gui.set_color then
		gui:set_color(variables.color)
	end

	if variables.blend_mode and gui.set_blend_mode then
		gui:set_blend_mode(variables.blend_mode)
	end

	if variables.alpha and gui.set_alpha then
		gui:set_alpha(variables.alpha)
	end
end

function MainMenuGui:_update_box_status(box, selected)
	local box_object = nil

	local function _update_box_object(object)
		local variables = {
			color = selected and object.selected_color or object.unselected_color or nil,
			blend_mode = selected and object.selected_blend_mode or object.unselected_blend_mode or nil,
			alpha = selected and object.selected_alpha or object.unselected_alpha or nil
		}

		if table.size(variables) > 0 then
			self:_set_variables_on_gui_hierarchy(object.gui, variables)
		end
	end

	for i, object_name in ipairs(box_objects) do
		box_object = box[object_name]

		if box_object then
			if box_object.gui then
				_update_box_object(box_object)
			else
				for _, object in ipairs(box_object) do
					_update_box_object(object)
				end
			end
		end
	end

	local text_object = box.text_object

	if text_object and text_object.selected_text and text_object.unselected_text then
		local panel = box.panel
		local align = box.params and box.params.text_align or false
		local vertical = box.params and box.params.text_vertical or false
		local gui_object = text_object.gui
		local border_padding = box.params and (box.params.border_padding or box.params.padding) or 5
		local shrink_text = box.params and box.params.shrink_text or true
		local adept_width = box.params and box.params.adept_width or false
		local keep_box_ratio = box.params and box.params.keep_box_ratio or true
		local font = box.params and box.params.font or tweak_data.menu.pd2_small_font
		local font_size = box.params and box.params.font_size or tweak_data.menu.pd2_small_font_size
		local text_x = box.params and box.params.text_x or 0
		local text_y = box.params and box.params.text_y or 0
		local wrap = box.params.text_wrap or false
		local word_wrap = box.params.text_word_wrap or false
		local x_padding = box.params.x_padding or 0
		local y_padding = box.params.y_padding or 0

		gui_object:set_font_size(font_size)
		gui_object:set_text(selected and text_object.selected_text or text_object.unselected_text)
		gui_object:set_wrap(wrap)
		gui_object:set_word_wrap(word_wrap)

		if wrap then
			gui_object:set_w(panel:w() - (border_padding * 2 + x_padding * 2 + text_x * 2))
			gui_object:set_h(panel:h() - (border_padding * 2 + y_padding * 2 + text_y * 2))
			gui_object:set_x(border_padding + x_padding)
			gui_object:set_y(border_padding + y_padding)
			gui_object:set_align(align or "center")
			gui_object:set_vertical(vertical or "center")
		else
			make_fine_text(gui_object)

			local w = box.panel:w()
			local needed_width = gui_object:w() + border_padding * 2

			if w < needed_width then
				if shrink_text then
					gui_object:set_font_size(font_size * w / needed_width)
					make_fine_text(gui_object)
				elseif box.params and adept_width then
					panel:set_w(needed_width)

					if keep_box_ratio then
						local ratio = w / h

						panel:set_h(panel:w() / ratio)
					end
				end
			end

			if vertical == "top" then
				gui_object:set_top(border_padding)
			elseif vertical == "bottom" then
				gui_object:set_bottom(panel:h() - border_padding)
			else
				gui_object:set_center_y(panel:h() / 2)
			end

			if align == "left" then
				gui_object:set_left(border_padding)
			elseif align == "right" then
				gui_object:set_right(panel:w() - border_padding)
			else
				gui_object:set_center_x(panel:w() / 2)
			end
		end

		gui_object:set_position(math.round(gui_object:x() + text_x), math.round(gui_object:y() + text_y))
	end
end

function MainMenuGui:back_pressed(button)
	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return
	end

	self:set_state("default", "play")
end

function MainMenuGui:special_btn_pressed(button)
	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return
	end

	if button == Idstring("menu_preview_item_alt") then
		local box = self:_get_selected_box()

		if box and box.panel:tree_visible() and box.clbks and box.clbks.right then
			box.clbks.right(box)
		end
	end
end

function MainMenuGui:_update_legends(name)
	local box = self._boxes_by_name[name]

	if box then
		local show_select = box.clbks and box.clbks.left and true or false
		local show_back = self._data.current_state ~= "default"

		if not managers.menu:is_pc_controller() then
			local legends = {
				[#legends + 1] = {
					string_id = "menu_legend_rotate"
				},
				[#legends + 1] = {
					string_id = "menu_legend_preview_move"
				}
			}

			if show_select then
				legends[#legends + 1] = {
					string_id = "menu_legend_select"
				}
			end

			if show_back then
				legends[#legends + 1] = {
					string_id = "menu_legend_back"
				}
			end

			local legend_text = ""

			for i, legend in ipairs(legends) do
				local spacing = i > 1 and "  |  " or ""
				legend_text = legend_text .. spacing .. managers.localization:to_upper_text(legend.string_id, {
					BTN_UPDATE = managers.localization:btn_macro("menu_update"),
					BTN_BACK = managers.localization:btn_macro("back")
				})
			end

			self._legends_panel:child("text"):set_text(legend_text)
		end
	end
end

function MainMenuGui:set_selected_box(selected)
	if self._data.selected_box ~= selected then
		local new_box = self._boxes_by_name[selected]

		if new_box and new_box.panel:tree_visible() then
			local selected_box = self:_get_selected_box()
			selected_box.selected = false

			self:_update_box_status(selected_box, false)

			if selected_box.unselect_anim then
				selected_box.panel:stop()
				selected_box.panel:animate(selected_box.unselect_anim, selected_box)
			end

			self._data.selected_box = selected
			new_box.selected = true

			self:_update_box_status(new_box, true)
			self:_update_legends(new_box.name)

			if new_box.select_anim then
				new_box.panel:stop()
				new_box.panel:animate(new_box.select_anim, new_box)
			end
		end
	end
end

function MainMenuGui:_move(dir, box)
	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return
	end

	local move_box = box or self:_get_selected_box()

	if move_box and move_box.links then
		local linked_box_name = move_box.links[dir]

		if linked_box_name then
			local new_box = self._boxes_by_name[linked_box_name]

			if new_box and not new_box.panel:tree_visible() then
				if new_box.links and new_box.links[dir] then
					return self:_move(dir, new_box)
				end

				return
			end

			managers.menu_component:post_event("highlight")
			self:set_selected_box(linked_box_name)
		end
	end
end

function MainMenuGui:mouse_moved(o, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if not self._panel:visible() then
		return false, "arrow"
	end

	if not self._enabled then
		return false, "arrow"
	end

	local used = false
	local pointer = "arrow"
	local mouse_over_selected_box = nil

	for i = self._max_layer, 1, -1 do
		if self._boxes_by_layer[i] then
			for _, box in ipairs(self._boxes_by_layer[i]) do
				if alive(box.panel) and box.panel:tree_visible() and box.can_select and box.select_object:inside(x, y) then
					self._data.selected_box = box.name
					mouse_over_selected_box = box.name
					used = true
					pointer = "link"

					break
				end
			end
		end

		if used then
			break
		end
	end

	for _, box in ipairs(self._boxes) do
		if self._data.selected_box == box.name then
			if not box.selected then
				box.selected = true

				managers.menu_component:post_event("highlight")
				self:_update_box_status(box, true)

				if box.select_anim then
					box.panel:stop()
					box.panel:animate(box.select_anim, box)
				end
			end
		elseif box.selected then
			box.selected = false

			self:_update_box_status(box, false)

			if box.unselect_anim then
				box.panel:stop()
				box.panel:animate(box.unselect_anim, box)
			end
		end
	end

	if self._mouse_over_selected_box ~= mouse_over_selected_box then
		self._mouse_over_selected_box = mouse_over_selected_box
	end

	self._input_focus = pointer == "arrow" and 2 or 1

	return used, pointer
end

function MainMenuGui:mouse_pressed(button, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if not self._panel:visible() then
		return false
	end

	if not self._enabled then
		return
	end

	local left_clicked = button == Idstring("0")
	local right_clicked = button == Idstring("1")
	local scroll_up = button == Idstring("mouse wheel up")
	local scroll_down = button == Idstring("mouse wheel down")
	local box = self:_get_selected_box()

	if box and box.clbks and box.panel:tree_visible() and box.select_object:inside(x, y) then
		if left_clicked and box.clbks.left then
			managers.menu_component:post_event("menu_enter")
			box.clbks.left(box)
		elseif right_clicked and box.clbks.right then
			box.clbks.right(box)
		elseif scroll_up and box.clbks.up then
			box.clbks.up(box)
		elseif scroll_down and box.clbks.down then
			box.clbks.down(box)
		end
	end
end

function MainMenuGui:set_video(video)
	if alive(self._video) then
		self._video:parent():remove(self._video)
	end

	self._video = video
end

function MainMenuGui:set_enabled(enabled)
	self._enabled = enabled

	if alive(self._ws) then
		self._ws:set_frozen(not enabled)
	end

	if alive(self._fullscreen_ws) then
		self._fullscreen_ws:set_frozen(not enabled)
	end

	if alive(self._video) then
		if enabled then
			self._video:play()
		else
			self._video:pause()
		end
	end

	if not enabled then
		self._legends_panel:child("text"):set_text("")
	else
		local box = self:_get_selected_box()

		if box then
			self:_update_legends(box.name)
		end
	end
end

function MainMenuGui:unretrieve_box_textures(box)
	local object = nil

	for _, object_name in ipairs(box_objects) do
		object = box[object_name]

		if object and object.requested_textures then
			for i = 1, #object.requested_textures do
				if object.requested_indices[i] then
					managers.menu_component:unretrieve_texture(object.requested_textures[i], object.requested_indices[i])
				end
			end
		end
	end
end

function MainMenuGui:close()
	for _, box in ipairs(self._boxes) do
		self:unretrieve_box_textures(box)
	end

	if alive(self._ws) then
		managers.gui_data:destroy_workspace(self._ws)

		self._ws = nil
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end

	self._boxes = {}
	self._boxes_by_name = {}
	self._boxes_by_layer = {}
end

function MainMenuGui:reload()
	self:close()
	self:init(self._ws, self._fullscreen_ws, self._node)
end
