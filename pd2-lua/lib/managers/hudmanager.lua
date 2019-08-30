HUDManager = HUDManager or class()
HUDManager.WAITING_SAFERECT = Idstring("guis/waiting_saferect")
HUDManager.STATS_SCREEN_SAFERECT = Idstring("guis/stats_screen/stats_screen_saferect_pd2")
HUDManager.STATS_SCREEN_FULLSCREEN = Idstring("guis/stats_screen/stats_screen_fullscreen")
HUDManager.WAITING_FOR_PLAYERS_SAFERECT = Idstring("guis/waiting_saferect")
HUDManager.ASSAULT_DIALOGS = {
	"b01a",
	"b01b",
	"b02a",
	"b02b",
	"b02c",
	"b03x",
	"b04x",
	"b05x",
	"b10",
	"b11",
	"b12"
}
HUDManager.ASSAULTS_MAX = 1024

core:import("CoreEvent")

function HUDManager:init()
	self._component_map = {}
	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
	local safe_rect = managers.viewport:get_safe_rect()
	local res = RenderSettings.resolution
	self._workspace_size = {
		x = 0,
		y = 0,
		w = res.x,
		h = res.y
	}
	self._saferect_size = {
		x = safe_rect.x,
		y = safe_rect.y,
		w = safe_rect.width,
		h = safe_rect.height
	}

	self:_setup_workspaces()

	self._updators = {}

	managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))

	self._sound_source = SoundDevice:create_source("hud")

	managers.user:add_setting_changed_callback("controller_mod", callback(self, self, "controller_mod_changed"), true)

	self._crosshair_visible = false
	self._crosshair_enabled = false

	self:_init_player_hud_values()

	self._chatinput_changed_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._chat_focus = false
	HUDManager.HIDEABLE_HUDS = {
		[PlayerBase.PLAYER_INFO_HUD_PD2:key()] = true,
		[PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2:key()] = true,
		[PlayerBase.PLAYER_DOWNED_HUD:key()] = true,
		[IngameWaitingForRespawnState.GUI_SPECTATOR:key()] = true,
		[Idstring("guis/mask_off_hud"):key()] = true
	}

	if Global.debug_show_coords then
		self:debug_show_coordinates()
	else
		self:debug_hide_coordinates()
	end

	self._visible_huds_states = {}
	self._disabled = Global.hud_disabled
	self._controller = managers.controller:create_controller("HUDManager", nil, false)

	self._controller:add_trigger("toggle_hud", callback(self, self, "_toggle_hud_callback"))
	self._controller:add_trigger("drop_in_accept", callback(self, self, "_drop_in_input_callback", "drop_in_accept"))
	self._controller:add_trigger("drop_in_return", callback(self, self, "_drop_in_input_callback", "drop_in_return"))
	self._controller:add_trigger("drop_in_kick", callback(self, self, "_drop_in_input_callback", "drop_in_kick"))
	self._controller:enable()

	self._waiting_index = {}

	call_on_next_update(function ()
		managers.custom_safehouse:register_trophy_unlocked_callback(function (...)
			if managers.hud then
				managers.hud:safe_house_challenge_popup(...)
			end
		end, "hud")
	end, "hud_add_challange_callback")
end

function HUDManager:destroy()
	self._controller:destroy()
end

function HUDManager:_setup_workspaces()
	self._workspaces = {
		overlay = {
			mid_saferect = managers.gui_data:create_saferect_workspace("screen", Overlay:gui()),
			fullscreen_workspace = managers.gui_data:create_fullscreen_16_9_workspace("screen", Overlay:gui()),
			saferect = managers.gui_data:create_saferect_workspace("screen", Overlay:gui()),
			workspace = managers.gui_data:create_fullscreen_workspace("screen", Overlay:gui())
		}
	}

	managers.gui_data:layout_corner_saferect_1280_workspace(self._workspaces.overlay.saferect)

	self._mid_saferect = self._workspaces.overlay.mid_saferect
	self._fullscreen_workspace = self._workspaces.overlay.fullscreen_workspace
	self._saferect = self._workspaces.overlay.saferect
	self._workspace = self._workspaces.overlay.workspace

	if _G.IS_VR then
		self._workspaces.menu = {
			mid_saferect = managers.gui_data:create_saferect_workspace(nil, MenuRoom:gui()),
			fullscreen_workspace = managers.gui_data:create_fullscreen_16_9_workspace(nil, MenuRoom:gui()),
			saferect = managers.gui_data:create_saferect_workspace(nil, MenuRoom:gui()),
			workspace = managers.gui_data:create_fullscreen_workspace(nil, MenuRoom:gui())
		}

		managers.gui_data:layout_corner_saferect_1280_workspace(self._workspaces.menu.saferect)
	end
end

function HUDManager:workspace(name, group)
	if _G.IS_VR and group then
		local t = self._workspaces[group]

		if t then
			return t[name]
		end
	end

	return self._workspaces.overlay[name]
end

function HUDManager:_toggle_hud_callback()
	if managers.menu:is_active() or not Global.hud_disabled and self._chat_focus then
		return
	end

	if Global.hud_disabled then
		managers.hud:set_enabled()
	else
		managers.hud:set_disabled()
	end
end

function HUDManager:_drop_in_input_callback(binding_str)
	if self._waiting_legend then
		self._waiting_legend:on_input(binding_str)
	end
end

function HUDManager:crosshair_enabled_changed(name, old_value, new_value)
	self._crosshair_enabled = new_value

	if new_value then
		self:_layout_crosshair()
		self:_set_crosshair_panel_visible(self._crosshair_visible)
	else
		self:_set_crosshair_panel_visible(false)
	end
