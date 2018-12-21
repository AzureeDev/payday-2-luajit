require("lib/utils/NNetHelper")

VRBodyCalibrator = VRBodyCalibrator or class()
VRBodyCalibrator.STATE_RUNNING = 1
VRBodyCalibrator.STATE_COMPLETE = 2
VRBodyCalibrator.STATE_FAILED = 3

function VRBodyCalibrator:init(controller)
	self._controller = controller
	self._x_length = 0
	self._y_length = 0
	self._arm_length = tweak_data.vr.default_body_metrics.arm_length
	self._head_to_shoulder = tweak_data.vr.default_body_metrics.head_to_shoulder
	self._shoulder_width = tweak_data.vr.default_body_metrics.shoulder_width
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
	self._best_point = Vector3(0, 0, 0)
end

function VRBodyCalibrator:refresh_settings()
	for _, setting in ipairs(self._settings) do
		setting.clbk(setting.name, nil, managers.vr:get_setting(setting.name))
	end
end

function VRBodyCalibrator:body_config()
	return self._body_config
end

function VRBodyCalibrator:is_good()
	return self._calibration_data.arm_length > 10 and self._calibration_data.shoulder_width and self._calibration_data.head_to_shoulder > 10
end

function VRBodyCalibrator:start_calibration(clbk)
	self._x_length = 0
	self._y_length = 0
	self._arm_length = 0
	self._head_to_shoulder = 0
	self._shoulder_width = 0
	self._best_point = Vector3(0, 0, 0)
	self._calibration_state = VRBodyCalibrator.STATE_RUNNING
	self._calibration_start_t = TimerManager:main():time()
	self._calibration_timeout_t = 15
	self._calbration_clbk = clbk
	self._body_config = NNetHelper.create_body_config(0, 0, 0)
	self._best_value = nil
	self._side_to_side = nil
	self._min_length = 1000
	self._max_length = -1000
	self._max_height = -1000
	self._calibration_data = {
		head_to_shoulder = 0,
		shoulder_width = 0,
		passed = 0,
		arm_length = 0
	}
end

function VRBodyCalibrator:stop_calibration(succeeded)
	self._calibration_state = nil

	if succeeded and self:is_good() then
		self:update_settings()
	end
end

local CONTROLLER_ROT = Rotation(math.X, -50)
local CONTROLLER_OFFSET = Vector3(0, -2, -7)

function VRBodyCalibrator:update(t, dt)
	local hmd_position, hmd_rotation = VRManager:hmd_pose()
	local rc = self._controller:position(0)
	local rr = self._controller:rotation(0)
	local lc = self._controller:position(1)
	local lr = self._controller:rotation(1)

	mrotation.multiply(rr, CONTROLLER_ROT)
	mrotation.multiply(lr, CONTROLLER_ROT)

	rc = rc + CONTROLLER_OFFSET:rotate_with(rr)
	lc = lc + CONTROLLER_OFFSET:rotate_with(lr)

	if self._calibration_state == VRBodyCalibrator.STATE_RUNNING then
		self:_calibrate(hmd_position, hmd_rotation, rc, lc)
		self:_update_calibration_state(t)
	end
end

function VRBodyCalibrator:update_settings()
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)

	managers.vr:set_setting("arm_length", self._arm_length)
	managers.vr:set_setting("head_to_shoulder", self._head_to_shoulder)
	managers.vr:set_setting("shoulder_width", self._shoulder_width)
end

function VRBodyCalibrator:_add_setting_callback(setting_name, method)
	local clbk = callback(self, self, method)

	managers.vr:add_setting_changed_callback(setting_name, clbk)
	clbk(setting_name, nil, managers.vr:get_setting(setting_name))

	self._settings = self._settings or {}

	table.insert(self._settings, {
		name = setting_name,
		clbk = clbk
	})
end

function VRBodyCalibrator:_arm_length_changed(setting, old, new)
	self._arm_length = new
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
end

function VRBodyCalibrator:_head_to_shoulder_changed(setting, old, new)
	self._head_to_shoulder = new
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
end

function VRBodyCalibrator:_shoulder_width_changed(setting, old, new)
	self._shoulder_width = new
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
end

function VRBodyCalibrator:_calibrate(hmd_position, hmd_rotation, rc, lc)
	local hmd = hmd_position
	local rot = hmd_rotation
	local side_to_side = mvector3.distance(rc:with_z(0), lc:with_z(0))

	if not self._side_to_side or self._side_to_side < side_to_side then
		self._side_to_side = side_to_side
	end

	local len = (rc.z + lc.z) * 0.5

	if len < self._min_length then
		self._min_length = len
	end

	if self._max_length < len then
		self._max_length = len
	end

	if self._max_height < hmd.z and math.abs(mvector3.dot(hmd_rotation:z(), math.Z)) > 0.9 then
		self._max_height = hmd.z
	end

	local arm_length = (self._max_length - self._min_length) * 0.5
	local neck_length = self._max_height - self._min_length - arm_length
	local shoulder_length = self._max_height - self._min_length - self._side_to_side * 0.5 + neck_length
	self._arm_length = math.round(arm_length + 5)
	self._shoulder_width = math.round(shoulder_length + 10)
	self._head_to_shoulder = math.round(neck_length)
end

function VRBodyCalibrator:_update_calibration_state(t)
	self._calibration_t = self._calibration_t or t + 0.1

	if self._calibration_t < t then
		local d1 = self._calibration_data.arm_length - self._arm_length
		local d2 = self._calibration_data.shoulder_width - self._shoulder_width
		local d3 = self._calibration_data.head_to_shoulder - self._head_to_shoulder
		local error_value = (d1 * d1 + d2 * d2 + d3 * d3) / 3
		self._calibration_data.arm_length = self._arm_length
		self._calibration_data.shoulder_width = self._shoulder_width
		self._calibration_data.head_to_shoulder = self._head_to_shoulder

		if error_value < 1 then
			self._calibration_data.passed = self._calibration_data.passed + 1
		else
			self._calibration_data.passed = 0
		end

		self._body_config = NNetHelper.create_body_config(math.max(self._arm_length, 0), math.max(self._head_to_shoulder, 0), math.max(self._shoulder_width, 0))
		self._calibration_t = nil
	end
end
