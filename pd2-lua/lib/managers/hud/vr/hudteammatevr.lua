HUDTeammateVR = HUDTeammate
HUDTeammateVR.old_init = HUDTeammate.init

function HUDTeammateVR:override_function_parameters(func_name, override)
	self["overridden_" .. func_name] = self[func_name]

	self[func_name] = function (...)
		local new_params = {
			override(...)
		}

		if #new_params > 0 then
			return self["overridden_" .. func_name](unpack(new_params))
		end
	end
end

function HUDTeammateVR:init(i, teammates_panel, is_player, width)
	self._watch_panel = managers.hud:watch_panel()
	self._watch_floating_panel = managers.hud:holo_panel(managers.hud:holo_count())
	self._tablet_panel = managers.hud:tablet_page()
	self._secondary_panel = managers.hud:tablet_page("right_page")
	self._ammo_panel = managers.hud:ammo_panel():panel({
		w = 200,
		name = "ammo",
		h = 150,
		x = 100
	})
	self._ammo_flash = managers.hud:ammo_flash()

	self._ammo_flash:set_shape(self._ammo_panel:shape())
	self:override_function_parameters("_create_carry", function (self, carry_panel)
		return self, self._carry_panel
	end)

	self._special_equipment_name = self._secondary_panel:text({
		name = "special_equipment_name",
		visible = false,
		text = "Player" .. i,
		y = self._secondary_panel:h() - self._secondary_panel:h() / 4 * i,
		font = tweak_data.hud_players.name_font,
		font_size = tweak_data.hud_players.name_size
	})

	managers.hud:make_fine_text(self._special_equipment_name)
	self._special_equipment_name:set_w(self._secondary_panel:w() / 2)

	self._special_equipment_panel = self._secondary_panel:panel({
		name = "special_equipment_panel",
		y = self._special_equipment_name:bottom(),
		w = self._secondary_panel:w() / 2
	})
	self._carry_panel = self._special_equipment_panel:panel({
		visible = false
	})

	self:old_init(i, self._tablet_panel, is_player, width)

	width = width / 2

	self._panel:set_x(width * (i - 1) + (is_player and 400 or 0))
	self._panel:set_y(self._panel:y() - 5)

	if self._main_player then
		local stamina_panel = managers.hud:ammo_panel():panel({
			name = "stamina_radial",
			h = 70,
			y = 80,
			w = 70,
			x = 15
		})

		self:_create_stamina_radial(stamina_panel)
	end

	if not self._ai and not self._main_player then
		self._radial_health_panel:set_y(24)
		self._interact._panel:set_y(24)
		self._interact:set_position(4, 0)
		self._condition_icon:set_y(24)
		self._panel:child("condition_timer"):set_y(24)
	end

	VRManagerPD2.overlay_helper(managers.hud:ammo_panel())
	VRManagerPD2.overlay_helper(self._watch_panel)
	VRManagerPD2.overlay_helper(self._watch_floating_panel)
end

local __create_radial_health = HUDTeammate._create_radial_health