end

function HUDManager:crosshair_enabled()
	return self._crosshair_enabled
end

function HUDManager:saferect_w()
	return self._saferect:width()
end

function HUDManager:saferect_h()
	return self._saferect:height()
end

function HUDManager:add_chatinput_changed_callback(callback_func)
	self._chatinput_changed_callback_handler:add(callback_func)
end

function HUDManager:remove_chatinput_changed_callback(callback_func)
	self._chatinput_changed_callback_handler:remove(callback_func)
end

local is_PS3 = SystemInfo:platform() == Idstring("PS3")

function HUDManager:init_finalize()
	if not self:exists(self.WAITING_FOR_PLAYERS_SAFERECT) then
		managers.hud:load_hud(self.WAITING_FOR_PLAYERS_SAFERECT, false, true, true, {})
	end

	if not self:exists(PlayerBase.PLAYER_DOWNED_HUD) then
		managers.hud:load_hud(PlayerBase.PLAYER_DOWNED_HUD, false, false, true, {})
	end

	if not self:exists(PlayerBase.PLAYER_CUSTODY_HUD) then
		managers.hud:load_hud(PlayerBase.PLAYER_CUSTODY_HUD, false, false, true, {})
	end

	if not self:exists(IngameAccessCamera.GUI_SAFERECT) then
		local group = nil

		if _G.IS_VR then
			group = "menu"
		end

		managers.hud:load_hud(IngameAccessCamera.GUI_FULLSCREEN, false, false, false, {}, nil, nil, nil, group)
		managers.hud:load_hud(IngameAccessCamera.GUI_SAFERECT, false, false, true, {}, nil, nil, nil, group)
	end

	if not self:exists(PlayerBase.PLAYER_INFO_HUD_PD2) then
		managers.hud:load_hud(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2, false, false, false, {})
		managers.hud:load_hud(PlayerBase.PLAYER_INFO_HUD_PD2, false, false, true, {})
	end

	if not self:exists(PlayerBase.PLAYER_HUD) then
		managers.hud:load_hud(PlayerBase.PLAYER_HUD, false, false, true, {})
	end
end

function HUDManager:set_safe_rect(rect)
	self._saferect_size = rect

	self._saferect:set_screen(rect.w, rect.h, rect.x, rect.y, RenderSettings.resolution.x)
end

function HUDManager:load_hud_menu(name, visible, using_collision, using_saferect, mutex_list, bounding_box_list, using_mid_saferect, using_16_9_fullscreen)
	if _G.IS_VR then
		return self:load_hud(name, visible, using_collision, using_saferect, mutex_list, bounding_box_list, using_mid_saferect, using_16_9_fullscreen, "menu")
	end

	return self:load_hud(name, visible, using_collision, using_saferect, mutex_list, bounding_box_list, using_mid_saferect, using_16_9_fullscreen)
end

function HUDManager:load_hud(name, visible, using_collision, using_saferect, mutex_list, bounding_box_list, using_mid_saferect, using_16_9_fullscreen, group)
	if self._component_map[name:key()] then
		Application:error("ERROR! Component " .. tostring(name) .. " have already been loaded!")

		return
	end

	local bounding_box = {}
	group = group or "overlay"
	local panel = nil

	if using_16_9_fullscreen then
		panel = self._workspaces[group].fullscreen_workspace:panel():gui(name, {})
	elseif using_mid_saferect then
		panel = self._workspaces[group].mid_saferect:panel():gui(name, {})
	elseif using_saferect then
		panel = self._workspaces[group].saferect:panel():gui(name, {})
	else
		panel = self._workspaces[group].workspace:panel():gui(name, {})
	end

	panel:hide()

	local bb_list = bounding_box_list

	if not bb_list and panel:has_script() then
		for k, v in pairs(panel:script()) do
			if k == "get_bounding_box_list" then
				if type(v) == "function" then
					bb_list = v()
				end

				break
			end
		end
	end

	if bb_list then
		if bb_list.x then
			table.insert(bb_list, {
				x1 = bb_list.x,
				y1 = bb_list.y,
				x2 = bb_list.x + bb_list.w,
				y2 = bb_list.y + bb_list.h
			})
		else
			for _, rect in pairs(bb_list) do
				table.insert(bounding_box, {
					x1 = rect.x,
					y1 = rect.y,
					x2 = rect.x + rect.w,
					y2 = rect.y + rect.h
				})
			end
		end
	else
		bounding_box = self:_create_bounding_boxes(panel)
	end

	self._component_map[name:key()] = {}
	self._component_map[name:key()].panel = panel
	self._component_map[name:key()].bb_list = bounding_box
	self._component_map[name:key()].mutex_list = {}
	self._component_map[name:key()].overlay_list = {}
	self._component_map[name:key()].idstring = name
	self._component_map[name:key()].load_visible = visible
	self._component_map[name:key()].load_using_collision = using_collision
	self._component_map[name:key()].load_using_saferect = using_saferect

	if mutex_list then
		self._component_map[name:key()].mutex_list = mutex_list
	end

	if using_collision then
		self._component_map[name:key()].overlay_list = self:_create_overlay_list(name)
	end

	if visible then
		panel:show()
	end

	self:setup(name)
	self:layout(name)
end

function HUDManager:setup(name)
	local panel = self:script(name).panel

	if not panel:has_script() then
		return
	end

	for k, v in pairs(panel:script()) do
		if k == "setup" then
			panel:script().setup(self)

			break
		end
	end
end

