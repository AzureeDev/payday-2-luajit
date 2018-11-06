ScriptUnitData = ScriptUnitData or class(CoreScriptUnitData)

function ScriptUnitData:init(unit)
	CoreScriptUnitData.init(self)

	if managers.occlusion and self.skip_occlusion then
		managers.occlusion:remove_occlusion(unit)
	end
end

function ScriptUnitData:destroy(unit)
	if managers.occlusion and self.skip_occlusion then
		managers.occlusion:add_occlusion(unit)
	end

	if self._destroy_listener_holder then
		self._destroy_listener_holder:call(unit)
	end
end

function ScriptUnitData:add_destroy_listener(key, clbk)
	self._destroy_listener_holder = self._destroy_listener_holder or ListenerHolder:new()

	self._destroy_listener_holder:add(key, clbk)
end

function ScriptUnitData:remove_destroy_listener(key)
	self._destroy_listener_holder:remove(key)

	if self._destroy_listener_holder:is_empty() then
		self._destroy_listener_holder = nil
	end
end
