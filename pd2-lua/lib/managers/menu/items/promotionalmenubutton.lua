PromotionalMenuButton = PromotionalMenuButton or class()
local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function PromotionalMenuButton:init(parent_gui, panel, params, theme)
	self._gui = parent_gui
	self._theme = theme
	self._parameters = params
	self._position = params.position
	self._size = params.size
	self._zoom_factor = params.zoom_factor or 1.1
	self._selected = false

	self:_setup_panel(panel, params)
	self:setup(parent_gui, panel, params, theme)
	self:refresh()
end

function PromotionalMenuButton:_setup_panel(panel, params)
	self._panel = panel:panel({
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h,
		halign = params.halign or "right",
		valign = params.valign or "top"
	})
end

function PromotionalMenuButton:setup(parent_gui, panel, params, theme)
	self:_setup_selection(parent_gui, panel, params, theme)
	self:_setup_titles(parent_gui, panel, params, theme)
	self:_setup_background(parent_gui, panel, params, theme)
	self:_setup_overlay(parent_gui, panel, params, theme)
end

function PromotionalMenuButton:_setup_selection(parent_gui, panel, params, theme)
	self._corner_rects = {}
	local corner_size = 2

	table.insert(self._corner_rects, self._panel:rect({
		layer = 10,
		w = corner_size,
		h = corner_size
	}))
	table.insert(self._corner_rects, self._panel:rect({
		layer = 10,
		x = self._panel:w() - corner_size,
		w = corner_size,
		h = corner_size
	}))
	table.insert(self._corner_rects, self._panel:rect({
		layer = 10,
		y = self._panel:h() - corner_size,
		w = corner_size,
		h = corner_size
	}))
	table.insert(self._corner_rects, self._panel:rect({
		layer = 10,
		x = self._panel:w() - corner_size,
		y = self._panel:h() - corner_size,
		w = corner_size,
		h = corner_size
	}))

	self._selection_outline = BoxGuiObject:new(self._panel:panel({layer = 100}), theme.selection_outline_sides or {sides = {
		1,
		1,
		1,
		1
	}})
end

function PromotionalMenuButton:_setup_titles(parent_gui, panel, params, theme)
	if params.title then
		local title_font = theme.font[params.title.font or "medium"]
		local title_font_size = theme.font_size[params.title.font_size or "medium"]
		self._title = self._panel:text({
			layer = 5,
			text = params.title.name_id and managers.localization:to_upper_text(params.title.name_id) or "",
			font = title_font,
			font_size = title_font_size,
			color = params.title.color or theme.title or Color.white,
			blend_mode = params.title.blend_mode or "normal",
			rotation = params.title.rotation,
			w = self._panel:w() - padding * 2,
			h = self._panel:h() - padding * 2,
			align = params.title.align or "left",
			vertical = params.title.vertical or "bottom"
		})

		make_fine_text(self._title)
		self._title:set_left(padding * 1.5)
		self._title:set_bottom(self._panel:h() - padding * 1)
	end

	if params.subtitle then
		local subtitle_font = theme.font[params.subtitle.font or "medium"]
		local subtitle_font_size = theme.font_size[params.subtitle.font_size or "medium"]
		self._subtitle = self._panel:text({
			layer = 5,
			text = params.subtitle.name_id and managers.localization:to_upper_text(params.subtitle.name_id) or "",
			font = subtitle_font,
			font_size = subtitle_font_size,
			color = params.subtitle.color or theme.subtitle or Color.white,
			blend_mode = params.subtitle.blend_mode or "normal",
			rotation = params.subtitle.rotation,
			w = self._panel:w() - padding * 2,
			h = self._panel:h() - padding * 2,
			align = params.subtitle.align or "left",
			vertical = params.subtitle.vertical or "bottom"
		})

		make_fine_text(self._subtitle)
		self._subtitle:set_left(padding * 1.5 + (params.subtitle.offset and params.subtitle.offset[1] or 0))
		self._subtitle:set_bottom(self._panel:h() - padding * 1.5 + (params.subtitle.offset and params.subtitle.offset[2] or 0))
		self._title:set_bottom(self._subtitle:top())
	end
