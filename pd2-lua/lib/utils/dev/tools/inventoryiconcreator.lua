InventoryIconCreator = InventoryIconCreator or class()
InventoryIconCreator.OPTIONAL = "<optional>"

function InventoryIconCreator:init()
	self:_set_job_settings()
end

function InventoryIconCreator:_set_job_settings()
	self._job_settings = {
		weapon = {
			pos = Vector3(4500, 0, 0),
			rot = Rotation(90, 0, 0),
			res = Vector3(3000, 1000, 0)
		},
		mask = {
			pos = Vector3(4500, 0, 0),
			rot = Rotation(90, 0, 0),
			res = Vector3(1000, 1000, 0)
		},
		melee = {
			pos = Vector3(5500, 0, 0),
			rot = Rotation(90, 0, 0),
			res = Vector3(2500, 1000, 0)
		},
		throwable = {
			pos = Vector3(4500, 0, 0),
			rot = Rotation(90, 0, 0),
			res = Vector3(2500, 1000, 0)
		}
	}
end

function InventoryIconCreator:_create_weapon(factory_id, blueprint, weapon_skin)
	self:destroy_items()

	self._current_texture_name = factory_id .. (weapon_skin and " " .. weapon_skin or "")
	local cosmetics = weapon_skin and {
		id = weapon_skin
	} or nil
	local unit_name = tweak_data.weapon.factory[factory_id].unit

	managers.dyn_resource:load(Idstring("unit"), Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1] + 180, thisrot[2], thisrot[3])
	self._weapon_unit = World:spawn_unit(Idstring(unit_name), self._item_position, rot)

	self._weapon_unit:base():set_factory_data(factory_id)
	self._weapon_unit:base():set_cosmetics_data(cosmetics)
	self._weapon_unit:base():assemble_from_blueprint(factory_id, blueprint, callback(self, self, "_assemble_completed"))
	self._weapon_unit:set_moving(true)
	self._weapon_unit:base():on_enabled()
end

