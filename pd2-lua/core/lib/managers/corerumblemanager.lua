core:module("CoreRumbleManager")

RumbleManager = RumbleManager or class()

function RumbleManager:init()
	self._last_played_ids = {}
	self._preset_rumbles = {}
	self._rumbling_controller_types = {}

	self:initialize_controller_types()

	self._registered_controllers = {}
	self._registered_controller_count = {}
	self._registered_controller_pos_callback_list = {}
	self._enabled = true
end

function RumbleManager:add_preset_rumbles(name, data)
	self._preset_rumbles[name] = data
end

function RumbleManager:initialize_controller_types()
	self._rumbling_controller_types.xbox360 = true
	self._rumbling_controller_types.ps3 = true
	self._rumbling_controller_types.ps4 = true
	self._rumbling_controller_types.xb1 = true
	self._rumbling_controller_types.vr = true
end

function RumbleManager:stop(rumble_id)
	if rumble_id then
		if rumble_id == "all" then
			for _, controller in pairs(self._registered_controllers) do
				if controller then
					controller:stop_rumble()
				end
			end
		else
			for _, controller in pairs(rumble_id.controllers) do
				controller:stop_rumble(rumble_id[1])

				if rumble_id[2] then
					controller:stop_rumble(rumble_id[2])
				end
			end
		end
	end
end

function RumbleManager:register_controller(controller, pos_callback)
	if self._rumbling_controller_types[controller.TYPE] then
		local ctrl = controller:get_controller()
		local key = ctrl:key()
		self._registered_controllers[key] = ctrl
		self._registered_controller_count[key] = (self._registered_controller_count[key] or 0) + 1
		self._registered_controller_pos_callback_list[key] = self._registered_controller_pos_callback_list[key] or {}
		self._registered_controller_pos_callback_list[key][pos_callback] = true

		return true
	end
end

function RumbleManager:unregister_controller(controller, pos_callback)
	local ctrl = controller:get_controller()
	local key = ctrl:key()
	self._registered_controller_count[key] = (self._registered_controller_count[key] or 0) - 1

	if self._registered_controller_count[key] <= 0 then
		self._registered_controllers[key] = nil
		self._registered_controller_count[key] = nil
	end

	if self._registered_controller_pos_callback_list[key] then
		self._registered_controller_pos_callback_list[key][pos_callback] = nil

		if not next(self._registered_controller_pos_callback_list[key]) then
			self._registered_controller_pos_callback_list[key] = nil
		end
	end
end

function RumbleManager:set_enabled(enabled)
	self._enabled = enabled

	if not enabled then
		self:stop("all")
	end
end

function RumbleManager:enabled()
	return self._enabled
end

function RumbleManager:play(name, controller_wrapper, multiplier_data, custom_data)
	if not self._enabled then
		return false
	end

	local rumble_controllers = nil

	if not controller_wrapper then
		rumble_controllers = self._registered_controllers
	elseif self._rumbling_controller_types[controller_wrapper.TYPE] then
		local ctrl = controller_wrapper:get_controller()
		rumble_controllers[ctrl:key()] = ctrl
	end

	local effect = self._preset_rumbles[name]

	if effect then
		local rumble_id = {
			controllers = rumble_controllers,
			name = name
		}
		local custom_peak = custom_data and custom_data.peak
		local custom_attack = custom_data and custom_data.attack
		local custom_sustain = custom_data and custom_data.sustain
		local custom_release = custom_data and custom_data.release
		local custom_engine = custom_data and custom_data.engine

		for _, controller in pairs(rumble_controllers) do
			if self._last_played_ids[controller:key()] then
				local redundant_rumble = self._last_played_ids[controller:key()][name]

				if redundant_rumble and (controller:is_rumble_playing(redundant_rumble[1]) or controller:is_rumble_playing(redundant_rumble[2])) then
					self:stop(redundant_rumble)
				end
			end

			local multiplier = multiplier_data or 1
			local timer = effect.timer or TimerManager:game()

			if multiplier_data and type(multiplier_data) == "table" and multiplier_data.func then
				multiplier = multiplier_data.func(self._registered_controller_pos_callback_list[controller:key()], multiplier_data.params) or 1
			end

			if effect.engine == "hybrid" then
				table.insert(rumble_id, 1, controller:rumble({
					engine = "left",
					timer = timer,
					peak = (effect.peak.l or 1) * multiplier,
					attack = effect.attack.l,
					sustain = effect.sustain.l,
					release = effect.release.l
				}))
				table.insert(rumble_id, 2, controller:rumble({
					engine = "right",
					timer = timer,
					peak = (effect.peak.r or 1) * multiplier,
					attack = effect.attack.r,
					sustain = effect.sustain.r,
					release = effect.release.r
				}))
			else
				rumble_id[1] = controller:rumble({
					engine = custom_engine or effect.engine,
					timer = timer,
					peak = (custom_peak or effect.peak or 1) * multiplier,
					attack = custom_attack or effect.attack,
					sustain = custom_sustain or effect.sustain,
					release = custom_release or effect.release
				})
			end

			if not effect.cumulative then
				self._last_played_ids[controller:key()] = self._last_played_ids[controller:key()] or {}
				self._last_played_ids[controller:key()][name] = rumble_id
			end
		end

		return rumble_id
	else
		Application:error("RumbleManager:: Effect ", name, " not found.")
	end
end

function RumbleManager:set_multiplier(rumble_id, multiplier)
	if not self._enabled or not rumble_id or not multiplier then
		return false
	end

	local effect = self._preset_rumbles[rumble_id.name]

	for _, controller in pairs(rumble_id.controllers) do
		if rumble_id[2] then
			controller:set_rumble_peak(rumble_id[1], (effect.peak.l or 1) * multiplier)
			controller:set_rumble_peak(rumble_id[2], (effect.peak.r or 1) * multiplier)
		else
			controller:set_rumble_peak(rumble_id[1], (effect.peak or 1) * multiplier)
		end
	end
end

function RumbleManager:mult_distance_lerp(pos_func_list, params)
	if pos_func_list then
		local closest_pos = nil

		for pos_func in pairs(pos_func_list) do
			local next_closest_pos = pos_func(params)

			if not closest_pos or (next_closest_pos - source):lenght() < (closest_pos - source):length() then
				closest_pos = next_closest_pos
			end
		end

		if closest_pos then
			local full_dis = params.full_dis or 0
			local zero_dis = params.zero_dis or 1000 - full_dis
			local mult = params.multiplier or 1
			local source = params.source
			mult = mult * (zero_dis - math.clamp((source - closest_pos):length() - full_dis, 0, zero_dis)) / zero_dis

			return mult
		end
	end

	return 0
end
