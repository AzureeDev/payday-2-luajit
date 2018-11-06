PlayerDrivingVR = PlayerDriving or Application:error("PlayerDrivingVR needs PlayerDriving!")
local __enter = PlayerDriving.enter

function PlayerDrivingVR:enter(...)
	__enter(self, ...)
	self._camera_unit:base():enter_vehicle()

	if self._seat.shooting_pos and self._seat.has_shooting_mode then
		self._seat.allow_shooting = true
	end

	if not self._seat.allow_shooting then
		managers.hud:belt():set_visible(false)
		self._unit:hand():set_belt_active(false)
		self._unit:hand():_set_hand_state(PlayerHand.RIGHT, "driving")
		self._unit:hand():_set_hand_state(PlayerHand.LEFT, "driving")
	else
		local weapon_hand_id = self._unit:hand():get_default_hand_id("weapon")

		if weapon_hand_id then
			self._unit:hand():_set_hand_state(PlayerHand.other_hand_id(weapon_hand_id), "driving")
		end
	end

	local driving_tweak = tweak_data.vr.driving[self._vehicle_ext.tweak_data]

	if not driving_tweak then
		debug_pause("Missing tweak_data for vehicle:", self._vehicle_ext.tweak_data)
	end

	self._vehicle_ws = {}

	self:_setup_help_text(self._seat.driving)
	self:set_throttle(0)
end

function PlayerDrivingVR:_setup_help_text(is_driver)
	local driving_tweak = tweak_data.vr.driving[self._vehicle_ext.tweak_data]

	if not driving_tweak then
		debug_pause("Missing tweak_data for vehicle:", self._vehicle_ext.tweak_data)

		return
	end

	if is_driver then
		local throttle = driving_tweak.throttle

		if type(driving_tweak.steering_pos) ~= "table" or not driving_tweak.steering_pos then
			local steering = {
				driving_tweak.steering_pos
			}
		end

		for key, offset in pairs(steering) do
			local id = "steering"

			if throttle.type == "twist_grip" and type(key) ~= "string" or throttle.hand == key then
				self:_add_help_text(driving_tweak, "throttle", "twist_grip")
			else
				self:_add_help_text(driving_tweak, "steering", type(key) == "string" and key)
			end
		end

		if throttle.type == "lever" then
			self:_add_help_text(throttle, "throttle", "lever")
		end
	end

	local exit = driving_tweak.exit_pos[self._seat.name]

	if exit then
		self:_add_help_text(exit, "exit")
	end
end