function InventoryIconCreator:_create_mask(mask_id, blueprint)
	self:destroy_items()

	self._current_texture_name = mask_id
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1] + 90, thisrot[2] + 90, thisrot[3])
	local mask_unit_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id)

	managers.dyn_resource:load(Idstring("unit"), Idstring(mask_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._mask_unit = World:spawn_unit(Idstring(mask_unit_name), self._item_position, rot)

	if not tweak_data.blackmarket.masks[mask_id].type then
		-- Nothing
	end

	if blueprint then
		self._mask_unit:base():apply_blueprint(blueprint)
	end

	self._mask_unit:set_moving(true)
end

function InventoryIconCreator:_create_melee(melee_id)
	self:destroy_items()

	self._current_texture_name = melee_id
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1], thisrot[2], thisrot[3])
	local melee_unit_name = tweak_data.blackmarket.melee_weapons[melee_id].unit

	managers.dyn_resource:load(Idstring("unit"), Idstring(melee_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._melee_unit = World:spawn_unit(Idstring(melee_unit_name), self._item_position, rot)

	self._melee_unit:set_moving(true)
end

function InventoryIconCreator:_create_throwable(throwable_id)
	self:destroy_items()

	self._current_texture_name = throwable_id
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1], thisrot[2], thisrot[3])
	local throwable_unit_name = tweak_data.blackmarket.projectiles[throwable_id].unit_dummy

	managers.dyn_resource:load(Idstring("unit"), Idstring(throwable_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._throwable_unit = World:spawn_unit(Idstring(throwable_unit_name), self._item_position, rot)

	for _, effect_spawner in ipairs(self._throwable_unit:get_objects_by_type(Idstring("effect_spawner"))) do
		effect_spawner:set_enabled(false)
	end

	self._throwable_unit:set_moving(true)
end

function InventoryIconCreator:_assemble_completed(parts, blueprint)
	self._weapon_unit:set_moving(true)
end

function InventoryIconCreator:start_jobs(jobs)
	self._current_job = 0
	self._jobs = jobs

	managers.editor:add_tool_updator("InventoryIconCreator", callback(self, self, "_update"))
end

function InventoryIconCreator:start_all_weapons_skin(test)
	local filter = self._filter:get_value()

	if not filter or #filter == 0 then
		EWS:message_box(Global.frame_panel, "Search filter empty!", "Error", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local weapons = {}

	if test then
		weapons = {
			"wpn_fps_rpg7",
			"wpn_fps_snp_r93",
			"wpn_fps_pis_x_g17",
			"wpn_fps_ass_74"
		}
	else
		weapons = self:_get_all_weapons()
	end

	local jobs = {}
	local search_string = "_" .. filter .. "$"

	for _, factory_id in ipairs(weapons) do
		local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)

		for name, item_data in pairs(tweak_data.blackmarket.weapon_skins) do
			local match_weapon_id = item_data.weapon_id or item_data.weapons[1]

			if match_weapon_id == weapon_id and string.find(name, search_string) then
				local bp = name and tweak_data.blackmarket.weapon_skins[name].default_blueprint or blueprint

				table.insert(jobs, {
					factory_id = factory_id,
					blueprint = bp,
					weapon_skin = name
				})
			end
		end
	end

	if #jobs == 0 then
		EWS:message_box(Global.frame_panel, "No weapons found matching speficied skin filter '" .. filter .. "'", "Error", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them (" .. tostring(#jobs) .. ")?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	self:start_jobs(jobs)
end

function InventoryIconCreator:start_all_weapons(test)
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local weapons = {}

	if test then
		weapons = {
			"wpn_fps_rpg7",
			"wpn_fps_snp_r93",
			"wpn_fps_pis_x_g17"
		}
	else
		weapons = self:_get_all_weapons()
	end

	local jobs = {}

	for _, factory_id in ipairs(weapons) do
		local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		table.insert(jobs, {
			factory_id = factory_id,
			blueprint = blueprint
		})
	end

	self:start_jobs(jobs)
end

function InventoryIconCreator:start_all_weapon_skins()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local jobs = {}

	for _, weapon_skin in ipairs(self:_get_weapon_skins()) do
		weapon_skin = weapon_skin ~= "none" and weapon_skin

		if weapon_skin then
			blueprint = tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint or blueprint
		end

		table.insert(jobs, {
			factory_id = factory_id,
			blueprint = blueprint,
			weapon_skin = weapon_skin
		})
	end

	self:start_jobs(jobs)
end

function InventoryIconCreator:start_one_weapon()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
	weapon_skin = weapon_skin ~= "none" and weapon_skin
	local blueprint = weapon_skin and tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint
	blueprint = blueprint or self:_get_blueprint_from_ui()

	self:start_jobs({
		{
			factory_id = factory_id,
			blueprint = blueprint,
			weapon_skin = weapon_skin
		}
	})
end

function InventoryIconCreator:preview_one_weapon()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
	weapon_skin = weapon_skin ~= "none" and weapon_skin
	local blueprint = weapon_skin and tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint
	blueprint = blueprint or self:_get_blueprint_from_ui()

	self:_create_weapon(factory_id, blueprint, weapon_skin)
end

function InventoryIconCreator:_get_blueprint_from_ui()
	local blueprint = {}

	for type, ctrlr in pairs(self._ctrlrs.weapon) do
		if type ~= "factory_id" and type ~= "weapon_skin" then
			local part_id = ctrlr:get_value()

			if part_id ~= self.OPTIONAL then
				table.insert(blueprint, part_id)
			end
		end
	end

	return blueprint
end

function InventoryIconCreator:_get_all_weapons()
	local weapons = {}

	for _, data in pairs(Global.blackmarket_manager.weapons) do
		table.insert(weapons, data.factory_id)
	end

	table.sort(weapons)

	return weapons
end

function InventoryIconCreator:_get_weapon_skins()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)
	local t = {
		"none"
	}

	for name, item_data in pairs(tweak_data.blackmarket.weapon_skins) do
		local match_weapon_id = item_data.weapon_id or item_data.weapons[1]

		if match_weapon_id == weapon_id then
			table.insert(t, name)
		end
	end

	return t
end

function InventoryIconCreator:start_all_masks(with_blueprint)
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local masks = {}

	if false then
		masks = {
			"troll",
			"mr_sinister",
			"baby_cry",
			"pazuzu",
			"anubis",
			"infamy_lurker",
			"plague",
			"robo_santa"
		}
	else
		masks = self:_get_all_masks()
	end

	local blueprint = with_blueprint and self:_get_mask_blueprint_from_ui() or nil
	local jobs = {}

	for _, mask_id in ipairs(masks) do
		table.insert(jobs, {
			mask_id = mask_id,
			blueprint = blueprint
		})
	end

	self:start_jobs(jobs)
end

function InventoryIconCreator:start_one_mask(with_blueprint)
	local mask_id = self._ctrlrs.mask.mask_id:get_value()
	local blueprint = with_blueprint and self:_get_mask_blueprint_from_ui() or nil

	self:start_jobs({
		{
			mask_id = mask_id,
			blueprint = blueprint
		}
	})
end

function InventoryIconCreator:preview_one_mask(with_blueprint)
	local mask_id = self._ctrlrs.mask.mask_id:get_value()
	local blueprint = with_blueprint and self:_get_mask_blueprint_from_ui() or nil

	self:_create_mask(mask_id, blueprint)
end

function InventoryIconCreator:_get_mask_blueprint_from_ui()
	local blueprint = {}

	for type, ctrlr in pairs(self._ctrlrs.mask) do
		if type ~= "mask_id" then
			local id = ctrlr:get_value()
			blueprint[type] = {
				id = id
			}
		end
	end

	return blueprint
end

function InventoryIconCreator:_get_all_masks()
	local t = {}

	for mask_id, data in pairs(tweak_data.blackmarket.masks) do
		if mask_id ~= "character_locked" then
			table.insert(t, mask_id)
		end
	end

	table.sort(t)

	return t
end

function InventoryIconCreator:start_all_melee()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}

	for _, melee_id in ipairs(self:_get_all_melee()) do
		table.insert(jobs, {
			melee_id = melee_id
		})
	end

	self:start_jobs(jobs)
end

function InventoryIconCreator:start_one_melee()
	local melee_id = self._ctrlrs.melee.melee_id:get_value()

	self:start_jobs({
		{
			melee_id = melee_id
		}
	})
end

function InventoryIconCreator:preview_one_melee()
	local melee_id = self._ctrlrs.melee.melee_id:get_value()

	self:_create_melee(melee_id)
end

function InventoryIconCreator:_get_all_melee()
	local t = {}

	for melee_id, data in pairs(tweak_data.blackmarket.melee_weapons) do
		if data.unit then
			table.insert(t, melee_id)
		else
			Application:error("No unit for " .. melee_id .. ". No icon created.")
		end
	end

	table.sort(t)

	return t
end

function InventoryIconCreator:start_all_throwable()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}

	for _, throwable_id in ipairs(self:_get_all_throwable()) do
		table.insert(jobs, {
			throwable_id = throwable_id
		})
	end

	self:start_jobs(jobs)
