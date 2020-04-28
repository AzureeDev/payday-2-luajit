ImageBoxGui = ImageBoxGui or class(TextBoxGui)

function ImageBoxGui:init(...)
	ImageBoxGui.super.init(self, ...)
end

function ImageBoxGui:update(t, dt)
end

function ImageBoxGui:_create_text_box(ws, title, text, content_data, text_config, image_config)
	ImageBoxGui.super._create_text_box(self, ws, title, text, content_data, text_config)
	self:_create_image_box(image_config)
end

function ImageBoxGui:_create_image_box(image_config)
	image_config = image_config or {}
	local image_shapes = image_config.shapes or {}
	local image_textures = image_config.textures or image_config.texture and {
		image_config.texture
	} or {}
	local image_video = image_config.video or nil
	local video_loop = image_config.video_loop or false
	local video_start_paused = image_config.video_start_paused or false
	local keep_texure_ratio = image_config.keep_ratio or false
	local image_render_template = image_config.render_template
	local image_blend_mode = image_config.blend_mode
	local image_width = image_config.w or image_config.width or 0
	local image_height = image_config.h or image_config.height or 0
	local image_padding = image_config.padding or 0
	local image_halign = Idstring(image_config.halign or image_config.align or "left")
	local image_valign = Idstring(image_config.valign or image_config.vertical or "center")
	local image_layer = image_config.layer or 0
	local main = self._panel
	local title = main:child("title")
	local info_area = main:child("info_area")
	local buttons_panel = info_area:child("buttons_panel")
	local scroll_panel = info_area:child("scroll_panel")
	local halign_not_center = image_halign ~= Idstring("center")
	local valign_not_center = image_valign ~= Idstring("center")
	local grow_w = 0
	local grow_h = 0

	if halign_not_center then
		grow_w = image_width + image_padding * 2
	end

	if valign_not_center and not halign_not_center then
		grow_h = image_height + image_padding * 2
	end

	main:grow(grow_w, grow_h)
	info_area:set_size(main:size())

	local move_x = 0
	local move_y = 0

	if image_halign == Idstring("left") then
		move_x = grow_w
	end

	if image_valign ~= Idstring("bottom") then
		move_y = grow_h
	end

	title:move(move_x, move_y)
	buttons_panel:move(move_x, move_y)
	scroll_panel:move(move_x, move_y)

	self._panel_w = main:w()
	self._panel_h = main:h()
	local top_line = self._panel:child("top_line")
	local bottom_line = self._panel:child("bottom_line")
	local scroll_up_indicator_shade = self._panel:child("scroll_up_indicator_shade")
	local scroll_down_indicator_shade = self._panel:child("scroll_down_indicator_shade")
	local scroll_up_indicator_arrow = self._panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._panel:child("scroll_down_indicator_arrow")

	top_line:set_world_bottom(scroll_panel:world_top())
	bottom_line:set_world_top(scroll_panel:world_bottom())
	scroll_up_indicator_shade:set_top(top_line:bottom())
	scroll_down_indicator_shade:set_bottom(bottom_line:top())
	scroll_up_indicator_arrow:set_lefttop(scroll_panel:right() + 2, scroll_up_indicator_shade:top() + 8)
	scroll_down_indicator_arrow:set_leftbottom(scroll_panel:right() + 2, scroll_down_indicator_shade:bottom() - 8)

	local image_panel = main:panel({
		name = "image_panel",
		w = image_width,
		h = image_height,
		layer = image_layer
	})

	if image_halign == Idstring("center") then
		image_panel:set_center_x(self._panel_w / 2)
	elseif image_halign == Idstring("right") then
		image_panel:set_right(self._panel_w - 10)
	else
		image_panel:set_left(10)
	end

	if image_valign == Idstring("center") then
		image_panel:set_center_y(self._panel_h / 2)
	elseif image_valign == Idstring("bottom") then
		image_panel:set_bottom(self._panel_h - 10)
	else
		image_panel:set_top(10)
	end

	self._requested_textures = {}

	for i, image_texture in ipairs(image_textures) do
		if image_texture and DB:has(Idstring("texture"), image_texture) then
			self:request_texture(image_texture, image_panel, keep_texure_ratio, image_blend_mode, i, image_render_template)
		end
	end

	if image_video then
		local image = image_panel:video({
			video = image_video,
			w = image_width,
			h = image_height,
			loop = video_loop,
			blend_mode = image_blend_mode
		})

		if image_render_template then
			image:set_render_template(image_render_template)
		end

		if video_start_paused then
			image:pause()
		end

		if keep_texure_ratio then
			local texture_width = image:video_width()
			local texture_height = image:video_height()
			local image_aspect = math.max(image_width, 1) / math.max(image_height, 1)
			local texture_aspect = math.max(texture_width, 1) / math.max(texture_height, 1)
			local aspect = texture_aspect / image_aspect
			local sw = math.min(image_width, image_width * aspect)
			local sh = math.min(image_height, image_height / aspect)

			image:set_size(sw, sh)
			image:set_center(image_panel:w() / 2, image_panel:h() / 2)
		end

		self._video = image
	end

	if image_shapes then
		for _, shape in pairs(image_shapes) do
			local type = shape.type or rect
			local new_shape = nil

			if type == "rect" then
				new_shape = image_panel:rect({
					color = shape.color or Color.white,
					w = shape.width or shape.w or 0,
					h = shape.height or shape.h or 0,
					layer = shape.layer or 0,
					blend_mode = image_blend_mode
				})
			elseif type == "bitmap" then
				new_shape = image_panel:bitmap({
					texture = shape.texture,
					color = shape.color or Color.white,
					w = shape.width or shape.w or 0,
					h = shape.height or shape.h or 0,
					layer = shape.layer or 0,
					blend_mode = image_blend_mode
				})
			end

			new_shape:set_center(shape.x * image_panel:w(), shape.y * image_panel:h())
			new_shape:set_position(math.round(new_shape:x()), math.round(new_shape:y()))
		end
	end

	self._info_box:create_sides(info_area, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self:_set_scroll_indicator()
	main:set_center(main:parent():w() / 2, main:parent():h() / 2)
end

function ImageBoxGui:set_video_paused(paused)
	if self._video then
		if paused then
			self._video:pause()
		else
			self._video:play()
		end
	end
end

function ImageBoxGui:request_texture(texture_path, panel, keep_aspect_ratio, blend_mode, layer, render_template)
	if not managers.menu_component then
		return
	end

	local texture_count = managers.menu_component:request_texture(texture_path, callback(self, self, "texture_done_clbk", {
		panel = panel,
		blend_mode = blend_mode,
		layer = layer,
		render_template = render_template,
		keep_aspect_ratio = keep_aspect_ratio
	}))

	table.insert(self._requested_textures, {
		texture_count = texture_count,
		texture = texture_path
	})
end

function ImageBoxGui:unretrieve_textures()
	if self._requested_textures then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end
	end

	self._requested_textures = {}
end

function ImageBoxGui:texture_done_clbk(params, texture_ids)
	params = params or {}
	local panel = params.panel or params[1]
	local keep_aspect_ratio = params.keep_aspect_ratio
	local blend_mode = params.blend_mode
	local layer = params.layer
	local render_template = params.render_template
	local name = params.name or "streamed_texture_" .. tostring(panel:num_children())

	if not alive(panel) then
		Application:error("[MenuNodeBaseGui:texture_done_clbk] Missing GUI panel", "texture_ids", texture_ids, "params", inspect(params))

		return
	end

	local image = panel:bitmap({
		name = name,
		texture = texture_ids,
		blend_mode = blend_mode,
		render_template = render_template,
		layer = layer
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

function ImageBoxGui:close()
	self:unretrieve_textures()
	ImageBoxGui.super.close(self)
end
