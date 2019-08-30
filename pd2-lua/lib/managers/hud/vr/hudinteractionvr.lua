HUDInteractionVR = HUDInteraction

function HUDInteractionVR:init(hud, child_name)
	self._watch_prompt_panel = managers.hud:watch_prompt_panel()
	hud.old_panel = hud.panel
	hud.panel = self._watch_prompt_panel:panel({
		name = child_name or "interact"
	})
	self._hud_panel = hud.panel
	self._circle_radius = 40
	self._sides = self._circle_radius
	self._child_name_text = (child_name or "interact") .. "_text"
	self._child_ivalid_name_text = (child_name or "interact") .. "_invalid_text"

	if self._hud_panel:child(self._child_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	end

	if self._hud_panel:child(self._child_ivalid_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))
	end

	local interact_text_bg = self._hud_panel:panel({
		layer = 0,
		visible = false,
		name = self._child_name_text .. "_bg",
		h = self._circle_radius * 2
	})

	interact_text_bg:rect({
		color = Color(0.3, 0, 0, 0)
	})
	BoxGuiObject:new(interact_text_bg, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local interact_text = self._hud_panel:text({
		vertical = "center",
		align = "center",
		text = "HELLO",
		visible = false,
		layer = 1,
		name = self._child_name_text,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		h = self._circle_radius * 2,
		w = interact_text_bg:w()
	})
	local invalid_text = self._hud_panel:text({
		vertical = "center",
		text = "HELLO",
		align = "center",
		blend_mode = "normal",
		visible = false,
		layer = 3,
		name = self._child_ivalid_name_text,
		color = Color(1, 0.3, 0.3),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		h = self._circle_radius * 2,
		w = interact_text_bg:w()
	})
	self._interaction_panel = managers.hud:interaction_panel()

	VRManagerPD2.overlay_helper(self._hud_panel)
	VRManagerPD2.overlay_helper(self._interaction_panel)

	hud.panel = hud.old_panel
	hud.old_panel = nil
end

HUDInteractionVR.default_show_interact = HUDInteraction.show_interact

function HUDInteractionVR:show_interact(data)
	data = data or {
		text = self._last_interaction_text or ""
	}

	self:default_show_interact(data)
	self._hud_panel:child(self._child_name_text .. "_bg"):set_visible(true)

	self._last_interaction_text = data.text

	self._hud_panel:show()
end

function HUDInteractionVR:remove_interact()
	if not alive(self._hud_panel) then
		return
	end

	if self._hud_panel:child(self._child_name_text) then
		self._hud_panel:child(self._child_name_text):set_visible(false)
	end

	if self._hud_panel:child(self._child_ivalid_name_text) then
		self._hud_panel:child(self._child_ivalid_name_text):set_visible(false)
	end

	if self._hud_panel:child(self._child_name_text .. "_bg") then
		self._hud_panel:child(self._child_name_text .. "_bg"):set_visible(false)
	end
end

function HUDInteractionVR:set_bar_valid(valid, text_id)
	self._hud_panel:child(self._child_name_text):set_visible(valid)

	local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)

	if text_id then
		invalid_text:set_text(managers.localization:to_upper_text(text_id))
	end

	invalid_text:set_visible(not valid)
	self._hud_panel:child(self._child_name_text .. "_bg"):set_visible(true)
end

function HUDInteractionVR:show_interaction_bar(current, total)
	if self._interact_circle then
		self._interact_circle:remove()

		self._interact_circle = nil

		self._interact_circle_overlay:remove()

		self._interact_circle_overlay = nil
	end

	self._interact_circle = CircleBitmapGuiObject:new(self._interaction_panel, {
		image = "guis/textures/pd2/progress_reload",
		bg = "guis/textures/pd2/progress_reload_black",
		use_bg = true,
		blend_mode = "normal",
		layer = 2,
		radius = self._circle_radius,
		sides = self._sides,
		current = self._sides,
		total = self._sides,
		color = Color.white
	})

	self._interact_circle:set_position(self._interaction_panel:w() - self._circle_radius * 2, 0)

	self._interact_circle_overlay = CircleBitmapGuiObject:new(self._interaction_panel, {
		image = "guis/textures/pd2/progress_reload",
		blend_mode = "add",
		layer = 2,
		radius = self._circle_radius,
		sides = self._sides,
		current = self._sides,
		total = self._sides,
		color = Color.white
	})

	self._interact_circle_overlay:set_position(self._interact_circle:position())
	self._interact_circle_overlay:set_alpha(0.2)
	self._interact_circle_overlay:set_depth_mode("disabled")
	VRManagerPD2.overlay_helper(self._interaction_panel)
	self._interaction_panel:show()
end

function HUDInteractionVR:set_interaction_bar_width(current, total)
	if self._interact_circle then
		self._interact_circle:set_current(current / total)
		self._interact_circle_overlay:set_current(current / total)
	end
end

function HUDInteractionVR:hide_interaction_bar(complete)
	if self._interact_circle then
		self._interact_circle:remove()

		self._interact_circle = nil

		self._interact_circle_overlay:remove()

		self._interact_circle_overlay = nil

		self._interaction_panel:hide()
	end
end

function HUDInteraction:destroy()
	self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))

	if self._interact_circle then
		self._interact_circle:remove()

		self._interact_circle = nil

		self._interact_circle_overlay:remove()

		self._interact_circle_overlay = nil
	end

	self._hud_panel:remove(self._hud_panel:child(self._child_name_text .. "_bg"))
end

function HUDInteractionVR:_animate_interaction_complete(bitmap, circle)
	bitmap:parent():remove(bitmap)
	circle:remove()
end