end

function InventoryIconCreator:start_one_throwable()
	local throwable_id = self._ctrlrs.throwable.throwable_id:get_value()

	self:start_jobs({
		{
			throwable_id = throwable_id
		}
	})
end

function InventoryIconCreator:preview_one_throwable()
	local throwable_id = self._ctrlrs.throwable.throwable_id:get_value()

	self:_create_throwable(throwable_id)
end

function InventoryIconCreator:_get_all_throwable()
	local t = {}

	for throwable_id, data in pairs(tweak_data.blackmarket.projectiles) do
		if data.throwable and data.unit_dummy then
			table.insert(t, throwable_id)
		end
	end

	table.sort(t)

	return t
end

function InventoryIconCreator:_start_job()
	self._has_job = true
	local job = self._jobs[self._current_job]

	if job.factory_id then
		self:_create_weapon(job.factory_id, job.blueprint, job.weapon_skin)
	elseif job.mask_id then
		self:_create_mask(job.mask_id, job.blueprint)
	elseif job.melee_id then
		self:_create_melee(job.melee_id)
	elseif job.throwable_id then
		self:_create_throwable(job.throwable_id)
	end

	self:start_create()
end

function InventoryIconCreator:check_next_job()
	if self._has_job then
		return
	end

	self._current_job = self._current_job + 1

	if self._current_job > #self._jobs then
		managers.editor:remove_tool_updator("InventoryIconCreator")

		return
	end

	self:_start_job()