end

function PromotionalMenuButton:_setup_background(parent_gui, panel, params, theme)
	if params.background then
		if params.background.color then
			self._bg = self._panel:rect({
				layer = -2,
				color = tweak_data.screen_colors.button_stage_3,
				blend_mode = params.background.blend_mode or "add"
			})
		end

		if params.background.image then
			self._bg_image = self._panel:bitmap({
				layer = -1,
				texture = params.background.image,
				color = params.background.image_color,
				blend_mode = params.background.image_blend_mode or "normal"
			})
			local panel_size = math.max(self._panel:w(), self._panel:h())
			local ratio = math.max(self._panel:w() / self._bg_image:w(), self._panel:h() / self._bg_image:h())

			self._bg_image:set_w(self._bg_image:w() * ratio)
			self._bg_image:set_h(self._bg_image:h() * ratio)

			self._bg_image_size = {
				self._bg_image:w(),
				self._bg_image:h()
			}

			self._bg_image:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)
		end
	end
end

function PromotionalMenuButton:_setup_overlay(parent_gui, panel, params, theme)
	if params.overlay then
		if params.overlay.color then
			self._overlay = self._panel:rect({
				layer = 50,
				color = tweak_data.screen_colors.button_stage_3,
				blend_mode = params.overlay.blend_mode or "add"
			})
		end

		if params.overlay.image then
			local overlay_image = self._panel:bitmap({
				layer = 50,
				texture = params.overlay.image,
				color = params.overlay.image_color,
				blend_mode = params.overlay.image_blend_mode or "normal"
			})

			if params.overlay.w then
				overlay_image:set_w(params.overlay.w)
			end

			if params.overlay.h then
				overlay_image:set_h(params.overlay.h)
			end

			if params.overlay.center then
				overlay_image:set_center(self._panel:w() * (params.overlay.center[1] or 0.5), self._panel:h() * (params.overlay.center[2] or 0.5))
			elseif params.overlay.align then
				if params.overlay.align[1] == "left" then
					overlay_image:set_left(0)
				else
					overlay_image:set_right(self._panel:w())
				end

				if params.overlay.align[2] == "top" then
					overlay_image:set_top(0)
				else
					overlay_image:set_bottom(self._panel:h())
				end
			end
		end
	end
end

function PromotionalMenuButton:refresh()
	if self._corner_rects then
		for _, rect in ipairs(self._corner_rects) do
			rect:set_color(self._theme.selection_corners)
		end
	end

	if alive(self._selection_outline) then
		self._selection_outline:set_color(self._theme.selection_outline)
	end

	if alive(self._bg) then
		self._bg:set_color(self._theme.background_unselected)
	end

	self:set_selected(self._selected, true)
end

function PromotionalMenuButton:position()
	return self._position
end

function PromotionalMenuButton:size()
	return self._size
end

function PromotionalMenuButton:inside(x, y)
	return self._panel:inside(x, y)
end

function PromotionalMenuButton:can_be_selected()
	if self._parameters.can_be_selected ~= nil then
		return self._parameters.can_be_selected
	else
		return true
	end
end

function PromotionalMenuButton:set_selected(selected, force)
	if self._selected == selected and not force then
		return
	end

	self._selected = selected

	managers.menu:post_event("highlight")

	if self._corner_rects then
		for _, rect in ipairs(self._corner_rects) do
			rect:set_visible(not selected)
		end
	end

	if alive(self._selection_outline) then
		self._selection_outline:set_visible(selected)
	end

	if alive(self._bg) then
		self._bg:set_color(selected and self._theme.background_selected or self._theme.background_unselected)
	end

	if alive(self._bg_image) then
		local h = self._bg_image_size[2]

		if selected then
			local w = self._bg_image_size[1] * self._zoom_factor
			h = h * self._zoom_factor
		end

		self._bg_image:stop()
		self._bg_image:animate(callback(self, self, "animate_image_size"), w, h, 0.25)
	end
end

function PromotionalMenuButton:trigger()
	if self._parameters and self._parameters.callback then
		self._gui[self._parameters.callback](self._gui)
	else
		print("No callback on button")
	end

	managers.menu:post_event("menu_enter")