function HUDManager:layout(name)
	local panel = self:script(name).panel

	if not panel:has_script() then
		return
	end

	for k, v in pairs(panel:script()) do
		if k == "layout" then
			panel:script().layout(self)

			break
		end
	end
end

function HUDManager:delete(name)
	self._component_map[name:key()] = nil
end

function HUDManager:set_disabled()
	self._disabled = true
	Global.hud_disabled = true

	for name, _ in pairs(HUDManager.HIDEABLE_HUDS) do
		if self._visible_huds_states[name] then
			local component = self._component_map[name]

			if component and alive(component.panel) then
				component.panel:hide()
			end
		end
	end
end

function HUDManager:set_enabled()
	self._disabled = false
	Global.hud_disabled = nil

	for name, _ in pairs(HUDManager.HIDEABLE_HUDS) do
		if self._visible_huds_states[name] then
			local component = self._component_map[name]

			if component and alive(component.panel) then
				component.panel:show()
			end
		end
	end
end

function HUDManager:set_freeflight_disabled()
	self._saferect:hide()
	self._workspace:hide()
	self._mid_saferect:hide()
	self._fullscreen_workspace:hide()
end

function HUDManager:set_freeflight_enabled()
	self._saferect:show()
	self._workspace:show()
	self._mid_saferect:show()
	self._fullscreen_workspace:show()
end

function HUDManager:disabled()
	return self._disabled
end

function HUDManager:reload_player_hud()
	local name = PlayerBase.PLAYER_HUD
	local recreate = self._component_map[name:key()]

	self:reload()

	if recreate then
		self:hide(name)
		self:delete(name)
		self:load_hud(name, false, false, true, {})
		self:show(name)
		self:_player_hud_layout()
	end
end

function HUDManager:reload_all()
	self:reload()

	for name, gui in pairs(clone(self._component_map)) do
		local visible = self:visible(gui.idstring)

		self:hide(gui.idstring)
		self:delete(gui.idstring)
		self:load_hud(gui.idstring, gui.load_visible, gui.load_using_collision, gui.load_using_saferect, {})

		if visible then
			self:show(gui.idstring)
		end
	end
end

function HUDManager:reload()
	self:_recompile(managers.database:root_path() .. "assets\\guis\\")
end

function HUDManager:_recompile(dir)
	local source_files = self:_source_files(dir)
	local t = {
		target_db_name = "all",
		send_idstrings = false,
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:root_path() .. "/assets",
		target_db_root = Application:base_path() .. "assets",
		source_files = source_files
	}

	Application:data_compile(t)
	DB:reload()
	managers.database:clear_all_cached_indices()

	for _, file in ipairs(source_files) do
		PackageManager:reload(managers.database:entry_type(file):id(), managers.database:entry_path(file):id())
	end
end

function HUDManager:_source_files(dir)
	local files = {}
	local entry_path = managers.database:entry_path(dir) .. "/"

	for _, file in ipairs(SystemFS:list(dir)) do
		table.insert(files, entry_path .. file)
	end

	for _, sub_dir in ipairs(SystemFS:list(dir, true)) do
		for _, file in ipairs(SystemFS:list(dir .. "/" .. sub_dir)) do
			table.insert(files, entry_path .. sub_dir .. "/" .. file)
		end
	end

	return files
end

function HUDManager:panel(name)
	if not self._component_map[name:key()] then
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	else
		return self._component_map[name:key()].panel
	end
end

function HUDManager:alive(name)
	local component = self._component_map[name:key()]

	return component and alive(component.panel)
end

function HUDManager:script(name)
	local component = self._component_map[name:key()]

	if component and alive(component.panel) then
		return self._component_map[name:key()].panel:script()
	end
end

function HUDManager:exists(name)
	return not not self._component_map[name:key()]
end

function HUDManager:show(name)
	if name == PlayerBase.PLAYER_INFO_HUD then
		name = PlayerBase.PLAYER_INFO_HUD_PD2
	end

	if name == PlayerBase.PLAYER_INFO_HUD_FULLSCREEN then
		name = PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2
	end

	if HUDManager.disabled[name:key()] then
		return
	end

	self._visible_huds_states[name:key()] = true

	if self._disabled and HUDManager.HIDEABLE_HUDS[name:key()] then
		return
	end

	if self._component_map[name:key()] then
		local panel = self:script(name).panel

		if panel:has_script() then
			for k, v in pairs(panel:script()) do
				if k == "show" then
					panel:script().show(self)

					break
				end
			end
		end

		for _, mutex_name in pairs(self._component_map[name:key()].mutex_list) do
			if self._component_map[mutex_name:key()].panel:visible() then
				self._component_map[mutex_name:key()].panel:hide()
			end
		end

		if self:_validate_components(name) then
			self._component_map[name:key()].panel:show()
		end
	else
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	end
end

function HUDManager:hide(name)
	if name == PlayerBase.PLAYER_INFO_HUD then
		name = PlayerBase.PLAYER_INFO_HUD_PD2
	end

	if name == PlayerBase.PLAYER_INFO_HUD_FULLSCREEN then
		name = PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2
	end

	self._visible_huds_states[name:key()] = nil
	local panel = self:script(name).panel

	if panel:has_script() then
		for k, v in pairs(panel:script()) do
			if k == "hide" then
				panel:script().hide(self)

				break
			end
		end
	end

	local component = self._component_map[name:key()]

	if component and alive(component.panel) then
		component.panel:hide()
	elseif not component then
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	end
end

function HUDManager:set_hud_chat(hud)
end

function HUDManager:visible(name)
	if self._component_map[name:key()] then
		return self._component_map[name:key()].panel:visible()
	else
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	end
end

