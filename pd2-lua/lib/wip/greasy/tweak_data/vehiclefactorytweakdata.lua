local ids_unit = Idstring("unit")

function preload_all()
	for id, part in pairs(tweak_data.vehicle.factory.parts) do
		if part.third_unit then
			local ids_unit_name = Idstring(part.third_unit)

			managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", false)
		else
			print(id, "didn't have third")
		end
	end
end

function preload_all_units()
	for id, part in pairs(tweak_data.vehicle.factory) do
		if part.unit then
			local ids_unit_name = Idstring(part.unit)

			managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", false)
		else
			print(id, "didn't have unit")
		end
	end
end

function print_package_strings_unit()
	for id, part in pairs(tweak_data.vehicle.factory) do
		if part.unit then
			print("<unit name=\"" .. part.unit .. "\"/>")
		end
	end
end

function print_package_strings_part_unit()
	for id, part in pairs(tweak_data.vehicle.factory.parts) do
		if part.unit then
			local f = SystemFS:open(id .. ".package", "w")

			f:puts("<package>")
			f:puts("\t<units>")
			f:puts("\t\t<unit name=\"" .. part.unit .. "\"/>")
			f:puts("\t</units>")
			f:puts("</package>")
			SystemFS:close(f)
		end
	end
end

function preload_all_first()
	for id, part in pairs(tweak_data.vehicle.factory.parts) do
		if part.unit then
			local ids_unit_name = Idstring(part.unit)

			managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", false)
		end
	end
end

function print_parts_without_texture()
	Application:debug("print_parts_without_texture")

	for id, part in pairs(tweak_data.vehicle.factory.parts) do
		if part.pcs then
			local guis_catalog = "guis/"
			local bundle_folder = part.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			guis_catalog = guis_catalog .. "textures/pd2/blackmarket/icons/vehicle_mods/"

			if not DB:has(Idstring("texture"), guis_catalog .. id) then
				print(guis_catalog .. id)
			end
		end
	end

	Application:debug("---------------------------")
end

VehicleFactoryTweakData = VehicleFactoryTweakData or class()

function VehicleFactoryTweakData:init()
	self.parts = {}

	self:_init_muscle_2()
	self:_create_extra_parts()
end

function VehicleFactoryTweakData:_create_extra_parts()
	local extra_parts_index = 1
	local extra_parts_id = "vhc_extra_part_"
	local extra_parts_map = {}

	for part_id, part_data in pairs(self.parts) do
		if part_data.extra_parts then
			local extra_id = nil
			local extra_parts = part_data.extra_parts
			local adds = part_data.adds or {}
			part_data.extra_parts = nil
			local extra_part = nil

			for index, extra_data in ipairs(extra_parts) do
				extra_part = deep_clone(part_data)
				extra_part.type = "extra"
				extra_part.texture_bundle_folder = nil

				for i, d in pairs(extra_data) do
					extra_part[i] = d
				end

				extra_id = extra_parts_id .. tostring(extra_parts_index)
				extra_parts_index = extra_parts_index + 1
				extra_parts_map[extra_id] = extra_part

				table.insert(adds, extra_id)
			end

			part_data.adds = adds
		end
	end

	for extra_id, extra_data in pairs(extra_parts_map) do
		if self.parts[extra_id] then
			Application:error("[VehicleFactoryTweakData:_create_extra_parts] Part with same id as extra part already exists!", extra_id)
		end

		self.parts[extra_id] = extra_data
	end
end

