require("lib/managers/hud/vr/HUDBelt")

HUDManagerVR = HUDManager or Application:error("HUDManagerVR requires HUDManager!")
local __init = HUDManager.init
local __destroy = HUDManager.destroy
local __update = HUDManager.update

function HUDManagerVR:init()
	__init(self)
	print("[HUDManagerVR] Init")

	self._gui = World:newgui()

	self:_init_tablet_gui()
	self:_init_prompt_gui()
	self:_init_ammo_gui()
	self:_init_watch_gui()
	self:_init_holo_gui()
	self:_init_belt()
	self:_init_interaction()
	self:_init_full_hmd_gui()
	self:_init_floating_gui()
	self:_init_ingame_subtitle_ws()
end

function HUDManagerVR:destroy()
	__destroy(self)
end

function HUDManagerVR:_init_tablet_gui()
	self._tablet_ws = self._gui:create_world_workspace(402, 226, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))
	local tablet_panel = self._tablet_ws:panel()
	local main = tablet_panel:panel({
		name = "main_page"
	})
	local right = tablet_panel:panel({
		name = "right_page",
		x = tablet_panel:w()
	})
	local left = tablet_panel:panel({
		name = "left_page",
		x = -tablet_panel:w()
	})
	self._tablet_highlight = tablet_panel:panel({
		layer = 10,
		name = "highlight"
	})

	self._tablet_highlight:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/pad_state_rollover",
		name = "highlight",
		w = tablet_panel:w(),
		h = tablet_panel:h()
	})

	self._tablet_touch = self._tablet_highlight:bitmap({
		texture = "guis/dlcs/vr/textures/pd2/pad_state_touch",
		name = "highlight",
		h = 100,
		w = 100
	})

	self._tablet_highlight:hide()

	for texture_name, page in pairs({
		pad_bg = main,
		pad_bg_l = right,
		pad_bg_r = left
	}) do
		page:bitmap({
			name = "bg",
			layer = -2,
			texture = "guis/dlcs/vr/textures/pd2/" .. texture_name,
			w = tablet_panel:w(),
			h = tablet_panel:h()
		})
	end

	self._page_panels = {
		main,
		right,
		left
	}
	self._pages = {
		main = {
			left = "left",
			right = "right"
		},
		right = {
			left = "main"
		},
		left = {
			right = "main"
		}
	}
	self._current_page = "main"
	self._page_callbacks = {
		on_interact = {},
		on_focus = {}
	}

	self._tablet_ws:hide()
end

function HUDManagerVR:add_page_callback(page, type, clbk)
	if self._page_callbacks[type] then
		self._page_callbacks[type][page] = self._page_callbacks[type][page] or {}

		table.insert(self._page_callbacks[type][page], clbk)
	end
end