end

function InventoryIconCreator:_update()
	if self._steps then
		self:_next_step()
	end

	self:check_next_job()
end

function InventoryIconCreator:start_create()
	self._old_data = {
		camera_position = managers.editor:camera_position(),
		camera_rotation = managers.editor:camera_rotation(),
		camera_fov = managers.editor:camera_fov(),
		layer_draw_grid = managers.editor._layer_draw_grid,
		layer_draw_marker = managers.editor._layer_draw_marker,
		base_chromatic_amount = managers.environment_controller:base_chromatic_amount(),
		base_contrast = managers.environment_controller:base_contrast()
	}

	managers.editor:set_show_camera_info(false)

	managers.editor._show_center = false
	managers.editor._layer_draw_grid = false
	managers.editor._layer_draw_marker = false

	self:_setup_camera()
	self:_create_backdrop()
	managers.editor:enable_all_post_effects()
	managers.environment_controller:set_dof_setting("none")
	managers.environment_controller:set_base_chromatic_amount(0)
	managers.environment_controller:set_base_contrast(0)

	self._steps = {}
	self._current_step = 0

	table.insert(self._steps, callback(self, self, "_take_screen_shot_1"))
	table.insert(self._steps, callback(self, self, "_pre_screen_shot_2"))
	table.insert(self._steps, callback(self, self, "_take_screen_shot_2"))
	table.insert(self._steps, callback(self, self, "end_create"))
end

function InventoryIconCreator:end_create()
	managers.editor:set_camera(self._old_data.camera_position, self._old_data.camera_rotation)
	managers.editor:set_camera_fov(self._old_data.camera_fov)
	managers.editor:set_show_camera_info(true)

	managers.editor._show_center = true
	managers.editor._layer_draw_grid = self._old_data.layer_draw_grid
	managers.editor._layer_draw_marker = self._old_data.layer_draw_marker

	self:_destroy_backdrop()
	managers.editor:change_visualization("deferred_lighting")
	managers.environment_controller:set_dof_setting("standard")
	managers.editor:_set_appwin_fixed_resolution(nil)
	managers.environment_controller:set_base_chromatic_amount(self._old_data.base_chromatic_amount)
	managers.environment_controller:set_base_contrast(self._old_data.base_contrast)

	self._has_job = false
end

function InventoryIconCreator:_create_backdrop()
	self:_destroy_backdrop()

	self._backdrop = safe_spawn_unit(Idstring("units/test/jocke/oneplanetorulethemall"), self._backdrop_position, self._backdrop_rotation)
end

function InventoryIconCreator:_destroy_backdrop()
	if alive(self._backdrop) then
		World:delete_unit(self._backdrop)

		self._backdrop = nil
	end
end

function InventoryIconCreator:_setup_camera()
	local job_setting = nil

	if self._jobs[1].factory_id then
		job_setting = self._job_settings.weapon
	elseif self._jobs[1].mask_id then
		job_setting = self._job_settings.mask
	elseif self._jobs[1].melee_id then
		job_setting = self._job_settings.melee
	elseif self._jobs[1].throwable_id then
		job_setting = self._job_settings.throwable
	end

	if not self._custom_ctrlrs.use_camera_setting:get_value() then
		local oobb = (self._weapon_unit or self._mask_unit or self._melee_unit or self._throwable_unit):oobb()
		local center = oobb:center()

		managers.editor:set_camera(Vector3(job_setting.pos.x, center.y, center.z), job_setting.rot)
		managers.editor:set_camera_fov(1)
	end

	local w = job_setting.res.x
	local h = job_setting.res.y

	if self._custom_ctrlrs.resolution.use:get_value() then
		w = tonumber(self._custom_ctrlrs.resolution.width:get_value())
		h = tonumber(self._custom_ctrlrs.resolution.height:get_value())
	end

	managers.editor:_set_appwin_fixed_resolution(Vector3(w + 4, h + 4, 0))
end