function HUDTeammateVR:_create_radial_health(radial_health_panel)
	if not self._main_player then
		return __create_radial_health(self, radial_health_panel)
	else
		radial_health_panel = managers.hud:ammo_panel():panel({
			w = 70,
			name = "radial",
			h = 70,
			x = 15
		})
		self._radial_health_panel = radial_health_panel
		local radial_size = self._main_player and 64 or 48
		local health_icon = radial_health_panel:bitmap({
			blend_mode = "add",
			name = "health_icon",
			alpha = 1,
			texture = "guis/textures/pd2/progress_health_icon",
			layer = 1,
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local radial_bg = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/progress_warp_black",
			name = "radial_bg",
			alpha = 1,
			layer = 0,
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local radial_health = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/progress_health",
			name = "radial_health",
			alpha = 1,
			layer = 2,
			blend_mode = "add",
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		radial_health:set_color(Color(1, 1, 0, 0))

		local radial_shield = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/progress_shield",
			name = "radial_shield",
			alpha = 1,
			layer = 1,
			blend_mode = "add",
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		radial_shield:set_color(Color(1, 0, 0, 0))

		local damage_indicator = radial_health_panel:bitmap({
			blend_mode = "add",
			name = "damage_indicator",
			alpha = 0,
			texture = "guis/textures/pd2/hud_radial_rim",
			layer = 1,
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		damage_indicator:set_color(Color(1, 1, 1, 1))

		local radial_custom = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/hud_swansong",
			name = "radial_custom",
			blend_mode = "add",
			visible = false,
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local radial_ability_panel = radial_health_panel:panel({
			visible = false,
			name = "radial_ability"
		})
		local radial_ability_meter = radial_ability_panel:bitmap({
			blend_mode = "add",
			name = "ability_meter",
			texture = "guis/textures/pd2/hud_fearless",
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local radial_ability_icon = radial_ability_panel:bitmap({
			blend_mode = "add",
			name = "ability_icon",
			alpha = 1,
			layer = 5,
			w = radial_size * 0.5,
			h = radial_size * 0.5
		})

		radial_ability_icon:set_center(radial_ability_panel:center())

		local radial_delayed_damage_panel = radial_health_panel:panel({
			name = "radial_delayed_damage"
		})
		local radial_delayed_damage_armor = radial_delayed_damage_panel:bitmap({
			texture = "guis/dlcs/vr/textures/pd2/vr_hud_dot_shield",
			name = "radial_delayed_damage_armor",
			visible = false,
			render_template = "VertexColorTexturedRadialFlex",
			layer = 5,
			w = radial_delayed_damage_panel:w(),
			h = radial_delayed_damage_panel:h()
		})
		local radial_delayed_damage_health = radial_delayed_damage_panel:bitmap({
			texture = "guis/dlcs/vr/textures/pd2/vr_hud_dot",
			name = "radial_delayed_damage_health",
			visible = false,
			render_template = "VertexColorTexturedRadialFlex",
			layer = 5,
			w = radial_delayed_damage_panel:w(),
			h = radial_delayed_damage_panel:h()
		})

		if self._main_player then
			local radial_rip = radial_health_panel:bitmap({
				texture = "guis/textures/pd2/hud_rip",
				name = "radial_rip",
				alpha = 1,
				layer = 3,
				blend_mode = "add",
				render_template = "VertexColorTexturedRadial",
				texture_rect = {
					128,
					0,
					-128,
					128
				},
				w = radial_health_panel:w(),
				h = radial_health_panel:h()
			})

			radial_rip:set_color(Color(1, 0, 0, 0))
			radial_rip:hide()

			local radial_rip_bg = radial_health_panel:bitmap({
				texture = "guis/textures/pd2/hud_rip_bg",
				name = "radial_rip_bg",
				alpha = 1,
				layer = 1,
				blend_mode = "normal",
				render_template = "VertexColorTexturedRadial",
				texture_rect = {
					128,
					0,
					-128,
					128
				},
				w = radial_health_panel:w(),
				h = radial_health_panel:h()
			})

			radial_rip_bg:set_color(Color(1, 0, 0, 0))
			radial_rip_bg:hide()
		end

		local radial_absorb_shield_active = radial_health_panel:bitmap({
			blend_mode = "normal",
			name = "radial_absorb_shield_active",
			alpha = 1,
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_shield",
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		radial_absorb_shield_active:set_color(Color(1, 0, 0, 0))
		radial_absorb_shield_active:hide()

		local radial_absorb_health_active = radial_health_panel:bitmap({
			blend_mode = "normal",
			name = "radial_absorb_health_active",
			alpha = 1,
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_health",
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		radial_absorb_health_active:set_color(Color(1, 0, 0, 0))
		radial_absorb_health_active:hide()
		radial_absorb_health_active:animate(callback(self, self, "animate_update_absorb_active"))

		local radial_info_meter = radial_health_panel:bitmap({
			blend_mode = "add",
			name = "radial_info_meter",
			alpha = 1,
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
			render_template = "VertexColorTexturedRadial",
			layer = 3,
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		radial_info_meter:set_color(Color(1, 0, 0, 0))
		radial_info_meter:hide()

		local radial_info_meter_bg = radial_health_panel:bitmap({
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_bg",
			name = "radial_info_meter_bg",
			alpha = 1,
			layer = 1,
			blend_mode = "normal",
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})

		radial_info_meter_bg:set_color(Color(1, 0, 0, 0))
		radial_info_meter_bg:hide()
		self:_create_condition(radial_health_panel)
	end
end

function HUDTeammateVR:hide_radial()
	self._radial_health_panel:hide()
end

function HUDTeammateVR:show_radial()
	self._radial_health_panel:show()
end

function HUDTeammateVR:_create_stamina_radial(stamina_panel)
	self._stamina_panel = stamina_panel
	local stamina_radial = stamina_panel:bitmap({
		texture = "guis/textures/pd2/progress_warp",
		name = "stamina_radial",
		alpha = 1,
		layer = 1,
		blend_mode = "add",
		render_template = "VertexColorTexturedRadial",
		texture_rect = {
			128,
			0,
			-128,
			128
		},
		w = stamina_panel:w(),
		h = stamina_panel:h()
	})

	stamina_radial:set_color(Color(1, 1, 0, 0))
	stamina_panel:bitmap({
		blend_mode = "add",
		name = "stamina_radial_bg",
		alpha = 1,
		texture = "guis/textures/pd2/progress_warp_black",
		render_template = "VertexColorTexturedRadial",
		w = stamina_panel:w(),
		h = stamina_panel:h()
	})
	stamina_panel:bitmap({
		blend_mode = "add",
		name = "stamina_icon",
		alpha = 1,
		texture = "guis/textures/pd2/progress_warp_icon",
		w = stamina_panel:w(),
		h = stamina_panel:h()
	})
end

function HUDTeammateVR:set_stamina(data)
	local stamina_radial = self._stamina_panel:child("stamina_radial")
	local red = data.current / data.total

	stamina_radial:set_color(Color(1, red, 1, 1))
end

HUDTeammateVR.default_create_condition = HUDTeammate._create_condition

function HUDTeammateVR:_create_condition(radial_health_panel)
	if not self._main_player then
		return self:default_create_condition(radial_health_panel)
	end

	local x, y, w, h = radial_health_panel:shape()
	self._condition_icon = self._watch_floating_panel:bitmap({
		name = "condition_icon",
		visible = false,
		layer = 4,
		color = Color.white,
		w = w,
		h = h
	})
	local condition_timer = self._panel:text({
		y = 0,
		vertical = "center",
		name = "condition_timer",
		align = "center",
		text = "000",
		visible = false,
		layer = 5,
		color = Color.white,
		font_size = tweak_data.hud_players.timer_size,
		font = tweak_data.hud_players.timer_font
	})

	condition_timer:set_shape(radial_health_panel:shape())
end

HUDTeammateVR.default_create_weapon_panels = HUDTeammate._create_weapon_panels

function HUDTeammateVR:_create_weapon_panels(weapons_panel)
	if not self._main_player then
		self:default_create_weapon_panels(weapons_panel)
		weapons_panel:set_y(20)
		weapons_panel:set_h(64)

		local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
		local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")

		primary_weapon_panel:set_bottom(secondary_weapon_panel:top())
		secondary_weapon_panel:set_x(primary_weapon_panel:x())
		secondary_weapon_panel:set_y(primary_weapon_panel:bottom() + 4)
	else
		local panel = self._ammo_panel

		panel:rect({
			name = "ammo_bg",
			color = Color(0.3, 0, 0, 0)
		})
		BoxGuiObject:new(panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		local text_w = panel:w() / 2 - 10
		local text_h = panel:h() / 2 - 10
		local primary_panel = panel:panel({
			name = "primary_weapon_panel",
			x = 5,
			visible = false,
			w = text_w
		})
		local primary_clip = primary_panel:text({
			blend_mode = "normal",
			name = "ammo_clip",
			vertical = "bottom",
			align = "center",
			text = 0,
			y = 5,
			layer = 1,
			color = Color.white,
			h = text_h,
			font_size = text_h / 1.5,
			font = tweak_data.hud_players.ammo_font
		})
		local primary_total = primary_panel:text({
			blend_mode = "normal",
			name = "ammo_total",
			vertical = "top",
			align = "center",
			text = 0,
			layer = 1,
			color = Color.white,
			y = text_h + 15,
			h = text_h,
			font_size = text_h / 1.5,
			font = tweak_data.hud_players.ammo_font
		})
		local weapon_selection_panel = primary_panel:panel({
			name = "weapon_selection",
			layer = 1,
			w = text_w,
			x = primary_panel:w() - text_w
		})

		self:setup_firemode(0, weapon_selection_panel)

		local secondary_panel = panel:panel({
			name = "secondary_weapon_panel",
			visible = false,
			w = text_w
		})

		secondary_panel:set_right(panel:w() - 5)

		local secondary_clip = secondary_panel:text({
			blend_mode = "normal",
			name = "ammo_clip",
			vertical = "bottom",
			align = "center",
			text = 0,
			y = 5,
			layer = 1,
			color = Color.white,
			h = text_h,
			font_size = text_h,
			font = tweak_data.hud_players.ammo_font
		})
		local secondary_total = secondary_panel:text({
			blend_mode = "normal",
			name = "ammo_total",
			vertical = "top",
			align = "center",
			text = 0,
			layer = 1,
			color = Color.white,
			y = text_h + 15,
			h = text_h,
			font_size = text_h,
			font = tweak_data.hud_players.ammo_font
		})
		local weapon_selection_panel = secondary_panel:panel({
			name = "weapon_selection",
			layer = 1,
			w = text_w,
			x = secondary_panel:w() - text_w
		})

		self:setup_firemode(1, weapon_selection_panel)

		local divider = panel:panel({
			w = 2,
			name = "divider",
			h = 120
		})

		divider:set_center(panel:w() / 2, panel:h() / 2)

		local line = divider:bitmap({
			texture = "guis/textures/pd2/shared_lines",
			w = divider:w(),
			h = divider:h()
		})
		local x = math.random(1, 255)
		local y = math.random(0, math.round(line:texture_height() / 2) - 1) * 2

		line:set_texture_coordinates(Vector3(x, y, 0), Vector3(x + divider:w(), y, 0), Vector3(x, y + divider:h(), 0), Vector3(x + divider:w(), y + divider:h(), 0))
		self:_create_reload_panel()
	end

	VRManagerPD2.overlay_helper(self._ammo_panel)
end

function HUDTeammateVR:_create_reload_panel()
	local panel = self._ammo_panel:panel({
		name = "reload_panel",
		w = self._ammo_panel:w() / 2
	})
	local bg = panel:rect({
		name = "reload_bg",
		layer = 2,
		color = Color.black:with_alpha(0.5)
	})
	local icon_size = panel:w() - 10
	local icon = panel:bitmap({
		texture = "guis/textures/pd2/reload_icon",
		name = "reload_icon",
		layer = 3,
		w = icon_size,
		h = icon_size
	})

	icon:set_center(panel:w() / 2, panel:h() / 3)

	self._reload_progress = CircleBitmapGuiObject:new(panel, {
		image = "guis/textures/pd2/progress_reload",
		current = 1,
		total = 1,
		bg = "guis/textures/pd2/progress_reload_black",
		use_bg = true,
		blend_mode = "normal",
		layer = 4,
		radius = icon_size / 2,
		sides = icon_size / 2,
		color = Color.white
	})

	self._reload_progress:set_position(icon:position())

	local text = panel:text({
		name = "reload_text",
		align = "center",
		layer = 3,
		text = managers.localization:to_upper_text("vr_reloading"),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.medium_default_font_size,
		y = icon:bottom() + 10
	})

	managers.hud:make_fine_text(text)
	text:set_center_x(panel:w() / 2)
	panel:set_visible(false)
end

function HUDTeammateVR:set_reload_visible(visible)
	local reload_panel = self._ammo_panel:child("reload_panel")

	reload_panel:set_visible(visible)

	if visible then
		if self._equipped_weapon_type == "secondary" then
			reload_panel:set_right(self._ammo_panel:w())
		else
			reload_panel:set_x(0)
		end
	else
		self:set_reload_timer(0, 1)
	end
end

function HUDTeammateVR:set_reload_timer(current, max)
	self._reload_progress:set_current(current / max)
end

HUDTeammateVR.default_set_weapon_selected = HUDTeammate.set_weapon_selected

function HUDTeammateVR:set_weapon_selected(id, hud_icon)
	if not self._main_player then
		return self:default_set_weapon_selected(id, hud_icon)
	end

	local active_type, inactive_type = unpack(id == 1 and {
		"secondary",
		"primary"
	} or {
		"primary",
		"secondary"
	})
	local active_panel = self._ammo_panel:child(active_type .. "_weapon_panel")
	local inactive_panel = self._ammo_panel:child(inactive_type .. "_weapon_panel")

	active_panel:set_alpha(1)
	inactive_panel:set_alpha(0.5)

	local clip = active_panel:child("ammo_clip")
	local total = active_panel:child("ammo_total")

	clip:set_font_size(clip:h())
	total:set_font_size(total:h())

	clip = inactive_panel:child("ammo_clip")
	total = inactive_panel:child("ammo_total")

	clip:set_font_size(clip:h() / 1.5)
	total:set_font_size(total:h() / 1.5)

	self._equipped_weapon_type = active_type

	managers.hud:belt():set_icon_by_type("weapon", inactive_type)
end

HUDTeammateVR.default_set_weapon_firemode = HUDTeammate.set_weapon_firemode

function HUDTeammateVR:set_weapon_firemode(id, firemode)
	if not self._main_player then
		return self:default_set_weapon_firemode(id, firemode)
	end

	local is_secondary = id == 1
	local secondary_weapon_panel = self._ammo_panel:child("secondary_weapon_panel")
	local primary_weapon_panel = self._ammo_panel:child("primary_weapon_panel")
	local weapon_selection = is_secondary and secondary_weapon_panel:child("weapon_selection") or primary_weapon_panel:child("weapon_selection")

	if alive(weapon_selection) then
		local firemode_single = weapon_selection:child("firemode_single")
		local firemode_auto = weapon_selection:child("firemode_auto")

		if alive(firemode_single) and alive(firemode_auto) then
			self:set_weapon_firemode_active(firemode_single, firemode == "single")
			self:set_weapon_firemode_active(firemode_auto, firemode ~= "single")
		end
	end
end

HUDTeammateVR.default_recreate_weapon_firemode = HUDTeammate.recreate_weapon_firemode

function HUDTeammateVR:recreate_weapon_firemode()
	self:setup_firemode(0, self._ammo_panel:child("primary_weapon_panel"):child("weapon_selection"))
	self:setup_firemode(1, self._ammo_panel:child("secondary_weapon_panel"):child("weapon_selection"))
end

HUDTeammateVR.default_set_ammo_amount_by_type = HUDTeammate.set_ammo_amount_by_type

function HUDTeammateVR:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max, weapon_panel)
	if not self._main_player then
		return self:default_set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max, weapon_panel)
	end

	self:default_set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max, self._ammo_panel:child(type .. "_weapon_panel"))

	if type ~= self._equipped_weapon_type then
		managers.hud:belt():set_amount("weapon", current_left)

		return
	end

	local function ammo_flash(o, color, alpha)
		managers.hud:set_ammo_flash_color(color)
		managers.hud:set_forced_ammo_alpha(alpha)
		o:show()

		local t = 0

		while true do
			t = t + coroutine.yield()
			local alpha = math.clamp(math.sin(t * 360) * 1.2, 0, 1)

			o:set_alpha(alpha)
		end
	end

	local low_ammo_clip = current_clip <= math.round(max_clip / 4)
	local out_of_ammo_clip = current_clip <= 0

	if out_of_ammo_clip then
		if self._ammo_animation ~= "empty" then
			self._ammo_flash:stop()

			self._ammo_animation = "empty"

			self._ammo_flash:animate(ammo_flash, Color(1, 0.9, 0.3, 0.3), 0.2)
		end
	elseif low_ammo_clip then
		if self._ammo_animation ~= "low" then
			self._ammo_flash:stop()

			self._ammo_animation = "low"

			self._ammo_flash:animate(ammo_flash, Color(1, 0.9, 0.9, 0.3), 0.1)
		end
	elseif self._ammo_animation then
		self._ammo_flash:stop()

		self._ammo_animation = nil

		self._ammo_flash:hide()
		managers.hud:set_forced_ammo_alpha(nil)
	end
end

HUDTeammateVR.default_set_state = HUDTeammate.set_state

function HUDTeammateVR:set_state(state)
	local teammate_panel = self._panel
	local is_player = state == "player"

	teammate_panel:child("player"):set_alpha(is_player and 1 or 0)

	local name = teammate_panel:child("name")
	local name_bg = teammate_panel:child("name_bg")
	local callsign_bg = teammate_panel:child("callsign_bg")
	local callsign = teammate_panel:child("callsign")

	if not self._main_player then
		if is_player then
			name:set_x(self._radial_health_panel:x() + name:h())
			name:set_bottom(self._radial_health_panel:top() - 6)
		else
			name:set_x(48 + name:h() + 4)
			name:set_bottom(teammate_panel:h())
		end

		name_bg:set_position(name:x(), name:y() - 1)
		callsign_bg:set_position(name:x() - name:h(), name:y() + 1)
		callsign:set_position(name:x() - name:h(), name:y() + 1)
	end
end

HUDTeammateVR.default_create_equipment_panels = HUDTeammate._create_equipment_panels

function HUDTeammateVR:_create_equipment_panels(player_panel, x, top, bottom)
	if self._main_player then
		return self:default_create_equipment_panels(self._tablet_panel, self._tablet_panel:w() - 60, self._tablet_panel:h() - 170, self._tablet_panel:h() - 100)
	else
		self:default_create_equipment_panels(player_panel, x, top, bottom)
		self._deployable_equipment_panel:set_x(92)
		self._cable_ties_panel:set_x(92)
		self._grenades_panel:set_x(92)
		self._deployable_equipment_panel:set_y(20)
		self._cable_ties_panel:set_y(self._deployable_equipment_panel:bottom())
		self._grenades_panel:set_y(self._cable_ties_panel:bottom())
	end
end

function HUDTeammateVR:add_special_equipment(data)
	local teammate_panel = self._special_equipment_panel
	local special_equipment = self._special_equipment
	local id = data.id
	local equipment_panel = teammate_panel:panel({
		y = 0,
		layer = 0,
		name = id
	})
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)

	equipment_panel:set_size(32, 32)

	local bitmap = equipment_panel:bitmap({
		name = "bitmap",
		layer = 1,
		texture = icon,
		color = Color.white,
		texture_rect = texture_rect,
		w = equipment_panel:w(),
		h = equipment_panel:w()
	})
	local amount, amount_bg = nil

	if data.amount then
		amount = equipment_panel:child("amount") or equipment_panel:text({
			name = "amount",
			vertical = "center",
			font_size = 12,
			align = "center",
			font = "fonts/font_small_noshadow_mf",
			layer = 4,
			text = tostring(data.amount),
			color = Color.black,
			w = equipment_panel:w(),
			h = equipment_panel:h()
		})

		amount:set_visible(data.amount > 1)

		amount_bg = equipment_panel:child("amount_bg") or equipment_panel:bitmap({
			texture = "guis/textures/pd2/equip_count",
			name = "amount_bg",
			layer = 3,
			color = Color.white
		})

		amount_bg:set_visible(data.amount > 1)
	end

	local flash_icon = equipment_panel:bitmap({
		name = "bitmap",
		layer = 2,
		texture = icon,
		color = tweak_data.hud.prime_color,
		texture_rect = texture_rect,
		w = equipment_panel:w() + 2,
		h = equipment_panel:w() + 2
	})

	table.insert(special_equipment, equipment_panel)

	local w = teammate_panel:w()

	equipment_panel:set_x(w - (equipment_panel:w() + 0) * #special_equipment)

	if amount then
		amount_bg:set_center(bitmap:center())
		amount_bg:move(7, 7)
		amount:set_center(amount_bg:center())
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

	flash_icon:set_center(bitmap:center())
	flash_icon:animate(hud.flash_icon, nil, equipment_panel)
	self:layout_special_equipments()
end

function HUDTeammateVR:remove_special_equipment(equipment)
	local teammate_panel = self._special_equipment_panel
	local special_equipment = self._special_equipment

	for i, panel in ipairs(special_equipment) do
		if panel:name() == equipment then
			local data = table.remove(special_equipment, i)

			teammate_panel:remove(panel)
			self:layout_special_equipments()

			return
		end
	end
end

function HUDTeammateVR:set_special_equipment_amount(equipment_id, amount)
	local teammate_panel = self._special_equipment_panel
	local special_equipment = self._special_equipment

	for i, panel in ipairs(special_equipment) do
		if panel:name() == equipment_id then
			panel:child("amount"):set_text(tostring(amount))
			panel:child("amount"):set_visible(amount > 1)
			panel:child("amount_bg"):set_visible(amount > 1)

			return
		end
	end
end

function HUDTeammateVR:clear_special_equipment()
	self._special_equipment_panel:clear()
end

function HUDTeammateVR:layout_special_equipments()
	local teammate_panel = self._special_equipment_panel
	local special_equipment = self._special_equipment
	local next_x = 0

	for i, panel in ipairs(special_equipment) do
		panel:set_x(panel:w() * (i - 1))

		next_x = panel:right()
	end

	self._carry_panel:set_x(next_x)
end

HUDTeammateVR.default_set_name = HUDTeammate.set_name

function HUDTeammateVR:set_name(teammate_name)
	self:default_set_name(teammate_name)
	self._special_equipment_name:set_text(teammate_name)
	self._special_equipment_name:show()
end

local __remove_panel = HUDTeammate.remove_panel

function HUDTeammateVR:remove_panel()
	if not self._main_player then
		return __remove_panel(self)
	end

	return __remove_panel(self, self._ammo_panel)
end

local __set_grenades_amount = HUDTeammate.set_grenades_amount

function HUDTeammateVR:set_grenades_amount(data)
	if self._main_player and data.amount then
		if data.amount > 0 then
			managers.hud:belt():set_state("throwable", "default")
		else
			managers.hud:belt():set_state("throwable", "invalid")
		end

		managers.hud:belt():set_amount("throwable", data.amount)
	end

	return __set_grenades_amount(self, data)
end

local __set_grenade_cooldown = HUDTeammate.set_grenade_cooldown

function HUDTeammateVR:set_grenade_cooldown(data)
	__set_grenade_cooldown(self, data)

	if self._main_player then
		if data and data.end_time and data.duration then
			local now = managers.game_play_central:get_heist_timer()
			local time_left = data.end_time - now
			local start_time = data.duration - time_left

			managers.hud:belt():start_timer("throwable", data.duration, start_time)
		else
			managers.hud:belt():stop_timer("throwable")
		end
	end
end

local __set_deployable_equipment_amount = HUDTeammate.set_deployable_equipment_amount

function HUDTeammateVR:set_deployable_equipment_amount(index, data)
	if self._main_player then
		local belt_id = index == 1 and "deployable" or "deployable_secondary"

		if data.amount > 0 then
			managers.hud:belt():set_state(belt_id, "default")
		else
			managers.hud:belt():set_state(belt_id, "invalid")
		end

		managers.hud:belt():set_amount(belt_id, data.amount)
	end

	return __set_deployable_equipment_amount(self, index, data)
end

local __set_deployable_equipment_amount_from_string = HUDTeammate.set_deployable_equipment_amount_from_string

function HUDTeammateVR:set_deployable_equipment_amount_from_string(index, data)
	if self._main_player then
		local belt_id = index == 1 and "deployable" or "deployable_secondary"

		if data.amount[1] > 0 then
			managers.hud:belt():set_state(belt_id, "default")
		else
			managers.hud:belt():set_state(belt_id, "invalid")
		end

		managers.hud:belt():set_amount(belt_id, data.amount[1])
	end

	return __set_deployable_equipment_amount_from_string(self, index, data)
end

local __set_deployable_equipment = HUDTeammate.set_deployable_equipment

function HUDTeammateVR:set_deployable_equipment(...)
	if self._main_player then
		managers.hud:belt():update_icon("deployable")
	end

	return __set_deployable_equipment(self, ...)
end

local __set_deployable_equipment_from_string = HUDTeammate.set_deployable_equipment_from_string

function HUDTeammateVR:set_deployable_equipment_from_string(...)
	if self._main_player then
		managers.hud:belt():update_icon("deployable")
	end

	return __set_deployable_equipment_from_string(self, ...)
end

function HUDTeammateVR:set_hand(hand)
	if PlayerHand.hand_id(hand) == PlayerHand.RIGHT then
		self._ammo_panel:set_x(100)
		self._radial_health_panel:set_x(15)
		self._stamina_panel:set_x(15)
	else
		self._ammo_panel:set_x(0)
		self._radial_health_panel:set_x(215)
		self._stamina_panel:set_x(215)
	end

	self._ammo_flash:set_shape(self._ammo_panel:shape())
end

function HUDTeammateVR:setup_firemode(id, weapon_selection_panel)
	if alive(weapon_selection_panel:child("firemode_single")) then
		weapon_selection_panel:remove(weapon_selection_panel:child("firemode_single"))
	end

	if alive(weapon_selection_panel:child("firemode_auto")) then
		weapon_selection_panel:remove(weapon_selection_panel:child("firemode_auto"))
	end

	local size_w = weapon_selection_panel:w() / 2
	local size_h = weapon_selection_panel:h() / 2
	local equipped_weapon = id == 1 and managers.blackmarket:equipped_secondary() or managers.blackmarket:equipped_primary()
	local weapon_tweak_data = tweak_data.weapon[equipped_weapon.weapon_id]
	local firemode = weapon_tweak_data.FIRE_MODE
	local can_toggle_firemode = weapon_tweak_data.CAN_TOGGLE_FIREMODE
	local locked_to_auto = managers.weapon_factory:has_perk("fire_mode_auto", equipped_weapon.factory_id, equipped_weapon.blueprint)
	local locked_to_single = managers.weapon_factory:has_perk("fire_mode_single", equipped_weapon.factory_id, equipped_weapon.blueprint)
	local firemode_single = weapon_selection_panel:text({
		name = "firemode_single",
		align = "right",
		text = "I",
		color = Color.white,
		selection_color = (locked_to_auto or not can_toggle_firemode) and Color.red or Color.black,
		w = size_w,
		h = size_h,
		font_size = size_h,
		font = tweak_data.hud_players.ammo_font
	})
	local firemode_auto = weapon_selection_panel:text({
		name = "firemode_auto",
		align = "right",
		text = "III",
		color = Color.white,
		selection_color = (locked_to_single or not can_toggle_firemode) and Color.red or Color.black,
		w = size_w,
		h = size_h,
		font_size = size_h,
		font = tweak_data.hud_players.ammo_font
	})

	firemode_auto:set_bottom(weapon_selection_panel:h())
	self:set_weapon_firemode_active(firemode_single, firemode == "single")
	self:set_weapon_firemode_active(firemode_auto, firemode ~= "single")
	firemode_single:set_visible(false)
	firemode_auto:set_visible(false)
end

function HUDTeammateVR:set_weapon_firemode_active(firemode_gui, active)
	firemode_gui:set_selection(0, active and 0 or utf8.len(firemode_gui:text()))
end