function HUDManager:_collision(rect1_map, rect2_map)
	if rect2_map.x2 <= rect1_map.x1 then
		return false
	end

	if rect1_map.x2 <= rect2_map.x1 then
		return false
	end

	if rect2_map.y2 <= rect1_map.y1 then
		return false
	end

	if rect1_map.y2 <= rect2_map.y1 then
		return false
	end

	return true
end

function HUDManager:_inside(rect1_map, rect2_map)
	if rect1_map.x1 < rect2_map.x1 or rect2_map.x2 < rect1_map.x1 then
		return false
	end

	if rect1_map.y1 < rect2_map.y1 or rect2_map.y2 < rect1_map.y1 then
		return false
	end

	if rect1_map.x2 < rect2_map.x1 or rect2_map.x2 < rect1_map.x2 then
		return false
	end

	if rect1_map.y2 < rect2_map.x1 or rect2_map.y2 < rect1_map.y2 then
		return false
	end

	return true
end

function HUDManager:_collision_rects(rect1_list, rect2_list)
	for _, rc1_map in pairs(rect1_list) do
		for _, rc2_map in pairs(rect2_list) do
			if self:_collision(rc1_map, rc2_map) then
				return true
			end
		end
	end

	return false
end

function HUDManager:_is_mutex(component_map, name)
	for _, mutex_name in pairs(component_map.mutex_list) do
		if mutex_name:key() == name then
			return true
		end
	end

	return false
end

function HUDManager:_create_bounding_boxes(panel)
	local bounding_box_list = {}
	local childrens = panel:children()
	local rect_map = {}

	for _, object in pairs(childrens) do
		rect_map = {
			x1 = object:x(),
			y1 = object:y(),
			x2 = object:x() + object:w(),
			y2 = object:y() + object:h()
		}

		if #bounding_box_list == 0 then
			table.insert(bounding_box_list, rect_map)
		else
			for _, bb_rect_map in pairs(bounding_box_list) do
				if self:_inside(rect_map, bb_rect_map) == false then
					table.insert(bounding_box_list, rect_map)

					break
				end
			end
		end
	end

	return bounding_box_list
end

function HUDManager:_create_overlay_list(name)
	local component = self._component_map[name:key()]
	local overlay_list = {}

	for cmp_name, cmp_map in pairs(self._component_map) do
		if name:key() ~= cmp_name and not self:_is_mutex(cmp_map, name:key()) and self:_collision_rects(component.bb_list, cmp_map.bb_list) then
			table.insert(overlay_list, cmp_map.idstring)

			if not self:_is_mutex(component, cmp_name) then
				table.insert(self._component_map[cmp_name].overlay_list, name)
			end

			if Application:production_build() then
				Application:error("WARNING! Component " .. tostring(name) .. " collides with " .. tostring(cmp_map.idstring))
			end
		end
	end

	return overlay_list
end

function HUDManager:_validate_components(name)
	for _, overlay_name in pairs(self._component_map[name:key()].overlay_list) do
		if self._component_map[overlay_name:key()] and self._component_map[overlay_name:key()].panel:visible() then
			Application:error("WARNING! Component " .. tostring(name) .. " collides with " .. tostring(overlay_name))

			return false
		end
	end

	return true
end

function HUDManager:resolution_changed()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
	local safe_rect = managers.viewport:get_safe_rect()

	managers.gui_data:layout_corner_saferect_1280_workspace(self._saferect)
	managers.gui_data:layout_fullscreen_workspace(self._workspace)
	managers.gui_data:layout_workspace(self._mid_saferect)
	managers.gui_data:layout_fullscreen_16_9_workspace(self._fullscreen_workspace)

	if _G.IS_VR then
		managers.gui_data:layout_corner_saferect_1280_workspace(self._workspace.menu.saferect)
		managers.gui_data:layout_fullscreen_workspace(self._workspace.menu.workspace)
		managers.gui_data:layout_workspace(self._workspace.menu.mid_saferect)
		managers.gui_data:layout_fullscreen_16_9_workspace(self._workspace.menu.fullscreen_workspace)
	end

	for name, gui in pairs(self._component_map) do
		self:layout(gui.idstring)
	end

	self:_additional_layout()
end

function HUDManager:_additional_layout()
end

function HUDManager:update(t, dt)
	for _, cb in pairs(self._updators) do
		cb(t, dt)
	end

	self:_update_name_labels(t, dt)
	self:_update_waypoints(t, dt)

	if self._debug then
		local cam_pos = managers.viewport:get_current_camera_position()

		if cam_pos then
			self._debug.coord:set_text(string.format("Cam pos:   \"%.0f %.0f %.0f\" [cm]", cam_pos.x, cam_pos.y, cam_pos.z))
		end
	end
end

function HUDManager:add_updator(id, cb)
	self._updators[id] = cb
end

function HUDManager:remove_updator(id)
	self._updators[id] = nil
end

local nl_w_pos = Vector3()
local nl_pos = Vector3()
local nl_dir = Vector3()
local nl_dir_normalized = Vector3()
local nl_cam_forward = Vector3()

