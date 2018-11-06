BlurSheet = BlurSheet or class(GUIObjectWrapper)

function BlurSheet:init(parent, config)
	config = config or {}
	config.texture = config.texture or "guis/textures/test_blur_df"
	config.render_template = config.render_template or "VertexColorTexturedBlur3D"
	config.color = config.color or Color(0.75, 0, 0, 0)
	config.blur = config.blur or 1
	local panel_config = config
	local gui_obj = parent:panel(panel_config)

	gui_obj:rect({
		layer = 0,
		name = "color",
		halign = "grow",
		valign = "grow",
		color = config.color
	})
	gui_obj:bitmap({
		name = "blur",
		layer = 1,
		halign = "grow",
		valign = "grow",
		texture = config.texture,
		render_template = config.render_template,
		alpha = config.blur,
		w = gui_obj:w(),
		h = gui_obj:h()
	})
	BlurSheet.super.init(self, gui_obj)
end