end

function PromotionalMenuButton:animate_image_size(img, target_w, target_h, duration)
	local orig_w = img:w()
	local orig_h = img:h()

	over(duration, function (t)
		img:set_w(Easing.out_quad(orig_w, target_w, t))
		img:set_h(Easing.out_quad(orig_h, target_h, t))
		img:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)
	end)
end
RaidPromotionalMenuButton = RaidPromotionalMenuButton or class(PromotionalMenuButton)

function RaidPromotionalMenuButton:_setup_selection(parent_gui, panel, params, theme)
	self._corner_rects = {}

	if not theme.selection_outline_sides then
		local config = {sides = {
			1,
			1,
			1,
			1
		}}
	end

	config.texture = "guis/textures/test_blur_df"
	local unselected_outline = BoxGuiObject:new(self._panel:panel({layer = 99}), config)
	self._selection_outline = BoxGuiObject:new(self._panel:panel({layer = 100}), config)
end
RaidPromotionalMenuFloatingButton = RaidPromotionalMenuFloatingButton or class(PromotionalMenuButton)

function RaidPromotionalMenuFloatingButton:_setup_panel(panel, params)
	local x = params.x
	local y = params.y
	local w = params.w
	local h = params.h

	if params.floating_position then
		x = params.floating_position[1]
		y = params.floating_position[2]
	end

	if params.floating_size then
		w = params.floating_size[1]
		h = params.floating_size[2]
	end

	self._panel = panel:panel({
		x = x,
		y = y,
		w = w,
		h = h
	})
end

function RaidPromotionalMenuFloatingButton:_setup_selection(parent_gui, panel, params, theme)
end
PromotionalMenuUnselectableButton = PromotionalMenuUnselectableButton or class(PromotionalMenuButton)

function PromotionalMenuUnselectableButton:_setup_selection(parent_gui, panel, params, theme)
end

function PromotionalMenuUnselectableButton:inside()
	return false
end

function PromotionalMenuUnselectableButton:can_be_selected()
	return false
end

function PromotionalMenuUnselectableButton:set_selected()
end

function PromotionalMenuUnselectableButton:trigger()
end
PromotionalMenuSeperatorRaid = PromotionalMenuSeperatorRaid or class(PromotionalMenuButton)

function PromotionalMenuSeperatorRaid:setup(parent_gui, panel, params, theme)
	local title_font = theme.font[params.title.font or "medium"]
	local title_font_size = theme.font_size[params.title.font_size or "medium"]
	self._title = self._panel:text({
		layer = 5,
		text = params.title.name_id and managers.localization:text(params.title.name_id) or "",
		font = title_font,
		font_size = title_font_size,
		color = Color.white,
		blend_mode = params.title.blend_mode or "normal",
		rotation = params.title.rotation,
		x = padding,
		y = padding,
		w = self._panel:w() - padding * 2,
		h = title_font_size,
		align = params.title.align or "center",
		vertical = params.title.vertical or "center"
	})

	make_fine_text(self._title)

	local underline = self._panel:rect({
		h = 3,
		layer = -1,
		w = self._title:w() + padding * 2,
		color = tweak_data.screen_colors.button_stage_2,
		blend_mode = params.background.blend_mode or "add"
	})

	underline:set_bottom(self._panel:h())

	self._underline = underline
	local bottom_line = self._panel:rect({
		h = 1,
		layer = -2,
		color = tweak_data.screen_colors.button_stage_3,
		blend_mode = params.background.blend_mode or "add"
	})

	bottom_line:set_bottom(self._panel:h())

	self._bottom_line = bottom_line
end

function PromotionalMenuSeperatorRaid:refresh()
	self._underline:set_color(self._theme.selection_outline)
	self._bottom_line:set_color(self._theme.background_unselected)
end

function PromotionalMenuSeperatorRaid:inside()
	return false
end

function PromotionalMenuSeperatorRaid:can_be_selected()
	return false
end

function PromotionalMenuSeperatorRaid:set_selected()
end

function PromotionalMenuSeperatorRaid:trigger()
end