function HUDManager:_update_name_labels(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local player = managers.player:local_player()
	local in_steelsight = false

	if alive(player) then
		in_steelsight = player:movement() and player:movement():current_state() and player:movement():current_state():in_steelsight() or false
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, nl_cam_forward)

	local to_remove = {}
	local panel = nil

	for _, data in ipairs(self._hud.name_labels) do
		local label_panel = data.panel
		panel = panel or label_panel:parent()
		local pos = nil

		if data.movement then
			if not alive(data.movement._unit) then
				label_panel:set_visible(false)

				to_remove[data.id] = true
			else
				pos = data.movement:m_pos()

				mvector3.set(nl_w_pos, pos)
				mvector3.set_z(nl_w_pos, mvector3.z(data.movement:m_head_pos()) + 30)
			end
		elseif data.vehicle then
			if not alive(data.vehicle) then
				return
			end

			pos = data.vehicle:position()

			mvector3.set(nl_w_pos, pos)
			mvector3.set_z(nl_w_pos, pos.z + data.vehicle:vehicle_driving().hud_label_offset)
		end

		if pos then
			mvector3.set(nl_pos, self._workspace:world_to_screen(cam, nl_w_pos))
			mvector3.set(nl_dir, nl_w_pos)
			mvector3.subtract(nl_dir, cam_pos)
			mvector3.set(nl_dir_normalized, nl_dir)
			mvector3.normalize(nl_dir_normalized)

			local dot = mvector3.dot(nl_cam_forward, nl_dir_normalized)

			if dot < 0 or panel:outside(mvector3.x(nl_pos), mvector3.y(nl_pos)) then
				if label_panel:visible() then
					label_panel:set_visible(false)
				end
			else
				label_panel:set_alpha(in_steelsight and math.clamp((1 - dot) * 100, 0, 1) or 1)
				label_panel:set_visible(true)

				if mvector3.distance_sq(cam_pos, nl_w_pos) < 250000 then
					label_panel:set_visible(true)
				elseif dot > 0.925 then
					-- Nothing
				end
			end

			if data.movement then
				if data.movement.current_state_name and data.movement:current_state_name() == "driving" then
					label_panel:set_visible(false)
				elseif data.movement.vehicle_seat and data.movement.vehicle_seat.occupant ~= nil then
					label_panel:set_visible(false)
				end
			end

			local offset = data.panel:child("cheater"):h() / 2

			if label_panel:visible() then
				label_panel:set_center(nl_pos.x, nl_pos.y - offset)
			end
		end
	end

	for id, _ in pairs(to_remove) do
		self:_remove_name_label(id)
	end
end

function HUDManager:_init_player_hud_values()
	self._hud = self._hud or {}
	self._hud.waypoints = self._hud.waypoints or {}
	self._hud.stored_waypoints = self._hud.stored_waypoints or {}
	self._hud.weapons = self._hud.weapons or {}
	self._hud.mugshots = self._hud.mugshots or {}
	self._hud.name_labels = self._hud.name_labels or {}
end

function HUDManager:post_event(event)
	self._sound_source:post_event(event)
end

function HUDManager:_player_hud_layout()
	if not self:alive(PlayerBase.PLAYER_HUD) then
		return
	end

	self:_init_player_hud_values()

	for id, data in pairs(self._hud.stored_waypoints) do
		self:add_waypoint(id, data)
	end
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
	local distance = nil

	if data.distance then
		distance = waypoint_panel:text({
			vertical = "center",
			h = 24,
			w = 128,
			align = "center",
			text = "16.5",
			rotation = 360,
			layer = 0,
			name = "distance" .. id,
			color = data.color or Color.white,
			font = tweak_data.hud.medium_font_noshadow,
			font_size = tweak_data.hud.default_font_size,
			blend_mode = data.blend_mode
		})

		distance:set_visible(false)
	end

	local timer = data.timer and waypoint_panel:text({
		font_size = 32,
		h = 32,
		vertical = "center",
		w = 32,
		align = "center",
		rotation = 360,
		layer = 0,
		name = "timer" .. id,
		text = (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer),
		font = tweak_data.hud.medium_font_noshadow
	})
	text = waypoint_panel:text({
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
		radius = data.radius or 160
	}
	self._hud.waypoints[id].init_data.position = data.position or data.unit:position()
	local slot = 1
	local t = {}

	for _, data in pairs(self._hud.waypoints) do
		if data.slot then
			t[data.slot] = data.text:w()
		end
	end

	for i = 1, 10, 1 do
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
end

function HUDManager:change_waypoint_icon_alpha(id, alpha)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]

	wp_data.bitmap:set_alpha(alpha)
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

	if self._hud.waypoints[id].timer_gui then
		waypoint_panel:remove(self._hud.waypoints[id].timer_gui)
	end

	if self._hud.waypoints[id].distance then
		waypoint_panel:remove(self._hud.waypoints[id].distance)
	end

	self._hud.waypoints[id] = nil
end

function HUDManager:set_waypoint_timer_pause(id, pause)
	if not self._hud.waypoints[id] then
		return
	end

	self._hud.waypoints[id].pause_timer = self._hud.waypoints[id].pause_timer + (pause and 1 or -1)
end

function HUDManager:get_waypoint_data(id)
	return self._hud.waypoints[id]
end

function HUDManager:clear_waypoints()
	for id, _ in pairs(clone(self._hud.waypoints)) do
		self:remove_waypoint(id)
	end
end

function HUDManager:clear_weapons()
	self._hud.weapons = {}
end

function HUDManager:add_mugshot_by_unit(unit)
	if unit:base().is_local_player then
		return
	end

	local character_name = unit:base():nick_name()
	local name_label_id = managers.hud:_add_name_label({
		name = character_name,
		unit = unit
	})
	unit:unit_data().name_label_id = name_label_id
	local is_husk_player = unit:base().is_husk_player
	local character_name_id = managers.criminals:character_name_by_unit(unit)

	for i, data in ipairs(self._hud.mugshots) do
		if data.character_name_id == character_name_id then
			if is_husk_player and not data.peer_id then
				self:_remove_mugshot(data.id)

				break
			else
				unit:unit_data().mugshot_id = data.id

				managers.hud:set_mugshot_normal(unit:unit_data().mugshot_id)
				managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, 1)
				managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, 1)

				return
			end
		end
	end

	local peer, peer_id = nil

	if is_husk_player then
		peer = unit:network():peer()
		peer_id = peer:id()
	end

	local use_lifebar = is_husk_player and true or false
	local mugshot_id = managers.hud:add_mugshot({
		name = character_name,
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})
	unit:unit_data().mugshot_id = mugshot_id

	if peer and peer:is_cheater() then
		self:mark_cheater(peer_id)
	end

	return mugshot_id
