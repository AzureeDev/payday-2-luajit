BipodDeployControllerInput = BipodDeployControllerInput or class()

function BipodDeployControllerInput:init()
	self._deploy_bipod_t = 0
	self._deploy_bipod_waiting = true
end

function BipodDeployControllerInput:update(t, dt, controller, input)
	input.btn_weapon_gadget_press = false

	if input.any_input_pressed and controller:get_input_pressed("weapon_gadget") then
		self._deploy_bipod_t = t
		self._deploy_bipod_waiting = true
	elseif input.any_input_downed and controller:get_input_bool("weapon_gadget") then
		if self._deploy_bipod_waiting and t - self._deploy_bipod_t > 0.5 then
			input.btn_deploy_bipod = true
			self._deploy_bipod_t = 0
			self._deploy_bipod_waiting = false
		end
	elseif input.any_input_released and controller:get_input_released("weapon_gadget") then
		self._deploy_bipod_t = 0

		if self._deploy_bipod_waiting then
			self._deploy_bipod_waiting = false
			input.btn_weapon_gadget_press = true
		end
	end
end
