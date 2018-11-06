RepelRopeBase = RepelRopeBase or class()

function RepelRopeBase:init(unit)
	self._tmp_vec3 = Vector3()

	unit:m_position(self._tmp_vec3)

	self._unit = unit
	self._end_object = unit:get_object(Idstring(self._end_object_name))

	unit:set_extension_update_enabled(Idstring("base"), false)
end

function RepelRopeBase:update(unit, t, dt)
	if self._retracting then
		local prog = (t - self._retract_start_t) / self._retract_duration

		if prog > 1 then
			unit:set_slot(0)
		else
			prog = prog^3
			local new_pos = self._tmp_vec3

			self._unit:m_position(new_pos)
			mvector3.lerp(new_pos, self._retract_pos, new_pos, prog)
			self._end_object:set_position(new_pos)
		end
	else
		local new_pos = self._tmp_vec3

		self._attach_obj:m_position(new_pos)
		self._end_object:set_position(new_pos)
	end
end

function RepelRopeBase:setup(attach_object)
	self._attach_obj = attach_object

	self._unit:set_extension_update_enabled(Idstring("base"), true)
end

function RepelRopeBase:retract()
	if not self._retracting then
		self._retracting = true
		self._retract_start_t = TimerManager:game():time()
		self._retract_pos = self._attach_obj:position()

		self._unit:m_position(self._tmp_vec3)

		self._retract_duration = math.max(1, mvector3.distance(self._retract_pos, self._tmp_vec3)) / 600
	end
end
