core:module("CoreElementPlaySound")
core:import("CoreMissionScriptElement")

ElementPlaySound = ElementPlaySound or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlaySound:init(...)
	ElementPlaySound.super.init(self, ...)
end

function ElementPlaySound:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlaySound:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._source and self:value("interrupt") ~= false then
		self._source:stop()
	end

	if self._values.use_instigator then
		if Network:is_server() and alive(instigator) and instigator:id() ~= -1 then
			instigator:sound():say(self._values.sound_event, true, not self._values.append_prefix, true)
		end
	elseif not self._values.elements or #self._values.elements == 0 then
		self:_play_sound()
	elseif Network:is_server() then
		self:_play_sound_on_elements()
	end

	ElementPlaySound.super.on_executed(self, instigator)
end

function ElementPlaySound:_play_sound_on_elements()
	local function f(unit)
		if unit:id() ~= -1 then
			unit:sound():say(self._values.sound_event, true, not self._values.append_prefix, true)
		end
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:execute_on_all_units(f)
	end
end

function ElementPlaySound:_play_sound()
	if self._values.sound_event then
		if self._source then
			self._source:stop()
		end

		self._source = SoundDevice:create_source(self._editor_name)

		self._source:set_position(self._values.position)
		self._source:set_orientation(self._values.rotation)

		if self._source:post_event(self._values.sound_event, callback(self, self, "sound_ended"), nil, "end_of_event") then
			self._mission_script:add_save_state_cb(self._id)
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant play sound event nil [" .. self._editor_name .. "]")
	end
end

function ElementPlaySound:sound_ended(...)
	self._mission_script:remove_save_state_cb(self._id)
end

function ElementPlaySound:operation_remove()
	if self._source then
		self._source:stop()
		self:sound_ended()
	end
end

function ElementPlaySound:save(data)
end

function ElementPlaySound:load(data)
	self:_play_sound()
end

function ElementPlaySound:stop_simulation()
	if self._source then
		self._source:stop()
	end

	ElementPlaySound.super.stop_simulation(self)
end

function ElementPlaySound:pre_destroy()
	if self._source then
		self._source:stop()
		self:sound_ended()
	end
end

function ElementPlaySound:destroy()
	if self._source then
		self._source:stop()
		self._source:delete()

		self._source = nil

		self:sound_ended()
	end
end
