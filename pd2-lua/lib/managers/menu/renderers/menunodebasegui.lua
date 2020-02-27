require("lib/managers/menu/BoxGuiObject")

MenuNodeBaseGui = MenuNodeBaseGui or class(MenuNodeGui)
MenuNodeBaseGui.massive_font = tweak_data.menu.pd2_massive_font
MenuNodeBaseGui.large_font = tweak_data.menu.pd2_large_font
MenuNodeBaseGui.medium_font = tweak_data.menu.pd2_medium_font
MenuNodeBaseGui.small_font = tweak_data.menu.pd2_small_font
MenuNodeBaseGui.massive_font_size = tweak_data.menu.pd2_massive_font_size
MenuNodeBaseGui.large_font_size = tweak_data.menu.pd2_large_font_size
MenuNodeBaseGui.medium_font_size = tweak_data.menu.pd2_medium_font_size
MenuNodeBaseGui.small_font_size = tweak_data.menu.pd2_small_font_size
MenuNodeBaseGui.text_color = tweak_data.screen_colors.text
MenuNodeBaseGui.button_default_color = tweak_data.screen_colors.button_stage_3
MenuNodeBaseGui.button_highlighted_color = tweak_data.screen_colors.button_stage_2
MenuNodeBaseGui.button_selected_color = tweak_data.screen_colors.button_stage_1
MenuNodeBaseGui.is_win32 = SystemInfo:platform() == Idstring("WIN32")

function MenuNodeBaseGui.make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return text:x(), text:y(), w, h
end

function MenuNodeBaseGui.rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			MenuNodeBaseGui.rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function MenuNodeBaseGui:init(node, layer, parameters)
	MenuNodeBaseGui.super.init(self, node, layer, parameters)
	self:setup()
end

function MenuNodeBaseGui:setup()
	self._requested_textures = {}
	self._gui_boxes = {}
	self._text_buttons = {}
	self.is_pc_controller = managers.menu:is_pc_controller()
end

function MenuNodeBaseGui:create_text_button(params)
	local left = params.left or params.x
	local right = params.right
	local top = params.top or params.y
	local bottom = params.bottom
	local text = params.text or params.text_id and managers.localization:text(params.text_id) or ""

	if params.text_to_upper then
		text = utf8.to_upper(text)
	end

	local clbk = params.clbk
	local layer = params.layer or self.layers.items
	local hide_blur = params.hide_blur
	local disabled = params.disabled
	local font = params.font or self.small_font
	local font_size = params.font_size or self.small_font_size
	local button_panel = self.safe_rect_panel:panel({
		x = left,
		y = top,
		layer = layer,
		visible = not disabled
	})
	local gui_blur = button_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "button_blur",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		visible = not hide_blur
	})
	local gui_text = button_panel:text({
		name = "button_text",
		blend_mode = "add",
		layer = 0,
		text = text,
		font = font,
		font_size = font_size,
		color = self.is_win32 and self.button_default_color or self.text_color
	})

	self.make_fine_text(gui_text)
	button_panel:set_size(gui_text:size())
	gui_blur:set_size(button_panel:size())

	if right then
		button_panel:set_right(right)
	end

	if bottom then
		button_panel:set_bottom(bottom)
	end

	table.insert(self._text_buttons, {
		highlighted = false,
		panel = button_panel,
		text = gui_text,
		blur = gui_blur,
		clbk = clbk,
		params = params.params
	})

	return button_panel
end