end

function HUDManager:add_mugshot_without_unit(char_name, ai, peer_id, name)
	local character_name = name
	local character_name_id = char_name

	if not ai then
		-- Nothing
	end

	local use_lifebar = not ai
	local mugshot_id = managers.hud:add_mugshot({
		name = character_name,
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})

	return mugshot_id
end

function HUDManager:add_mugshot(data)
	local panel_id = self:add_teammate_panel(data.character_name_id, data.name, not data.use_lifebar, data.peer_id)
	managers.criminals:character_data_by_name(data.character_name_id).panel_id = panel_id
	local last_id = self._hud.mugshots[#self._hud.mugshots] and self._hud.mugshots[#self._hud.mugshots].id or 0
	local id = last_id + 1

	table.insert(self._hud.mugshots, {
		id = id,
		character_name_id = data.character_name_id,
		peer_id = data.peer_id
	})

	return id
end

function HUDManager:remove_hud_info_by_unit(unit)
	if unit:unit_data().name_label_id then
		self:_remove_name_label(unit:unit_data().name_label_id)
	end
end

function HUDManager:remove_mugshot_by_character_name(character_name)
	for i, data in ipairs(self._hud.mugshots) do
		if data.character_name_id == character_name then
			self:_remove_mugshot(data.id)

			break
		end
	end
end

function HUDManager:remove_mugshot(id)
	self:_remove_mugshot(id)
end

function HUDManager:_remove_mugshot(id)
	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			table.remove(self._hud.mugshots, i)
			self:remove_teammate_panel_by_name_id(data.character_name_id)

			break
		end
	end
end

function HUDManager:remove_teammate_panel_by_name_id(name_id)
	local character_data = managers.criminals:character_data_by_name(name_id)

	if character_data and character_data.panel_id then
		self:remove_teammate_panel(character_data.panel_id)
	end
end

function HUDManager:set_mugshot_weapon(id, hud_icon_id, weapon_index)
	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			print("set_mugshot_weapon", id, hud_icon_id, weapon_index)
			self:_set_teammate_weapon_selected(managers.criminals:character_data_by_name(data.character_name_id).panel_id, weapon_index, hud_icon_id)

			break
		end
	end
end

function HUDManager:set_mugshot_damage_taken(id)
	if not id then
		return
	end
end

function HUDManager:set_mugshot_armor(id, amount)
	if not id then
		return
	end

	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			self:set_teammate_armor(managers.criminals:character_data_by_name(data.character_name_id).panel_id, {
				total = 1,
				max = 1,
				current = amount
			})

			break
		end
	end
end

function HUDManager:set_mugshot_health(id, amount)
	if not id then
		return
	end

	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			self:set_teammate_health(managers.criminals:character_data_by_name(data.character_name_id).panel_id, {
				total = 1,
				max = 1,
				current = amount
			})

			break
		end
	end
end

function HUDManager:set_mugshot_talk(id, active)
	if not id then
		return
	end
end

function HUDManager:set_mugshot_voice(id, active)
	if not id then
		return
	end
end

function HUDManager:_get_mugshot_data(id)
	if not id then
		return nil
	end

	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			return data
		end
	end

	return nil
end

function HUDManager:set_mugshot_normal(id)
	local data = self:_get_mugshot_data(id)

	if not data then
		return
	end

	self:set_teammate_condition(managers.criminals:character_data_by_name(data.character_name_id).panel_id, "mugshot_normal", "")
end

function HUDManager:set_mugshot_downed(id)
	self:_set_mugshot_state(id, "mugshot_downed", managers.localization:text("debug_mugshot_downed"))
end

function HUDManager:set_mugshot_custody(id)
	self:set_mugshot_talk(id, false)

	local data = self:_set_mugshot_state(id, "mugshot_in_custody", managers.localization:text("debug_mugshot_in_custody"))

	if data then
		local i = managers.criminals:character_data_by_name(data.character_name_id).panel_id

		self:set_teammate_health(i, {
			total = 100,
			current = 0,
			no_hint = true
		})
		self:set_teammate_armor(i, {
			total = 100,
			current = 0,
			no_hint = true
		})
	end
end

function HUDManager:set_mugshot_cuffed(id)
	self:_set_mugshot_state(id, "mugshot_cuffed", managers.localization:text("debug_mugshot_cuffed"))
end

function HUDManager:set_mugshot_tased(id)
	self:_set_mugshot_state(id, "mugshot_electrified", managers.localization:text("debug_mugshot_electrified"))
end

function HUDManager:_set_mugshot_state(id, icon_data, text)
	local data = self:_get_mugshot_data(id)

	if not data then
		return
	end

	local i = managers.criminals:character_data_by_name(data.character_name_id).panel_id

	self:set_teammate_condition(i, icon_data, text)

	return data
end

function HUDManager:update_name_label_by_peer(peer)
	for _, data in pairs(self._hud.name_labels) do
		if data.peer_id == peer:id() then
			local name = data.character_name

			if peer:level() then
				local experience = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "-" or "") .. peer:level()
				name = name .. " (" .. experience .. ")"
			end

			data.text:set_text(name)
			self:align_teammate_name_label(data.panel, data.interact)

			break
		end
	end
