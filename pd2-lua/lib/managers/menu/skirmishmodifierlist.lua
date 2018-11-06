SkirmishModifierList = SkirmishModifierList or class(GUIObjectWrapper)

function SkirmishModifierList:init(parent, config)
	local h_padding = 20
	local v_padding = 5
	local scrollbar_padding = 10
	local panel = parent:panel(config)
	self._scroll = ScrollablePanel:new(panel, "scroll_area", {
		padding = 0,
		force_scroll_indicators = true,
		layer = 1
	})
	local modifiers = config.modifiers
	local font = config.font or tweak_data.menu.pd2_small_font
	local font_size = config.font_size or tweak_data.menu.pd2_small_font_size
	local next_y = 0

	for i, modifier_key in ipairs(modifiers) do
		local modifier_tweak = tweak_data.skirmish.weekly_modifiers[modifier_key]
		local modifier_class = _G[modifier_tweak.class]
		local modifier_panel = self._scroll:canvas():panel({
			name = "modifier",
			y = next_y
		})
		local icon_tweak = tweak_data.hud_icons[modifier_tweak.icon]
		local modifier_icon = modifier_panel:bitmap({
			name = "modifier_icon",
			h = 40,
			layer = 1,
			w = 40,
			texture = icon_tweak.texture,
			texture_rect = icon_tweak.texture_rect,
			x = h_padding
		})
		local description_width = modifier_panel:width() - modifier_icon:width() - 5 - h_padding * 2 - scrollbar_padding
		local modifier_desc = modifier_panel:text({
			vertical = "center",
			name = "modifier_desc",
			wrap = true,
			word_wrap = true,
			alpha = 0.8,
			layer = 1,
			text = managers.localization:text(modifier_class.desc_id, modifier_tweak.data),
			font = font,
			font_size = font_size,
			color = Color.white,
			x = h_padding + modifier_icon:width() + 5,
			y = v_padding,
			w = description_width
		})
		local _, _, _, h = modifier_desc:text_rect()
		h = math.max(h, modifier_icon:height()) + v_padding * 2

		modifier_desc:set_height(h - v_padding * 2)
		modifier_panel:set_height(h)
		modifier_panel:rect({
			color = Color.black,
			alpha = i % 2 == 0 and 0.4 or 0
		})
		modifier_icon:set_center_y(h * 0.5)

		next_y = modifier_panel:bottom()
	end

	self._scroll:update_canvas_size()
	SkirmishModifierList.super.init(self, panel)
end

function SkirmishModifierList:scroll(...)
	self._scroll:scroll(...)
end

function SkirmishModifierList:perform_scroll(...)
	self._scroll:perform_scroll(...)
end