function InventoryIconCreator:_next_step()
	self._current_step = self._current_step + 1

	if self._current_step > #self._steps then
		return
	end

	local func = self._steps[self._current_step]

	func()
end

function InventoryIconCreator:_take_screen_shot_1()
	local name = self._current_texture_name .. "_dif.tga"
	local path = managers.database:root_path()

	Application:screenshot(path .. name)
end

function InventoryIconCreator:_pre_screen_shot_2()
	managers.editor:on_post_processor_effect("empty")
	managers.editor:change_visualization("depth_visualization")
	self._backdrop:set_visible(false)
end

function InventoryIconCreator:_take_screen_shot_2()
	local name = self._current_texture_name .. "_dph.tga"
	local path = managers.database:root_path()

	Application:screenshot(path .. name)
end

function InventoryIconCreator:destroy_items()
	self:destroy_weapon()
	self:destroy_mask()
	self:destroy_melee()
	self:destroy_throwable()
end

function InventoryIconCreator:destroy_weapon()
	if not alive(self._weapon_unit) then
		return
	end

	self._weapon_unit:set_slot(0)

	self._weapon_unit = nil
end

function InventoryIconCreator:destroy_mask()
	if not alive(self._mask_unit) then
		return
	end

	self._mask_unit:set_slot(0)

	self._mask_unit = nil
end

function InventoryIconCreator:destroy_melee()
	if not alive(self._melee_unit) then
		return
	end

	self._melee_unit:set_slot(0)

	self._melee_unit = nil
end

function InventoryIconCreator:destroy_throwable()
	if not alive(self._throwable_unit) then
		return
	end

	self._throwable_unit:set_slot(0)

	self._throwable_unit = nil
end

function InventoryIconCreator:show_ews()
	if not self._main_frame then
		self:create_ews()
	end
end

function InventoryIconCreator:create_ews()
	self:close_ews()

	self._main_frame = EWS:Frame("Icon creator", Vector3(250, 0, 0), Vector3(420, 700, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE,FULL_REPAINT_ON_RESIZE", Global.frame)

	self._main_frame:set_icon(CoreEws.image_path("world_editor/icon_creator_16x16.png"))

	local main_box = EWS:BoxSizer("HORIZONTAL")
	self._main_panel = EWS:Panel(self._main_frame, "", "FULL_REPAINT_ON_RESIZE")
	local main_panel_sizer = EWS:BoxSizer("VERTICAL")

	self._main_panel:set_sizer(main_panel_sizer)
	main_box:add(self._main_panel, 1, 0, "EXPAND")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "close_ews"), "")

	local common_sizer = EWS:StaticBoxSizer(self._main_panel, "VERTICAL", "")

	main_panel_sizer:add(common_sizer, 0, 0, "EXPAND")

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")

	common_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(self._main_panel, "Delete item", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "destroy_items"), false)
	self:_create_custom_job(self._main_panel, common_sizer)

	local notebook = EWS:Notebook(self._main_panel, "", "NB_TOP,NB_MULTILINE")

	main_panel_sizer:add(notebook, 1, 0, "EXPAND")

	self._ctrlrs = {
		weapon = {},
		mask = {},
		melee = {},
		throwable = {}
	}

	notebook:add_page(self:_create_weapons_page(notebook), "Weapons", true)
	notebook:add_page(self:_create_masks_page(notebook), "Masks", false)
	notebook:add_page(self:_create_melee_page(notebook), "Melee", false)
	notebook:add_page(self:_create_throwable_page(notebook), "Throwable", false)
	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(true)
end