end

function HUDManager:update_vehicle_label_by_id(label_id, num_players)
	for _, data in pairs(self._hud.name_labels) do
		if data.id == label_id then
			local name = data.character_name

			if num_players > 0 then
				name = "(" .. num_players .. ") " .. name
			end

			data.text:set_text(utf8.to_upper(name))
			self:align_teammate_name_label(data.panel, data.interact)

			break
		end
	end
end

function HUDManager:start_anticipation(data)
	local hud = managers.hud:script(PlayerBase.PLAYER_HUD)

	if not hud then
		return
	end
end

function HUDManager:sync_start_anticipation()
end

function HUDManager:check_start_anticipation_music(t)
	if not self._anticipation_music_started and t < 30 then
		self._anticipation_music_started = true

		managers.network:session():send_to_peers_synched("sync_start_anticipation_music")
		self:sync_start_anticipation_music()
	end
end

function HUDManager:sync_start_anticipation_music()
	managers.music:post_event(tweak_data.levels:get_music_event("anticipation"))
end

function HUDManager:start_assault(assault_number)
	self._hud.in_assault = true

	managers.network:session():send_to_peers_synched("sync_start_assault", math.min(assault_number, HUDManager.ASSAULTS_MAX))
	self:sync_start_assault(assault_number)
end

function HUDManager:end_assault(result)
	self._anticipation_music_started = false
	self._hud.in_assault = false

	self:sync_end_assault(result)
	managers.network:session():send_to_peers_synched("sync_end_assault", result)
end

function HUDManager:setup_anticipation(total_t)
	local exists = self._anticipation_dialogs and true or false
	self._anticipation_dialogs = {}

	if not exists and total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 45,
			dialog = 1
		})
		table.insert(self._anticipation_dialogs, {
			time = 30,
			dialog = 2
		})
	elseif exists and total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 30,
			dialog = 6
		})
	end

	if total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 20,
			dialog = 3
		})
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 4
		})
	end

	if total_t == 35 then
		table.insert(self._anticipation_dialogs, {
			time = 20,
			dialog = 7
		})
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 4
		})
	end

	if total_t == 25 then
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 8
		})
	end
end

function HUDManager:check_anticipation_voice(t)
	if not self._anticipation_dialogs[1] then
		return
	end

	if t < self._anticipation_dialogs[1].time then
		local data = table.remove(self._anticipation_dialogs, 1)

		self:sync_assault_dialog(data.dialog)
		managers.network:session():send_to_peers_synched("sync_assault_dialog", data.dialog)
	end
end

function HUDManager:sync_assault_dialog(index)
	if not managers.groupai:state():bain_state() then
		return
	end

	local dialog = HUDManager.ASSAULT_DIALOGS[index]

	managers.dialog:queue_narrator_dialog(dialog, {})
end

function HUDManager:set_crosshair_offset(offset)
end

function HUDManager:set_crosshair_visible(visible)
end

function HUDManager:_set_crosshair_panel_visible(visible)
end

function HUDManager:present_mid_text(params)
	params.present_mid_text = true

	self:present(params)
end

function HUDManager:_kick_crosshair_offset(offset)
end

function HUDManager:_layout_crosshair()
end

function HUDManager:_update_crosshair_offset(t, dt)
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

			data.bitmap:set_center_x(data.current_position.x)
			data.bitmap:set_center_y(data.current_position.y)

			data.slot = nil
			data.current_scale = 1
			data.state = "present_ended"
			data.text_alpha = 0.5
			data.in_timer = 0
			data.target_scale = 1

			if data.distance then
				data.distance:set_visible(true)
			end
		elseif data.state == "present" then
			data.current_position = Vector3(panel:center_x() + data.slot_x, panel:center_y() + panel:center_y() / 2)

			data.bitmap:set_center_x(data.current_position.x)
			data.bitmap:set_center_y(data.current_position.y)
			data.text:set_center_x(data.bitmap:center_x())
			data.text:set_top(data.bitmap:bottom())

			data.present_timer = data.present_timer - dt

			if data.present_timer <= 0 then
				data.slot = nil
				data.current_scale = 1
				data.state = "present_ended"
				data.text_alpha = 0.5
				data.in_timer = 0
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
				data.arrow:set_center(mvector3.x(data.current_position) + direction.x * 24, mvector3.y(data.current_position) + direction.y * 24)

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
					data.bitmap:set_color(data.bitmap:color():with_alpha(1))

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

				if data.bitmap:color().alpha ~= alpha then
					data.bitmap:set_color(data.bitmap:color():with_alpha(alpha))

					if data.distance then
						data.distance:set_color(data.distance:color():with_alpha(alpha))
					end

					if data.timer_gui then
						data.timer_gui:set_color(data.bitmap:color():with_alpha(alpha))
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

					data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, wp_pos)
				end

				data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

				if data.text_alpha ~= 0 then
					data.text:set_center_x(data.bitmap:center_x())
					data.text:set_top(data.bitmap:bottom())
				end

				if data.distance then
					local length = wp_dir:length()

					data.distance:set_text(string.format("%.0f", length / 100) .. "m")
					data.distance:set_center_x(data.bitmap:center_x())
					data.distance:set_top(data.bitmap:bottom())
				end
			end
		end

		if data.timer_gui then
			data.timer_gui:set_center_x(data.bitmap:center_x())
			data.timer_gui:set_bottom(data.bitmap:top())

			if data.pause_timer == 0 then
				data.timer = data.timer - dt
				local text = data.timer < 0 and "00" or (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer)

				data.timer_gui:set_text(text)
			end
		end
	end