function PlayerDrivingVR:_add_help_text(tweak, type, subtype)
	local rot = self._vehicle_unit:rotation()
	local offset = nil
	local dir = math.Y
	local up = math.UP

	if type == "steering" or type == "throttle" and subtype == "twist_grip" then
		local hand = type == "throttle" and tweak.throttle.hand or subtype
		offset = hand and tweak.steering_pos[hand] or tweak.steering_pos
		dir = tweak.steering_dir or dir
		up = tweak.steering_up or up
	elseif type == "throttle" and subtype == "lever" then
		offset = tweak.position
		dir = -math.UP
		up = math.Y
	elseif type == "exit" then
		offset = tweak.position
		dir = tweak.direction
		up = tweak.up or up
	else
		debug_pause("Invalid help text", type, subtype)

		return
	end

	dir = dir:rotate_with(rot)
	up = up:rotate_with(rot)
	local w = 128
	local h = 128

	if type == "throttle" then
		h = 384
	end

	local ws = managers.hud:create_vehicle_interaction_ws(type, self._vehicle_unit, offset, dir, up, w, h)
	self._vehicle_ws[type] = ws
	local panel = ws:panel():panel({
		w = 128,
		h = 128,
		name = type
	})

	panel:set_center(ws:panel():w() / 2, ws:panel():h() / 2)
	BoxGuiObject:new(panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	if type == "throttle" then
		self._throttle_panel = ws:panel()
		local throttle_up_outline = self._throttle_panel:bitmap({
			texture = "guis/dlcs/vr/textures/pd2/icon_belt_arrow",
			name = "up_outline",
			texture_rect = {
				128,
				0,
				128,
				128
			}
		})
		local throttle_up = self._throttle_panel:bitmap({
			texture = "guis/dlcs/vr/textures/pd2/icon_belt_arrow",
			name = "up",
			texture_rect = {
				0,
				0,
				128,
				128
			}
		})
		local throttle_down_outline = self._throttle_panel:bitmap({
			texture = "guis/dlcs/vr/textures/pd2/icon_belt_arrow",
			name = "down_outline",
			y = 256,
			rotation = 180,
			texture_rect = {
				128,
				0,
				128,
				128
			}
		})
		local throttle_down = self._throttle_panel:bitmap({
			texture = "guis/dlcs/vr/textures/pd2/icon_belt_arrow",
			name = "down",
			y = 256,
			rotation = 180,
			texture_rect = {
				0,
				0,
				128,
				128
			}
		})
		self._throttle_arrows = {
			up = throttle_up,
			down = throttle_down
		}
	end

	local text = panel:text({
		name = "text",
		rotation = 360,
		text = self:get_text_from_id(type),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_center(panel:w() / 2, panel:h() / 2)
end

function PlayerDrivingVR:get_text_from_id(id, type)
	if type then
		id = id .. "_" .. type
	end

	return managers.localization:to_upper_text("hud_vr_" .. id)
end

function PlayerDrivingVR:set_help_text(id, type)
	local ws = self._vehicle_ws[id]

	if not ws then
		return
	end

	local text = self:get_text_from_id(id, type)

	ws:panel():child(id):child("text"):set_text(text)
end

local __exit = PlayerDriving.exit

function PlayerDrivingVR:exit(...)
	__exit(self, ...)
	self._unit:hand():_change_hand_to_default(PlayerHand.RIGHT)
	self._unit:hand():_change_hand_to_default(PlayerHand.LEFT)
	self._unit:hand():set_base_rotation(self._camera_unit:base():base_rotation())
	managers.hud:belt():set_visible(true)

	for id in pairs(self._vehicle_ws) do
		managers.hud:destroy_vehicle_interaction_ws(id)
	end

	self._throttle_arrows = nil
end

function PlayerDrivingVR:_postion_player_on_seat(seat)
	local rot = self._seat.object:rotation()
	local pos = self._seat.object:position()

	if tweak_data.vr.driving[self._vehicle_ext.tweak_data].seat_offsets and tweak_data.vr.driving[self._vehicle_ext.tweak_data].seat_offsets[self._seat.name] then
		pos = pos + tweak_data.vr.driving[self._vehicle_ext.tweak_data].seat_offsets[self._seat.name]
	end

	self._unit:set_rotation(rot)
	self._unit:set_position(pos)
	self._ext_movement:reset_ghost_position()
	self._ext_movement:reset_hmd_position()

	self._initial_hmd_rotation_inv = Rotation(VRManager:hmd_rotation():yaw(), 0, 0):inverse()
	self._hmd_delta = Vector3()
end

local __update = PlayerDriving.update
local hmd_delta = Vector3()
local ghost_pos = Vector3()
local seat_offset = Vector3()
local hmd_rot = Rotation()

function PlayerDrivingVR:update(t, dt)
	__update(self, t, dt)

	local seat_pos, seat_rot = self._vehicle_unit:vehicle_driving():get_object_placement(self._unit)

	if not seat_pos or not seat_rot then
		return
	end

	if self._seat.shooting_pos and self._seat.allow_shooting and self._stance ~= PlayerDriving.STANCE_SHOOTING then
		self._stance = PlayerDriving.STANCE_SHOOTING

		self._ext_network:send("sync_vehicle_change_stance", self._stance)
	end

	mrotation.set_yaw_pitch_roll(hmd_rot, seat_rot:yaw(), seat_rot:pitch(), seat_rot:roll())
	mrotation.multiply(hmd_rot, self._initial_hmd_rotation_inv)
	self._unit:hand():set_base_rotation(hmd_rot)
	mvector3.add(self._hmd_delta, self._ext_movement:hmd_delta())
	mvector3.set(hmd_delta, self._hmd_delta)
	mvector3.set_z(hmd_delta, 0)
	mvector3.rotate_with(hmd_delta, hmd_rot)

	local static_offset = 145 - managers.vr:get_setting("height")

	mvector3.set_static(seat_offset, 0, 0, static_offset)

	if tweak_data.vr.driving[self._vehicle_ext.tweak_data].seat_offsets and tweak_data.vr.driving[self._vehicle_ext.tweak_data].seat_offsets[self._seat.name] then
		mvector3.add(seat_offset, tweak_data.vr.driving[self._vehicle_ext.tweak_data].seat_offsets[self._seat.name])
	end

	mvector3.rotate_with(seat_offset, seat_rot)
	mvector3.set(ghost_pos, seat_pos)
	mvector3.add(ghost_pos, seat_offset)
	mvector3.add(ghost_pos, hmd_delta)
	self._ext_movement:set_ghost_position(ghost_pos)
end

function PlayerDrivingVR:reset_ghost_position()
	self._hmd_delta = Vector3()
end

function PlayerDrivingVR:set_steering(value)
	self._steering_value = value
end

function PlayerDrivingVR:set_throttle(value)
	self._throttle_value = value

	if self._throttle_arrows then
		local function stretch_value(val, range)
			if val == 0 then
				return 0
			end

			local mul = range * 2
			val = math.abs(val)

			return (val - 0.5) * mul + 0.5
		end

		local function set_arrow_size(arrow, val, inverse)
			val = stretch_value(val, 0.4)
			local size = 128
			local new_size = size * val

			arrow:set_texture_rect(0, size - new_size, size, new_size)
			arrow:set_h(new_size)

			if not inverse then
				arrow:set_y(size - new_size)
			end
		end

		local up = self._throttle_arrows.up
		local down = self._throttle_arrows.down

		if not value then
			set_arrow_size(up, 0)
			set_arrow_size(down, 0, true)
		elseif value < 0 then
			set_arrow_size(down, value, true)
			set_arrow_size(up, 0)
		else
			set_arrow_size(up, value)
			set_arrow_size(down, 0, true)
		end
	end
end

local __get_drive_axis = PlayerDriving._get_drive_axis

function PlayerDrivingVR:_get_drive_axis()
	local drive_axis = __get_drive_axis(self)

	if self._steering_value then
		mvector3.set_x(drive_axis, self._steering_value)
	end

	if self._throttle_value then
		mvector3.set_y(drive_axis, self._throttle_value)
	end

	return drive_axis
end