function InventoryIconCreator:_create_custom_job(panel, sizer)
	self._custom_ctrlrs = {
		resolution = {}
	}
	local checkbox = EWS:CheckBox(panel, "Use current camera setting", "")

	checkbox:set_value(false)
	sizer:add(checkbox, 0, 0, "EXPAND,RIGHT")

	self._custom_ctrlrs.use_camera_setting = checkbox
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local checkbox = EWS:CheckBox(panel, "Use custom resolution", "")

	checkbox:set_value(false)
	h_sizer:add(checkbox, 0, 4, "EXPAND,RIGHT")

	self._custom_ctrlrs.resolution.use = checkbox
	local number_params = {
		value = 64,
		name = "Width:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Set a number value",
		min = 64,
		sizer_proportions = 1,
		max = 8192,
		panel = panel,
		sizer = h_sizer
	}
	local ctrlr = CoreEws.number_controller(number_params)
	self._custom_ctrlrs.resolution.width = ctrlr
	local number_params = {
		value = 64,
		name = "Height:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Set a number value",
		min = 64,
		sizer_proportions = 1,
		max = 8192,
		panel = panel,
		sizer = h_sizer
	}
	local ctrlr = CoreEws.number_controller(number_params)
	self._custom_ctrlrs.resolution.height = ctrlr

	h_sizer:add(EWS:BoxSizer("HORIZONTAL"), 1, 0, "EXPAND")

	self._backdrop_position = Vector3(-500, 0, 0)
	self._backdrop_rotation = Rotation(180, 0, -90)
	self._item_position = Vector3(0, 0, 0)
	self._item_rotation = {
		0,
		0,
		0
	}
	self._backdrop_position_control = self:_create_position_control("Backdrop Position: ", self._backdrop_position, panel, sizer, callback(self, self, "_update_backdrop_position"))
	self._backdrop_rotation_control = self:_create_rotation_control("Backdrop Rotation: ", self._backdrop_rotation, panel, sizer, callback(self, self, "_update_backdrop_rotation"))
	self._item_position_control = self:_create_item_position("Item Position: ", self._item_position, panel, sizer, callback(self, self, "_update_item_position"))
	self._item_rotation_control = self:_create_item_rotation("Item Rotation: ", self._item_rotation, panel, sizer, callback(self, self, "_update_item_rotation"))
end

function InventoryIconCreator:_update_backdrop_position(position)
	self._backdrop_position = position
end

function InventoryIconCreator:_update_backdrop_rotation(rotation)
	self._backdrop_rotation = rotation
end

function InventoryIconCreator:_update_item_position(position)
	self._item_position = position
end

function InventoryIconCreator:_update_item_rotation(rotation)
	self._item_rotation = rotation
end

function InventoryIconCreator:_create_axis_control(name, default_value, panel, sizer, cb, prop)
	local axis_params = {
		floats = 0,
		name_proportions = 1,
		name = name,
		panel = panel,
		sizer = sizer,
		value = default_value,
		ctrlr_proportions = prop or 5,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = cb
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = cb
			}
		}
	}

	CoreEws.number_controller(axis_params)

	return axis_params
end

