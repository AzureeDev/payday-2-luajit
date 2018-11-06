local ids_unit = Idstring("unit")
local sky_orientation_data_key = Idstring("sky_orientation/rotation"):key()
MenuSceneManager = MenuSceneManager or class()

function MenuSceneManager:init()
	self._standard_fov = 50
	self._current_fov = 50
	self._camera_start_pos = Vector3()
	self._camera_start_rot = Rotation(-5, 0, 0)
	self._active_lights = {}
	self._fade_down_lights = {}
	self._character_yaw = 0
	self._character_pitch = 0
	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0
	self._item_rot = Rotation()
	self._item_rot_mod = Rotation(0, 0, 0)
	self._item_rot_temp = Rotation()
	self._use_item_grab = false
	self._use_character_grab = false
	self._use_character_grab2 = false
	self._one_frame_delayed_clbks = {}
	self._current_scene_template = ""
	self._global_poses = {}
	self._forced_secondaries = {}
	self._global_poses.generic = {
		"husk_generic1",
		"husk_generic2",
		"husk_generic3",
		"husk_generic4"
	}
	self._global_poses.assault_rifle = {
		"husk_rifle1",
		"husk_rifle2"
	}
	self._global_poses.pistol = {
		"husk_pistol1"
	}
	self._global_poses.saw = {
		"husk_saw1"
	}
	self._global_poses.shotgun = {
		"husk_shotgun1"
	}
	self._global_poses.snp = {
		"husk_bullpup"
	}
	self._global_poses.lmg = {
		"husk_lmg"
	}
	self._global_poses.bow = {
		"husk_bow1",
		"husk_bow2"
	}
	self._global_poses.infamous = {
		"husk_infamous1",
		"husk_infamous3",
		"husk_infamous4"
	}
	self._global_poses.famas = {
		"husk_bullpup"
	}
	self._global_poses.aug = {
		"husk_bullpup"
	}
	self._global_poses.m95 = {
		"husk_m95"
	}
	self._global_poses.r93 = {
		"husk_r93"
	}
	self._global_poses.huntsman = {
		"husk_mosconi",
		"husk_bullpup"
	}
	self._global_poses.gre_m79 = {
		"husk_mosconi"
	}
	self._global_poses.ksg = {
		"husk_mosconi",
		"husk_bullpup"
	}
	self._global_poses.m249 = {
		"husk_m249"
	}
	self._global_poses.jowi = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_1911 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_b92fs = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_deagle = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_g17 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_g22c = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_usp = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.m134 = {
		"husk_minigun"
	}
	self._global_poses.x_sr2 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_mp5 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_akmsu = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.rota = {
		"husk_bullpup"
	}
	self._global_poses.x_packrat = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.ray = {
		"husk_ray"
	}

	table.insert(self._forced_secondaries, "ray")

	self._global_poses.x_shepheard = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_coal = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_baka = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_cobray = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_erma = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_hajk = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_m45 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_m1928 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_mac10 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_mp7 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_mp9 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_olympic = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_p90 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_polymer = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_schakal = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_scorpion = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_sterling = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_tec9 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_uzi = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_2006m = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_breech = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_c96 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_g18c = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_hs2000 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_lemming = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_p226 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_peacemaker = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_pl14 = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_ppk = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_rage = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_sparrow = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_judge = {
		"husk_akimbo1",
		"husk_akimbo2"
	}
	self._global_poses.x_rota = {
		"husk_akimbo1",
		"husk_akimbo2"
	}

	self:_init_lobby_poses()

	self._mask_units = {}
	self._weapon_units = {}
	self._character_visibilities = {}
	self._deployable_equipped = {}

	self:_setup_bg()
	self:_set_up_environments()
	self:_set_up_templates()
	self:_setup_gui()

	self._transition_bezier = {
		0,
		0,
		1,
		1
	}
	self._transition_time = 0
	self._weapon_transition_time = 0
	self._transition_done_callback_handler = CoreEvent.CallbackEventHandler:new()
end

function MenuSceneManager:_init_lobby_poses()
	self._lobby_poses = {
		generic = {
			{
				"lobby_generic_idle1"
			},
			{
				"lobby_generic_idle2"
			},
			{
				"lobby_generic_idle3"
			},
			{
				"lobby_generic_idle4"
			}
		},
		m134 = {
			"lobby_minigun_idle1"
		}
	}
end

function MenuSceneManager:_setup_gui()
	self._workspace = managers.gui_data:create_saferect_workspace()
	self._main_panel = self._workspace:panel():panel({
		layer = 0
	})
	local scaled_size = managers.gui_data:scaled_size()

	self._main_panel:set_shape(0, 0, scaled_size.width, scaled_size.height)

	self._item_grab = self._main_panel:panel({
		w = self._main_panel:w(),
		h = self._main_panel:h() - 64
	})
	self._character_grab = self._main_panel:panel({
		w = 550,
		h = self._main_panel:h() - 64
	})
	self._character_grab2 = self._main_panel:panel({
		y = 20,
		x = self._main_panel:w() * 0.25,
		w = self._main_panel:w() * 0.45,
		h = self._main_panel:h() - 64
	})
end

function MenuSceneManager:_set_up_templates()
	local ref = self._bg_unit:get_object(Idstring("a_camera_reference"))
	local c_ref = self._bg_unit:get_object(Idstring("a_reference"))
	local target_pos = Vector3(0, 0, ref:position().z)
	local offset = Vector3(ref:position().x, ref:position().y, 0)
	self._scene_templates = {
		standard = {}
	}
	self._scene_templates.standard.use_character_grab = true
	self._scene_templates.standard.character_visible = true
	self._scene_templates.standard.camera_pos = ref:position()
	self._scene_templates.standard.target_pos = target_pos
	self._scene_templates.standard.character_pos = c_ref:position()
	local l_pos = self._scene_templates.standard.camera_pos
	local rot = Rotation(self._scene_templates.standard.target_pos - l_pos, math.UP)
	local l1_pos = l_pos + rot:x() * -200 + rot:y() * 200
	self._scene_templates.standard.lights = {
		self:_create_light({
			far_range = 400,
			color = Vector3(0.86, 0.37, 0.21) * 4,
			position = Vector3(80, 33, 20)
		}),
		self:_create_light({
			far_range = 180,
			specular_multiplier = 8,
			color = Vector3(0.3, 0.5, 0.8) * 6,
			position = Vector3(-120, -6, 32)
		}),
		self:_create_light({
			far_range = 800,
			specular_multiplier = 0,
			color = Vector3(1, 1, 1) * 0.35,
			position = Vector3(160, -250, -40)
		})
	}
	self._scene_templates.blackmarket = {
		fov = 20,
		use_item_grab = true,
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = Vector3(-100, -100, 0) + self._camera_start_rot:x() * 100 + self._camera_start_rot:y() * 6 + self._camera_start_rot:z() * 0,
		lights = {}
	}
	self._scene_templates.blackmarket_item = {
		fov = 40,
		can_change_fov = true,
		use_item_grab = true,
		camera_pos = offset:rotate_with(Rotation(90)) + Vector3(0, 0, 202),
		target_pos = target_pos + Vector3(0, 0, 200),
		character_pos = c_ref:position() + Vector3(0, 500, 0)
	}
	local l_pos = self._scene_templates.blackmarket_item.camera_pos
	local rot = Rotation(self._scene_templates.blackmarket_item.target_pos - l_pos, math.UP)
	local l1_pos = l_pos + rot:x() * 50 + rot:y() * 50
	local l2_pos = l_pos + rot:x() * -50 + rot:y() * 100
	self._scene_templates.blackmarket_item.lights = {
		self:_create_light({
			far_range = 270,
			specular_multiplier = 155,
			color = Vector3(0.86, 0.67, 0.31) * 3,
			position = Vector3(160, -130, 220)
		}),
		self:_create_light({
			far_range = 270,
			specular_multiplier = 155,
			color = Vector3(0.86, 0.67, 0.41) * 2,
			position = Vector3(50, -150, 220)
		}),
		self:_create_light({
			far_range = 270,
			specular_multiplier = 155,
			color = Vector3(0.86, 0.67, 0.41) * 2,
			position = Vector3(160, 0, 220)
		}),
		self:_create_light({
			far_range = 250,
			specular_multiplier = 55,
			color = Vector3(0.5, 1.5, 2) * 2,
			position = Vector3(50, -100, 280)
		}),
		self:_create_light({
			far_range = 370,
			specular_multiplier = 55,
			color = Vector3(1, 0.4, 0.04) * 1.5,
			position = Vector3(200, 60, 180)
		})
	}
	self._scene_templates.blackmarket_mask = {
		fov = 40,
		can_change_fov = true,
		use_item_grab = true,
		camera_pos = offset:rotate_with(Rotation(90)) + Vector3(0, 0, 202),
		target_pos = target_pos + Vector3(0, 0, 200),
		character_pos = c_ref:position() + Vector3(0, 500, 0)
	}
	local l_pos = self._scene_templates.blackmarket_mask.camera_pos
	local rot = Rotation(self._scene_templates.blackmarket_mask.target_pos - l_pos, math.UP)
	local l1_pos = l_pos + rot:x() * 50 + rot:y() * 50
	local l2_pos = l_pos + rot:x() * -50 + rot:y() * 100
	self._scene_templates.blackmarket_mask.lights = {
		self:_create_light({
			far_range = 250,
			specular_multiplier = 55,
			color = Vector3(0.2, 0.5, 1) * 4.3,
			position = Vector3(0, -200, 280)
		}),
		self:_create_light({
			far_range = 370,
			specular_multiplier = 55,
			color = Vector3(1, 0.7, 0.5) * 2.3,
			position = Vector3(200, 60, 280)
		}),
		self:_create_light({
			far_range = 270,
			specular_multiplier = 0,
			color = Vector3(1, 1, 1) * 0.8,
			position = Vector3(160, -130, 220)
		})
	}
	self._scene_templates.character_customization = {
		use_character_grab = true,
		camera_pos = Vector3(-73.1618, -168.021, -35.0786),
		target_pos = Vector3(-73.1618, -168.021, -35.0786) + Vector3(0.31113, 0.944697, -0.103666) * 100,
		lights = {}
	}
	self._scene_templates.play_online = {
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = Vector3(-206.4, 56.0677, -135.539) + Vector3(-0.418134, 0.889918, 0.182234) * 100,
		lights = {}
	}
	self._scene_templates.options = {
		use_character_grab = true,
		camera_pos = Vector3(0, 60, -60),
		target_pos = self._camera_start_rot:y() * 100 + self._camera_start_rot:x() * -6 + self._camera_start_rot:z() * -60,
		lights = {}
	}
	self._scene_templates.lobby = {
		use_character_grab = false,
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = target_pos,
		character_pos = c_ref:position() + Vector3(0, 500, 0),
		lobby_characters_visible = true,
		fov = 40,
		lights = {
			self:_create_light({
				far_range = 300,
				color = Vector3(0.86, 0.57, 0.31) * 3,
				position = Vector3(56, 100, -10)
			}),
			self:_create_light({
				far_range = 3000,
				specular_multiplier = 6,
				color = Vector3(1, 2.5, 4.5) * 3,
				position = Vector3(-1000, -300, 800)
			}),
			self:_create_light({
				far_range = 800,
				specular_multiplier = 0,
				color = Vector3(1, 1, 1) * 0.35,
				position = Vector3(300, 100, 0)
			})
		}
	}
	self._scene_templates.lobby1 = {
		use_character_grab = false,
		lobby_characters_visible = true,
		camera_pos = Vector3(-90.5634, -157.226, -28.6729),
		target_pos = Vector3(-90.5634, -157.226, -28.6729) + Vector3(-0.58315, 0.781811, 0.220697) * 100,
		fov = 30,
		lights = clone(self._scene_templates.lobby.lights)
	}
	self._scene_templates.lobby2 = {
		use_character_grab = false,
		lobby_characters_visible = true,
		camera_pos = Vector3(-21.2779, -264.36, -56.7304),
		target_pos = Vector3(-21.2779, -264.36, -56.7304) + Vector3(-0.633319, 0.758269, 0.154709) * 100,
		fov = 30,
		lights = clone(self._scene_templates.lobby.lights)
	}
	self._scene_templates.lobby3 = {
		use_character_grab = false,
		lobby_characters_visible = true,
		camera_pos = Vector3(149.695, -363.069, -110.613),
		target_pos = Vector3(149.695, -363.069, -110.613) + Vector3(-0.648856, 0.748553, 0.136579) * 100,
		fov = 30,
		lights = clone(self._scene_templates.lobby.lights)
	}
	self._scene_templates.lobby4 = {
		use_character_grab = false,
		lobby_characters_visible = true,
		camera_pos = Vector3(210.949, -449.61, -126.709),
		target_pos = Vector3(210.949, -449.61, -126.709) + Vector3(-0.668524, 0.734205, 0.118403) * 100,
		fov = 30,
		lights = clone(self._scene_templates.lobby.lights)
	}
	self._scene_templates.inventory = {
		fov = 50,
		can_change_fov = true,
		change_fov_sensitivity = 3,
		use_character_grab2 = true,
		use_character_pan = true,
		character_visible = true,
		recreate_character = true,
		lobby_characters_visible = false,
		hide_menu_logo = true,
		camera_pos = ref:position(),
		target_pos = target_pos - self._camera_start_rot:x() * 40 - self._camera_start_rot:z() * 5,
		character_pos = c_ref:position(),
		remove_infamy_card = true
	}
	self._scene_templates.blackmarket_crafting = {
		camera_pos = Vector3(1500, -2000, 0)
	}
	self._scene_templates.blackmarket_crafting.target_pos = self._scene_templates.blackmarket_crafting.camera_pos + Vector3(0, 1, 0) * 100
	local camera_look = self._scene_templates.blackmarket_crafting.target_pos - self._scene_templates.blackmarket_crafting.camera_pos:normalized()

	mvector3.rotate_with(camera_look, Rotation(4, 2.25, 0))

	self._scene_templates.blackmarket_crafting.item_pos = self._scene_templates.blackmarket_crafting.camera_pos + camera_look * 240
	self._scene_templates.blackmarket_crafting.fov = 40
	self._scene_templates.blackmarket_crafting.use_item_grab = true
	self._scene_templates.blackmarket_crafting.can_change_fov = true
	self._scene_templates.blackmarket_crafting.disable_rotate = true
	self._scene_templates.blackmarket_crafting.environment = "crafting"
	self._scene_templates.blackmarket_crafting.use_workbench_room = true
	self._scene_templates.blackmarket_crafting.lights = {}

	if not managers.menu:is_pc_controller() then
		-- Nothing
	end

	self._scene_templates.safe = {
		camera_pos = Vector3(1500, -2000, 0)
	}
	self._scene_templates.safe.target_pos = self._scene_templates.safe.camera_pos + Vector3(0, 1, 0) * 100
	self._scene_templates.safe.fov = 40
	self._scene_templates.safe.use_item_grab = true
	self._scene_templates.safe.environment = "safe"
	self._scene_templates.safe.ambience_event = "cash_ambience"
	local l_pos = self._scene_templates.inventory.camera_pos
	local rot = Rotation(self._scene_templates.inventory.target_pos - l_pos, math.UP)
	local l1_pos = l_pos + rot:x() * -200 + rot:y() * 200
	self._scene_templates.inventory.lights = {
		self:_create_light({
			far_range = 400,
			color = Vector3(0.86, 0.37, 0.21) * 4,
			position = Vector3(80, 33, 20)
		}),
		self:_create_light({
			far_range = 180,
			specular_multiplier = 8,
			color = Vector3(0.3, 0.5, 0.8) * 6,
			position = Vector3(-120, -6, 32)
		}),
		self:_create_light({
			far_range = 800,
			specular_multiplier = 0,
			color = Vector3(1, 1, 1) * 0.35,
			position = Vector3(160, -250, -40)
		})
	}
	self._scene_templates.blackmarket_customize = {
		fov = 40,
		use_item_grab = true,
		disable_rotate = true,
		disable_item_updates = true,
		can_change_fov = true,
		can_move_item = true,
		change_fov_sensitivity = 2,
		camera_pos = Vector3(1500, -2000, 0)
	}
	self._scene_templates.blackmarket_customize.target_pos = self._scene_templates.blackmarket_customize.camera_pos + Vector3(0, 1, 0) * 100
	local camera_look = self._scene_templates.blackmarket_customize.target_pos - self._scene_templates.blackmarket_customize.camera_pos:normalized()

	mvector3.rotate_with(camera_look, Rotation(4, 2.25, 0))

	self._scene_templates.blackmarket_customize.item_pos = self._scene_templates.blackmarket_customize.camera_pos + camera_look * 240
	self._scene_templates.blackmarket_customize.environment = "crafting"
	self._scene_templates.blackmarket_customize.use_workbench_room = true
	local l_pos = self._scene_templates.blackmarket_customize.camera_pos
	local rot = Rotation(self._scene_templates.blackmarket_customize.target_pos - l_pos, math.UP)
	local l1_pos = l_pos + rot:x() * 50 + rot:y() * 50
	local l2_pos = l_pos + rot:x() * -50 + rot:y() * 100
	self._scene_templates.blackmarket_customize.lights = {}
	self._scene_templates.blackmarket_character = deep_clone(self._scene_templates.inventory)
	self._scene_templates.blackmarket_character.character_pos = c_ref:position() + Vector3(-10, 100, 20)
	self._scene_templates.blackmarket_customize_armour = deep_clone(self._scene_templates.inventory)
	self._scene_templates.blackmarket_customize_armour.environment = "crafting"
	self._scene_templates.blackmarket_customize_armour.camera_pos = ref:position() - Vector3(0, 200, 0)
	self._scene_templates.blackmarket_customize_armour.lights = {
		self:_create_light({
			far_range = 600,
			color = Vector3(1, 1, 1) * 2,
			position = Vector3(-20, -80, 0)
		}),
		self:_create_light({
			far_range = 400,
			color = Vector3(1, 1, 1) * 2,
			position = Vector3(80, 33, 20)
		}),
		self:_create_light({
			far_range = 180,
			specular_multiplier = 8,
			color = Vector3(1, 1, 1) * 3,
			position = Vector3(-120, -6, 32)
		})
	}
	self._scene_templates.blackmarket_armor = {
		fov = 20,
		can_change_fov = false,
		use_character_grab2 = true,
		use_character_pan = false,
		character_visible = true,
		recreate_character = true,
		lobby_characters_visible = false,
		hide_menu_logo = true,
		camera_pos = Vector3(1420, -2200, 0)
	}
	self._scene_templates.blackmarket_armor.target_pos = self._scene_templates.blackmarket_armor.camera_pos + Vector3(0.15, 1, -0.105) * 100
	local camera_look = self._scene_templates.blackmarket_armor.target_pos - self._scene_templates.blackmarket_armor.camera_pos:normalized()

	mvector3.rotate_with(camera_look, Rotation(6, 2.75, 0))

	self._scene_templates.blackmarket_armor.character_pos = self._scene_templates.blackmarket_armor.camera_pos + camera_look * 600 + Vector3(80, 0, -150)
	self._scene_templates.blackmarket_armor.environment = "crafting"
	self._scene_templates.blackmarket_armor.use_workbench_room = true
	self._scene_templates.blackmarket_armor.remove_infamy_card = true
	self._scene_templates.blackmarket_armor.lights = {
		self:_create_light({
			far_range = 400,
			color = Vector3(1, 1, 1) * 0.8,
			position = Vector3(1600, -1750, -25)
		})
	}
	self._scene_templates.blackmarket_armor_workshop = {
		fov = 20,
		can_change_fov = true,
		use_character_grab2 = true,
		use_character_pan = true,
		character_visible = true,
		recreate_character = true,
		lobby_characters_visible = false,
		hide_menu_logo = true,
		camera_pos = Vector3(1460, -2200, 0)
	}
	self._scene_templates.blackmarket_armor_workshop.target_pos = self._scene_templates.blackmarket_armor_workshop.camera_pos + Vector3(0.15, 1, -0.105) * 100
	local camera_look = self._scene_templates.blackmarket_armor_workshop.target_pos - self._scene_templates.blackmarket_armor_workshop.camera_pos:normalized()

	mvector3.rotate_with(camera_look, Rotation(6, 2.75, 0))

	self._scene_templates.blackmarket_armor_workshop.character_pos = self._scene_templates.blackmarket_armor_workshop.camera_pos + camera_look * 600 + Vector3(30, 0, -120)
	self._scene_templates.blackmarket_armor_workshop.environment = "crafting"
	self._scene_templates.blackmarket_armor_workshop.use_workbench_room = true
	self._scene_templates.blackmarket_armor_workshop.remove_infamy_card = true
	self._scene_templates.blackmarket_armor_workshop.lights = {
		self:_create_light({
			far_range = 600,
			color = Vector3(1, 1, 1) * 0.8,
			position = Vector3(1400, -1650, -45)
		}),
		self:_create_light({
			far_range = 400,
			color = Vector3(1, 1, 1) * 2,
			position = Vector3(1600, -1750, -25)
		})
	}
	self._scene_templates.blackmarket_armor_screenshot = deep_clone(self._scene_templates.blackmarket_armor)
	self._scene_templates.blackmarket_armor_screenshot.fov = 25
	self._scene_templates.blackmarket_armor_screenshot.can_change_fov = true
	self._scene_templates.blackmarket_armor_screenshot.use_character_grab2 = true
	self._scene_templates.blackmarket_armor_screenshot.use_character_pan = true
	local camera_look = self._scene_templates.blackmarket_armor_screenshot.target_pos - self._scene_templates.blackmarket_armor_screenshot.camera_pos:normalized()

	mvector3.rotate_with(camera_look, Rotation(6, 2.75, 0))

	self._scene_templates.blackmarket_armor_screenshot.character_pos = self._scene_templates.blackmarket_armor_screenshot.camera_pos + camera_look * 600 + Vector3(60, 0, -120)
	self._scene_templates.blackmarket_armor_screenshot.lights = {
		self:_create_light({
			far_range = 600,
			color = Vector3(1, 1, 1) * 0.8,
			position = Vector3(1400, -1650, -45)
		}),
		self:_create_light({
			far_range = 400,
			color = Vector3(1, 1, 1) * 2,
			position = Vector3(1600, -1750, -25)
		})
	}
	self._scene_templates.blackmarket_screenshot = {
		fov = 40,
		can_change_fov = true,
		use_item_grab = true,
		disable_rotate = true,
		disable_item_updates = true,
		camera_pos = offset:rotate_with(Rotation(45)) + Vector3(0, 0, 200),
		target_pos = target_pos + Vector3(0, 50, 200)
	}
	self._scene_templates.blackmarket_screenshot.item_pos = self._scene_templates.blackmarket_screenshot.target_pos
	local l_pos = self._scene_templates.blackmarket_screenshot.camera_pos
	local rot = Rotation(self._scene_templates.blackmarket_screenshot.target_pos - l_pos, math.UP)
	local l1_pos = l_pos + rot:x() * 50 + rot:y() * 50
	local l2_pos = l_pos + rot:x() * -50 + rot:y() * 100
	self._scene_templates.blackmarket_screenshot.lights = {
		self:_create_light({
			far_range = 270,
			specular_multiplier = 155,
			color = Vector3(0.86, 0.67, 0.31) * 3,
			position = Vector3(160, -130, 220)
		}),
		self:_create_light({
			far_range = 270,
			specular_multiplier = 155,
			color = Vector3(0.86, 0.67, 0.41) * 2,
			position = Vector3(50, -150, 220)
		}),
		self:_create_light({
			far_range = 270,
			specular_multiplier = 155,
			color = Vector3(0.86, 0.67, 0.41) * 2,
			position = Vector3(160, 0, 220)
		}),
		self:_create_light({
			far_range = 250,
			specular_multiplier = 55,
			color = Vector3(0.5, 1.5, 2) * 2,
			position = Vector3(50, -100, 280)
		}),
		self:_create_light({
			far_range = 370,
			specular_multiplier = 55,
			color = Vector3(1, 0.4, 0.04) * 1.5,
			position = Vector3(200, 60, 180)
		})
	}
	self._scene_templates.crime_spree_lobby = {
		use_character_grab = false,
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = target_pos,
		character_pos = c_ref:position() + Vector3(0, 500, 0),
		lobby_characters_visible = true,
		fov = 40,
		lights = {
			self:_create_light({
				far_range = 300,
				color = Vector3(0.86, 0.57, 0.31) * 3,
				position = Vector3(56, 100, -10)
			}),
			self:_create_light({
				far_range = 3000,
				specular_multiplier = 6,
				color = Vector3(1, 2.5, 4.5) * 3,
				position = Vector3(-1000, -300, 800)
			}),
			self:_create_light({
				far_range = 800,
				specular_multiplier = 0,
				color = Vector3(1, 1, 1) * 0.35,
				position = Vector3(300, 100, 0)
			})
		}
	}
	self._scene_templates.crew_management = {
		use_character_grab = false,
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = target_pos,
		character_pos = c_ref:position() + Vector3(0, 500, 0),
		character_visible = false,
		lobby_characters_visible = false,
		henchmen_characters_visible = true,
		fov = 40,
		lights = {
			self:_create_light({
				far_range = 300,
				color = Vector3(0.86, 0.57, 0.31) * 3,
				position = Vector3(56, 100, -10)
			}),
			self:_create_light({
				far_range = 3000,
				specular_multiplier = 6,
				color = Vector3(1, 2.5, 4.5) * 3,
				position = Vector3(-1000, -300, 800)
			}),
			self:_create_light({
				far_range = 800,
				specular_multiplier = 0,
				color = Vector3(1, 1, 1) * 0.35,
				position = Vector3(300, 100, 0)
			})
		}
	}
	self._scene_templates.raid_menu = {
		use_character_grab = false,
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = target_pos,
		character_pos = c_ref:position() + Vector3(0, 500, 0),
		character_visible = false,
		lobby_characters_visible = false,
		henchmen_characters_visible = true,
		fov = 40,
		lights = {
			self:_create_light({
				far_range = 300,
				color = Vector3(0.86, 0.57, 0.31) * 3,
				position = Vector3(56, 100, -10)
			}),
			self:_create_light({
				far_range = 3000,
				specular_multiplier = 6,
				color = Vector3(1, 2.5, 4.5) * 3,
				position = Vector3(-1000, -300, 800)
			}),
			self:_create_light({
				far_range = 800,
				specular_multiplier = 0,
				color = Vector3(1, 1, 1) * 0.35,
				position = Vector3(300, 100, 0)
			})
		}
	}
	self._scene_templates.movie_theater = {
		use_character_grab = false,
		camera_pos = offset:rotate_with(Rotation(90)),
		target_pos = target_pos,
		character_visible = false,
		lobby_characters_visible = false,
		fov = 40
	}
