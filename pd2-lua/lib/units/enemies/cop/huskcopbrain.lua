HuskCopBrain = HuskCopBrain or class()
HuskCopBrain._NET_EVENTS = {
	weapon_laser_off = 2,
	weapon_laser_on = 1
}
HuskCopBrain._ENABLE_LASER_TIME = 3
HuskCopBrain._get_radio_id = CopBrain._get_radio_id

function HuskCopBrain:init(unit)
	self._unit = unit
end

function HuskCopBrain:post_init()
	self._alert_listen_key = "HuskCopBrain" .. tostring(self._unit:key())
	local alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminal")

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, {
		aggression = true,
		bullet = true,
		vo_intimidate = true,
		explosion = true,
		footstep = true,
		vo_cbt = true
	}, self._unit:movement():m_head_pos())

	self._last_alert_t = 0

	self._unit:character_damage():add_listener("HuskCopBrain_death" .. tostring(self._unit:key()), {
		"death"
	}, callback(self, self, "clbk_death"))

	self._post_init_complete = true
	self._surrendered = false
end

function HuskCopBrain:interaction_voice()
	return self._interaction_voice
end

function HuskCopBrain:on_intimidated(amount, aggressor_unit)
	amount = math.clamp(math.ceil(amount * 10), 0, 10)

	self._unit:network():send_to_host("long_dis_interaction", amount, aggressor_unit, false)

	return self._interaction_voice
end

function HuskCopBrain:clbk_death(my_unit, damage_info)
	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)

		self._alert_listen_key = nil
	end

	if self._unit:inventory():equipped_unit() then
		self._unit:inventory():equipped_unit():base():set_laser_enabled(false)
	end

	if self._following_hostage_contour_id then
		self._unit:contour():remove_by_id(self._following_hostage_contour_id)

		self._following_hostage_contour_id = nil
	end

	self._unit:movement():set_attention()
end

function HuskCopBrain:set_interaction_voice(voice)
	self._interaction_voice = voice
end

function HuskCopBrain:load(load_data)
	local my_load_data = load_data.brain

	self:set_interaction_voice(my_load_data.interaction_voice)

	if my_load_data.weapon_laser_on then
		self:sync_net_event(self._NET_EVENTS.weapon_laser_on)
	end

	if my_load_data.trade_flee_contour then
		self._unit:contour():add("hostage_trade", nil, nil)
	end

	if my_load_data.following_hostage_contour then
		self._unit:contour():add("friendly", nil, nil)
	end

	self._surrendered = my_load_data.surrendered
end

function HuskCopBrain:on_tied(aggressor_unit, not_tied, can_flee)
	self._unit:network():send_to_host("unit_tied", aggressor_unit, can_flee)
end

function HuskCopBrain:on_trade(position, rotation)
	self._unit:network():send_to_host("unit_traded", position, rotation)
end

function HuskCopBrain:on_cool_state_changed(state)
end

function HuskCopBrain:action_complete_clbk(action)
end

function HuskCopBrain:on_alert(alert_data)
	if self._unit:id() == -1 then
		return
	end

	if TimerManager:game():time() - self._last_alert_t < 5 then
		return
	end

	if CopLogicBase._chk_alert_obstructed(self._unit:movement():m_head_pos(), alert_data) then
		return
	end

	self._unit:network():send_to_host("alert", alert_data[5])

	self._last_alert_t = TimerManager:game():time()
end

function HuskCopBrain:sync_surrender(surrendered)
	self._surrendered = surrendered
end

function HuskCopBrain:surrendered()
	return self._surrendered
end

function HuskCopBrain:sync_converted()
	self._converted = true
end

function HuskCopBrain:converted()
	return self._converted
end

function HuskCopBrain:is_hostile()
	return not self._surrendered and not self._converted
end

function HuskCopBrain:on_long_dis_interacted(amount, aggressor_unit, secondary)
	secondary = secondary or false
	amount = math.clamp(math.ceil(amount * 10), 0, 10)

	self._unit:network():send_to_host("long_dis_interaction", amount, aggressor_unit, secondary)
end

function HuskCopBrain:player_ignore()
	return false
end

function HuskCopBrain:on_team_set(team_data)
end

function HuskCopBrain:update(unit, t, dt)
	if self._add_laser_t ~= nil and self._post_init_complete then
		self._add_laser_t = self._add_laser_t - dt

		if self._add_laser_t < 0 then
			self:enable_weapon_laser()

			self._add_laser_t = nil
		end
	end
end

function HuskCopBrain:sync_net_event(event_id)
	if event_id == self._NET_EVENTS.weapon_laser_on then
		self._add_laser_t = HuskCopBrain._ENABLE_LASER_TIME
	elseif event_id == self._NET_EVENTS.weapon_laser_off then
		self:disable_weapon_laser()
	end
end

function HuskCopBrain:enable_weapon_laser()
	self._weapon_laser_on = true

	self._unit:inventory():equipped_unit():base():set_laser_enabled(true)
	managers.enemy:_destroy_unit_gfx_lod_data(self._unit:key())
end

function HuskCopBrain:disable_weapon_laser()
	self._weapon_laser_on = nil

	if self._unit:inventory():equipped_unit() then
		self._unit:inventory():equipped_unit():base():set_laser_enabled(false)
	end

	if not self._unit:character_damage():dead() then
		managers.enemy:_create_unit_gfx_lod_data(self._unit)
	end
end

function HuskCopBrain:pre_destroy()
	if Network:is_server() then
		self._unit:movement():set_attention()
	else
		self._unit:movement():synch_attention()
	end

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)

		self._alert_listen_key = nil
	end

	if self._weapon_laser_on then
		self:sync_net_event(self._NET_EVENTS.weapon_laser_off)
	end
end