function InventoryIconCreator:_create_position_control(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local pp = {}

	table.insert(pp, self:_create_axis_control(" X:", default_value.x, panel, h_sizer, function ()
		cb(Vector3(pp[1].value, pp[2].value, pp[3].value))
	end))
	table.insert(pp, self:_create_axis_control(" Y:", default_value.y, panel, h_sizer, function ()
		cb(Vector3(pp[1].value, pp[2].value, pp[3].value))
	end))
	table.insert(pp, self:_create_axis_control(" Z:", default_value.z, panel, h_sizer, function ()
		cb(Vector3(pp[1].value, pp[2].value, pp[3].value))
	end))

	return pp
end

function InventoryIconCreator:_create_rotation_control(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local rp = {}

	table.insert(rp, self:_create_axis_control(" Yaw:", default_value:yaw(), panel, h_sizer, function ()
		cb(Rotation(rp[1].value, rp[2].value, rp[3].value))
	end, 2))
	table.insert(rp, self:_create_axis_control(" Pitch:", default_value:pitch(), panel, h_sizer, function ()
		cb(Rotation(rp[1].value, rp[2].value, rp[3].value))
	end, 2))
	table.insert(rp, self:_create_axis_control(" Roll:", default_value:roll(), panel, h_sizer, function ()
		cb(Rotation(rp[1].value, rp[2].value, rp[3].value))
	end, 2))

	return rp
end

function InventoryIconCreator:_create_item_position(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local ppx = {}

	table.insert(ppx, self:_create_axis_control(" X:", default_value.x, panel, h_sizer, function ()
		cb(Vector3(ppx[1].value, ppx[2].value, ppx[3].value))
	end))
	table.insert(ppx, self:_create_axis_control(" Y:", default_value.y, panel, h_sizer, function ()
		cb(Vector3(ppx[1].value, ppx[2].value, ppx[3].value))
	end))
	table.insert(ppx, self:_create_axis_control(" Z:", default_value.z, panel, h_sizer, function ()
		cb(Vector3(ppx[1].value, ppx[2].value, ppx[3].value))
	end))

	return ppx
end

function InventoryIconCreator:_create_item_rotation(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local rpx = {}

	table.insert(rpx, self:_create_axis_control(" Yaw:", 0, panel, h_sizer, function ()
		cb({
			rpx[1].value,
			rpx[2].value,
			rpx[3].value
		})
	end, 2))
	table.insert(rpx, self:_create_axis_control(" Pitch:", 0, panel, h_sizer, function ()
		cb({
			rpx[1].value,
			rpx[2].value,
			rpx[3].value
		})
	end, 2))
	table.insert(rpx, self:_create_axis_control(" Roll:", 0, panel, h_sizer, function ()
		cb({
			rpx[1].value,
			rpx[2].value,
			rpx[3].value
		})
	end, 2))

	return rpx
end

function InventoryIconCreator:_create_weapons_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local all_weapons_btn = EWS:Button(panel, "All (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(all_weapons_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	all_weapons_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_weapons"), false)

	local all_weapons_skin_btn = EWS:Button(panel, "All (filter)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(all_weapons_skin_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	all_weapons_skin_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_weapons_skin"), false)

	local one_weapon_btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(one_weapon_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	one_weapon_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_weapon"), true)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_weapon"), true)

	local _btn = EWS:Button(panel, "Selected (all skins)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_weapon_skins"), true)

	local filtertext = EWS:StaticText(panel, "Filter:", 0, "ALIGN_LEFT")

	btn_sizer:add(filtertext, 0, 0, "ALIGN_CENTER")

	self._filter = EWS:TextCtrl(panel, "", "", "TE_LEFT")

	btn_sizer:add(self._filter, 10, 10, "ALIGN_CENTER")

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local weapon_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "factory_id", self:_get_all_weapons())

	weapon_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_add_weapon_mods"), {
		panel = panel,
		sizer = comboboxes_sizer
	})
	weapon_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_weapon_skins"), nil)

	local weapon_skins_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "weapon_skin", self:_get_weapon_skins())

	weapon_skins_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_weapon_skin"), {})
	self:_add_weapon_mods({
		panel = panel,
		sizer = comboboxes_sizer
	})

	return panel
end

function InventoryIconCreator:_add_weapon_mods(params)
	local panel = params.panel
	local sizer = params.sizer

	if alive(self._weapon_mods_panel) then
		self._weapon_mods_panel:destroy()

		self._weapon_mods_panel = nil
	end

	self._weapon_mods_panel = EWS:Panel(panel, "", "FULL_REPAINT_ON_RESIZE")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self._weapon_mods_panel:set_sizer(panel_sizer)
	sizer:add(self._weapon_mods_panel, 0, 0, "EXPAND")

	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	self._ctrlrs.weapon = {
		factory_id = self._ctrlrs.weapon.factory_id,
		weapon_skin = self._ctrlrs.weapon.weapon_skin
	}
	local parts = managers.weapon_factory:get_parts_from_factory_id(factory_id)
	local optional_types = tweak_data.weapon.factory[factory_id].optional_types or {}

	for type, options in pairs(parts) do
		local new_options = {}
		local default_part_id = managers.weapon_factory:get_part_id_from_weapon_by_type(type, blueprint)

		for _, part_id in ipairs(options) do
			local part_data = tweak_data.weapon.factory.parts[part_id]

			if part_data.pcs or part_data.pc then
				table.insert(new_options, part_id)
			end
		end

		if default_part_id then
			table.insert(new_options, 1, default_part_id)
		elseif #new_options > 0 then
			table.insert(new_options, 1, self.OPTIONAL)
		end

		if #new_options > 0 then
			self:_add_weapon_ctrlr(self._weapon_mods_panel, panel_sizer, type, new_options, default_part_id or self.OPTIONAL)
		end
	end

	self._weapon_mods_panel:parent():layout()
end