end

function MenuSceneManager:_set_up_environments()
	self._environments = {
		standard = {}
	}
	self._environments.standard.environment = "environments/env_menu/env_menu"
	self._environments.standard.color_grading = "color_matrix"
	self._environments.standard.angle = 0
	self._environments.safe = {
		environment = "environments/pd2_cash/env_cash_01",
		color_grading = "color_off",
		angle = -135
	}
	self._environments.crafting = {
		environment = "environments/pd2_cash/env_cash_02",
		color_grading = "color_off",
		angle = -135
	}
end

function MenuSceneManager:_use_environment(name)
	local setting = self._environments[name]

	if not setting then
		return
	end

	if managers.viewport:default_environment() ~= setting.environment then
		managers.viewport:preload_environment(setting.environment)
		managers.viewport:set_default_environment(setting.environment, nil, nil)
	end

	if managers.environment_controller:default_color_grading() ~= setting.color_grading then
		managers.environment_controller:set_default_color_grading(setting.color_grading, true)
		managers.environment_controller:refresh_render_settings()
	end

	self:_set_sky_rotation_angle(setting.angle)
end

function MenuSceneManager:post_ambience_event(ambience_event)
	if self._current_ambience_event and self._current_ambience_event == ambience_event then
		return
	end

	self._current_ambience_event = ambience_event

	managers.menu:post_event(ambience_event)
end

function MenuSceneManager:add_one_frame_delayed_clbk(clbk)
	table.insert(self._one_frame_delayed_clbks, clbk)
end

function MenuSceneManager:input_focus()
	return self._character_grabbed or self._item_grabbed and true or false
end

function MenuSceneManager:update(t, dt)
	if self._one_frame_delayed_clbks and #self._one_frame_delayed_clbks > 0 then
		for _, clbk in ipairs(self._one_frame_delayed_clbks) do
			clbk()
		end

		self._one_frame_delayed_clbks = {}
	end

	if self._delayed_callbacks then
		local callbacks = self._delayed_callbacks

		if callbacks[1] and callbacks[1][1] < t then
			local clbk_data = table.remove(callbacks, 1)
			local clbk = clbk_data[2]

			if #callbacks == 0 then
				self._delayed_callbacks = nil
			end

			clbk(clbk_data[3])
		end
	end

	if self._camera_values and self._transition_time then
		self._transition_time = math.min(self._transition_time + dt, 1)
		local bezier_value = math.bezier(self._transition_bezier, self._transition_time)

		if self._transition_time == 1 then
			self._transition_time = nil

			self:dispatch_transition_done()
			managers.skilltree:check_reset_message()
			managers.infamy:check_reset_message()
		end

		local camera_pos = math.lerp(self._camera_values.camera_pos_current, self._camera_values.camera_pos_target, bezier_value)
		local target_pos = math.lerp(self._camera_values.target_pos_current, self._camera_values.target_pos_target, bezier_value)
		local fov = math.lerp(self._camera_values.fov_current, self._camera_values.fov_target, bezier_value)
		self._current_fov = fov

		self:_set_camera_position(camera_pos)
		self:_set_target_position(target_pos)

		if self._character_values and not self._transition_time and #self._character_dynamic_bodies > 0 then
			self._enabled_character_dynamic_bodies = math.max(self._enabled_character_dynamic_bodies and self._enabled_character_dynamic_bodies or 0, 1)
		end
	elseif self._character_values and not mvector3.equal(self._character_values.pos_current, self._character_values.pos_target) then
		mvector3.lerp(self._character_values.pos_current, self._character_values.pos_current, self._character_values.pos_target, dt * 20)
		self._character_unit:set_position(self._character_values.pos_current)
	end

	if self._enabled_character_dynamic_bodies then
		self._enabled_character_dynamic_bodies = self._enabled_character_dynamic_bodies - 1

		if self._enabled_character_dynamic_bodies == 0 then
			self._enabled_character_dynamic_bodies = nil
		end
	end

	if self._camera_object and self._new_fov ~= self._current_fov + (self._fov_mod or 0) then
		self._new_fov = self._current_fov + (self._fov_mod or 0)

		self._camera_object:set_fov(self._new_fov)
	end

	if self._weapon_transition_time then
		self._weapon_transition_time = math.min(self._weapon_transition_time + dt, 1)
		local bezier_value = math.bezier(self._transition_bezier, self._weapon_transition_time)

		if self._item_offset_target then
			self._item_offset = math.lerp(self._item_offset_current, self._item_offset_target, bezier_value)
		end
	end

	if self._item_unit and self._item_unit.unit and not self._disable_item_updates and not self._item_grabbed then
		if not managers.blackmarket:currently_customizing_mask() and not self._disable_rotate then
			self._item_yaw = (self._item_yaw + 5 * dt) % 360
		end

		self._item_pitch = math.lerp(self._item_pitch, 0, 10 * dt)
		self._item_roll = math.lerp(self._item_roll, 0, 10 * dt)

		mrotation.set_yaw_pitch_roll(self._item_rot_temp, self._item_yaw, self._item_pitch, self._item_roll)
		mrotation.set_zero(self._item_rot)
		mrotation.multiply(self._item_rot, self._camera_object:rotation())
		mrotation.multiply(self._item_rot, self._item_rot_temp)
		mrotation.multiply(self._item_rot, self._item_rot_mod)
		self._item_unit.unit:set_rotation(self._item_rot)

		local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)

		self._item_unit.unit:set_position(new_pos)
		self._item_unit.unit:set_moving(2)
	end

	if self._fade_down_lights then
		for _, light in ipairs(self._fade_down_lights) do
			light:set_multiplier(0)
		end
	end

	if self._active_lights then
		for _, light in ipairs(self._active_lights) do
			light:set_multiplier(0.8)
		end
	end

	self:_update_safe_scene(t, dt)
end