end

function HUDManager:reset_player_hpbar()
	local crim_entry = managers.criminals:character_static_data_by_name(managers.criminals:local_character_name())

	if not crim_entry then
		return
	end

	local color_id = managers.network:session():local_peer():id()

	if self._teammate_panels[HUDManager.PLAYER_PANEL] then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:add_panel()
		self:set_teammate_callsign(HUDManager.PLAYER_PANEL, color_id)
		self:set_teammate_name(HUDManager.PLAYER_PANEL, managers.network:session():local_peer():name())
	else
		Application:stack_dump_error("UI won't work!!")
	end
end

function HUDManager:show_stats_screen()
	local safe = self.STATS_SCREEN_SAFERECT
	local full = self.STATS_SCREEN_FULLSCREEN

	if not self:exists(safe) then
		self:load_hud(safe, false, true, true, {})
		self:load_hud(full, false, true, false, {})
	end

	self:script(safe):layout()
	managers.hud:show(safe)
	managers.hud:show(full)

	self._showing_stats_screen = true
end

function HUDManager:hide_stats_screen()
	self._showing_stats_screen = false
	local safe = self.STATS_SCREEN_SAFERECT
	local full = self.STATS_SCREEN_FULLSCREEN

	if not self:exists(safe) then
		return
	end

	self:script(safe):hide()
	managers.hud:hide(safe)
	managers.hud:hide(full)
end

function HUDManager:showing_stats_screen()
	return self._showing_stats_screen
end

function HUDManager:pd_start_progress(current, total, msg, icon_id)
	local hud = self:script(PlayerBase.PLAYER_DOWNED_HUD)

	if not hud then
		return
	end

	self._pd2_hud_interaction = HUDInteraction:new(managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD))

	self._pd2_hud_interaction:show_interact({
		text = utf8.to_upper(managers.localization:text(msg))
	})
	self._pd2_hud_interaction:show_interaction_bar(current, total)
	self._hud_player_downed:hide_timer()

	local function feed_circle(o, total)
		local t = 0

		while total > t do
			t = t + coroutine.yield()

			self._pd2_hud_interaction:set_interaction_bar_width(t, total)
		end
	end

	if _G.IS_VR then
		return
	end

	self._pd2_hud_interaction._interact_circle._circle:stop()
	self._pd2_hud_interaction._interact_circle._circle:animate(feed_circle, total)
end

function HUDManager:pd_stop_progress()
	local hud = self:script(PlayerBase.PLAYER_DOWNED_HUD)

	if not hud then
		return
	end

	if self._pd2_hud_interaction then
		self._pd2_hud_interaction:destroy()

		self._pd2_hud_interaction = nil
	end

	self._hud_player_downed:show_timer()
end

function HUDManager:pd_start_timer(data)
	self:pd_stop_timer()

	local time = data.time or 10
	local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)
	self._hud.timer_thread = hud.timer:animate(hud.start_timer, time)

	self._hud_player_downed:hide_arrest_finished()
end

function HUDManager:pd_pause_timer()
	local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)

	hud.pause_timer()
end

function HUDManager:pd_unpause_timer()
	local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)

	hud.unpause_timer()
end

function HUDManager:pd_stop_timer()
	local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)

	if self._hud.timer_thread then
		hud.timer:stop(self._hud.timer_thread)

		self._hud.timer_thread = nil
	end

	hud.unpause_timer()
end

function HUDManager:pd_show_text()
	local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)

	self._hud_player_downed:hide_timer()
	self._hud_player_downed:show_arrest_finished()
end

function HUDManager:pd_hide_text()
	local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)

	self._hud_player_downed:hide_arrest_finished()
end

function HUDManager:on_simulation_ended()
	self:remove_updator("point_of_no_return")
	self:end_assault()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:remove_panel()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:add_panel()
	self._hud_heist_timer:reset()
end

function HUDManager:debug_show_coordinates()
	if self._debug then
		return
	end

	self._debug = {
		ws = Overlay:newgui():create_screen_workspace()
	}
	self._debug.panel = self._debug.ws:panel()
	self._debug.coord = self._debug.panel:text({
		text = "",
		name = "debug_coord",
		y = 14,
		font_size = 14,
		x = 14,
		layer = 2000,
		font = tweak_data.hud.small_font,
		color = Color.white
	})
end

function HUDManager:debug_hide_coordinates()
	if not self._debug then
		return
	end

	Overlay:newgui():destroy_workspace(self._debug.ws)

	self._debug = nil
end

function HUDManager:save(data)
	local state = {
		waypoints = {},
		in_assault = self._hud.in_assault,
		assault_number = managers.groupai:state().get_assault_number and managers.groupai:state():get_assault_number() or 1,
		assault_mode = self._hud_assault_corner:get_assault_mode()
	}

	for id, data in pairs(self._hud.waypoints) do
		if not data.no_sync then
			state.waypoints[id] = data.init_data
			state.waypoints[id].timer = data.timer
			state.waypoints[id].pause_timer = data.pause_timer
			state.waypoints[id].unit = nil
		end
	end

	data.HUDManager = state
end

function HUDManager:load(data)
	local state = data.HUDManager

	for id, init_data in pairs(state.waypoints) do
		self:add_waypoint(id, init_data)
	end

	if state.in_assault then
		self:sync_start_assault(state.assault_number ~= nil and state.assault_number or 1)

		if state.assault_mode then
			managers.hud:sync_set_assault_mode(state.assault_mode)
		end
	end
end

require("lib/managers/HUDManagerPD2")
