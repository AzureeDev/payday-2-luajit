ChartGuiFactory = ChartGuiFactory or class()

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local COLORS = {
	Color.green,
	Color.yellow,
	Color.cyan,
	Color.red,
	Color.purple
}

function ChartGuiFactory:init()
	self._pie_chart_template = {
		render_template = "VertexColorTexturedRadial",
		texture = "guis/textures/pd2/level_ring_small"
	}
end

function ChartGuiFactory:create_pie(panel, data, opional_params)
	local num_enties = #data
	local template = self._pie_chart_template
	local total_value = 0

	for _, data in ipairs(data) do
		total_value = total_value + data.value
	end

	if alive(panel:child("pie_chart")) then
		panel:remove(panel:child("pie_chart"))
	end

	local chart_panel = panel:panel({
		layer = 1,
		name = "pie_chart"
	})
	local pie_panel = chart_panel:panel({
		name = "pie"
	})
	local legend_panel = chart_panel:panel({
		name = "legend"
	})
	local w = math.min(chart_panel:w(), chart_panel:h())
	local h = math.min(chart_panel:w(), chart_panel:h())

	pie_panel:set_size(w, h)
	legend_panel:set_size(chart_panel:w() - w - 5, chart_panel:h())
	legend_panel:set_left(w + 5)

	local rotation = 0
	local ratio = nil
	local num_data = #data

	for i, data in ipairs(data) do
		if data.value and data.value ~= 0 then
			ratio = data.value / total_value
			local piece = pie_panel:bitmap({
				blend_mode = "add",
				layer = 1,
				name = i,
				w = pie_panel:w(),
				h = pie_panel:h(),
				texture = template.texture,
				render_template = template.render_template,
				color = Color(ratio, 1, 1),
				rotation = rotation
			})
			local legend_color = legend_panel:rect({
				blend_mode = "add",
				w = 8,
				h = 8,
				alpha = 0.7,
				color = COLORS[i] or Color.white
			})
			local legend_text = legend_panel:text({
				name = i,
				text = data.name,
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(legend_text)
			legend_text:set_left(legend_color:right() + 2)
			legend_text:set_bottom(legend_panel:h() - (num_data - i) * legend_text:h())
			legend_color:set_center_y(legend_text:center_y())

			rotation = rotation + ratio * 360
		end
	end

	return pie_panel
end