function MenuSceneManager:add_callback(clbk, delay, param)
	if not clbk then
		debug_pause("[MenuSceneManager:add_callback] Empty callback object!")
	end

	local clbk_data = {
		Application:time() + delay,
		clbk,
		param
	}
	self._delayed_callbacks = self._delayed_callbacks or {}
	local callbacks = self._delayed_callbacks
	local i = #callbacks

	if i > 0 then
		while i > 0 and clbk_data[1] < callbacks[i][1] do
			i = i - 1
		end
	end

	table.insert(callbacks, i + 1, clbk_data)
end

function MenuSceneManager:on_blackmarket_reset()
	self:set_character(managers.blackmarket:get_preferred_character())
	self:_set_character_equipment()
end

function MenuSceneManager:_setup_bg()
	local yaw = 180
	self._bg_unit = World:spawn_unit(Idstring("units/menu/menu_scene/menu_cylinder"), Vector3(0, 0, 0), Rotation(yaw, 0, 0))

	World:spawn_unit(Idstring("units/menu/menu_scene/menu_cylinder_pattern"), Vector3(0, 0, 0), Rotation(yaw, 0, 0))
	World:spawn_unit(Idstring("units/menu/menu_scene/menu_smokecylinder1"), Vector3(0, 0, 0), Rotation(yaw, 0, 0))
	World:spawn_unit(Idstring("units/menu/menu_scene/menu_smokecylinder2"), Vector3(0, 0, 0), Rotation(yaw, 0, 0))
	World:spawn_unit(Idstring("units/menu/menu_scene/menu_smokecylinder3"), Vector3(0, 0, 0), Rotation(yaw, 0, 0))

	self._menu_logo = World:spawn_unit(Idstring("units/menu/menu_scene/menu_logo"), Vector3(0, 10, 0), Rotation(yaw, 0, 0))

	self:set_character(managers.blackmarket:get_preferred_character())
	self:_setup_lobby_characters()
	self:_setup_henchmen_characters()
end

function MenuSceneManager:_set_player_character_unit(unit_name)
	self._character_unit = self:_set_character_unit(unit_name, self._character_unit, self._character_values and self._character_values.pos_target)

	self:_setup_character_dynamic_bodies(self._character_unit)

	self._character_visibilities[self._character_unit:key()] = true

	self:_set_character_equipment()
end

function MenuSceneManager:_setup_character_dynamic_bodies(unit)
	self._character_dynamic_bodies = {}
	local bodies = self._character_dynamic_bodies

	for i = 0, unit:num_bodies() - 1, 1 do
		if unit:body(i):dynamic() then
			table.insert(bodies, unit:body(i))
		end
	end

	self._enabled_character_dynamic_bodies = 61
end

function MenuSceneManager:_set_character_dynamic_bodies_state(state)
	local func_name = state == "keyframed" and "set_keyframed" or "set_dynamic"

	for _, body in ipairs(self._character_dynamic_bodies) do
		body[func_name](body)
	end
end

function MenuSceneManager:_set_character_unit(unit_name, unit, pos_override)
	local pos, rot = nil

	if alive(unit) then
		pos = unit:position()
		rot = unit:rotation()

		self:_delete_character_mask(unit)
		self:_delete_character_weapon(unit, "all")
		World:delete_unit(unit)
	end

	local a = self._bg_unit:get_object(Idstring("a_reference"))
	unit = World:spawn_unit(Idstring(unit_name), pos_override or pos or a:position(), rot or a:rotation())
	self._character_yaw = rot or a:rotation():yaw()
	self._character_pitch = rot or a:rotation():pitch()

	self:_set_character_unit_pose("husk_rifle1", unit)

	self._character_unit_need_pose = true

	return unit
end

function MenuSceneManager:_set_character_unit_pose(pose, unit)
	local state = unit:play_redirect(Idstring("idle_menu"))

	unit:anim_state_machine():set_parameter(state, pose, 1)

	if self._character_unit == unit then
		self:add_one_frame_delayed_clbk(callback(self, self, "_character_unit_pose_updated"))
	end
end

function MenuSceneManager:_character_unit_pose_updated()
	self._character_unit_need_pose = false

	self:_chk_character_visibility(self._character_unit)
end

