core:import("CoreMissionScriptElement")

ElementCinematicCamera = ElementCinematicCamera or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCinematicCamera:init(...)
	ElementCinematicCamera.super.init(self, ...)

	self._camera_unit = nil
end

function ElementCinematicCamera:on_script_activated()
	self._camera_unit = safe_spawn_unit(Idstring("units/pd2_cinematics/cs_camera/cs_camera"), self._values.position, self._values.rotation)

	self._camera_unit:base():set_mission_element(self)
end

function ElementCinematicCamera:client_on_executed(...)
end

function ElementCinematicCamera:on_executed(instigator, alternative, ...)
	if not self._values.enabled then
		return
	end

	if not alternative or type_name(alternative) ~= "string" then
		self._camera_unit:base():start()
		self._camera_unit:base():play_state(Idstring(self._values.state))
	end

	ElementCinematicCamera.super.on_executed(self, instigator, alternative or "normal", ...)
end

function ElementCinematicCamera:anim_clbk_done()
	self._camera_unit:base():stop()
	self:on_executed(nil, "camera_done")
end

function ElementCinematicCamera:_delete_camera_unit()
	if not self._camera_unit then
		return
	end

	World:delete_unit(self._camera_unit)

	self._camera_unit = nil
end

function ElementCinematicCamera:stop_simulation(...)
	ElementCinematicCamera.super.stop_simulation(self, ...)
	self:_delete_camera_unit()
end

function ElementCinematicCamera:pre_destroy(...)
	ElementCinematicCamera.super.pre_destroy(self, ...)
	self:_delete_camera_unit()
end