function InventoryIconCreator:_add_weapon_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.weapon[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_weapon_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_weapon_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

function InventoryIconCreator:_update_weapon_combobox_text(param)
	local name = param.name
	local value = param.ctrlr:get_value()
	local text = nil

	if name == "factory_id" then
		text = managers.weapon_factory:get_weapon_name_by_factory_id(value)
	elseif name == "weapon_skin" then
		local name_id = tweak_data.blackmarket.weapon_skins[value] and tweak_data.blackmarket.weapon_skins[value].name_id or "none"
		text = managers.localization:text(name_id)
	else
		text = value == self.OPTIONAL and self.OPTIONAL or managers.weapon_factory:get_part_name_by_part_id(value)
	end

	param.text_ctrlr:set_value(text)

	if not param.no_layout then
		param.text_ctrlr:parent():layout()
	end
end

function InventoryIconCreator:_set_weapon_skin()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
end

function InventoryIconCreator:_update_weapon_skins()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin

	weapon_skin:clear()

	for _, name in ipairs(self:_get_weapon_skins()) do
		weapon_skin:append(name)
	end

	weapon_skin:set_value("none")
end

function InventoryIconCreator:_create_masks_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_masks"), false)

	local _btn = EWS:Button(panel, "All (blueprint)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_masks"), true)

	local btn_sizer2 = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(btn_sizer2, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "Selected (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer2:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_mask"), false)

	local _btn = EWS:Button(panel, "Selected (blueprint)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer2:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_mask"), true)

	local btn_sizer3 = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(btn_sizer3, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "Preview (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer3:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_mask"), false)

	local _btn = EWS:Button(panel, "Preview (blueprint)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer3:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_mask"), true)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local mask_ctrlr = self:_add_mask_ctrlr(panel, comboboxes_sizer, "mask_id", self:_get_all_masks())

	self:_add_mask_ctrlr(panel, comboboxes_sizer, "color", table.map_keys(tweak_data.blackmarket.colors), "nothing")
	self:_add_mask_ctrlr(panel, comboboxes_sizer, "material", table.map_keys(tweak_data.blackmarket.materials), "plastic")
	self:_add_mask_ctrlr(panel, comboboxes_sizer, "pattern", table.map_keys(tweak_data.blackmarket.textures), "no_color_no_material")

	return panel
end

function InventoryIconCreator:_add_mask_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.mask[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_mask_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_mask_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

function InventoryIconCreator:_update_mask_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "mask_id" then
		text = managers.localization:text(tweak_data.blackmarket.masks[value].name_id)
	elseif name == "color" then
		text = managers.localization:text(tweak_data.blackmarket.colors[value].name_id)
	elseif name == "material" then
		text = managers.localization:text(tweak_data.blackmarket.materials[value].name_id)
	elseif name == "pattern" then
		text = managers.localization:text(tweak_data.blackmarket.textures[value].name_id)
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

function InventoryIconCreator:_create_melee_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_melee"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_melee"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_melee"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local melee_ctrlr = self:_add_melee_ctrlr(panel, comboboxes_sizer, "melee_id", self:_get_all_melee())

	return panel
end

function InventoryIconCreator:_add_melee_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.melee[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_melee_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_melee_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

function InventoryIconCreator:_update_melee_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "melee_id" then
		text = managers.localization:text(tweak_data.blackmarket.melee_weapons[value].name_id)
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

function InventoryIconCreator:_create_throwable_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_throwable"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_throwable"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_throwable"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local throwable_ctrlr = self:_add_throwable_ctrlr(panel, comboboxes_sizer, "throwable_id", self:_get_all_throwable())

	return panel
end

function InventoryIconCreator:_add_throwable_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.throwable[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_throwable_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_throwable_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

function InventoryIconCreator:_update_throwable_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "throwable_id" then
		print(value, tweak_data.blackmarket.projectiles[value].name_id)

		text = managers.localization:text(tweak_data.blackmarket.projectiles[value].name_id or "N/A")
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

function InventoryIconCreator:close_ews()
	if alive(self._weapon_mods_panel) then
		self._weapon_mods_panel:destroy()

		self._weapon_mods_panel = nil
	end

	if self._main_frame then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end
