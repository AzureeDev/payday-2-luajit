MenuNodeStatsGui = MenuNodeStatsGui or class(MenuNodeGui)

function MenuNodeStatsGui:init(node, layer, parameters)
	MenuNodeStatsGui.super.init(self, node, layer, parameters)

	self._stats_items = {}

	self:_setup_stats(node)
end

function MenuNodeStatsGui:_setup_panels(node)
	MenuNodeStatsGui.super._setup_panels(self, node)

	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
end

function MenuNodeStatsGui:_setup_stats(node)
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_money"),
		data = managers.experience:total_cash_string()
	})
	self:_add_stats({
		type = "progress",
		topic = managers.localization:text("menu_stats_level_progress"),
		data = managers.experience:current_level() / managers.experience:level_cap(),
		text = "" .. managers.experience:current_level() .. "/" .. managers.experience:level_cap()
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_time_played"),
		data = managers.statistics:time_played() .. " " .. managers.localization:text("menu_stats_time")
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_favourite_campaign"),
		data = string.upper(managers.statistics:favourite_level())
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_total_completed_campaigns"),
		data = "" .. managers.statistics:total_completed_campaigns()
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_total_completed_objectives"),
		data = "" .. managers.statistics:total_completed_objectives()
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_favourite_weapon"),
		data = "" .. string.upper(managers.statistics:favourite_weapon())
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_hit_accuracy"),
		data = "" .. managers.statistics:hit_accuracy() .. "%"
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_total_kills"),
		data = "" .. managers.statistics:total_kills()
	})
	self:_add_stats({
		type = "text",
		topic = managers.localization:text("menu_stats_total_head_shots"),
		data = "" .. managers.statistics:total_head_shots()
	})

	if SystemInfo:platform() == Idstring("WIN32") then
		local y = 30

		for _, panel in ipairs(self._stats_items) do
			y = y + panel:h() + self.spacing
		end

		local safe_rect = managers.viewport:get_safe_rect_pixels()
		local panel = self._item_panel_parent:panel({
			y = y
		})
		local text = panel:text({
			halign = "center",
			vertical = "center",
			align = "center",
			y = 0,
			font_size = tweak_data.menu.stats_font_size,
			x = safe_rect.x,
			w = safe_rect.width,
			font = self.font,
			color = self.row_item_color,
			layer = self.layers.items,
			text = managers.localization:text("menu_visit_more_stats"),
			render_template = Idstring("VertexColorTextured")
		})
		local _, _, _, h = text:text_rect()

		text:set_h(h)
		panel:set_h(h)
	end
end

function MenuNodeStatsGui:_add_stats(params)
	local y = 0

	for _, panel in ipairs(self._stats_items) do
		y = y + panel:h() + self.spacing
	end

	local panel = self._item_panel_parent:panel({
		y = y
	})
	local topic = panel:text({
		halign = "right",
		vertical = "center",
		align = "right",
		y = 0,
		x = 0,
		font_size = tweak_data.menu.stats_font_size,
		w = self:_left_align(),
		font = self.font,
		color = self.row_item_color,
		layer = self.layers.items,
		text = params.topic,
		render_template = Idstring("VertexColorTextured")
	})
	local x, y, w, h = topic:text_rect()

	topic:set_h(h)
	panel:set_h(h)

	if params.type == "text" then
		local text = panel:text({
			halign = "left",
			vertical = "center",
			align = "left",
			y = 0,
			font_size = tweak_data.menu.stats_font_size,
			x = self:_right_align(),
			h = h,
			font = self.font,
			color = self.color,
			layer = self.layers.items,
			text = params.data,
			render_template = Idstring("VertexColorTextured")
		})
	end

	if params.type == "progress" then
		local bg = panel:rect({
			halign = "center",
			vertical = "center",
			h = 22,
			w = 256,
			align = "center",
			x = self:_right_align(),
			y = h / 2 - 11,
			color = Color.black:with_alpha(0.5),
			layer = self.layers.items - 1
		})
		local bar = panel:gradient({
			vertical = "center",
			align = "center",
			halign = "center",
			orientation = "vertical",
			gradient_points = {
				0,
				Color(1, 1, 0.6588235294117647, 0),
				1,
				Color(1, 0.6039215686274509, 0.4, 0)
			},
			x = self:_right_align() + 2,
			y = bg:y() + 2,
			w = (bg:w() - 4) * params.data,
			h = bg:h() - 4,
			layer = self.layers.items
		})
		local text = panel:text({
			y = 0,
			vertical = "center",
			align = "center",
			halign = "center",
			valign = "center",
			font_size = tweak_data.menu.stats_font_size,
			x = self:_right_align(),
			h = h,
			w = bg:w(),
			font = self.font,
			color = self.color,
			layer = self.layers.items + 1,
			text = params.text or "" .. math.floor(params.data * 100) .. "%",
			render_template = Idstring("VertexColorTextured")
		})
	end

	table.insert(self._stats_items, panel)
end

function MenuNodeStatsGui:_create_menu_item(row_item)
	MenuNodeStatsGui.super._create_menu_item(self, row_item)
end

function MenuNodeStatsGui:_setup_item_panel_parent(safe_rect)
	MenuNodeStatsGui.super._setup_item_panel_parent(self, safe_rect)
end

function MenuNodeStatsGui:_setup_item_panel(safe_rect, res)
	MenuNodeStatsGui.super._setup_item_panel(self, safe_rect, res)
end

function MenuNodeStatsGui:resolution_changed()
	MenuNodeStatsGui.super.resolution_changed(self)
end