function MenuSceneManager:_select_character_pose(unit)
	unit = unit or self._character_unit

	if self._scene_templates and self._scene_templates[self._current_scene_template] and self._scene_templates[self._current_scene_template].poses then
		local poses = self._scene_templates[self._current_scene_template].poses
		local pose = nil
		local primary = managers.blackmarket:equipped_primary()

		if primary then
			local weapon_id_poses = poses[primary.weapon_id]

			if weapon_id_poses then
				pose = weapon_id_poses[math.random(#weapon_id_poses)]
			else
				local primary_category = tweak_data.weapon[primary.weapon_id].categories[1]

				if poses[primary_category] then
					pose = poses[primary_category][math.random(#poses[primary_category])]
				end
			end

			if pose then
				self:_set_character_unit_pose(pose, unit)

				return
			end
		end

		local secondary = managers.blackmarket:equipped_secondary()

		if secondary then
			local weapon_id_poses = poses[secondary.weapon_id]

			if weapon_id_poses then
				pose = weapon_id_poses[math.random(#weapon_id_poses)]
			else
				local primary_category = tweak_data.weapon[secondary.weapon_id].categories[1]

				if poses[primary_category] then
					pose = poses[primary_category][math.random(#poses[primary_category])]
				end
			end

			if pose then
				self:_set_character_unit_pose(pose, unit)

				return
			end
		end
	end

	if managers.experience:current_rank() > 0 and self._card_units and self._card_units[unit:key()] then
		local pose = self._global_poses.infamous[math.random(#self._global_poses.infamous)]

		self:_set_character_unit_pose(pose, unit)

		return
	end

	local pose = nil
	local secondary = managers.blackmarket:equipped_secondary()

	if secondary and (math.rand(1) < 0.12 or table.contains(self._forced_secondaries, secondary.weapon_id)) then
		local primary_category = tweak_data.weapon[secondary.weapon_id].categories[1]

		if primary_category == "pistol" then
			pose = self._global_poses.pistol[math.random(#self._global_poses.pistol)]
		elseif self._global_poses[secondary.weapon_id] then
			local wep_poses = self._global_poses[secondary.weapon_id]
			pose = wep_poses[math.random(#wep_poses)]
		end

		if pose then
			self:_set_character_unit_pose(pose, unit)

			return
		end
	end

	if math.rand(1) < 0.25 then
		pose = self._global_poses.generic[math.random(#self._global_poses.generic)]

		self:_set_character_unit_pose(pose, unit)

		return
	end

	local primary = managers.blackmarket:equipped_primary()

	if primary then
		local weapon_id_poses = self._global_poses[primary.weapon_id]

		if weapon_id_poses then
			pose = weapon_id_poses[math.random(#weapon_id_poses)]
		else
			local primary_category = tweak_data.weapon[primary.weapon_id].categories[1]

			if primary_category == "shotgun" then
				pose = self._global_poses.shotgun[math.random(#self._global_poses.shotgun)]
			elseif primary_category == "assault_rifle" then
				pose = self._global_poses.assault_rifle[math.random(#self._global_poses.assault_rifle)]
			elseif primary_category == "saw" then
				pose = self._global_poses.saw[math.random(#self._global_poses.saw)]
			elseif primary_category == "lmg" then
				pose = self._global_poses.lmg[math.random(#self._global_poses.lmg)]
			elseif primary_category == "snp" then
				pose = self._global_poses.snp[math.random(#self._global_poses.snp)]
			elseif primary_category == "bow" then
				pose = self._global_poses.bow[math.random(#self._global_poses.bow)]
			end
		end

		if pose then
			self:_set_character_unit_pose(pose, unit)

			return
		end
	end

	pose = self._global_poses.generic[math.random(#self._global_poses.generic)]

	self:_set_character_unit_pose(pose, unit)
end

function MenuSceneManager:_select_henchmen_pose(unit, weapon_id, index)
	local delays = {
		0,
		0.8,
		0.2,
		0.5
	}
	local animation_delay = delays[index] or index * 0.2
	local state = unit:play_redirect(Idstring("idle_menu"))

	if not weapon_id then
		unit:anim_state_machine():set_parameter(state, "cvc_var1", 1)
		unit:anim_state_machine():set_animation_time_all_segments(animation_delay)

		return
	end

	local category = tweak_data.weapon[weapon_id].categories[1]
	local lobby_poses = self._lobby_poses[weapon_id]
	lobby_poses = lobby_poses or self._lobby_poses[category]
	lobby_poses = lobby_poses or self._lobby_poses.generic
	local pose = nil

	if type(lobby_poses[1]) == "string" then
		pose = lobby_poses[math.random(#lobby_poses)]
	else
		pose = lobby_poses[index][math.random(#lobby_poses[index])]
	end

	unit:anim_state_machine():set_parameter(state, pose, 1)
	unit:anim_state_machine():set_animation_time_all_segments(animation_delay)
end

function MenuSceneManager:_set_character_equipment()
	local equipped_mask = managers.blackmarket:equipped_mask()

	if equipped_mask.mask_id then
		self:set_character_mask_by_id(equipped_mask.mask_id, equipped_mask.blueprint)
	end

	for armor_id, data in pairs(tweak_data.blackmarket.armors) do
		if Global.blackmarket_manager.armors[armor_id].equipped then
			self:set_character_armor(armor_id)

			break
		end
	end

	self:set_character_armor_skin(managers.blackmarket:equipped_armor_skin())

	local rank = managers.experience:current_rank()
	local ignore_infamy_card = self._scene_templates and self._scene_templates[self._current_scene_template] and self._scene_templates[self._current_scene_template].remove_infamy_card and true or false
	local ignore_weapons = self._scene_templates and self._scene_templates[self._current_scene_template] and self._scene_templates[self._current_scene_template].remove_weapons and true or false

	if rank > 0 and not ignore_infamy_card then
		self:set_character_equipped_card(nil, rank - 1)
	else
		local secondary = managers.blackmarket:equipped_secondary()

		if secondary and not ignore_weapons then
			self:set_character_equipped_weapon(nil, secondary.factory_id, secondary.blueprint, "secondary", secondary.cosmetics)
		else
			self:_delete_character_weapon(self._character_unit, "secondary")
		end
	end

	local primary = managers.blackmarket:equipped_primary()

	if primary and not ignore_weapons then
		self:set_character_equipped_weapon(nil, primary.factory_id, primary.blueprint, "primary", primary.cosmetics)
	else
		self:_delete_character_weapon(self._character_unit, "primary")
	end

	self:set_character_deployable(managers.blackmarket:equipped_deployable(), false, 0)
end

function MenuSceneManager:get_current_scene_template()
	return self._current_scene_template
end

function MenuSceneManager:get_scene_template_data(scene_template)
	return self._scene_templates[scene_template]
end

function MenuSceneManager:_setup_henchmen_characters()
	if self._henchmen_characters then
		for _, unit in ipairs(self._henchmen_characters) do
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end
	end

	self._henchmen_characters = {}
	local masks = {
		"dallas",
		"dallas",
		"dallas"
	}

	for i = 1, 3, 1 do
		local pos, rot = self:get_henchmen_positioning(i)
		local unit_name = tweak_data.blackmarket.characters.locked.menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

		self:_init_character(unit, i)
		self:set_character_mask(tweak_data.blackmarket.masks[masks[i]].unit, unit, nil, masks[i])
		table.insert(self._henchmen_characters, unit)

		self._character_visibilities[unit:key()] = false

		self:_chk_character_visibility(unit)
	end
end

function MenuSceneManager:get_henchmen_positioning(index)
	local offset = Vector3(0, -200, -130)
	local rotation = {
		-65,
		-79,
		-89
	}
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()

	mrotation.set_yaw_pitch_roll(rot, rotation[math.min(index, #rotation)], 0, 0)
	mvector3.set(pos, offset)
	mvector3.rotate_with(pos, rot)
	mvector3.set(mvec, pos)
	mvector3.negate(mvec)
	mvector3.set_z(mvec, 0)
	mvector3.set(mvec, mvec + Vector3(100, 150, 0))
	mrotation.set_look_at(rot, mvec, math_up)
	mvector3.set_x(pos, 50 + -80 * index)
	mvector3.set_z(pos, -135)

	return pos, rot
end

function MenuSceneManager:set_henchmen_visible(visible, i)
	if i then
		local unit = self._henchmen_characters[i]

		if alive(unit) then
			self._character_visibilities[unit:key()] = visible

			self:_chk_character_visibility(unit)
		end
	else
		for i, _ in ipairs(self._henchmen_characters) do
			self:set_henchmen_visible(visible, i)
		end
	end
end

function MenuSceneManager:set_henchmen_loadout(index, character, loadout)
	self._picked_character_position = self._picked_character_position or {}
	loadout = loadout or managers.blackmarket:henchman_loadout(index)
	character = character or managers.blackmarket:preferred_henchmen(index)

	if not character then
		local preferred = managers.blackmarket:preferred_henchmen()
		local characters = CriminalsManager.character_names()
		local player_character = managers.blackmarket:get_preferred_characters_list()[1]
		local available = {}

		for i, name in ipairs(characters) do
			if player_character ~= name then
				local found_current = table.get_key(self._picked_character_position, name) or 999

				if not table.contains(preferred, name) and index <= found_current then
					local new_name = CriminalsManager.convert_old_to_new_character_workname(name)
					local char_tweak = tweak_data.blackmarket.characters.locked[new_name] or tweak_data.blackmarket.characters[new_name]

					if not char_tweak.dlc or managers.dlc:is_dlc_unlocked(char_tweak.dlc) then
						table.insert(available, name)
					end
				end
			end
		end

		if #available < 1 then
			available = CriminalsManager.character_names()
		end

		character = available[math.random(#available)] or "russian"
	end

	self._picked_character_position[index] = character
	local character_id = managers.blackmarket:get_character_id_by_character_name(character)
	local unit = self._henchmen_characters[index]

	self:_delete_character_weapon(unit, "all")

	local unit_name = tweak_data.blackmarket.characters[character_id].menu_unit

	if not alive(unit) or Idstring(unit_name) ~= unit:name() then
		local pos = unit:position()
		local rot = unit:rotation()

		if alive(unit) then
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end

		unit = World:spawn_unit(Idstring(unit_name), pos, rot)

		self:_init_character(unit, index)

		self._henchmen_characters[index] = unit
	end

	unit:base():set_character_name(character)

	local mask = loadout.mask
	local mask_blueprint = loadout.mask_blueprint
	local crafted_mask = managers.blackmarket:get_crafted_category_slot("masks", loadout.mask_slot)

	if crafted_mask then
		mask = crafted_mask.mask_id
		mask_blueprint = crafted_mask.blueprint
	end

	self:set_character_mask_by_id(mask, mask_blueprint, unit, nil, character)

	local mask_data = self._mask_units[unit:key()]

	if mask_data then
		self:update_mask_offset(mask_data)
	end

	local weapon_id = nil
	local crafted_primary = managers.blackmarket:get_crafted_category_slot("primaries", loadout.primary_slot)

	if crafted_primary then
		local primary = crafted_primary.factory_id
		local primary_id = crafted_primary.weapon_id
		local primary_blueprint = crafted_primary.blueprint
		local primary_cosmetics = crafted_primary.cosmetics

		self:set_character_equipped_weapon(unit, primary, primary_blueprint, "primary", primary_cosmetics)

		weapon_id = primary_id
	else
		local primary = tweak_data.character[character].weapon.weapons_of_choice.primary
		primary = string.gsub(primary, "_npc", "")
		local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(primary)

		self:set_character_equipped_weapon(unit, primary, blueprint, "primary", nil)

		weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(primary)
	end

	self:_select_henchmen_pose(unit, weapon_id, index)

	local pos, rot = self:get_henchmen_positioning(index)

	unit:set_position(pos)
	unit:set_rotation(rot)
	self:set_henchmen_visible(true, index)
end

function MenuSceneManager:_setup_lobby_characters()
	if self._lobby_characters then
		for _, unit in ipairs(self._lobby_characters) do
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end
	end

	self._lobby_characters = {}
	self._characters_offset = Vector3(0, -200, -130)
	self._characters_rotation = {
		-89,
		-73,
		-56,
		-106,
		-89,
		-64,
		-35,
		-115
	}
	local masks = {}

	for i = 1, tweak_data.max_players, 1 do
		table.insert(masks, "dallas")
	end

	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()

	for i = 1, tweak_data.max_players, 1 do
		mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[i] or self._characters_rotation[1], 0, 0)
		mvector3.set(pos, self._characters_offset)
		mvector3.rotate_with(pos, rot)
		mvector3.set(mvec, pos)
		mvector3.negate(mvec)
		mvector3.set_z(mvec, 0)
		mrotation.set_look_at(rot, mvec, math_up)

		local unit_name = tweak_data.blackmarket.characters.locked.menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

		self:_init_character(unit, i)
		self:set_character_mask(tweak_data.blackmarket.masks[masks[i]].unit, unit, nil, masks[i])
		table.insert(self._lobby_characters, unit)
		self:set_lobby_character_visible(i, false, true)
	end
end

function MenuSceneManager:_init_character(unit, peer_id)
	local state = unit:play_redirect(Idstring("idle_menu"))

	unit:anim_state_machine():set_parameter(state, "husk" .. peer_id, 1)
end

function MenuSceneManager:change_lobby_character(peer_id, character_id)
	local unit = self._lobby_characters[peer_id]
	local unit_name = tweak_data.blackmarket.characters[character_id].menu_unit

	if not alive(unit) or Idstring(unit_name) ~= unit:name() then
		local pos = unit:position()
		local rot = unit:rotation()

		if alive(unit) then
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end

		unit = World:spawn_unit(Idstring(unit_name), pos, rot)

		self:_init_character(unit, peer_id)

		self._lobby_characters[peer_id] = unit
	end

	unit:base():set_character_name(managers.network:session():peer(peer_id):character())

	local mask_data = self._mask_units[unit:key()]

	if mask_data then
		self:update_mask_offset(mask_data)
	end
end

function MenuSceneManager:test_show_all_lobby_characters(enable_card)
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()
	self._ti = (self._ti or 0) + 1
	self._ti = (self._ti - 1) % 4 + 1

	for i = 1, 4, 1 do
		local is_me = i == self._ti
		local unit = self._lobby_characters[i]

		if unit and alive(unit) then
			if enable_card then
				self:set_character_card(i, math.random(25), unit)
			else
				local state = unit:play_redirect(Idstring("idle_menu"))

				unit:anim_state_machine():set_parameter(state, "lobby_generic_idle" .. i, 1)
			end

			mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[(is_me and 4 or 0) + i], 0, 0)
			mvector3.set(pos, self._characters_offset)

			if is_me then
				mvector3.set_y(pos, mvector3.y(pos) + 100)
			end

			mvector3.rotate_with(pos, rot)
			mvector3.set(mvec, pos)
			mvector3.negate(mvec)
			mvector3.set_z(mvec, 0)
			mrotation.set_look_at(rot, mvec, math_up)
			unit:set_position(pos)
			unit:set_rotation(rot)

			local character = managers.blackmarket:equipped_character()
			local mask_blueprint = managers.blackmarket:equipped_mask().blueprint

			self:change_lobby_character(i, character)

			unit = self._lobby_characters[i]

			self:set_character_mask_by_id(managers.blackmarket:equipped_mask().mask_id, mask_blueprint, unit, i)
			self:set_character_armor(managers.blackmarket:equipped_armor(), unit)
			self:set_character_armor_skin(managers.blackmarket:equipped_armor_skin(), unit)
			self:set_lobby_character_visible(i, true)
		end
	end
end

function MenuSceneManager:hide_all_lobby_characters()
	for i = 1, tweak_data.max_players, 1 do
		self:set_lobby_character_visible(i, false, true)
	end
end

function MenuSceneManager:set_lobby_character_visible(i, visible, no_state)
	local unit = self._lobby_characters[i]
	self._character_visibilities[unit:key()] = visible

	if not visible then
		self._deployable_equipped[i] = nil
	end

	self:_chk_character_visibility(unit)

	if self._current_profile_slot == i then
		managers.menu_component:close_lobby_profile_gui()

		self._current_profile_slot = 0
	end
end

function MenuSceneManager:update_menu_character_text(i)
	if managers.menu_component then
		managers.menu_component:update_contract_character(i)
	end
end

function MenuSceneManager:set_lobby_character_menu_state(i, state)
	if managers.menu_component then
		managers.menu_component:update_contract_character_menu_state(i, state)
	end
end

function MenuSceneManager:set_lobby_character_out_fit(i, outfit_string, rank)
	local outfit = managers.blackmarket:unpack_outfit_from_string(outfit_string)
	local character = outfit.character

	if managers.network:session() then
		if not managers.network:session():peer(i) then
			return
		end

		character = managers.network:session():peer(i):character_id()
	end

	self:change_lobby_character(i, character)

	local unit = self._lobby_characters[i]
	local mask_blueprint = managers.blackmarket:mask_blueprint_from_outfit_string(outfit_string)

	self:set_character_mask_by_id(outfit.mask.mask_id, outfit.mask.blueprint, unit, i)
	self:set_character_armor(outfit.armor, unit)
	self:set_character_deployable(outfit.deployable, unit, i)
	self:set_character_armor_skin(outfit.armor_skin or managers.blackmarket:equipped_armor_skin(), unit)
	self:_delete_character_weapon(unit, "all")

	local prio_item = self:_get_lobby_character_prio_item(rank, outfit)

	if prio_item == "rank" then
		self:set_character_card(i, rank, unit)
	else
		self:_select_lobby_character_pose(i, unit, outfit[prio_item])
		self:set_character_equipped_weapon(unit, outfit[prio_item].factory_id, outfit[prio_item].blueprint, "primary", outfit[prio_item].cosmetics)
	end

	local is_me = i == managers.network:session():local_peer():id()
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()

	mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[(is_me and 4 or 0) + i], 0, 0)
	mvector3.set(pos, self._characters_offset)

	if is_me then
		mvector3.set_y(pos, mvector3.y(pos) + 100)
	end

	mvector3.rotate_with(pos, rot)
	mvector3.set(mvec, pos)
	mvector3.negate(mvec)
	mvector3.set_z(mvec, 0)
	mrotation.set_look_at(rot, mvec, math_up)
	unit:set_position(pos)
	unit:set_rotation(rot)
	self:set_lobby_character_visible(i, true)
end

function MenuSceneManager:_get_lobby_character_prio_item(rank, outfit)
	local infamous = rank and rank > 0
	local primary_rarity, secondary_rarity = nil

	if outfit.primary.cosmetics and outfit.primary.cosmetics.id and outfit.primary.cosmetics.id ~= "nil" then
		local rarity = tweak_data.blackmarket.weapon_skins[outfit.primary.cosmetics.id] and tweak_data.blackmarket.weapon_skins[outfit.primary.cosmetics.id].rarity
		primary_rarity = tweak_data.economy.rarities[rarity].index
	end

	if outfit.secondary.cosmetics and outfit.secondary.cosmetics.id and outfit.secondary.cosmetics.id ~= "nil" then
		local rarity = tweak_data.blackmarket.weapon_skins[outfit.secondary.cosmetics.id] and tweak_data.blackmarket.weapon_skins[outfit.secondary.cosmetics.id].rarity
		secondary_rarity = tweak_data.economy.rarities[rarity].index
	end

	if primary_rarity and secondary_rarity then
		return secondary_rarity <= primary_rarity and "primary" or "secondary"
	elseif primary_rarity then
		return "primary"
	elseif secondary_rarity then
		return "secondary"
	end

	return infamous and "rank" or "primary"
end

function MenuSceneManager:_select_lobby_character_pose(peer_id, unit, weapon_info)
	local state = unit:play_redirect(Idstring("idle_menu"))
	local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(weapon_info.factory_id)
	local category = tweak_data.weapon[weapon_id].categories[1]
	local lobby_poses = self._lobby_poses[weapon_id]
	lobby_poses = lobby_poses or self._lobby_poses[category]
	lobby_poses = lobby_poses or self._lobby_poses.generic

	if type(lobby_poses[1]) == "string" then
		local pose = lobby_poses[math.random(#lobby_poses)]

		unit:anim_state_machine():set_parameter(state, pose, 1)
	else
		local id = peer_id % #lobby_poses + 1
		local pose = lobby_poses[id][math.random(#lobby_poses[id])]

		unit:anim_state_machine():set_parameter(state, pose, 1)
	end
end

function MenuSceneManager:set_character_deployable(deployable_id, unit, peer_id)
	unit = unit or self._character_unit

	if self._deployable_equipped[peer_id] and self._deployable_equipped[peer_id] ~= "nil" then
		local tweak_data = tweak_data.equipments[self._deployable_equipped[peer_id]]
		local object_name = tweak_data.visual_object

		unit:get_object(Idstring(object_name)):set_visibility(false)
	end

	if deployable_id and deployable_id ~= "nil" then
		local tweak_data = tweak_data.equipments[deployable_id]
		local object_name = tweak_data.visual_object

		unit:get_object(Idstring(object_name)):set_visibility(self._characters_deployable_visible)
	end

	self._deployable_equipped[peer_id] = deployable_id
end

function MenuSceneManager:set_character_mask_by_id(mask_id, blueprint, unit, peer_id, character_name)
	mask_id = managers.blackmarket:get_real_mask_id(mask_id, peer_id, character_name)
	local unit_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id, character_name)

	self:set_character_mask(unit_name, unit, peer_id, mask_id, callback(self, self, "clbk_mask_loaded", blueprint))

	local owner_unit = unit or self._character_unit

	owner_unit:base():request_cosmetics_update()
end

function MenuSceneManager:clbk_mask_loaded(blueprint, mask_unit)
	if mask_unit then
		mask_unit:base():apply_blueprint(blueprint, function ()
		end)
	end
end

function MenuSceneManager:set_character_mask(mask_name_str, unit, peer_id_or_char, mask_id, ready_clbk)
	local character_name = type(peer_id_or_char) == "string" and peer_id_or_char
	local peer_id = type(peer_id_or_char) == "number" and peer_id_or_char
	unit = unit or self._character_unit
	local mask_name = Idstring(mask_name_str)
	local old_mask_data = self._mask_units[unit:key()]

	if old_mask_data and old_mask_data.mask_name == mask_name then
		old_mask_data.peer_id = peer_id
		old_mask_data.character_name = character_name

		if old_mask_data.ready then
			ready_clbk(old_mask_data.mask_unit)
		else
			old_mask_data.ready_clbk = ready_clbk
		end

		return
	end

	self:_delete_character_mask(unit)

	local mask_name_key = mask_name:key()
	local mask_data = {
		mask_unit = false,
		ready = false,
		unit = unit,
		mask_name = mask_name,
		peer_id = peer_id,
		character_name = character_name,
		mask_id = mask_id,
		ready_clbk = ready_clbk
	}
	self._mask_units[unit:key()] = mask_data

	managers.dyn_resource:load(ids_unit, mask_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_unit_loaded", mask_data))
	self:_chk_character_visibility(unit)
end

function MenuSceneManager:clbk_mask_unit_loaded(mask_data_param, status, asset_type, asset_name)
	if not alive(mask_data_param.unit) then
		return
	end

	local mask_data = self._mask_units[mask_data_param.unit:key()]

	if mask_data ~= mask_data_param then
		return
	end

	if asset_name ~= mask_data.mask_name then
		return
	end

	if mask_data.ready then
		return
	end

	local mask_align = mask_data.unit:get_object(Idstring("Head"))
	local mask_unit = self:_spawn_mask(mask_data.mask_name, false, mask_align:position(), mask_align:rotation(), mask_data.mask_id)
	mask_data.mask_align = mask_align
	mask_data.mask_unit = mask_unit
	mask_data.ready = true

	mask_data.unit:link(mask_align:name(), mask_unit)
	self:update_mask_offset(mask_data)
	mask_data.unit:base():set_mask_id(mask_data.mask_id)
	self:_chk_character_visibility(mask_data.unit)

	if mask_data.ready_clbk then
		mask_data.ready_clbk(mask_unit)

		mask_data.ready_clbk = nil
	end
end

function MenuSceneManager:update_mask_offset(mask_data)
	local char = managers.blackmarket:get_real_character(mask_data.character_name, mask_data.peer_id)
	local mask_tweak = tweak_data.blackmarket.masks[mask_data.mask_id]

	if mask_tweak and mask_tweak.offsets and mask_tweak.offsets[char] then
		local char_tweak = mask_tweak.offsets[char]

		self:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, char_tweak[1] or Vector3(0, 0, 0), char_tweak[2] or Rotation(0, 0, 0))
		self:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, char_tweak[1] or Vector3(0, 0, 0), char_tweak[2] or Rotation(0, 0, 0))
	else
		self:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, Vector3(0, 0, 0), Rotation(0, 0, 0))
	end
end

function MenuSceneManager:set_mask_offset(mask_unit, mask_align, position, rotation)
	if not alive(mask_unit) then
		return
	end

	if rotation then
		mask_unit:set_rotation(mask_align:rotation() * rotation)
	end

	if position then
		mask_unit:set_position(mask_align:position() + mask_unit:rotation():x() * position.x + mask_unit:rotation():z() * position.z + mask_unit:rotation():y() * position.y)
	end
end

function MenuSceneManager:set_character_armor(armor_id, unit)
	unit = unit or self._character_unit
	local sequence = tweak_data.blackmarket.armors[armor_id].sequence

	unit:damage():run_sequence_simple(sequence)
	unit:base():set_armor_id(armor_id)
	self:set_character_armor_skin(managers.blackmarket:equipped_armor_skin())
end

function MenuSceneManager:set_character_armor_skin(skin_id, unit)
	unit = unit or self._character_unit

	if not unit or not unit:base() then
		return
	end

	unit:base():set_cosmetics_data(skin_id, true)
end

function MenuSceneManager:set_character_card(peer_id, rank, unit)
	if rank and rank > 0 then
		local state = unit:play_redirect(Idstring("idle_menu"))

		unit:anim_state_machine():set_parameter(state, "husk_card" .. peer_id, 1)

		local card = rank - 1
		local card_unit = World:spawn_unit(Idstring("units/menu/menu_scene/infamy_card"), Vector3(0, 0, 0), Rotation(0, 0, 0))

		card_unit:damage():run_sequence_simple("enable_card_" .. (card < 10 and "0" or "") .. tostring(math.min(card, 24)))
		unit:link(Idstring("a_weapon_left_front"), card_unit, card_unit:orientation_object():name())
		self:_delete_character_weapon(unit, "secondary")

		self._card_units = self._card_units or {}
		self._card_units[unit:key()] = card_unit
	end
end

function MenuSceneManager:set_character_equipped_weapon(unit, factory_id, blueprint, type, cosmetics)
	unit = unit or self._character_unit

	self:_delete_character_weapon(unit, type)

	if factory_id then
		local factory_weapon = tweak_data.weapon.factory[factory_id]
		local ids_unit_name = Idstring(factory_weapon.unit)
		self._weapon_units[unit:key()] = self._weapon_units[unit:key()] or {}
		self._weapon_units[unit:key()][type] = {
			unit = false,
			assembly_complete = false,
			name = ids_unit_name
		}
		local clbk = callback(self, self, "clbk_weapon_base_unit_loaded", {
			owner = unit,
			factory_id = factory_id,
			blueprint = blueprint,
			cosmetics = cosmetics,
			type = type
		})

		managers.dyn_resource:load(ids_unit, ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, clbk)
	end

	self:_chk_character_visibility(unit)
end

function MenuSceneManager:_is_lobby_character(char_unit)
	return table.contains(self._lobby_characters, char_unit)
end

function MenuSceneManager:_is_henchmen_character(char_unit)
	return table.contains(self._henchmen_characters, char_unit)
end

function MenuSceneManager:_chk_character_visibility(char_unit)
	local char_key = char_unit:key()

	if not self._character_visibilities[char_key] then
		self:_set_character_and_outfit_visibility(char_unit, false)

		return
	end

	local char_weapons = self._weapon_units[char_key]

	if char_weapons then
		for w_type, w_data in pairs(char_weapons) do
			if not w_data.assembly_complete then
				self:_set_character_and_outfit_visibility(char_unit, false)

				return
			end
		end
	end

	local char_mask = self._mask_units[char_key]

	if char_mask and not char_mask.mask_unit then
		self:_set_character_and_outfit_visibility(char_unit, false)

		return
	end

	local scene_template = self._current_scene_template ~= "" and self._scene_templates[self._current_scene_template]

	if char_unit == self._character_unit then
		local visible = false

		if self._character_unit_need_pose then
			self:_set_character_and_outfit_visibility(char_unit, false)

			return
		end

		if scene_template and not scene_template.character_visible then
			self:_set_character_and_outfit_visibility(char_unit, false)

			return
		end
	elseif scene_template then
		if self:_is_henchmen_character(char_unit) then
			if not scene_template.henchmen_characters_visible then
				self:_set_character_and_outfit_visibility(char_unit, false)

				return
			end
		elseif not scene_template.lobby_characters_visible then
			self:_set_character_and_outfit_visibility(char_unit, false)

			return
		end
	end

	self:_set_character_and_outfit_visibility(char_unit, true)
end

function MenuSceneManager:_set_character_and_outfit_visibility(char_unit, state)
	self:_set_unit_enabled_tree(char_unit, state)
end

function MenuSceneManager:_set_unit_enabled_tree(unit, state)
	unit:set_enabled(state)

	if state then
		unit:set_moving()
	end

	if unit:digital_gui() then
		unit:digital_gui():set_visible(state)
	end

	if unit:digital_gui_upper() then
		unit:digital_gui_upper():set_visible(state)
	end

	for _, child_unit in ipairs(unit:children()) do
		self:_set_unit_enabled_tree(child_unit, state)
	end
end

local null_vector = Vector3()
local null_rotation = Rotation()

function MenuSceneManager:clbk_weapon_base_unit_loaded(params, status, asset_type, asset_name)
	local owner = params.owner

	if not alive(owner) then
		return
	end

	local owner_weapon_data = self._weapon_units[owner:key()]

	if not owner_weapon_data or not owner_weapon_data[params.type] or owner_weapon_data[params.type].unit or owner_weapon_data[params.type].name ~= asset_name then
		return
	end

	owner_weapon_data = owner_weapon_data[params.type]
	local weapon_unit = World:spawn_unit(asset_name, null_vector, self.null_rotation)
	owner_weapon_data.unit = weapon_unit

	weapon_unit:base():set_npc(true)
	weapon_unit:base():set_factory_data(params.factory_id)
	weapon_unit:base():set_cosmetics_data(params.cosmetics)

	if params.blueprint then
		weapon_unit:base():assemble_from_blueprint(params.factory_id, params.blueprint, nil, callback(self, self, "clbk_weapon_assembly_complete", params))
	else
		weapon_unit:base():assemble(params.factory_id)
	end

	local align_name = params.type == "primary" and Idstring("a_weapon_right_front") or Idstring("a_weapon_left_front")

	owner:link(align_name, weapon_unit, weapon_unit:orientation_object():name())

	if owner == self._character_unit then
		self:_select_character_pose()
	end

	self:_chk_character_visibility(owner)
end

function MenuSceneManager:clbk_weapon_assembly_complete(params)
	local owner = params.owner

	if not alive(owner) then
		return
	end

	local owner_weapon_data = self._weapon_units[owner:key()]

	if not owner_weapon_data or not owner_weapon_data[params.type] or owner_weapon_data[params.type].assembly_complete then
		return
	end

	owner_weapon_data[params.type].assembly_complete = true

	self:_chk_character_visibility(owner)
end

function MenuSceneManager:set_character_equipped_card(unit, card)
	unit = unit or self._character_unit
	local card_unit = World:spawn_unit(Idstring("units/menu/menu_scene/infamy_card"), Vector3(0, 0, 0), Rotation(0, 0, 0))

	card_unit:damage():run_sequence_simple("enable_card_" .. (card < 10 and "0" or "") .. tostring(math.min(card, 24)))
	unit:link(Idstring("a_weapon_left_front"), card_unit, card_unit:orientation_object():name())
	self:_delete_character_weapon(unit, "secondary")

	self._card_units = self._card_units or {}
	self._card_units[unit:key()] = card_unit

	self:_select_character_pose()
end

function MenuSceneManager:_spawn_mask(mask_unit_name, as_item, pos, rot, mask_id)
	local mask_unit = World:spawn_unit(mask_unit_name, pos, rot)

	if not tweak_data.blackmarket.masks[managers.blackmarket:get_real_mask_id(mask_id)].type then
		local back_name = as_item and "units/payday2/masks/msk_fps_back_straps/msk_fps_back_straps" or "units/payday2/masks/msk_backside/msk_backside"
		local backside = World:spawn_unit(Idstring(back_name), pos, rot)

		if as_item then
			backside:anim_set_time(Idstring("mask_on"), backside:anim_length(Idstring("mask_on")))
		end

		mask_unit:link(mask_unit:orientation_object():name(), backside, backside:orientation_object():name())
	end

	return mask_unit
end

function MenuSceneManager:_delete_character_mask(owner)
	local owner_key = owner:key()
	local old_mask = self._mask_units[owner_key]

	if not old_mask then
		return
	end

	if alive(old_mask.mask_unit) then
		for _, linked_unit in ipairs(old_mask.mask_unit:children()) do
			linked_unit:unlink()
			World:delete_unit(linked_unit)
		end

		old_mask.mask_unit:unlink()
		World:delete_unit(old_mask.mask_unit)
	end

	self._mask_units[owner_key] = nil
	local unload = true

	for u_key, mask_data in pairs(self._mask_units) do
		if mask_data.mask_name == old_mask.mask_name then
			unload = false

			break
		end
	end

	if unload then
		managers.dyn_resource:unload(ids_unit, old_mask.mask_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end
end

function MenuSceneManager:_delete_character_weapon(owner, type)
	local weapons = {}
	self._weapon_units[owner:key()] = self._weapon_units[owner:key()] or {}

	if type == "all" then
		table.insert(weapons, self._weapon_units[owner:key()].primary)
		table.insert(weapons, self._weapon_units[owner:key()].secondary)

		self._weapon_units[owner:key()] = nil
	else
		table.insert(weapons, self._weapon_units[owner:key()][type])

		self._weapon_units[owner:key()][type] = nil
	end

	for _, old_weapon_data in ipairs(weapons) do
		local name = old_weapon_data.name

		if alive(old_weapon_data.unit) then
			old_weapon_data.unit:unlink()
			old_weapon_data.unit:set_slot(0)
			World:delete_unit(old_weapon_data.unit)
		end

		managers.dyn_resource:unload(ids_unit, name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	if self._card_units and self._card_units[owner:key()] and type ~= "primary" then
		local card_unit = self._card_units[owner:key()]

		if alive(card_unit) then
			card_unit:unlink()
			card_unit:set_slot(0)
			World:delete_unit(card_unit)
		end

		self._card_units[owner:key()] = nil
	end
end

function MenuSceneManager:set_main_character_outfit(outfit_string)
	local data = string.split(outfit_string, " ")

	self:set_character(data[managers.blackmarket:outfit_string_index("character")])
	self:set_character_mask(tweak_data.blackmarket.masks[data[managers.blackmarket:outfit_string_index("mask")]].unit)
end

function MenuSceneManager:on_set_preferred_character()
	self._character_unit:base():set_character_name(managers.blackmarket:get_preferred_character())

	local equipped_mask = managers.blackmarket:equipped_mask()

	if equipped_mask.mask_id then
		self:set_character_mask_by_id(equipped_mask.mask_id, equipped_mask.blueprint)
	end

	self:set_character_armor_skin(managers.blackmarket:equipped_armor_skin(), self._character_unit)

	local mask_data = self._mask_units[self._character_unit:key()]

	if mask_data then
		self:update_mask_offset(mask_data)
	end
end

function MenuSceneManager:set_character(character_name, force_recreate)
	local character_id = managers.blackmarket:get_character_id_by_character_name(character_name)
	local unit_name = tweak_data.blackmarket.characters[character_id].menu_unit
	self._player_character_name = character_name

	if force_recreate or not alive(self._character_unit) or Idstring(unit_name) ~= self._character_unit:name() then
		self:_set_player_character_unit(unit_name, self._character_unit)
	end

	self._character_unit:base():set_character_name(character_name)
	self:set_character_armor_skin(managers.blackmarket:equipped_armor_skin(), self._character_unit)
end

function MenuSceneManager:_create_light(params)
	local light = World:create_light("omni|specular")

	light:set_far_range(params.far_range or 200)
	light:set_color(params.color or Vector3())
	light:set_position(params.position or Vector3())
	light:set_enable(false)
	light:set_multiplier(0)
	light:set_specular_multiplier(params.specular_multiplier or 4)

	return light
end

function MenuSceneManager:setup_camera()
	if self._camera_values then
		return
	end

	local ref = self._bg_unit:get_object(Idstring("a_camera_reference"))
	local target_pos = Vector3(0, 0, ref:position().z)
	self._camera_values = {
		camera_pos_current = ref:position():rotate_with(Rotation(90))
	}
	self._camera_values.camera_pos_target = self._camera_values.camera_pos_current
	self._camera_values.target_pos_current = target_pos
	self._camera_values.target_pos_target = self._camera_values.target_pos_current
	self._camera_values.fov_current = self._standard_fov
	self._camera_values.fov_target = self._camera_values.fov_current
	self._camera_object = World:create_camera()

	self._camera_object:set_near_range(3)
	self._camera_object:set_far_range(250000)
	self._camera_object:set_fov(self._standard_fov)
	self._camera_object:set_rotation(self._camera_start_rot)
	self:_use_environment("standard")

	self._vp = managers.viewport:new_vp(0, 0, 1, 1, "menu_main")

	self._vp:set_width_mul_enabled()

	self._director = self._vp:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera_object, Idstring("menu"))

	self._director:set_camera(self._camera_controller)
	self._director:position_as(self._camera_object)
	self._camera_controller:set_both(self._camera_object)
	self._camera_controller:set_target(self._camera_start_rot:y() * 100 + self._camera_start_rot:x() * 6)
	self:_set_camera_position(self._camera_values.camera_pos_current)
	self:_set_target_position(self._camera_values.camera_pos_target)
	self._vp:set_camera(self._camera_object)
	self._vp:set_active(true)
	self._vp:camera():set_width_multiplier(CoreMath.width_mul(1.7777777777777777))
	self:_set_dimensions()
	self._shaker:play("breathing", 0.2)

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "_resolution_changed"))
	self._sky_rotation_angle = 0
	self._environment_modifier_id = managers.viewport:create_global_environment_modifier(sky_orientation_data_key, true, function ()
		return self:_sky_rotation_modifier()
	end)
end

function MenuSceneManager:_resolution_changed()
	self:_set_dimensions()
	managers.gui_data:layout_workspace(self._workspace)
end

function MenuSceneManager:_real_aspect_ratio()
	if SystemInfo:platform() == Idstring("WIN32") then
		return RenderSettings.aspect_ratio
	else
		local screen_res = Application:screen_resolution()
		local screen_pixel_aspect = screen_res.x / screen_res.y

		return screen_pixel_aspect
	end
end

function MenuSceneManager:_set_dimensions()
	local aspect_ratio = self:_real_aspect_ratio()
	local screen_aspect = 1.77778
	local width_mul = 1.7777777777777777
	local x = 0
	local y = 0
	local w = 1
	local h = 1

	if SystemInfo:platform() == Idstring("WIN32") then
		if aspect_ratio == 0 then
			local screen_res = Application:screen_resolution()
			aspect_ratio = screen_res.x / screen_res.y
		end

		if screen_aspect < aspect_ratio then
			width_mul = aspect_ratio
		elseif aspect_ratio < screen_aspect then
			local screen_res = Application:screen_resolution()
			local new_height = screen_res.x / width_mul

			if new_height % 2 > 0 then
				local new_width = new_height * width_mul
				width_mul = new_width / (new_height - 1)
			end

			y = (1 - aspect_ratio / width_mul) / 2
			h = aspect_ratio / width_mul
		end
	else
		y = (1 - aspect_ratio / width_mul) / 2
		h = aspect_ratio / width_mul
	end

	self._vp._vp:set_dimensions(x, y, w, h)
	self._vp:camera():set_width_multiplier(CoreMath.width_mul(width_mul))
end

function MenuSceneManager:_sky_rotation_modifier()
	return self._sky_rotation_angle
end

function MenuSceneManager:_set_sky_rotation_angle(angle)
	self._sky_rotation_angle = angle
end

function MenuSceneManager:add_transition_done_callback(callback_func)
	self._transition_done_callback_handler:add(callback_func)
end

function MenuSceneManager:remove_transition_done_callback(callback_func)
	self._transition_done_callback_handler:remove(callback_func)
end

function MenuSceneManager:_set_camera_position(pos)
	self._camera_controller:set_camera(pos)
end

function MenuSceneManager:_set_target_position(pos)
	self._camera_controller:set_target(pos)
end

function MenuSceneManager:set_scene_template(template, data, custom_name, skip_transition)
	if not skip_transition and (self._current_scene_template == template or self._current_scene_template == custom_name) then
		return
	end

	local template_data = nil

	if not skip_transition then
		managers.menu_component:play_transition()

		self._fov_mod = 0

		if self._camera_object then
			self._camera_object:set_fov(self._current_fov + (self._fov_mod or 0))
		end

		template_data = data or self._scene_templates[template]
		self._current_scene_template = custom_name or template
		self._character_values = self._character_values or {}

		if template_data.character_pos then
			self._character_values.pos_current = self._character_values.pos_current or Vector3()

			mvector3.set(self._character_values.pos_current, template_data.character_pos)
		elseif self._character_values.pos_target then
			self._character_values.pos_current = self._character_values.pos_current or Vector3()

			mvector3.set(self._character_values.pos_current, self._character_values.pos_target)
		end

		local set_character_position = false

		if template_data.character_pos then
			self._character_values.pos_target = self._character_values.pos_target or Vector3()

			mvector3.set(self._character_values.pos_target, template_data.character_pos)

			set_character_position = true
		elseif self._character_values.pos_current then
			self._character_values.pos_target = self._character_values.pos_target or Vector3()

			mvector3.set(self._character_values.pos_target, self._character_values.pos_current)

			set_character_position = true
		end

		if set_character_position and self._character_values.pos_target then
			self._character_unit:set_position(self._character_values.pos_target)
		end

		if template_data and template_data.recreate_character and self._player_character_name then
			self:set_character(self._player_character_name, true)
		end

		self:_chk_character_visibility(self._character_unit)

		if self._lobby_characters then
			for _, unit in pairs(self._lobby_characters) do
				self:_chk_character_visibility(unit)
			end
		end

		if self._henchmen_characters then
			for _, unit in pairs(self._henchmen_characters) do
				self:_chk_character_visibility(unit)
			end
		end

		self:_use_environment(template_data.environment or "standard")
		self:post_ambience_event(template_data.ambience_event or "menu_main_ambience")

		self._camera_values.camera_pos_current = self._camera_values.camera_pos_target
		self._camera_values.target_pos_current = self._camera_values.target_pos_target
		self._camera_values.fov_current = self._camera_values.fov_target

		if self._transition_time then
			self:dispatch_transition_done()
		end

		self._transition_time = 1
		self._camera_values.camera_pos_target = template_data.camera_pos or self._camera_values.camera_pos_current
		self._camera_values.target_pos_target = template_data.target_pos or self._camera_values.target_pos_current
		self._camera_values.fov_target = template_data.fov or self._standard_fov

		self:_release_item_grab()
		self:_release_character_grab()

		self._use_item_grab = template_data.use_item_grab
		self._use_character_grab = template_data.use_character_grab
		self._use_character_grab2 = template_data.use_character_grab2
		self._use_character_pan = template_data.use_character_pan
		self._disable_rotate = template_data.disable_rotate or false
		self._disable_item_updates = template_data.disable_item_updates or false
		self._can_change_fov = template_data.can_change_fov or false
		self._can_move_item = template_data.can_move_item or false
		self._change_fov_sensitivity = template_data.change_fov_sensitivity or 1
		self._characters_deployable_visible = template_data.characters_deployable_visible or false

		self:set_character_deployable(managers.blackmarket:equipped_deployable(), false, 0)

		if template_data.remove_infamy_card and self._card_units and self._card_units[self._character_unit:key()] then
			local secondary = managers.blackmarket:equipped_secondary()

			if secondary then
				self:set_character_equipped_weapon(nil, secondary.factory_id, secondary.blueprint, "secondary", secondary.cosmetics)
			end
		end

		if not _G.IS_VR then
			self:_select_character_pose()
		end

		if alive(self._menu_logo) then
			self._menu_logo:set_visible(not template_data.hide_menu_logo)
		end
	end

	if template_data and template_data.upgrade_object then
		self._temp_upgrade_object = template_data.upgrade_object

		self:_set_item_offset(template_data.upgrade_object:oobb())
	elseif self._use_item_grab and self._item_unit then
		if self._item_unit.unit then
			managers.menu_scene:_set_weapon_upgrades(self._current_weapon_id)
			self:_set_item_offset(self._current_item_oobb_object:oobb())
		else
			self._item_unit.scene_template = {
				template = template,
				data = data,
				custom_name = custom_name
			}
		end
	end

	if not skip_transition then
		local fade_lights = {}

		for _, light in ipairs(self._fade_down_lights) do
			if light:multiplier() ~= 0 and template_data.lights and not table.contains(template_data.lights, light) then
				table.insert(fade_lights, light)
			end
		end

		for _, light in ipairs(self._active_lights) do
			table.insert(fade_lights, light)
		end

		self._fade_down_lights = fade_lights
		self._active_lights = {}

		if template_data.lights then
			for _, light in ipairs(template_data.lights) do
				light:set_enable(true)
				table.insert(self._active_lights, light)
			end
		end
	end

	if template_data then
		if template_data.use_workbench_room then
			self:spawn_workbench_room()
		else
			self:delete_workbench_room()
		end
	end

	managers.network.account:inventory_load()
end

function MenuSceneManager:dispatch_transition_done()
	self._transition_done_callback_handler:dispatch()
	self._transition_done_callback_handler:clear()
end

function MenuSceneManager:clicked_blackmarket_item()
	managers.menu_scene:set_scene_template("blackmarket_item")
end

function MenuSceneManager:clicked_masks()
	managers.menu_scene:set_scene_template(nil, {
		use_character_grab = true,
		fov = 50,
		camera_pos = Vector3(-24.0303, 63.8565, 1.49128),
		target_pos = Vector3(-24.0303, 63.8565, 2.49128) + Vector3(0.5091, 0.852881, 0.115804) * 100,
		lights = self._scene_templates.character_customization.lights
	}, "mask")
end

function MenuSceneManager:clicked_armor()
	managers.menu_scene:set_scene_template(nil, {
		use_character_grab = true,
		fov = 50,
		camera_pos = Vector3(-44.5502, 18.1584, -40.7396),
		target_pos = Vector3(-44.5502, 18.1584, -40.7396) + Vector3(0.5091, 0.852881, 0.115804) * 100,
		lights = self._scene_templates.character_customization.lights
	}, "armor")
end

function MenuSceneManager:clicked_upper_body()
	managers.menu_scene:set_scene_template(nil, {
		use_character_grab = true,
		fov = 50,
		camera_pos = Vector3(-75.5435, -27.7427, -42.5198),
		target_pos = Vector3(-75.5435, -27.7427, -42.5198) + Vector3(0.525678, 0.845068, 0.0975835) * 100,
		lights = self._scene_templates.character_customization.lights
	}, "upper_body")
end

function MenuSceneManager:clicked_lower_body()
	managers.menu_scene:set_scene_template(nil, {
		use_character_grab = true,
		fov = 50,
		camera_pos = Vector3(-87.9057, -49.0395, -106.341),
		target_pos = Vector3(-87.9057, -49.0395, -106.341) + Vector3(0.548727, 0.83587, 0.0148322) * 100,
		lights = self._scene_templates.character_customization.lights
	}, "lower_body")
end

function MenuSceneManager:clicked_customize_character_category()
	self:set_scene_template("character_customization")
end

function MenuSceneManager:clicked_weapon_upgrade_type(type)
	managers.menu_scene:_set_weapon_upgrades(self._current_weapon_id)

	local fov = 5 + math.max(100 - self._item_max_size, 0) / 10

	if type == "scopes" then
		local obj = self._item_unit.unit:get_object(Idstring("g_sight"))

		managers.menu_scene:set_scene_template(nil, {
			use_item_grab = true,
			camera_pos = self._scene_templates.blackmarket.camera_pos,
			target_pos = self._scene_templates.blackmarket.target_pos + Vector3(0, 5, 1),
			fov = fov,
			upgrade_object = obj,
			lights = self._scene_templates.blackmarket.lights
		}, type)
	elseif type == "barrels" then
		local obj = self._item_unit.unit:get_object(Idstring("fire"))

		managers.menu_scene:set_scene_template(nil, {
			use_item_grab = true,
			camera_pos = self._scene_templates.blackmarket.camera_pos,
			target_pos = self._scene_templates.blackmarket.target_pos + Vector3(0, 5, 1),
			fov = fov,
			upgrade_object = obj,
			lights = self._scene_templates.blackmarket.lights
		}, type)
	elseif type == "grips" then
		local obj = self._item_unit.unit:get_object(Idstring("g_mag"))

		managers.menu_scene:set_scene_template(nil, {
			use_item_grab = true,
			camera_pos = self._scene_templates.blackmarket.camera_pos,
			target_pos = self._scene_templates.blackmarket.target_pos + Vector3(0, 5, 1),
			fov = fov,
			upgrade_object = obj,
			lights = self._scene_templates.blackmarket.lights
		}, type)
	end
end

function MenuSceneManager:remove_item()
	if self._item_unit then
		if self._item_unit.unit then
			if self._item_unit.backstrap_unit_name then
				for _, linked_unit in ipairs(self._item_unit.unit:children()) do
					local linked_unit_name = linked_unit:name()

					linked_unit:unlink()
					World:delete_unit(linked_unit)

					if managers.dyn_resource:has_resource(ids_unit, linked_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
						managers.dyn_resource:unload(ids_unit, linked_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
					end
				end
			end

			if alive(self._item_unit.second_unit) then
				World:delete_unit(self._item_unit.second_unit)
			end

			World:delete_unit(self._item_unit.unit)
		end

		if managers.dyn_resource:has_resource(ids_unit, self._item_unit.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
			managers.dyn_resource:unload(ids_unit, self._item_unit.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end

		self._item_unit = nil
	end
end

function MenuSceneManager:spawn_infamy_card(rank)
	self:add_one_frame_delayed_clbk(callback(self, self, "_spawn_infamy_card", rank - 1))
end

function MenuSceneManager:infamy_card_shown()
	return self._infamy_card_shown or false
end

function MenuSceneManager:destroy_infamy_card()
	self._disable_rotate = nil
	self._disable_dragging = nil
	self._infamy_card_shown = nil

	self:remove_item()
end

function MenuSceneManager:_spawn_infamy_card(card)
	self._item_pos = Vector3(0, 0, 0)
	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_zero(self._item_rot)
	mrotation.set_zero(self._item_rot_mod)

	self._disable_rotate = true
	self._disable_dragging = true
	self._infamy_card_shown = true
	local unit = World:spawn_unit(Idstring("units/menu/menu_scene/infamy_card"), self._item_pos, self._item_rot)

	unit:damage():run_sequence_simple("enable_card_" .. (card < 10 and "0" or "") .. tostring(math.min(card, 24)))
	unit:damage():run_sequence_simple("card_flip_01")

	local anim_time = 2.666 + unit:anim_length(Idstring("card"))

	self:add_callback(callback(self, self, "_infamy_enable_dragging"), anim_time)
	self:_set_item_unit(unit)
end

function MenuSceneManager:_infamy_enable_dragging()
	self._disable_dragging = nil
end

function MenuSceneManager:spawn_grenade(grenade_id)
	local grenade = tweak_data.blackmarket.projectiles[grenade_id]

	if not grenade.unit_dummy then
		return
	end

	self:add_one_frame_delayed_clbk(callback(self, self, "spawn_grenade_clbk", grenade_id))
end

function MenuSceneManager:spawn_grenade_clbk(grenade_id)
	local grenade = tweak_data.blackmarket.projectiles[grenade_id]
	local grenade_unit = grenade.unit_dummy

	if not grenade_unit then
		return
	end

	local ids_unit_name = Idstring(grenade_unit)

	managers.dyn_resource:load(Idstring("unit"), ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._item_pos = Vector3(0, 0, 0)

	mrotation.set_zero(self._item_rot_mod)

	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_zero(self._item_rot)

	local new_unit = World:spawn_unit(ids_unit_name, self._item_pos, self._item_rot)

	self:_set_item_unit(new_unit, nil, nil, nil, nil, {
		id = grenade_id
	})
	mrotation.set_yaw_pitch_roll(self._item_rot_mod, -90, 0, 0)

	return new_unit
end

function MenuSceneManager:spawn_melee_weapon(melee_weapon_id)
	local melee_weapon = tweak_data.blackmarket.melee_weapons[melee_weapon_id]

	if not melee_weapon.unit then
		return
	end

	self:add_one_frame_delayed_clbk(callback(self, self, "spawn_melee_weapon_clbk", melee_weapon_id))
end

function MenuSceneManager:spawn_deployable(deployable_id)
	local deployable = tweak_data.equipments[deployable_id]

	if not deployable.dummy_unit then
		return
	end

	self:add_one_frame_delayed_clbk(callback(self, self, "spawn_grenade_clbk", deployable.dummy_unit))
end

function MenuSceneManager:spawn_melee_weapon_clbk(melee_weapon_id)
	local melee_weapon = tweak_data.blackmarket.melee_weapons[melee_weapon_id]

	if not melee_weapon.unit then
		return
	end

	local melee_weapon_unit = melee_weapon.unit
	local ids_unit_name = Idstring(melee_weapon_unit)

	managers.dyn_resource:load(Idstring("unit"), ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._item_pos = Vector3(0, 0, 0)

	mrotation.set_zero(self._item_rot_mod)

	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_zero(self._item_rot)

	local new_unit = World:spawn_unit(ids_unit_name, self._item_pos, self._item_rot)

	self:_set_item_unit(new_unit, nil, nil, nil, nil, {
		id = melee_weapon_id
	})

	if alive(new_unit) and new_unit:damage() and new_unit:damage():has_sequence("menu") then
		new_unit:damage():run_sequence_simple("menu")
	end

	mrotation.set_yaw_pitch_roll(self._item_rot_mod, -90, 0, 0)

	local anim = melee_weapon.menu_scene_anim

	if anim then
		local anim_ids = Idstring(anim)
		local anim_length = new_unit:anim_length(anim_ids)
		local anim_params = melee_weapon.menu_scene_params or {}

		if anim_params.loop then
			new_unit:anim_play_loop(anim_ids, 0, anim_length, anim_params.speed or 1)
		else
			new_unit:anim_play(anim_ids, anim_params.speed or 1)
		end

		if anim_params.start_time then
			local start_time = anim_params.start_time

			if start_time == -1 then
				start_time = anim_length
			end

			new_unit:anim_set_time(start_time)
		end

		new_unit:set_visible(false)

		local anim_time = 0.03333333333333333

		self:add_callback(callback(self, self, "_show_item_unit"), anim_time)
	end

	return new_unit
end

function MenuSceneManager:destroy_melee_weapon()
end

function MenuSceneManager:_show_item_unit()
	if not self._item_unit or not alive(self._item_unit.unit) then
		return
	end

	self._item_unit.unit:set_visible(true)
end

function MenuSceneManager:spawn_item_weapon(factory_id, blueprint, cosmetics, texture_switches, custom_data)
	local factory_weapon = tweak_data.weapon.factory[factory_id]
	local ids_unit_name = Idstring(factory_weapon.unit)

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
		print("[MenuSceneManager:spawn_item_weapon]", "Weapon unit is not loaded, force loading it.", factory_weapon.unit)
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	self._item_pos = custom_data and custom_data.item_pos or Vector3(0, 0, 200)

	mrotation.set_zero(self._item_rot_mod)

	self._item_yaw = custom_data and custom_data.item_yaw or 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_zero(self._item_rot)

	local function spawn_weapon(pos, rot)
		local w_unit = World:spawn_unit(ids_unit_name, pos, rot)

		w_unit:base():set_factory_data(factory_id)
		w_unit:base():set_cosmetics_data(cosmetics)
		w_unit:base():set_texture_switches(texture_switches)

		if blueprint then
			w_unit:base():assemble_from_blueprint(factory_id, blueprint, true)
		else
			w_unit:base():assemble(factory_id, true)
		end

		return w_unit
	end

	local new_unit = spawn_weapon(self._item_pos, self._item_rot)
	local second_unit = nil

	if new_unit:base().AKIMBO then
		second_unit = spawn_weapon(self._item_pos + self._item_rot:x() * -10 + self._item_rot:z() * -7 + self._item_rot:y() * -5, self._item_rot * Rotation(0, 8, -10))

		new_unit:link(new_unit:orientation_object():name(), second_unit)
		second_unit:base():tweak_data_anim_stop("unequip")
		second_unit:base():tweak_data_anim_play("equip")
	end

	new_unit:base():tweak_data_anim_stop("unequip")
	new_unit:base():tweak_data_anim_play("equip")

	custom_data = custom_data or {}
	custom_data.id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)

	self:_set_item_unit(new_unit, nil, nil, nil, second_unit, custom_data)
	mrotation.set_yaw_pitch_roll(self._item_rot_mod, 90, 0, 0)

	return new_unit
end

function MenuSceneManager:update_weapon_texture_switches(factory_id, texture_switches)
	local unit = self._item_unit and self._item_unit.unit

	if alive(unit) and unit:base() and unit:base()._factory_id == factory_id then
		unit:base():set_texture_switches(texture_switches)
		unit:base():apply_texture_switches()
	end
end

function MenuSceneManager:_set_item_unit(unit, oobb_object, max_mod, type, second_unit, custom_data)
	self:remove_item()

	self._current_weapon_id = nil
	local scene_template = custom_data and custom_data.scene_template and self._scene_templates[custom_data.scene_template] or type == "mask" and self._scene_templates.blackmarket_mask or self._scene_templates.blackmarket_item
	self._item_pos = custom_data and custom_data.item_pos or Vector3(0, 0, 200)
	local item_yaw = self._item_yaw
	local item_pitch = self._item_pitch
	local item_roll = self._item_roll
	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_yaw_pitch_roll(self._item_rot, self._item_yaw, self._item_pitch, self._item_roll)
	mrotation.multiply(self._item_rot, self._item_rot_mod)

	self._item_unit = {
		unit = unit,
		name = unit:name(),
		second_unit = second_unit
	}

	unit:set_position(self._item_pos)
	unit:set_rotation(self._item_rot)
	unit:set_moving(2)

	local oobb = oobb_object and unit:get_object(Idstring(oobb_object)):oobb() or unit:oobb()
	self._current_item_oobb_object = oobb_object and unit:get_object(Idstring(oobb_object)) or unit
	local oobb_size = oobb:size()
	local max = math.max(oobb_size.x, oobb_size.y)
	max = math.max(max, oobb_size.z)
	local offset_dir = scene_template.target_pos - scene_template.camera_pos:normalized()
	self._item_max_size = math.max(max * (max_mod or 1), 20)
	local pos = Vector3(self._item_pos.x, self._item_pos.y, self._item_pos.z)
	pos = pos - offset_dir * (150 - self._item_max_size)
	self._item_rot_pos = pos

	self:_set_item_offset(oobb, true)

	self._item_yaw = item_yaw or 0
	self._item_pitch = item_pitch or 0
	self._item_roll = item_roll or 0

	mrotation.set_yaw_pitch_roll(self._item_rot, self._item_yaw, self._item_pitch, self._item_roll)
	mrotation.multiply(self._item_rot, self._item_rot_mod)
end

function MenuSceneManager:_spawn_item(unit_name, oobb_object, max_mod, type, mask_id)
	self._current_weapon_id = nil
	self._item_pos = Vector3(0, 0, 0)

	mrotation.set_zero(self._item_rot_mod)

	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_zero(self._item_rot)

	local unit = nil

	if type == "mask" then
		unit = self:_spawn_mask(unit_name, true, self._item_pos, self._item_rot, mask_id)
	else
		unit = World:spawn_unit(Idstring(unit_name), self._item_pos, self._item_rot)
	end

	self:_set_item_unit(unit, oobb_object, max_mod, type, nil, {
		id = mask_id
	})
end

function MenuSceneManager:_set_weapon_upgrades(weapon_id)
	if not weapon_id or not tweak_data.upgrades.visual.upgrade[weapon_id] then
		return
	end

	for obj, visible in pairs(tweak_data.upgrades.visual.upgrade[weapon_id].objs) do
		local object = self._item_unit.unit:get_object(Idstring(obj))

		if object then
			object:set_visibility(visible)
		end
	end

	local weapon_upgrades = Global.blackmarket_manager.weapon_upgrades[weapon_id]

	if not weapon_upgrades then
		return
	end

	for name, upgrade_data in pairs(weapon_upgrades) do
		if upgrade_data.attached then
			local visual_upgrade = tweak_data.weapon_upgrades.upgrades[name].visual_upgrade
			local vis_upgrade = tweak_data.upgrades.visual.upgrade[visual_upgrade]
			local objs = vis_upgrade and vis_upgrade.objs

			if objs then
				for obj, visible in pairs(objs) do
					self._item_unit.unit:get_object(Idstring(obj)):set_visibility(visible)
				end
			end
		end
	end
end

function MenuSceneManager:_set_item_offset(oobb, instant)
	local center = oobb:center()

	if self._item_unit.second_unit then
		center = math.lerp(self._item_unit.second_unit:oobb():center(), oobb:center(), 0.5)
	end

	local offset = self._item_unit.unit:orientation_object():position() - center:rotate_with(self._item_rot:inverse())
	self._weapon_transition_time = self._weapon_transition_time and (self._weapon_transition_time == 1 and 0 or 1 - self._weapon_transition_time) or 0

	if instant then
		self._weapon_transition_time = 1
	end

	self._item_offset_current = self._item_offset_target or offset
	self._item_offset_target = offset
	self._item_offset = self._item_offset or offset
end

function MenuSceneManager:view_weapon_upgrade(weapon_id, visual_upgrade)
	local vis_upgrade = tweak_data.upgrades.visual.upgrade[visual_upgrade]
	local objs = vis_upgrade and vis_upgrade.objs

	if objs then
		for obj, visible in pairs(objs) do
			self._item_unit.unit:get_object(Idstring(obj)):set_visibility(visible)
		end
	end
end

function MenuSceneManager:spawn_mask(mask_id, blueprint)
	local mask_unit_name_str = managers.blackmarket:mask_unit_name_by_mask_id(mask_id)
	local mask_unit_name = Idstring(mask_unit_name_str)

	self:remove_item()

	local backstrap_unit_name = Idstring("units/payday2/masks/msk_fps_back_straps/msk_fps_back_straps")
	self._item_unit = {
		mask_loaded = false,
		unit = false,
		backstrap_loaded = false,
		name = mask_unit_name,
		backstrap_unit_name = backstrap_unit_name,
		mask_id = mask_id,
		blueprint = blueprint
	}

	managers.dyn_resource:load(ids_unit, mask_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_item_unit_loaded"))
	managers.dyn_resource:load(ids_unit, backstrap_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_item_unit_loaded"))
end

function MenuSceneManager:clbk_mask_item_unit_loaded(status, asset_type, asset_name)
	if not self._item_unit then
		return
	end

	local is_the_mask = asset_name == self._item_unit.name

	if is_the_mask then
		if self._item_unit.mask_loaded then
			return
		end

		self._item_unit.mask_loaded = true
	elseif self._item_unit.backstrap_loaded or asset_name ~= self._item_unit.backstrap_unit_name then
		return
	else
		self._item_unit.backstrap_loaded = true
	end

	if not self._item_unit.mask_loaded or not self._item_unit.backstrap_loaded then
		return
	end

	local item = self._item_unit
	self._item_unit = nil

	self:_spawn_item(item.name, nil, nil, "mask", item.mask_id)

	local new_unit = self._item_unit.unit
	self._item_unit = item
	self._item_unit.unit = new_unit

	new_unit:set_enabled(false)
	new_unit:set_visible(false)

	for _, linked_unit in ipairs(new_unit:children()) do
		linked_unit:set_visible(false)
	end

	local default_blueprint = managers.blackmarket:get_mask_default_blueprint(self._item_unit.mask_id)

	self._item_unit.unit:base():apply_blueprint(self._item_unit.blueprint or default_blueprint, callback(self, self, "clbk_mask_item_unit_assembled"))
	mrotation.set_yaw_pitch_roll(self._item_rot_mod, 0, 90, 0)

	if self._item_unit.scene_template then
		local scene_template = self._item_unit.scene_template
		self._item_unit.scene_template = nil

		self:set_scene_template(scene_template.template, scene_template.data, scene_template.custom_name, true)
	end
end

function MenuSceneManager:clbk_mask_item_unit_assembled()
	if not self._item_unit or not alive(self._item_unit.unit) then
		return
	end

	self._item_unit.unit:set_enabled(true)
	self._item_unit.unit:set_moving()
	self:add_one_frame_delayed_clbk(function ()
		self._item_unit.unit:set_visible(true)

		for _, linked_unit in ipairs(self._item_unit.unit:children()) do
			linked_unit:set_visible(true)
		end
	end)
end

function MenuSceneManager:spawn_or_update_mask(mask_id, blueprint)
	if self._item_unit then
		self:update_mask(blueprint)
	else
		self:spawn_mask(mask_id, blueprint)
	end
end

function MenuSceneManager:update_mask(blueprint)
	if self._item_unit and blueprint then
		if self._item_unit.unit then
			self._item_unit.unit:base():apply_blueprint(blueprint, function ()
			end)
		else
			self._item_unit.blueprint = blueprint
		end
	end
end

function MenuSceneManager:spawn_armor(armor_id)
	self:remove_item()

	if not armor_id then
		return
	end

	self:_spawn_item("units/menu/menu_character/menu_character_test", nil)
end

function MenuSceneManager:character_screen_position(peer_id)
	local unit = self._lobby_characters[peer_id]

	if unit and alive(unit) then
		local is_me = peer_id == managers.network:session():local_peer():id()
		local peer_3_x_offset = 0

		if peer_id == 3 then
			if is_me then
				peer_3_x_offset = -20
			else
				peer_3_x_offset = -40
			end
		end

		local peer_y_offset = 0

		if peer_id == 2 then
			if is_me then
				peer_y_offset = -3
			else
				peer_y_offset = 0
			end
		elseif peer_id == 3 then
			if is_me then
				peer_y_offset = -7
			else
				peer_y_offset = 0
			end
		elseif peer_id == 4 then
			if is_me then
				peer_y_offset = 5
			else
				peer_y_offset = 0
			end
		end

		local spine_pos = unit:get_object(Idstring("Spine")):position() + Vector3(peer_3_x_offset, 0, -5 + 15 * (peer_id % 4) + peer_y_offset)

		return self._workspace:world_to_screen(self._camera_object, spine_pos)
	end
end

function MenuSceneManager:_release_item_grab()
	self._item_grabbed = false
end

function MenuSceneManager:_release_item_move_grab()
	self._item_move_grabbed = false
end

function MenuSceneManager:_release_character_grab()
	self._character_grabbed = false
end

function MenuSceneManager:controller_move(x, y)
	if self._item_unit and alive(self._item_unit.unit) then
		local diff = -y * 90
		self._item_yaw = (self._item_yaw + x * 75) % 360
		local yaw_sin = math.sin(self._item_yaw)
		local yaw_cos = math.cos(self._item_yaw)
		local treshhold = math.sin(45)

		if yaw_cos > -treshhold and yaw_cos < treshhold then
			-- Nothing
		else
			self._item_pitch = math.clamp(self._item_pitch + diff * yaw_cos, -30, 30)
		end

		if yaw_sin > -treshhold and yaw_sin < treshhold then
			-- Nothing
		else
			self._item_roll = math.clamp(self._item_roll - diff * yaw_sin, -30, 30)
		end

		mrotation.set_yaw_pitch_roll(self._item_rot_temp, self._item_yaw, self._item_pitch, self._item_roll)
		mrotation.set_zero(self._item_rot)
		mrotation.multiply(self._item_rot, self._camera_object:rotation())
		mrotation.multiply(self._item_rot, self._item_rot_temp)
		mrotation.multiply(self._item_rot, self._item_rot_mod)
		self._item_unit.unit:set_rotation(self._item_rot)

		local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)

		self._item_unit.unit:set_position(new_pos)
		self._item_unit.unit:set_moving(2)
	end

	self._item_grabbed = true
end

function MenuSceneManager:stop_controller_move()
	self._item_grabbed = false
end

function MenuSceneManager:controller_zoom(x, y)
	self:change_fov("out", y * 20)

	if (self._use_character_grab or self._use_character_grab2) and alive(self._character_unit) then
		self._character_yaw = (self._character_yaw + x * 95) % 360

		self._character_unit:set_rotation(Rotation(self._character_yaw, self._character_pitch))

		self._character_grabbed = true
	end
end

function MenuSceneManager:stop_controller_zoom()
	self._character_grabbed = false
end

local target_pos_vector = Vector3()

function MenuSceneManager:change_fov(zoom, amount)
	if self._can_change_fov then
		if zoom == "in" then
			self._fov_mod = math.clamp((self._fov_mod or 0) + (amount or 0.45) * (self._change_fov_sensitivity or 1), tweak_data.gui.mod_preview_min_fov, tweak_data.gui.mod_preview_max_fov)
		elseif zoom == "out" then
			self._fov_mod = math.clamp((self._fov_mod or 0) - (amount or 0.45) * (self._change_fov_sensitivity or 1), tweak_data.gui.mod_preview_min_fov, tweak_data.gui.mod_preview_max_fov)
		end

		if self._current_scene_template and self._scene_templates[self._current_scene_template] and self._scene_templates[self._current_scene_template].item_pos then
			mvector3.lerp(target_pos_vector, self._camera_values.target_pos_target, self._scene_templates[self._current_scene_template].item_pos, math.max(-self._fov_mod / 20, 0))
			self:_set_target_position(target_pos_vector)
		end
	end
end

function MenuSceneManager:mouse_pressed(o, button, x, y)
	if managers.menu_component:input_focus() == true or managers.menu_component:input_focus() == 1 then
		return
	end

	if button == Idstring("mouse wheel down") then
		self:change_fov("in")
	elseif button == Idstring("mouse wheel up") then
		self:change_fov("out")
	end

	if button == Idstring("0") then
		local pos = self._workspace:screen_to_world(self._camera_object, Vector3(x, y, 0))
		local to = self._workspace:screen_to_world(self._camera_object, Vector3(x, y, 1000))
		local data = World:raycast("ray", pos, to, "slot_mask", 16)

		if data and data.unit then
			local slot = nil

			for i, unit in ipairs(self._lobby_characters) do
				if unit == data.unit and unit:visible() then
					slot = i
				end
			end

			if slot then
				if self._current_profile_slot == slot then
					managers.menu_component:close_lobby_profile_gui()

					self._current_profile_slot = 0
				else
					local pos = data.unit:get_object(Idstring("Spine")):position()
					pos = self._workspace:world_to_screen(self._camera_object, pos)
					self._current_profile_slot = slot
				end
			end
		end

		if self._use_character_grab and self._character_grab:inside(x, y) then
			self._character_grabbed = true
			self._character_grabbed_current_x = x
			self._character_grabbed_current_y = y

			return true
		end

		if self._use_character_grab2 and self._character_grab2:inside(x, y) then
			self._character_grabbed = true
			self._character_grabbed_current_x = x
			self._character_grabbed_current_y = y

			return true
		end
	end

	if not self._use_item_grab or self._disable_dragging then
		return
	end

	if button == Idstring("0") then
		if self._item_grab:inside(x, y) then
			self._item_grabbed = true
			self._item_grabbed_current_x = x
			self._item_grabbed_current_y = y

			return false
		end
	elseif self._can_move_item and button == Idstring("1") and self._item_grab:inside(x, y) then
		self._item_move_grabbed = true
		self._item_move_grabbed_current_x = x
		self._item_move_grabbed_current_y = y

		return false
	end
end

function MenuSceneManager:mouse_released(o, button, x, y)
	if button == Idstring("0") then
		self:_release_item_grab()
		self:_release_character_grab()
	elseif button == Idstring("1") then
		self:_release_item_move_grab()
	end
end

function MenuSceneManager:mouse_moved(o, x, y)
	if managers.menu_component:input_focus() == true or managers.menu_component:input_focus() == 1 then
		return false, "arrow"
	end

	if self._character_grabbed then
		self._character_yaw = self._character_yaw + (x - self._character_grabbed_current_x) / 4

		if self._use_character_pan and self._character_values and self._scene_templates and self._scene_templates[self._current_scene_template] then
			local new_z = mvector3.z(self._character_values.pos_target) - (y - self._character_grabbed_current_y) / 12
			local default_z = mvector3.z(self._scene_templates and self._scene_templates[self._current_scene_template].character_pos or self._character_values.pos_current)
			new_z = math.clamp(new_z, default_z - 20, default_z + 10)

			mvector3.set_z(self._character_values.pos_target, new_z)
		end

		self._character_unit:set_rotation(Rotation(self._character_yaw, self._character_pitch))

		self._character_grabbed_current_x = x
		self._character_grabbed_current_y = y

		return true, "grab"
	end

	if self._item_grabbed then
		if self._item_unit and alive(self._item_unit.unit) then
			local diff = (y - self._item_grabbed_current_y) / 4
			self._item_yaw = (self._item_yaw + (x - self._item_grabbed_current_x) / 4) % 360
			local yaw_sin = math.sin(self._item_yaw)
			local yaw_cos = math.cos(self._item_yaw)
			local treshhold = math.sin(45)

			if yaw_cos <= -treshhold or yaw_cos >= treshhold then
				self._item_pitch = math.clamp(self._item_pitch + diff * yaw_cos, -30, 30)
			end

			if yaw_sin <= -treshhold or yaw_sin >= treshhold then
				self._item_roll = math.clamp(self._item_roll - diff * yaw_sin, -30, 30)
			end

			mrotation.set_yaw_pitch_roll(self._item_rot_temp, self._item_yaw, self._item_pitch, self._item_roll)
			mrotation.set_zero(self._item_rot)
			mrotation.multiply(self._item_rot, self._camera_object:rotation())
			mrotation.multiply(self._item_rot, self._item_rot_temp)
			mrotation.multiply(self._item_rot, self._item_rot_mod)
			self._item_unit.unit:set_rotation(self._item_rot)

			local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)

			self._item_unit.unit:set_position(new_pos)
			self._item_unit.unit:set_moving(2)
		end

		if alive(self._economy_character) then
			local diff = (x - self._item_grabbed_current_x) / 4

			if diff ~= 0 then
				self._economy_character:rotate_with(Rotation(Vector3(0, 0, 1), diff))
			end
		end

		self._item_grabbed_current_x = x
		self._item_grabbed_current_y = y

		return true, "grab"
	elseif self._item_move_grabbed and self._item_unit and alive(self._item_unit.unit) then
		local diff_x = (x - self._item_move_grabbed_current_x) / 10
		local diff_y = (y - self._item_move_grabbed_current_y) / 10
		local move_v = Vector3(diff_x, 0, -diff_y):rotate_with(self._camera_object:rotation())

		mvector3.add(self._item_rot_pos, move_v)

		local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)

		self._item_unit.unit:set_position(new_pos)
		self._item_unit.unit:set_moving(2)

		self._item_move_grabbed_current_x = x
		self._item_move_grabbed_current_y = y

		return true, "grab"
	end

	if self._use_item_grab and self._item_grab:inside(x, y) then
		return true, "hand"
	end

	if self._use_character_grab and self._character_grab:inside(x, y) then
		return true, "hand"
	end

	if self._use_character_grab2 and self._character_grab2:inside(x, y) then
		return true, "hand"
	end
end

function MenuSceneManager:get_crafting_custom_data()
	return {
		scene_template = "blackmarket_crafting",
		item_yaw = self._current_scene_template == "blackmarket_crafting" and self._item_yaw,
		item_pos = self._scene_templates.blackmarket_crafting.item_pos
	}
end

function MenuSceneManager:get_screenshot_custom_data()
	return {
		item_yaw = 0,
		scene_template = "blackmarket_screenshot",
		item_pos = self._scene_templates.blackmarket_screenshot.item_pos
	}
end

function MenuSceneManager:workbench_room_name()
	return Idstring("units/pd2_dlc_shiny/menu_showcase/menu_showcase")
end

function MenuSceneManager:delete_workbench_room()
	if alive(self._workbench_room) then
		local old_name = self._workbench_room:name()

		World:delete_unit(self._workbench_room)

		self._workbench_room = nil

		if self._workbench_force_loaded then
			managers.dyn_resource:unload(ids_unit, old_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

			self._workbench_force_loaded = nil
		end
	end
end

function MenuSceneManager:spawn_workbench_room()
	self:delete_workbench_room()

	local ids_unit_workbench_room_name = self:workbench_room_name()

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_workbench_room_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
		print("[MenuSceneManager:spawn_workbench_room]", "workbench room unit is not loaded, force loading it.")
		managers.dyn_resource:load(Idstring("unit"), ids_unit_workbench_room_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._workbench_force_loaded = true
	end

	local pos = self._scene_templates.blackmarket_crafting.camera_pos
	self._workbench_room = World:spawn_unit(ids_unit_workbench_room_name, pos)
end

function MenuSceneManager:pre_unload()
	self._weapon_names = {}

	for _, weapon_units in pairs(self._weapon_units) do
		for _, weapon_data in pairs(weapon_units) do
			table.insert(self._weapon_names, weapon_data.name)

			if weapon_data.unit then
				World:delete_unit(weapon_data.unit)
			end
		end
	end

	for owner_key, mask_data in pairs(self._mask_units) do
		if mask_data.mask_unit then
			World:delete_unit(mask_data.mask_unit)

			mask_data.mask_unit = nil
			mask_data.ready = nil
		end
	end
end

function MenuSceneManager:unload()
	local unloaded_masks = {}

	for asset_name_key, asset_data in pairs(self._mask_units) do
		if not unloaded_masks[asset_data.mask_name:key()] then
			unloaded_masks[asset_data.mask_name:key()] = true

			managers.dyn_resource:unload(ids_unit, asset_data.mask_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end
	end

	self._mask_units = {}

	for _, weapon_name in ipairs(self._weapon_names) do
		managers.dyn_resource:unload(ids_unit, weapon_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end
end

function MenuSceneManager:set_server_loading()
end

function MenuSceneManager:set_lobby_character_stance(i, stance)
	local unit = self._lobby_characters[i]

	unit:play_redirect(Idstring(stance))
end

function MenuSceneManager:_update_safe_scene(t, dt)
	if self._safe_shake and self._safe_shake_transition then
		self._safe_shake_transition.speed = math.step(self._safe_shake_transition.speed, self._safe_shake_transition.target_speed, dt / 2)
		self._safe_shake_transition.lerp = math.min(1, self._safe_shake_transition.lerp + dt * self._safe_shake_transition.speed)

		self._shaker:set_parameter(self._safe_shake, "amplitude", math.bezier({
			1,
			1,
			0,
			0
		}, self._safe_shake_transition.lerp))

		if self._safe_shake_transition.lerp == 1 then
			self._safe_shake_transition = nil
		end
	end

	if self._safe_explosion_blur then
		self._safe_explosion_blur.lerp = math.min(1, self._safe_explosion_blur.lerp + dt / self._safe_explosion_blur.duration)
		local dof_setting = self._safe_explosion_blur.max_value * math.bezier({
			1,
			1,
			1,
			0
		}, self._safe_explosion_blur.lerp)

		managers.environment_controller:set_custom_dof_settings(dof_setting)

		if self._safe_explosion_blur.lerp == 1 then
			self._safe_explosion_blur = nil

			managers.environment_controller:set_custom_dof_settings(nil)
		end
	end
end

function MenuSceneManager:_test_start_open_economy_safe(safe_entry)
	managers.network.account:inventory_reward_unlock(safe_entry, nil, nil, callback(self, self, "_safe_result_recieved"))

	local function ready_clbk()
		print("ECONOMY SAFE READY CALLBACK")
	end

	self:start_open_economy_safe(safe_entry, ready_clbk)
end

function MenuSceneManager:reset_economy_safe()
	self._safe_scene_destroyed = true

	self:_destroy_economy_safe()
	managers.menu_scene:remove_item()
end

function MenuSceneManager:store_safe_result(error, items_new, items_removed)
	managers.network.account:inventory_repair_list(items_new)
	managers.network.account:inventory_repair_list(items_removed)

	self._safe_result_recieved_data = {
		error,
		items_new,
		items_removed
	}
end

function MenuSceneManager:fetch_safe_result()
	if self._safe_result_recieved_data then
		local data = self._safe_result_recieved_data
		self._safe_result_recieved_data = nil

		return data
	end
end

function MenuSceneManager:create_economy_safe_scene(safe_entry, ready_clbk)
	self:_load_economy_safe(safe_entry, ready_clbk)
end

function MenuSceneManager:start_open_economy_safe()
	self._safe_scene_destroyed = false

	if self:_check_safe_data_loaded() then
		if not _G.IS_VR then
			self._safe_shake = self._shaker:play("cash_opening", 0)

			self._shaker:set_parameter(self._safe_shake, "amplitude", 1)

			self._safe_shake_transition = {
				lerp = 0,
				speed = 0.05
			}
			self._safe_shake_transition.target_speed = self._safe_shake_transition.speed
		end

		self:_create_economy_safe_scene()

		return true
	end

	return false
end

function MenuSceneManager:_load_economy_safe(safe_entry, ready_clbk)
	self:_destroy_economy_safe()

	local safe_entry_data = tweak_data.economy.safes[safe_entry]
	local safe_name = Idstring(safe_entry_data.unit_name)
	local drill_name = Idstring(tweak_data.economy.drills[safe_entry_data.drill].unit_name)
	local saferoom_name = Idstring("units/payday2_cash/safe_room/cash_int_safehouse_saferoom")
	local safe_data = {
		ready = false,
		safe_unit = false,
		safe_name = safe_name
	}
	local drill_data = {
		ready = false,
		safe_unit = false,
		drill_name = drill_name
	}
	local saferoom_data = {
		saferoom_unit = false,
		ready = false,
		saferoom_name = saferoom_name
	}
	self._safe_scene_data = {
		safe_data = safe_data,
		drill_data = drill_data,
		saferoom_data = saferoom_data,
		ready_clbk = ready_clbk
	}

	managers.blackmarket:load_economy_safe(safe_entry, self._safe_scene_data)
end

function MenuSceneManager:_clbk_safe_unit_loaded(safe_data_param)
	print("A: SAFE LOADED", Application:time())

	self._safe_scene_data.safe_data.ready = true

	self:_check_safe_data_ready()
end

function MenuSceneManager:_clbk_drill_unit_loaded(drill_data_param)
	print("A: DRILL LOADED", Application:time())

	self._safe_scene_data.drill_data.ready = true

	self:_check_safe_data_ready()
end

function MenuSceneManager:_clbk_saferoom_unit_loaded(saferoom_data)
	print("A: SAFEROOM LOADED", Application:time())

	self._safe_scene_data.saferoom_data.ready = true

	self:_check_safe_data_ready()
end

function MenuSceneManager:_check_safe_data_loaded()
	print(inspect(self._safe_scene_data))

	if not self._safe_scene_data.drill_data.ready then
		return false
	end

	if not self._safe_scene_data.safe_data.ready then
		return false
	end

	if not self._safe_scene_data.saferoom_data.ready then
		return false
	end

	return true
end

function MenuSceneManager:_check_safe_data_ready()
	if self:_check_safe_data_loaded() and self._safe_scene_data.ready_clbk then
		self._safe_scene_data.ready_clbk()
	end
end

function MenuSceneManager:_calc_angles()
	local cx = 200
	local cy = 100
	local cz = 50
	local spin = 90 - math.atan((self:_scene_offset_from_camera().y + cy) / cx)
	local tilt = 90 - math.atan((self:_scene_offset_from_camera().y + cy) / cz)

	return math.rad(spin), math.rad(tilt)
end

function MenuSceneManager:_scene_offset_from_camera()
	return Vector3(0, 600, -80)
end

function MenuSceneManager:_create_economy_safe_scene()
	local pos = self._scene_templates.safe.camera_pos + self:_scene_offset_from_camera()
	self._economy_safe = World:spawn_unit(self._safe_scene_data.safe_data.safe_name, pos)
	self._economy_drill = World:spawn_unit(self._safe_scene_data.drill_data.drill_name, self._economy_safe:get_object(Idstring("spawn_drill")):position())
	self._economy_saferoom = World:spawn_unit(self._safe_scene_data.saferoom_data.saferoom_name, pos)

	self:_start_safe_drill_sequence()
end

function MenuSceneManager:_safe_result_recieved(error, items_new, items_removed)
	local load_start_time = Application:time()
	local result = items_new[1]

	print("B: RESULT RECIEVED", result.weapon_skin, Application:time())

	local function ready_clbk()
		local min_time_left = math.max(3 - (Application:time() - load_start_time), 0)

		print("READY CALLBACK", min_time_left)
		self:add_callback(callback(self, self, "create_safe_content"), min_time_left, nil)
	end

	self:load_safe_result_content(result, ready_clbk)
end

function MenuSceneManager:load_safe_result_content(result, ready_clbk)
	local item_data = tweak_data.economy[result.category] or tweak_data.blackmarket[result.category][result.entry]
	self._safe_result_content_data = {
		result = result,
		item_data = item_data,
		ready_flags = {},
		ready_clbk = ready_clbk
	}

	if result.category == "weapon_skins" then
		local weapon_id = item_data.weapon_id or item_data.weapons[1]
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
		local blueprint = item_data.default_blueprint or deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
		local weapon_name = Idstring(tweak_data.weapon.factory[factory_id].unit)
		self._safe_result_content_data.weapon_name = weapon_name
		self._safe_result_content_data.factory_id = factory_id
		self._safe_result_content_data.ready_flags.parts_ready = false
		self._safe_result_content_data.ready_flags.weapon_ready = false

		managers.dyn_resource:load(ids_unit, weapon_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_set_safe_result_ready_flag", "weapon_ready"))

		slot8 = managers.weapon_factory:preload_blueprint(factory_id, blueprint, false, false, callback(self, self, "_safe_result_parts_loaded"), false)
	elseif result.category == "armor_skins" then
		self._safe_result_content_data.armor_id = result.entry

		self:_check_safe_result_content_loaded()

		local rarity_data = tweak_data.economy.rarities[item_data.rarity] or {}
		local random_ang = 15
		local pos = self._scene_templates.safe.camera_pos + self._scene_templates.safe.target_pos - self._scene_templates.safe.camera_pos:normalized() * 310 + math.UP * -120
		local ang = Rotation(180 + math.random(-random_ang, random_ang), 0, 0)
		local unit_name = tweak_data.blackmarket.characters[managers.blackmarket:equipped_character()].menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, ang)

		self:_set_character_unit_pose(rarity_data.armor_sequence or "cvc_var1", unit)
		unit:base():set_character_name(self._character_unit:base():character_name())
		unit:base():set_mask_id(self._character_unit:base():mask_id())
		unit:set_visible(false)

		self._economy_character = unit

		self._economy_character:set_rotation(Rotation(180, 0, 0))

		self._safe_result_content_data.ready_flags.armor_ready = false
		local armors = managers.blackmarket:get_sorted_armors()

		self:set_character_armor(armors[#armors], unit)
		managers.menu_scene:preview_character_skin(result.entry, self._economy_character, {
			done = callback(self, self, "_set_safe_result_ready_flag", "armor_ready")
		})
	end
end

function MenuSceneManager:_set_safe_result_ready_flag(flag)
	print("B: RESULT CONTENT LOADED", Application:time(), flag)

	self._safe_result_content_data.ready_flags[flag] = true

	self:_check_safe_result_content_loaded()
end

function MenuSceneManager:_safe_result_parts_loaded(part, blueprint)
	print("B: RESULT WEAPON PARTS LOADED", Application:time())

	self._safe_result_content_data.ready_flags.parts_ready = true
	self._safe_result_content_data.blueprint = blueprint

	self:_check_safe_result_content_loaded()
end

function MenuSceneManager:_safe_open_minimum_time()
	print("B: SAFE OPEN MINIMUM TIME", Application:time())

	self._safe_result_content_data.min_time_ready = true

	self:_check_safe_result_content_loaded()
end

function MenuSceneManager:_check_safe_result_content_loaded()
	for flag, ready in pairs(self._safe_result_content_data.ready_flags) do
		if not ready then
			return
		end
	end

	print("B: COMPLETED", Application:time())

	if self._safe_result_content_data.ready_clbk then
		self._safe_result_content_data.ready_clbk()
	end
end

function MenuSceneManager:create_safe_content(created_clbk)
	if self._safe_shake_transition then
		self._safe_shake_transition.target_speed = 0.5
	end

	print("C: CREATE SAFE CONTENT", Application:time())
	self:_push_through_safe_drill_sequence()
	self:_open_safe_sequence()
	self._economy_safe:damage():add_trigger_callback("create_safe_result", callback(self, self, "_create_safe_result_trigger", created_clbk))
end

function MenuSceneManager:_create_safe_result_trigger(created_clbk)
	self:add_callback(callback(self, self, "_create_safe_result", created_clbk), 0.1, nil)
end

function MenuSceneManager:_create_safe_result(created_clbk)
	if self._safe_scene_destroyed then
		return
	end

	self:_start_safe_explosion_blur()

	if self._shaker then
		self._shaker:play("player_fall_damage")
	end

	managers.environment_controller:set_dof_distance(100, true)

	if self._safe_result_content_data.factory_id then
		local item_pos = self._scene_templates.safe.camera_pos + self._scene_templates.safe.target_pos - self._scene_templates.safe.camera_pos:normalized() * 200
		local custom_data = {
			scene_template = "safe",
			item_pos = item_pos
		}
		local cosmetics = {
			id = self._safe_result_content_data.result.entry,
			quality = self._safe_result_content_data.result.quality
		}
		slot5 = self:spawn_item_weapon(self._safe_result_content_data.factory_id, self._safe_result_content_data.blueprint, cosmetics, nil, custom_data)
	elseif self._safe_result_content_data.armor_id and alive(self._economy_character) then
		self._economy_character:set_visible(true)

		local equipped_mask = managers.blackmarket:equipped_mask()

		if equipped_mask.mask_id then
			self:set_character_mask_by_id(equipped_mask.mask_id, equipped_mask.blueprint, self._economy_character)
		end

		self:_set_character_and_outfit_visibility(self._economy_character, true)
	end

	self._can_change_fov = true

	if created_clbk then
		created_clbk()
	end

	if alive(self._economy_saferoom) then
		self._economy_saferoom:damage():run_sequence_simple("int_seq_darken_background")
	end

	managers.menu:set_cash_safe_scene_done(true)
end

function MenuSceneManager:_start_safe_explosion_blur()
	self._safe_explosion_blur = {
		max_value = Vector3(0, 1, 4),
		lerp = 0,
		duration = 1
	}
end

function MenuSceneManager:_start_safe_drill_sequence()
	self._economy_drill:damage():run_sequence_simple("anim_start_drilling")
end

function MenuSceneManager:_push_through_safe_drill_sequence()
	self._economy_drill:damage():run_sequence_simple("anim_push_through")
end

function MenuSceneManager:_done_safe_drill_sequence()
	self._economy_drill:damage():run_sequence_simple("anim_fall_off")
end

function MenuSceneManager:_open_safe_sequence()
	local rarity = self._safe_result_content_data.item_data.rarity

	print("rarity", rarity)

	local sequence = tweak_data.economy.rarities[rarity].open_safe_sequence

	self._economy_safe:damage():run_sequence_simple(sequence)
end

function MenuSceneManager:_destroy_economy_safe()
	if alive(self._economy_safe) then
		local old_name = self._economy_safe:name()

		World:delete_unit(self._economy_safe)

		self._economy_safe = nil
	end

	if alive(self._economy_drill) then
		local old_name = self._economy_drill:name()

		World:delete_unit(self._economy_drill)

		self._economy_drill = nil
	end

	if alive(self._economy_saferoom) then
		local old_name = self._economy_saferoom:name()

		World:delete_unit(self._economy_saferoom)

		self._economy_saferoom = nil
	end

	if alive(self._economy_character) then
		if self._mask_units[self._economy_character:key()] and alive(self._mask_units[self._economy_character:key()].unit) then
			self:_delete_character_mask(self._economy_character)
		end

		World:delete_unit(self._economy_character)

		self._economy_character = nil
	end

	if self._safe_shake then
		self._shaker:stop(self._safe_shake)

		self._safe_shake = nil
	end

	managers.blackmarket:release_preloaded_category("economy_safe")
end

function MenuSceneManager:set_blackmarket_tradable_loaded()
end

function MenuSceneManager:preview_character_skin(skin_id, unit, clbks)
	unit = unit or self._character_unit

	self:set_character_armor_skin(skin_id, unit)
	unit:base():_apply_cosmetics(clbks)
end

function MenuSceneManager:destroy()
	if self._vp then
		self._vp:destroy()
	end
end

if _G.IS_VR then
	require("lib/managers/MenuSceneManagerVR")
end
