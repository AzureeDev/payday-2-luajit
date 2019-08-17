DebugStringsBoxGui = DebugStringsBoxGui or class(TextBoxGui)

function DebugStringsBoxGui:init(ws, title, text, content_data, config, file)
	self._file = file
	config = config or {}
	config.h = 300
	config.w = 300
	local x, y = ws:size()
	config.x = x - config.w
	config.y = y - config.h - CoreMenuRenderer.Renderer.border_height + 10
	config.no_close_legend = true
	config.no_scroll_legend = true
	self._default_font_size = tweak_data.menu.default_font_size
	self._topic_state_font_size = 22

	DebugStringsBoxGui.super.init(self, ws, title, text, content_data, config)
	self:set_layer(10)
end

function DebugStringsBoxGui:set_layer(layer)
	DebugStringsBoxGui.super.set_layer(self, layer)
end

function DebugStringsBoxGui:_create_text_box(ws, title, text, content_data, config)
	DebugStringsBoxGui.super._create_text_box(self, ws, title, text, content_data, config)

	if self._info_box then
		self._info_box:close()

		self._info_box = nil
	end

	local strings_panel = self._scroll_panel:panel({
		h = 600,
		name = "strings_panel",
		x = 0,
		layer = 1
	})
	local y = 0
	local i = 0
	local ids = managers.localization:debug_file(self._file)
	local sorted = {}

	for id, _ in pairs(ids) do
		table.insert(sorted, id)
	end

	table.sort(sorted)

	for _, id in pairs(sorted) do
		local localized = ids[id]
		local even = math.mod(i, 2) == 0
		local string_panel = strings_panel:panel({
			w = 528,
			name = id,
			y = y
		})

		string_panel:rect({
			name = "bg",
			layer = 1,
			halign = "grow",
			color = (even and Color.white / 1.5 or Color.white / 2):with_alpha(0.25)
		})

		local text_id = string_panel:text({
			y = 0,
			name = "id",
			vertical = "center",
			align = "left",
			halign = "left",
			x = 16,
			layer = 2,
			text = id,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = Color.white
		})
		local text = string_panel:text({
			name = "text",
			vertical = "top",
			word_wrap = true,
			wrap = true,
			align = "left",
			y = 0,
			layer = 2,
			text = localized,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = string_panel:w() / 2,
			color = Color.white
		})
		local _, _, tw, th = text_id:text_rect()
		local _, _, tw2, th2 = text:text_rect()

		text_id:set_size(tw, th)
		text:set_size(tw2, th2)
		string_panel:set_h(math.max(text_id:h(), text:h()) + 4)

		y = y + string_panel:h()
		i = i + 1
	end

	strings_panel:set_h(y + 14)
	self._scroll_panel:set_h(math.max(self._scroll_panel:h(), strings_panel:h()))
	self:_set_scroll_indicator()
end

function DebugStringsBoxGui:mouse_moved(x, y)
end

function DebugStringsBoxGui:_check_scroll_indicator_states()
	DebugStringsBoxGui.super._check_scroll_indicator_states(self)
end

function DebugStringsBoxGui:set_size(x, y)
	DebugStringsBoxGui.super.set_size(self, x, y)

	local strings_panel = self._scroll_panel:child("strings_panel")

	strings_panel:set_w(self._scroll_panel:w())

	local hy = 0

	for _, child in ipairs(strings_panel:children()) do
		child:set_w(strings_panel:w())
		child:set_y(hy)

		local text_id = child:child("id")
		local text = child:child("text")

		text:set_x(child:w() / 2)
		text:set_w(child:w() / 2 - 16)
		text:set_shape(text:text_rect())
		text:set_x(child:w() / 2)
		text:set_y(0)

		local _, _, tw2, th2 = text:text_rect()
		local _, _, tw, th = text_id:text_rect()

		text_id:set_h(th)
		child:set_h(math.max(text_id:h(), text:h()) + 4)

		hy = hy + child:h()
	end
end

function DebugStringsBoxGui:set_visible(visible)
	DebugStringsBoxGui.super.set_visible(self, visible)
end

function DebugStringsBoxGui:close()
	print("DebugStringsBoxGui:close()")
	DebugStringsBoxGui.super.close(self)
end
