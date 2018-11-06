require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateSwipe = PlayerHandStateSwipe or class(PlayerHandState)

function PlayerHandStateSwipe:init(hsm, name, hand_unit, sequence)
	PlayerHandStateWeapon.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateSwipe:at_enter(prev_state, params)
	PlayerHandStateSwipe.super.at_enter(self, prev_state)

	self._params = params
	self.prev_state = prev_state:name()
	self._flick_callback = params.flick_callback

	self:hsm():enter_controller_state("tablet")
end

function PlayerHandStateSwipe:at_exit(next_state)
	managers.hud:on_touch(false, Vector3(0, 0, 0))
	PlayerHandStateSwipe.super.at_exit(self, next_state)

	self._flick_callback = nil
end

local ids_tablet = Idstring("tablet")

function PlayerHandStateSwipe:post_event(event)
	self._hand_unit:base():other_hand_base():post_event(event, ids_tablet)
end

local tmp_vec = Vector3(0, 0, 0)
local tmp_vec2 = Vector3(0, 0, 0)

function PlayerHandStateSwipe:update(t, dt)
	local hand_base = self._hand_unit:base()
	local hand_rotation = hand_base:rotation()

	mvector3.set(tmp_vec, hand_base:finger_position())

	local tablet_hand = hand_base:other_hand_unit()
	local hud_object = tablet_hand:get_object(Idstring("player_hud_tablet"))
	local oobb = hud_object:oobb()
	local x = oobb:x()
	local y = oobb:y()
	local width = mvector3.normalize(x)
	local height = mvector3.normalize(y)
	local up = tmp_vec2

	mvector3.cross(up, y, x)

	local d = mvector3.dot(oobb:center(), up)
	local dir = tmp_vec
	local center = oobb:center()

	mvector3.subtract(tmp_vec, center)

	local length = mvector3.dot(dir, up)
	local x_len = mvector3.dot(dir, x)
	local y_len = mvector3.dot(dir, y)
	local inside = false
	local vol = tweak_data.vr.tablet.interaction_volume

	if mvector3.dot(hand_rotation:y(), up) < vol.angle_th and vol.min_depth < length and length < vol.max_depth and math.abs(x_len) <= width + vol.extra_width and math.abs(y_len) <= height + vol.extra_height then
		inside = true
	end

	self._swiped = self._swiped and inside
	local controller = managers.vr:hand_state_machine():controller()
	local ws_pos = tmp_vec

	mvector3.set_static(ws_pos, x_len / width, y_len / height, 0)

	if inside and controller:get_input_pressed("tablet_interact") then
		managers.hud:on_interact(ws_pos)
	end

	managers.hud:on_touch(inside, ws_pos)

	self._current_swipe = x_len

	if not self._swiped and not self._flick_delay_t or t - self._flick_delay_t > 0 then
		if inside and not self._start_swipe then
			self._start_swipe = self._start_swipe or x_len
			self._start_t = self._start_t or t

			if not self._touch then
				self:post_event("matrix_tablet_click")
			end

			self._touch = true
		elseif not inside or self:_check_flick(t, center, x) then
			self._start_swipe = nil
			self._start_t = nil
			self._last_flick = nil
			self._touch = inside

			if not inside then
				-- Nothing
			end
		end
	end
end

local dir_vec = Vector3(0, 0, 0)

function PlayerHandStateSwipe:_check_flick(t, pos, x)
	local length = math.abs(self._current_swipe - self._start_swipe)
	local tablet = tweak_data.vr.tablet

	if tablet.swipe_length < length then
		local dir_string = self._current_swipe < self._start_swipe and "right" or "left"
		local flick_time = tablet.flick_time

		if self._flick_callback and not self._flick_callback(dir_string, flick_time) then
			return false
		end

		self:post_event("matrix_tablet_swipe_" .. dir_string)

		self._flick_delay_t = t + flick_time
		self._swiped = true

		return true
	end
end

function PlayerHandStateSwipe:item_transition(next_state, params)
	params = self._params

	self:default_transition(next_state, params)
end