function MenuNodeBaseGui:create_gui_box(panel, params)
	if not alive(panel) then
		return
	end

	local box = BoxGuiObject:new(panel, params or {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local name = params and params.name or panel:name()

	if name and name ~= "" then
		if self._gui_boxes[name] then
			Application:error("[MenuNodeBaseGui:create_gui_box] GUI Box with that name already exists", name)
			table.insert(self._gui_boxes, box)
		else
			self._gui_boxes[name] = box
		end
	else
		table.insert(self._gui_boxes, box)
	end
end

function MenuNodeBaseGui:update_info(button)
end

function MenuNodeBaseGui:mouse_moved(o, x, y)
	local used = false
	local icon = "arrow"

	for _, button in ipairs(self._text_buttons) do
		if alive(button.panel) and button.panel:visible() then
			if button.panel:inside(x, y) then
				if not button.highlighted then
					button.highlighted = true

					managers.menu_component:post_event("highlight")

					if alive(button.text) then
						button.text:set_color(button.highlighted_color or self.button_highlighted_color)
					end

					if alive(button.image) then
						button.image:set_color(button.highlighted_color or self.button_highlighted_color)
					end
				end

				self:update_info(button)

				icon = "link"
				used = true
			elseif button.highlighted then
				button.highlighted = false

				if alive(button.text) then
					button.text:set_color(button.default_color or self.button_default_color)
				end

				if alive(button.image) then
					button.image:set_color(button.default_color or self.button_default_color)
				end
			end
		end
	end

	if not used then
		self:update_info()
	end

	return used, icon
end

function MenuNodeBaseGui:mouse_pressed(button, x, y)
	if button == Idstring("0") or button == Idstring("1") then
		for _, btn in ipairs(self._text_buttons) do
			if alive(btn.panel) and btn.panel:visible() and btn.panel:inside(x, y) then
				if btn.clbk then
					btn.clbk(button, btn.params)
				end

				managers.menu_component:post_event("menu_enter")

				return true
			end
		end
	end

	return MenuNodeBaseGui.super.mouse_pressed(self, button, x, y)
end

function MenuNodeBaseGui:mouse_released(button, x, y)
end

function MenuNodeBaseGui:confirm_pressed()
end

function MenuNodeBaseGui:previous_page()
end

function MenuNodeBaseGui:next_page()
end

function MenuNodeBaseGui:move_up()
end

function MenuNodeBaseGui:move_down()
end

function MenuNodeBaseGui:move_left()
end

function MenuNodeBaseGui:move_right()
end

function MenuNodeBaseGui:request_texture(texture_path, panel, keep_aspect_ratio, blend_mode)
	if not managers.menu_component then
		return
	end

	local texture_count = managers.menu_component:request_texture(texture_path, callback(self, self, "texture_done_clbk", {
		panel = panel,
		keep_aspect_ratio = keep_aspect_ratio,
		blend_mode = blend_mode
	}))

	if texture_count ~= false then
		table.insert(self._requested_textures, {
			texture_count = texture_count,
			texture = texture_path
		})
	end
end

function MenuNodeBaseGui:unretrieve_textures()
	if self._requested_textures then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end
	end

	self._requested_textures = {}
end

function MenuNodeBaseGui:texture_done_clbk(params, texture_ids)
	params = params or {}
	local panel = params.panel or params[1]
	local keep_aspect_ratio = params.keep_aspect_ratio
	local blend_mode = params.blend_mode
	local name = params.name or "streamed_texture"

	if not alive(panel) then
		Application:error("[MenuNodeBaseGui:texture_done_clbk] Missing GUI panel", "texture_ids", texture_ids, "params", inspect(params))

		return
	end

	local image = panel:bitmap({
		name = name,
		texture = texture_ids,
		blend_mode = blend_mode
	})

	if keep_aspect_ratio then
		local texture_width = image:texture_width()
		local texture_height = image:texture_height()
		local panel_width = panel:w()
		local panel_height = panel:h()
		local tw = texture_width
		local th = texture_height
		local pw = panel_width
		local ph = panel_height

		if tw == 0 or th == 0 then
			Application:error("[MenuNodeBaseGui:texture_done_clbk] Texture size error!:", "width", tw, "height", th)

			tw = 1
			th = 1
		end

		local sw = math.min(pw, ph * tw / th)
		local sh = math.min(ph, pw / (tw / th))

		image:set_size(math.round(sw), math.round(sh))
		image:set_center(panel:w() * 0.5, panel:h() * 0.5)
	else
		image:set_size(panel:size())
	end
end

function MenuNodeBaseGui:close()
	self:unretrieve_textures()
	MenuNodeBaseGui.super.close(self)
end