function HUDManagerVR:_init_prompt_gui()
	self._prompt_ws = self._gui:create_world_workspace(600, 150, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._prompt_ws:set_billboard(Workspace.BILLBOARD_X)
	self._prompt_ws:hide()
end

function HUDManagerVR:_init_ammo_gui()
	self._ammo_ws = self._gui:create_world_workspace(300, 200, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._ammo_ws:hide()

	local ammo_flash = self._ammo_ws:panel():panel({
		name = "ammo_flash"
	})

	ammo_flash:gradient({
		valign = "scale",
		orientation = "horizontal",
		halign = "scale"
	})
	ammo_flash:gradient({
		valign = "scale",
		orientation = "vertical",
		halign = "scale"
	})
	ammo_flash:hide()

	self._controller_assist_panel = self._ammo_ws:panel():panel({
		name = "controller_assist",
		h = 50,
		y = 150,
		w = 200,
		x = 100
	})

	self._controller_assist_panel:set_visible(false)
end

function HUDManagerVR:_init_watch_gui()
	self._watch_ws = self._gui:create_world_workspace(100, 100, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._watch_ws:hide()

	self._watch_prompt_ws = self._gui:create_world_workspace(800, 80, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._watch_prompt_ws:set_billboard(Workspace.BILLBOARD_Y)
	self._watch_prompt_ws:hide()
end

function HUDManagerVR:_init_holo_gui()
	self._holo_ws = {}
	self._holo_count = 15
	self._holo_height = 2

	for i = 1, self._holo_count do
		local holo_ws = self._gui:create_world_workspace(100, 100, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

		table.insert(self._holo_ws, holo_ws)
		holo_ws:hide()
	end
end

function HUDManagerVR:_init_belt()
	self._belt_ws = self._gui:create_world_workspace(640, 240, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._belt_ws:hide()

	self._belt = HUDBelt:new(self._belt_ws)
end

function HUDManagerVR:_init_interaction()
	self._interaction_ws = self._gui:create_world_workspace(80, 80, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._interaction_ws:set_billboard(Workspace.BILLBOARD_BOTH)
	self._interaction_ws:hide()
end

function HUDManagerVR:_init_full_hmd_gui()
	self._full_hmd_ws = Overlay:gui():create_screen_workspace()

	self._full_hmd_ws:set_pinned_screen(true)
end

function HUDManagerVR:_init_floating_gui()
	self._floating_ws = self._gui:create_world_workspace(1024, 1024, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._floating_ws:panel():set_visible(false)
end

function HUDManagerVR:_init_ingame_subtitle_ws()
	self._subtitle_ws = self._gui:create_world_workspace(1280, 720, Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0))

	self._subtitle_ws:hide()
end

function HUDManagerVR:set_ammo_flash_color(color)
	local ammo_flash = self:ammo_flash()
	local trans = color:with_alpha(0)
	local gradient_points = {
		0,
		color,
		0.1,
		trans,
		0.9,
		trans,
		1,
		color
	}

	for _, gradient in ipairs(ammo_flash:children()) do
		gradient:set_gradient_points(gradient_points)
	end
end

function HUDManagerVR:set_ammo_alpha(alpha)
	self:ammo_panel():set_alpha(math.max(alpha, self._forced_ammo_alpha or 0))
end

function HUDManagerVR:set_forced_ammo_alpha(alpha)
	self._forced_ammo_alpha = alpha
end

function HUDManagerVR:show_controller_assist(text_id, macros)
	local panel = self._controller_assist_panel

	if panel:visible() and self._controller_assist_current_id == text_id then
		return
	end

	local text = panel:child("text")
	text = text or panel:text({
		name = "text",
		vertical = "center",
		align = "center",
		rotation = 360,
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.medium_default_font_size
	})
	self._controller_assist_current_id = text_id

	text:set_size(panel:size())
	text:set_text(managers.localization:to_upper_text(text_id, macros))
	panel:set_visible(true)
end

function HUDManagerVR:hide_controller_assist()
	self._controller_assist_current_id = nil

	self._controller_assist_panel:set_visible(false)
end

function HUDManagerVR:holo_count()
	return self._holo_count
end

function HUDManagerVR:tablet_ws()
	return self._tablet_ws
end

function HUDManagerVR:tablet_page(page)
	return self._tablet_ws:panel():child(page or "main_page")
end

function HUDManagerVR:prompt_panel()
	return self._prompt_ws:panel()
end

function HUDManagerVR:ammo_panel()
	return self._ammo_ws:panel()
end

function HUDManagerVR:ammo_flash()
	return self._ammo_ws:panel():child("ammo_flash")
end

function HUDManagerVR:watch_panel()
	return self._watch_ws:panel()
end

function HUDManagerVR:holo_panel(index)
	return self._holo_ws[index]:panel()
end

function HUDManagerVR:watch_prompt_panel()
	return self._watch_prompt_ws:panel()
end

function HUDManagerVR:belt()
	return self._belt
end

function HUDManagerVR:interaction_panel()
	return self._interaction_ws:panel()
end

function HUDManagerVR:full_hmd_panel()
	return self._full_hmd_ws:panel()
end

function HUDManagerVR:floating_panel()
	return self._floating_ws:panel()
end

function HUDManagerVR:belt_workspace()
	return self._belt_ws
end

function HUDManagerVR:subtitle_workspace()
	return self._subtitle_ws
end

function HUDManagerVR:on_touch(enter, position)
	local visible = self._tablet_highlight:visible()

	if enter and not visible then
		self._tablet_highlight:show()
		self:on_focus(true)
	elseif not enter and visible then
		self._tablet_highlight:hide()
		self:on_focus(false)
	end

	local width = self._tablet_highlight:w()
	local height = self._tablet_highlight:h()

	self._tablet_touch:set_w(40)
	self._tablet_touch:set_h(40)
	self._tablet_touch:set_center_x(width * 0.5 + position.x * width * 0.5)
	self._tablet_touch:set_center_y(height * 0.5 + position.y * height * 0.5)
end

function HUDManagerVR:on_interact(position)
	local clbks = self._page_callbacks.on_interact[self._current_page]

	if clbks then
		for _, clbk in ipairs(clbks) do
			clbk(position)
		end
	end
end

function HUDManagerVR:on_focus(focus)
	local clbks = self._page_callbacks.on_focus[self._current_page]

	if clbks then
		for _, clbk in ipairs(clbks) do
			clbk(focus)
		end
	end
end

function HUDManagerVR:on_flick(dir, time)
	if not self._pages[self._current_page][dir] then
		return false
	end

	if self._transitioning_tablet_page and self._transitioning_tablet_page > 0 then
		self._queued_transition = {
			dir,
			time
		}

		return true
	end

	local function panel_swipe(o, x, y)
		if not alive(o) then
			return
		end

		x = x * o:w()
		y = y * o:h()
		local start_x = o:x()
		local start_y = o:y()

		over(time, function (p)
			if not alive(o) then
				return
			end

			o:set_x(start_x + p * x)
			o:set_y(start_y + p * y)
			o:set_alpha((1 - math.abs(o:x() / o:w())) * (1 - math.abs(o:y() / o:h())))
		end)

		self._transitioning_tablet_page = self._transitioning_tablet_page - 1

		if self._queued_transition and self._transitioning_tablet_page <= 0 then
			self:on_flick(unpack(self._queued_transition))

			self._queued_transition = nil
		end
	end

	local x = dir == "right" and -1 or dir == "left" and 1 or 0
	local y = dir == "up" and -1 or dir == "down" and 1 or 0

	for _, panel in ipairs(self._page_panels) do
		self._transitioning_tablet_page = (self._transitioning_tablet_page or 0) + 1

		panel:animate(panel_swipe, x, y)
	end

	self:on_focus(false)

	self._current_page = self._pages[self._current_page][dir]

	self:on_focus(true)

	return true
end

function HUDManagerVR:set_tablet_page(page)
	local dir = nil

	for d, p in pairs(self._pages[self._current_page]) do
		if p == page then
			dir = d

			break
		end
	end

	if dir then
		self:on_flick(dir, 0.5)
	else
		Application:error("[HUDManagerVR:set_tablet_page] No way to go from", self._current_page, "to", page)
	end
end

function HUDManagerVR:current_tablet_page()
	return self._current_page
end

function HUDManagerVR:link_ammo_hud(hand_unit, side)
	local hand_obj = hand_unit:get_object(Idstring("g_glove"))
	local hand_rot = hand_unit:rotation()

	if side == 1 or side == "right" then
		self._ammo_ws:set_linked(300, 200, hand_obj, hand_obj:position() + Vector3(-20, -5, 7):rotate_with(hand_rot), Vector3(15, 0, 0):rotate_with(hand_rot), Vector3(0, 0, -10):rotate_with(hand_rot))
		self._controller_assist_panel:set_x(100)
	elseif side == 2 or side == "left" then
		self._ammo_ws:set_linked(300, 200, hand_obj, hand_obj:position() + Vector3(5, -5, 7):rotate_with(hand_rot), Vector3(15, 0, 0):rotate_with(hand_rot), Vector3(0, 0, -10):rotate_with(hand_rot))
		self._controller_assist_panel:set_x(0)
	end

	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_hand(side)
end

function HUDManagerVR:link_watch_prompt(hand_unit, side)
	local hand_obj = hand_unit:get_object(Idstring("g_glove"))
	local hand_rot = hand_unit:rotation()

	if side == 1 or side == "right" then
		self._watch_prompt_ws:set_linked(800, 80, hand_obj, hand_obj:position() + Vector3(10.4, 0, 15.8):rotate_with(hand_rot), Vector3(12, 0, -20.8):rotate_with(hand_rot), Vector3(-1.92, -0.8, -1.12):rotate_with(hand_rot))
	elseif side == 2 or side == "left" then
		self._watch_prompt_ws:set_linked(800, 80, hand_obj, hand_obj:position() + Vector3(-18, 0, -5):rotate_with(hand_rot), Vector3(12, 0, 20.8):rotate_with(hand_rot), Vector3(1.92, -0.8, -1.12):rotate_with(hand_rot))
	end
end

function HUDManagerVR:link_watch_prompt_as_hand(hand_unit, side, offset)
	offset = offset or Vector3()
	local hand_obj = hand_unit:get_object(Idstring("g_glove"))
	local hand_rot = hand_unit:rotation()

	if side == 1 or side == "right" then
		self._watch_prompt_ws:set_linked(800, 80, hand_obj, hand_obj:position() + (Vector3(-24, 0, 24) + offset):rotate_with(hand_rot), Vector3(24, 0, 0):rotate_with(hand_rot), Vector3(0, -1.7, -1.7):rotate_with(hand_rot))
	elseif side == 2 or side == "left" then
		self._watch_prompt_ws:set_linked(800, 80, hand_obj, hand_obj:position() + (Vector3(0, 0, 24) + offset):rotate_with(hand_rot), Vector3(24, 0, 0):rotate_with(hand_rot), Vector3(0, -1.7, -1.7):rotate_with(hand_rot))
	end
end

function HUDManagerVR:bind_watch_to_hand(hand_unit)
	local watch_object = hand_unit:get_object(Idstring("player_hud_watch"))

	self._watch_ws:set_object(100, 100, watch_object, Vector3(0, 0, 0))
	self._watch_ws:show()

	local base_offset = 0.7

	for i, holo_ws in ipairs(self._holo_ws) do
		holo_ws:set_object(100, 100, watch_object, Vector3(0, 0, base_offset - self._holo_height * i / self._holo_count))
		holo_ws:show()
	end
end

function HUDManagerVR:bind_hud_to_vr_hand(weapon_hand_unit, tablet_hand_unit, belt_unit, weapon_side, tablet_side, float_unit)
	local tablet_object = tablet_hand_unit:get_object(Idstring("player_hud_tablet"))

	self._tablet_ws:set_object(self._tablet_ws:width(), self._tablet_ws:height(), tablet_object, Vector3(0, 0, 0))
	self._tablet_ws:show()

	local tablet_rot = tablet_object:rotation()

	self._prompt_ws:set_linked(600, 150, tablet_object, tablet_object:position() + Vector3(-15, -3.5, -7.5):rotate_with(tablet_rot), Vector3(30, 0, 0):rotate_with(tablet_rot), Vector3(0, 0, 7.5):rotate_with(tablet_rot))
	self._prompt_ws:show()
	self:link_floating_hud(float_unit)
	self:link_ammo_hud(weapon_hand_unit, weapon_side)
	self:bind_watch_to_hand(tablet_hand_unit)
	self:link_watch_prompt(tablet_hand_unit, tablet_side)
	self.link_belt(self._belt_ws, belt_unit)
	self:belt():update_icons()
end

function HUDManagerVR:link_floating_hud(float_unit)
	local size = 100
	local rot = float_unit:rotation()
	local x_vec = Vector3(1, 0, 0):rotate_with(rot) * size
	local y_vec = Vector3(0, 0, -1):rotate_with(rot) * size

	self._floating_ws:set_linked(1024, 1024, float_unit:orientation_object(), float_unit:position() + Vector3(-size / 2, size / 2, 0):rotate_with(rot), x_vec, y_vec)
	self._floating_ws:show()

	local sub_h = size / 1280 * 720
	y_vec = Vector3(0, 0, -1):rotate_with(rot) * sub_h

	self._subtitle_ws:set_linked(1280, 720, float_unit:orientation_object(), float_unit:position() + Vector3(-size / 2, size / 2, -10):rotate_with(rot), x_vec, y_vec)
	self._subtitle_ws:show()
	VRManagerPD2.depth_disable_helper(self._floating_ws:panel())
end

function HUDManagerVR.link_belt(ws, belt_unit, custom_size)
	local width = 1380
	local height = 880
	local aspect_ratio = height / width
	local size = custom_size or managers.vr:get_setting("belt_size")
	local sx = size
	local sy = size * aspect_ratio
	local belt_rot = belt_unit:rotation()
	local x_vec = Vector3(sx, 0, 0):rotate_with(belt_rot)
	local y_vec = Vector3(0, -sy, 0):rotate_with(belt_rot)

	ws:set_linked(width, height, belt_unit:orientation_object(), belt_unit:position() + Vector3(-sx / 2, sy / 2, 0):rotate_with(belt_rot), x_vec, y_vec)
	ws:show()
end

function HUDManagerVR:link_interaction_hud(hand_unit, interaction_object)
	self._interaction_hand = hand_unit
	self._interaction_object = interaction_object
	self._interaction_use_head = not alive(interaction_object)
end

function HUDManagerVR:start_reload_timer(time, clip_start, clip_full)
	local reload_panel = self:reload_panel()
	local size = reload_panel:w()
	local timer_circle = CircleBitmapGuiObject:new(reload_panel, {
		total = 1,
		current = 1,
		image = "units/pd2_dlc_vr/player/hud_interaction_circle",
		blend_mode = "normal",
		layer = 2,
		radius = size / 2,
		sides = size / 2,
		color = Color.white
	})
	local reload_text = reload_panel:child("reload_text")

	reload_text:set_text(tostring(clip_start) .. "/" .. tostring(clip_full))
	reload_text:set_visible(true)
	reload_panel:animate(function (o)
		if not alive(o) or not alive(timer_circle._circle) then
			return
		end

		local inc = clip_full - clip_start

		over(time, function (p)
			timer_circle:set_current(p, 1)
			reload_text:set_text(tostring(math.floor(clip_start + inc * p)) .. "/" .. tostring(clip_full))
		end)
		reload_text:set_text(tostring(math.floor(clip_full)) .. "/" .. tostring(clip_full))
		timer_circle:remove()
		reload_text:hide()
	end)

	self._reload_timer = timer_circle
end

function HUDManagerVR:stop_reload_timer()
	if not self._reload_timer or not alive(self._reload_timer._panel) then
		return
	end

	self._reload_timer._panel:stop()
	self._reload_timer:remove()
	self:reload_panel():child("reload_text"):hide()
end

function HUDManagerVR:reload_world_pos()
	local x, y = self:reload_panel():center()

	return self._reload_ws:local_to_world(Vector3(x, y, 0))
end

function HUDManagerVR:set_stamina(data)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina(data)
end

function HUDManagerVR:set_reload_visible(visible)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_reload_visible(visible)
end

function HUDManagerVR:set_reload_timer(current, max)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_reload_timer(current, max)
end

local tmp_vec1 = Vector3()

function HUDManagerVR:update(t, dt)
	if alive(self._interaction_hand) and (alive(self._interaction_object) or self._interaction_use_head) and self:interaction_panel():visible() then
		local interaction_object_pos = self._interaction_use_head and managers.player:player_unit():movement():m_head_pos() or self._interaction_object:interaction() and self._interaction_object:interaction():interact_position() or self._interaction_object:position()
		local interaction_pos = tmp_vec1

		mvector3.set(interaction_pos, interaction_object_pos)
		mvector3.subtract(interaction_pos, self._interaction_hand:position())
		mvector3.multiply(interaction_pos, self._interaction_use_head and 0.5 or 0.3)
		mvector3.add(interaction_pos, self._interaction_hand:position())

		local size = self._interaction_use_head and 10 or 20

		self._interaction_ws:set_world(80, 80, interaction_pos - Vector3(size / 2, 0, size / 2), Vector3(size, 0, 0), Vector3(0, 0, size))
	end

	__update(self, t, dt)
end

function HUDManagerVR:create_vehicle_interaction_ws(id, vehicle_unit, position, direction, up, w, h)
	self._vehicle_interactions = self._vehicle_interactions or {}

	if self._vehicle_interactions[id] then
		self:destroy_vehicle_interaction_ws(id)
	end

	local vehicle_rot = vehicle_unit:rotation()
	w = w or 128
	h = h or 128
	local ws_rot = Rotation(direction, up or math.UP)
	local size = Vector3(10, 0, -10 * h / w)
	self._vehicle_interactions[id] = self._gui:create_linked_workspace(w, h, vehicle_unit:orientation_object(), vehicle_unit:orientation_object():position() + position:rotate_with(vehicle_rot) - size:rotate_with(ws_rot) / 2 - direction * 5, ws_rot:x() * size.x, ws_rot:z() * size.z)

	return self._vehicle_interactions[id]
end

function HUDManagerVR:destroy_vehicle_interaction_ws(id)
	self._vehicle_interactions = self._vehicle_interactions or {}

	if not self._vehicle_interactions[id] then
		return
	end

	self._gui:destroy_workspace(self._vehicle_interactions[id])

	self._vehicle_interactions[id] = nil
end

function HUDManagerVR:_add_name_label(data)
	local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels].id or 0
	local id = last_id + 1
	local character_name = data.name
	local rank = 0
	local peer_id = nil
	local is_husk_player = data.unit:base().is_husk_player

	if is_husk_player then
		peer_id = data.unit:network():peer():id()
		local level = data.unit:network():peer():level()
		rank = data.unit:network():peer():rank()

		if level then
			local color_range_offset = utf8.len(data.name) + 2
			local experience, color_ranges = managers.experience:gui_string(level, rank, color_range_offset)
			data.name_color_ranges = color_ranges
			data.name = data.name .. " (" .. experience .. ")"
		end
	end

	local ws = self._gui:create_linked_workspace(256, 64, data.unit:get_object(Idstring("Head")), data.unit:movement():m_head_pos() + Vector3(40, 0, 20), Vector3(-80, 0, 0), Vector3(0, 0, -20))

	ws:set_billboard(Workspace.BILLBOARD_Y)

	local panel = ws:panel():panel({
		name = "name_label" .. id
	})
	local radius = 24
	local interact = CircleBitmapGuiObject:new(panel, {
		blend_mode = "add",
		depth_mode = "disabled",
		use_bg = true,
		render_template = "OverlayVertexColorTexturedRadial",
		layer = 0,
		radius = radius,
		color = Color.white
	})

	interact:set_visible(false)

	local tabs_texture = "guis/textures/pd2/hud_tabs"
	local bag_rect = {
		2,
		34,
		20,
		17
	}
	local color_id = managers.criminals:character_color_id_by_unit(data.unit)
	local crim_color = tweak_data.chat_colors[color_id]
	local text = panel:text({
		name = "text",
		vertical = "top",
		h = 18,
		w = 256,
		align = "left",
		depth_mode = "disabled",
		render_template = "OverlayText",
		layer = -1,
		text = data.name,
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = crim_color
	})
	local bag = panel:bitmap({
		name = "bag",
		layer = 0,
		visible = false,
		render_template = "OverlayText",
		depth_mode = "disabled",
		y = 1,
		x = 1,
		texture = tabs_texture,
		texture_rect = bag_rect,
		color = (crim_color * 1.1):with_alpha(1)
	})

	panel:text({
		w = 256,
		name = "cheater",
		h = 18,
		align = "center",
		depth_mode = "disabled",
		visible = false,
		render_template = "OverlayText",
		layer = -1,
		text = utf8.to_upper(managers.localization:text("menu_hud_cheater")),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = tweak_data.screen_colors.pro_color
	})
	panel:text({
		vertical = "bottom",
		name = "action",
		h = 18,
		w = 256,
		align = "left",
		render_template = "OverlayText",
		depth_mode = "disabled",
		visible = false,
		rotation = 360,
		layer = -1,
		text = utf8.to_upper("Fixing"),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = (crim_color * 1.1):with_alpha(1)
	})

	if rank > 0 then
		local texture, texture_rect = managers.experience:rank_icon_data(rank)

		panel:bitmap({
			name = "infamy",
			h = 16,
			visible = false,
			w = 16,
			layer = 0,
			depth_mode = "disabled",
			y = 4,
			render_template = "OverlayText",
			texture = texture,
			texture_rect = texture_rect,
			color = crim_color
		})
	end

	for _, color_range in ipairs(data.name_color_ranges or {}) do
		text:set_range_color(color_range.start, color_range.stop, color_range.color)
	end

	self:align_teammate_name_label(panel, interact)
	table.insert(self._hud.name_labels, {
		movement = data.unit:movement(),
		panel = panel,
		text = text,
		id = id,
		peer_id = peer_id,
		character_name = character_name,
		interact = interact,
		bag = bag,
		ws = ws
	})

	return id
end

function HUDManager:add_vehicle_name_label(data)
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels].id or 0
	local id = last_id + 1
	local vehicle_name = data.name
	local ws = self._gui:create_linked_workspace(256, 72, data.unit:orientation_object(), data.unit:position() + Vector3(40, 0, 210), Vector3(-80, 0, 0), Vector3(0, 0, -20))

	ws:set_billboard(Workspace.BILLBOARD_Y)

	local panel = ws:panel():panel({
		name = "name_label" .. id
	})
	local radius = 24
	local interact = CircleBitmapGuiObject:new(panel, {
		blend_mode = "add",
		use_bg = true,
		layer = 0,
		radius = radius,
		color = Color.white
	})

	interact:set_visible(false)

	local tabs_texture = "guis/textures/pd2/hud_tabs"
	local bag_rect = {
		2,
		34,
		20,
		17
	}
	local crim_color = tweak_data.chat_colors[1]
	local text = panel:text({
		name = "text",
		vertical = "top",
		h = 18,
		w = 256,
		align = "left",
		depth_mode = "disabled",
		render_template = "OverlayText",
		layer = -1,
		text = utf8.to_upper(data.name),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = crim_color
	})
	local bag = panel:bitmap({
		name = "bag",
		layer = 0,
		visible = false,
		render_template = "OverlayText",
		depth_mode = "disabled",
		y = 1,
		x = 1,
		texture = tabs_texture,
		texture_rect = bag_rect,
		color = (crim_color * 1.1):with_alpha(1)
	})
	local bag_number = panel:text({
		name = "bag_number",
		vertical = "top",
		h = 18,
		w = 32,
		align = "left",
		depth_mode = "disabled",
		visible = false,
		render_template = "OverlayText",
		layer = -1,
		text = utf8.to_upper(""),
		font = tweak_data.hud.small_font,
		font_size = tweak_data.hud.small_name_label_font_size,
		color = crim_color
	})

	panel:text({
		w = 256,
		name = "cheater",
		h = 18,
		align = "center",
		depth_mode = "disabled",
		visible = false,
		render_template = "OverlayText",
		layer = -1,
		text = utf8.to_upper(managers.localization:text("menu_hud_cheater")),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = tweak_data.screen_colors.pro_color
	})
	panel:text({
		vertical = "bottom",
		name = "action",
		h = 18,
		w = 256,
		align = "left",
		render_template = "OverlayText",
		depth_mode = "disabled",
		visible = false,
		rotation = 360,
		layer = -1,
		text = utf8.to_upper("Fixing"),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = (crim_color * 1.1):with_alpha(1)
	})
	self:align_teammate_name_label(panel, interact)
	table.insert(self._hud.name_labels, {
		vehicle = data.unit,
		panel = panel,
		text = text,
		id = id,
		character_name = vehicle_name,
		interact = interact,
		bag = bag,
		bag_number = bag_number,
		ws = ws
	})

	return id
end

function HUDManagerVR:_update_name_labels(t, dt)
	if not alive(managers.player:player_unit()) then
		return
	end

	local my_pos = managers.player:player_unit():movement():m_pos()
	local label_pos, label_obj, label_h = nil

	for _, data in ipairs(self._hud.name_labels) do
		local unit = data.movement and data.movement._unit or data.vehicle

		if alive(unit) and not unit:occluded() then
			if data.movement then
				label_pos = data.movement:m_head_pos()
				label_obj = unit:get_object(Idstring("Head"))
				label_h = 20
			else
				label_pos = unit:position()
				label_obj = unit:orientation_object()
				label_h = 200
			end

			if label_pos then
				local dis = math.max(mvector3.distance(my_pos, label_pos), 10)
				local w = dis * -0.4
				local h = dis * -0.1

				data.ws:set_linked(256, 72, label_obj, label_pos + Vector3(-w / 2, 0, label_h - h * 0.75), Vector3(w, 0, 0), Vector3(0, 0, h))
			end
		end
	end
end

function HUDManagerVR:_remove_name_label(id)
	for i, data in ipairs(self._hud.name_labels) do
		if data.id == id then
			self._gui:destroy_workspace(data.ws)
			table.remove(self._hud.name_labels, i)

			break
		end
	end
end

local __align_teammate_name_label = HUDManager.align_teammate_name_label

function HUDManagerVR:align_teammate_name_label(panel, interact)
	__align_teammate_name_label(self, panel, interact)
	panel:set_center_x(panel:parent():w() / 2)
end

local __show_progress_timer = HUDManager.show_progress_timer

function HUDManagerVR:show_progress_timer(...)
	__show_progress_timer(self, ...)
	self._hud_interaction:remove_interact()
end

local __remove_progress_timer = HUDManager.remove_progress_timer

function HUDManagerVR:remove_progress_timer()
	__remove_progress_timer(self)
	self._hud_interaction:show_interact()
end

function HUDManager:add_waypoint(id, data)
	if self._hud.waypoints[id] then
		self:remove_waypoint(id)
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

	if not hud then
		self._hud.stored_waypoints[id] = data

		return
	end

	local ws = self._gui:create_world_workspace(128, 64, (data.position or data.unit:position()) + Vector3(40, 0, 20), Vector3(-80, 0, 0), Vector3(0, 0, -40))

	ws:set_billboard(Workspace.BILLBOARD_Y)

	local waypoint_panel = hud.panel
	local icon = data.icon or "wp_standard"
	local text = ""
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon, {
		0,
		0,
		32,
		32
	})
	local bitmap = waypoint_panel:bitmap({
		layer = 0,
		visible = false,
		rotation = 360,
		name = "bitmap" .. id,
		texture = icon,
		texture_rect = texture_rect,
		w = texture_rect[3],
		h = texture_rect[4],
		blend_mode = data.blend_mode
	})
	local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("wp_arrow")
	local arrow = waypoint_panel:bitmap({
		layer = 0,
		visible = false,
		rotation = 360,
		name = "arrow" .. id,
		texture = arrow_icon,
		texture_rect = arrow_texture_rect,
		color = (data.color or Color.white):with_alpha(0.75),
		w = arrow_texture_rect[3],
		h = arrow_texture_rect[4],
		blend_mode = data.blend_mode
	})
	local bitmap_world = ws:panel():bitmap({
		layer = 0,
		render_template = "OverlayText",
		depth_mode = "disabled",
		rotation = 360,
		name = "bitmap" .. id,
		texture = icon,
		texture_rect = texture_rect,
		w = texture_rect[3],
		h = texture_rect[4],
		blend_mode = data.blend_mode
	})

	bitmap_world:set_center_x(ws:panel():w() / 2)

	local distance = nil

	if data.distance then
		distance = ws:panel():text({
			vertical = "center",
			h = 24,
			w = 128,
			align = "center",
			render_template = "OverlayText",
			text = "16.5",
			depth_mode = "disabled",
			rotation = 360,
			layer = 0,
			name = "distance" .. id,
			color = data.color or Color.white,
			font = tweak_data.hud.medium_font_noshadow,
			font_size = tweak_data.hud.default_font_size,
			blend_mode = data.blend_mode
		})

		distance:set_bottom(ws:panel():h())
		distance:set_center_x(ws:panel():w() / 2)
		distance:set_visible(false)
	end

	local timer = data.timer and ws:panel():text({
		font_size = 32,
		h = 32,
		vertical = "center",
		w = 32,
		align = "center",
		render_template = "OverlayText",
		depth_mode = "disabled",
		rotation = 360,
		layer = 0,
		name = "timer" .. id,
		text = (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer),
		font = tweak_data.hud.medium_font_noshadow
	})

	if timer then
		timer:set_bottom(ws:panel():h())
		timer:set_center_x(ws:panel():w() / 2)
	end

	text = ws:panel():text({
		h = 24,
		vertical = "center",
		w = 512,
		align = "center",
		rotation = 360,
		layer = 0,
		name = "text" .. id,
		text = utf8.to_upper(" " .. text),
		font = tweak_data.hud.small_font,
		font_size = tweak_data.hud.small_font_size
	})
	local _, _, w, _ = text:text_rect()

	text:set_w(w)
	text:set_bottom(ws:panel():h())
	text:set_center_x(ws:panel():w() / 2)

	local w, h = bitmap:size()
	self._hud.waypoints[id] = {
		move_speed = 1,
		init_data = data,
		state = data.state or "present",
		present_timer = data.present_timer or 2,
		bitmap = bitmap,
		arrow = arrow,
		size = Vector3(w, h, 0),
		text = text,
		distance = distance,
		timer_gui = timer,
		timer = data.timer,
		pause_timer = data.pause_timer or data.timer and 0,
		position = data.position,
		unit = data.unit,
		no_sync = data.no_sync,
		radius = data.radius or 160,
		ws = ws,
		bitmap_world = bitmap_world
	}
	self._hud.waypoints[id].init_data.position = data.position or data.unit:position()
	local slot = 1
	local t = {}

	for _, data in pairs(self._hud.waypoints) do
		if data.slot then
			t[data.slot] = data.text:w()
		end
	end

	for i = 1, 10 do
		if not t[i] then
			self._hud.waypoints[id].slot = i

			break
		end
	end

	self._hud.waypoints[id].slot_x = 0

	if self._hud.waypoints[id].slot == 2 then
		self._hud.waypoints[id].slot_x = t[1] / 2 + self._hud.waypoints[id].text:w() / 2 + 10
	elseif self._hud.waypoints[id].slot == 3 then
		self._hud.waypoints[id].slot_x = -t[1] / 2 - self._hud.waypoints[id].text:w() / 2 - 10
	elseif self._hud.waypoints[id].slot == 4 then
		self._hud.waypoints[id].slot_x = t[1] / 2 + t[2] + self._hud.waypoints[id].text:w() / 2 + 20
	elseif self._hud.waypoints[id].slot == 5 then
		self._hud.waypoints[id].slot_x = -t[1] / 2 - t[3] - self._hud.waypoints[id].text:w() / 2 - 20
	end
end

function HUDManager:change_waypoint_icon(id, icon)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]
	local texture, rect = tweak_data.hud_icons:get_icon_data(icon, {
		0,
		0,
		32,
		32
	})

	wp_data.bitmap:set_image(texture, rect[1], rect[2], rect[3], rect[4])
	wp_data.bitmap:set_size(rect[3], rect[4])

	wp_data.size = Vector3(rect[3], rect[4])

	wp_data.bitmap_world:set_image(texture, rect[1], rect[2], rect[3], rect[4])
	wp_data.bitmap_world:set_size(rect[3], rect[4])
end

function HUDManager:change_waypoint_icon_alpha(id, alpha)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]

	wp_data.bitmap:set_alpha(alpha)
	wp_data.bitmap_world:set_alpha(alpha)
end

function HUDManager:change_waypoint_arrow_color(id, color)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]

	wp_data.arrow:set_color(color)
end

function HUDManager:remove_waypoint(id)
	self._hud.stored_waypoints[id] = nil

	if not self._hud.waypoints[id] then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

	if not hud then
		return
	end

	local waypoint_panel = hud.panel

	waypoint_panel:remove(self._hud.waypoints[id].bitmap)
	waypoint_panel:remove(self._hud.waypoints[id].text)
	waypoint_panel:remove(self._hud.waypoints[id].arrow)
	self._gui:destroy_workspace(self._hud.waypoints[id].ws)

	self._hud.waypoints[id] = nil
end

local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()

function HUDManager:_update_waypoints(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, wp_cam_forward)

	for id, data in pairs(self._hud.waypoints) do
		local panel = data.bitmap:parent()

		if data.state == "dirty" then
			-- Nothing
		end

		if data.state == "sneak_present" then
			data.current_position = Vector3(panel:center_x(), panel:center_y())
			data.state = "present_ended"
			data.text_alpha = 0.5
			data.in_timer = 0
			data.current_scale = 1
			data.target_scale = 1

			if data.distance then
				data.distance:set_visible(true)
			end
		elseif data.state == "present" then
			data.current_position = Vector3(panel:center_x() + data.slot_x, panel:center_y() + panel:center_y() / 2)
			data.present_timer = data.present_timer - dt

			if data.present_timer <= 0 then
				data.state = "present_ended"
				data.text_alpha = 0.5
				data.in_timer = 0
				data.current_scale = 1
				data.target_scale = 1

				if data.distance then
					data.distance:set_visible(true)
				end
			end
		else
			if data.text_alpha ~= 0 then
				data.text_alpha = math.clamp(data.text_alpha - dt, 0, 1)

				data.text:set_color(data.text:color():with_alpha(data.text_alpha))
			end

			data.position = data.unit and data.unit:position() or data.position

			mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
			mvector3.set(wp_dir, data.position)
			mvector3.subtract(wp_dir, cam_pos)
			mvector3.set(wp_dir_normalized, wp_dir)
			mvector3.normalize(wp_dir_normalized)

			local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)

			if dot < 0 or panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
				if data.state ~= "offscreen" then
					data.state = "offscreen"

					data.arrow:set_visible(true)
					data.bitmap_world:set_visible(false)
					data.bitmap:set_visible(true)
					data.bitmap:set_color(data.bitmap:color():with_alpha(0.75))

					data.off_timer = 0 - (1 - data.in_timer)
					data.target_scale = 0.75

					if data.distance then
						data.distance:set_visible(false)
					end

					if data.timer_gui then
						data.timer_gui:set_visible(false)
					end
				end

				local direction = wp_onscreen_direction
				local panel_center_x, panel_center_y = panel:center()

				mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
				mvector3.normalize(direction)

				local distance = data.radius * tweak_data.scale.hud_crosshair_offset_multiplier
				local target_pos = wp_onscreen_target_pos

				mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * distance, panel_center_y + mvector3.y(direction) * distance, 0)

				data.off_timer = math.clamp(data.off_timer + dt / data.move_speed, 0, 1)

				if data.off_timer ~= 1 then
					mvector3.set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						target_pos,
						target_pos
					}, data.off_timer))

					data.current_scale = math.bezier({
						data.current_scale,
						data.current_scale,
						data.target_scale,
						data.target_scale
					}, data.off_timer)

					data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, target_pos)
				end

				data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

				local offset = 24

				data.arrow:set_center(mvector3.x(data.current_position) + direction.x * offset, mvector3.y(data.current_position) + direction.y * offset)

				local angle = math.X:angle(direction) * math.sign(direction.y)

				data.arrow:set_rotation(angle)

				if data.text_alpha ~= 0 then
					data.text:set_center_x(data.bitmap:center_x())
					data.text:set_top(data.bitmap:bottom())
				end
			else
				if data.state == "offscreen" then
					data.state = "onscreen"

					data.arrow:set_visible(false)
					data.bitmap:set_visible(false)
					data.bitmap_world:set_visible(true)
					data.bitmap_world:set_color(data.bitmap_world:color():with_alpha(1))

					data.in_timer = 0 - (1 - data.off_timer)
					data.target_scale = 1

					if data.distance then
						data.distance:set_visible(true)
					end

					if data.timer_gui then
						data.timer_gui:set_visible(true)
					end
				end

				local alpha = 0.8

				if dot > 0.99 then
					alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
				end

				if data.bitmap_world:color().alpha ~= alpha then
					data.bitmap_world:set_color(data.bitmap_world:color():with_alpha(alpha))

					if data.distance then
						data.distance:set_color(data.distance:color():with_alpha(alpha))
					end

					if data.timer_gui then
						data.timer_gui:set_color(data.bitmap_world:color():with_alpha(alpha))
					end
				end

				if data.in_timer ~= 1 then
					data.in_timer = math.clamp(data.in_timer + dt / data.move_speed, 0, 1)

					mvector3.set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						wp_pos,
						wp_pos
					}, data.in_timer))

					data.current_scale = math.bezier({
						data.current_scale,
						data.current_scale,
						data.target_scale,
						data.target_scale
					}, data.in_timer)

					data.bitmap_world:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, wp_pos)
				end

				if data.text_alpha ~= 0 then
					data.text:set_center_x(data.bitmap:center_x())
					data.text:set_top(data.bitmap:bottom())
				end

				local length = wp_dir:length()

				if data.distance then
					data.distance:set_text(string.format("%.0f", length / 100) .. "m")
				end

				local w = length * -0.2
				local h = length * -0.1

				data.ws:set_world(128, 64, data.position + Vector3(-w / 2, 0, -h / 2), Vector3(w, 0, 0), Vector3(0, 0, h))
			end
		end

		if data.timer_gui and data.pause_timer == 0 then
			data.timer = data.timer - dt
			local text = data.timer < 0 and "00" or (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer)

			data.timer_gui:set_text(text)
		end
	end
end