function VehicleFactoryTweakData:_init_muscle_2()
	self.parts.vhc_fps_muscle_bf_mod0 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/bumpers/mod_0_bumper_front",
		texture_bundle_folder = "greasy",
		type = "bumper_front"
	}
	self.parts.vhc_fps_muscle_bf_mod1 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod1/bumpers/mod_1_bumper_front",
		texture_bundle_folder = "greasy",
		type = "bumper_front"
	}
	self.parts.vhc_fps_muscle_bf_mod2 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod2/bumpers/mod_2_bumper_front",
		texture_bundle_folder = "greasy",
		type = "bumper_front"
	}
	self.parts.vhc_fps_muscle_bf_mod3 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod3/bumpers/mod_3_bumper_front",
		texture_bundle_folder = "greasy",
		type = "bumper_front"
	}
	self.parts.vhc_fps_muscle_bf_mod5 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod5/bumpers/mod_5_bumper_front",
		texture_bundle_folder = "greasy",
		type = "bumper_front"
	}
	self.parts.vhc_fps_muscle_br_mod0 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/bumpers/mod_0_bumper_rear",
		texture_bundle_folder = "greasy",
		type = "bumper_rear"
	}
	self.parts.vhc_fps_muscle_br_mod1 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod1/bumpers/mod_1_bumper_rear",
		texture_bundle_folder = "greasy",
		type = "bumper_rear"
	}
	self.parts.vhc_fps_muscle_br_mod2 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod2/bumpers/mod_2_bumper_rear",
		texture_bundle_folder = "greasy",
		type = "bumper_rear"
	}
	self.parts.vhc_fps_muscle_br_mod3 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod3/bumpers/mod_3_bumper_rear",
		texture_bundle_folder = "greasy",
		type = "bumper_rear"
	}
	self.parts.vhc_fps_muscle_br_mod5 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod5/bumpers/mod_5_bumper_rear",
		texture_bundle_folder = "greasy",
		type = "bumper_rear"
	}
	self.parts.vhc_fps_muscle_c_mod0 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/chassis/mod_0_chassis",
		texture_bundle_folder = "greasy",
		type = "chassis"
	}
	self.parts.vhc_fps_muscle_d_mod0 = {
		a_obj = "anim_door_front_left",
		texture_bundle_folder = "greasy",
		type = "door",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/doors/mod_0_door_front_left",
		extra_parts = {
			{
				unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/doors/mod_0_door_front_right",
				a_obj = "anim_door_front_right"
			}
		}
	}
	self.parts.vhc_fps_muscle_h_mod0 = {
		a_obj = "anim_hood",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/hood/mod_0_hood",
		texture_bundle_folder = "greasy",
		type = "hood"
	}
	self.parts.vhc_fps_muscle_h_mod1 = {
		a_obj = "anim_hood",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod1/hood/mod_1_hood",
		texture_bundle_folder = "greasy",
		type = "hood"
	}
	self.parts.vhc_fps_muscle_h_mod2 = {
		a_obj = "anim_hood",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod2/hood/mod_2_hood",
		texture_bundle_folder = "greasy",
		type = "hood"
	}
	self.parts.vhc_fps_muscle_h_mod3 = {
		a_obj = "anim_hood",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod3/hood/mod_3_hood",
		texture_bundle_folder = "greasy",
		type = "hood"
	}
	self.parts.vhc_fps_muscle_h_mod4 = {
		a_obj = "anim_hood",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod4/hood/mod_4_hood",
		texture_bundle_folder = "greasy",
		type = "hood"
	}
	self.parts.vhc_fps_muscle_h_mod5 = {
		a_obj = "anim_hood",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod5/hood/mod_5_hood",
		texture_bundle_folder = "greasy",
		type = "hood"
	}
	self.parts.vhc_fps_muscle_i_mod0 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/interior/mod_0_interior",
		texture_bundle_folder = "greasy",
		type = "interior"
	}
	self.parts.vhc_fps_muscle_s_mod1 = {
		a_obj = "anim_body",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod1/spoiler/mod_1_spoiler",
		texture_bundle_folder = "greasy",
		type = "spoiler"
	}
	local right_tire_rotation = Rotation(180, 0, 0)
	self.parts.vhc_fps_muscle_tire_mod0 = {
		a_obj = "anim_tire_front_left",
		texture_bundle_folder = "greasy",
		type = "tire",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/tire/mod_0_tire",
		extra_parts = {
			{
				a_obj = "anim_tire_front_right",
				rotation = right_tire_rotation
			},
			{
				a_obj = "anim_tire_rear_left"
			},
			{
				a_obj = "anim_tire_rear_right",
				rotation = right_tire_rotation
			}
		}
	}
	self.parts.vhc_fps_muscle_tire_mod1 = {
		a_obj = "anim_tire_front_left",
		texture_bundle_folder = "greasy",
		type = "tire",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod1/tire/mod_1_tire",
		extra_parts = {
			{
				a_obj = "anim_tire_front_right",
				rotation = right_tire_rotation
			},
			{
				a_obj = "anim_tire_rear_left"
			},
			{
				a_obj = "anim_tire_rear_right",
				rotation = right_tire_rotation
			}
		}
	}
	self.parts.vhc_fps_muscle_tire_mod2 = {
		a_obj = "anim_tire_front_left",
		texture_bundle_folder = "greasy",
		type = "tire",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod2/tire/mod_2_tire",
		extra_parts = {
			{
				a_obj = "anim_tire_front_right",
				rotation = right_tire_rotation
			},
			{
				a_obj = "anim_tire_rear_left"
			},
			{
				a_obj = "anim_tire_rear_right",
				rotation = right_tire_rotation
			}
		}
	}
	self.parts.vhc_fps_muscle_tire_mod3 = {
		a_obj = "anim_tire_front_left",
		texture_bundle_folder = "greasy",
		type = "tire",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod3/tire/mod_3_tire",
		extra_parts = {
			{
				a_obj = "anim_tire_front_right",
				rotation = right_tire_rotation
			},
			{
				a_obj = "anim_tire_rear_left"
			},
			{
				a_obj = "anim_tire_rear_right",
				rotation = right_tire_rotation
			}
		}
	}
	self.parts.vhc_fps_muscle_tire_mod4 = {
		a_obj = "anim_tire_front_left",
		texture_bundle_folder = "greasy",
		type = "tire",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod4/tire/mod_4_tire",
		extra_parts = {
			{
				a_obj = "anim_tire_front_right",
				rotation = right_tire_rotation
			},
			{
				a_obj = "anim_tire_rear_left"
			},
			{
				a_obj = "anim_tire_rear_right",
				rotation = right_tire_rotation
			}
		}
	}
	self.parts.vhc_fps_muscle_tire_mod5 = {
		a_obj = "anim_tire_front_left",
		texture_bundle_folder = "greasy",
		type = "tire",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod5/tire/mod_5_tire",
		extra_parts = {
			{
				a_obj = "anim_tire_front_right",
				rotation = right_tire_rotation
			},
			{
				a_obj = "anim_tire_rear_left"
			},
			{
				a_obj = "anim_tire_rear_right",
				rotation = right_tire_rotation
			}
		}
	}
	self.parts.vhc_fps_muscle_t_mod0 = {
		a_obj = "anim_trunk",
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/mod0/trunk/mod_0_trunk",
		texture_bundle_folder = "greasy",
		type = "trunk"
	}
	self.vhc_fps_muscle_2 = {
		unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/fps_vehicle_muscle_2",
		dummy_unit = "units/pd2_dlc_drive/vehicles/fps_vehicle_muscle_2/fps_vehicle_muscle_2_dummy",
		texture_bundle_folder = "greasy",
		default_blueprint = {
			"vhc_fps_muscle_bf_mod0",
			"vhc_fps_muscle_br_mod0",
			"vhc_fps_muscle_c_mod0",
			"vhc_fps_muscle_d_mod0",
			"vhc_fps_muscle_h_mod0",
			"vhc_fps_muscle_i_mod0",
			"vhc_fps_muscle_t_mod0",
			"vhc_fps_muscle_tire_mod0"
		},
		uses_parts = {
			"vhc_fps_muscle_bf_mod0",
			"vhc_fps_muscle_bf_mod1",
			"vhc_fps_muscle_bf_mod2",
			"vhc_fps_muscle_bf_mod3",
			"vhc_fps_muscle_bf_mod5",
			"vhc_fps_muscle_br_mod0",
			"vhc_fps_muscle_br_mod1",
			"vhc_fps_muscle_br_mod2",
			"vhc_fps_muscle_br_mod3",
			"vhc_fps_muscle_br_mod5",
			"vhc_fps_muscle_c_mod0",
			"vhc_fps_muscle_d_mod0",
			"vhc_fps_muscle_h_mod0",
			"vhc_fps_muscle_h_mod1",
			"vhc_fps_muscle_h_mod2",
			"vhc_fps_muscle_h_mod3",
			"vhc_fps_muscle_h_mod4",
			"vhc_fps_muscle_h_mod5",
			"vhc_fps_muscle_i_mod0",
			"vhc_fps_muscle_s_mod1",
			"vhc_fps_muscle_t_mod0",
			"vhc_fps_muscle_tire_mod0",
			"vhc_fps_muscle_tire_mod1",
			"vhc_fps_muscle_tire_mod2",
			"vhc_fps_muscle_tire_mod3",
			"vhc_fps_muscle_tire_mod4",
			"vhc_fps_muscle_tire_mod5"
		}
	}
end
