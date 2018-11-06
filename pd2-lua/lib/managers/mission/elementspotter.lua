core:import("CoreMissionScriptElement")

ElementSpotter = ElementSpotter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSpotter:init(...)
	ElementSpotter.super.init(self, ...)

	self._forward = self._values.rotation:y()
	self._enemy_contours = {}
end

function ElementSpotter:on_script_activated()
	if self._values.enabled then
		self:add_callback()
	end
end

function ElementSpotter:set_enabled(enabled)
	ElementSpotter.super.set_enabled(self, enabled)

	if enabled then
		self:add_callback()
	else
		self:remove_callback()
	end
end

function ElementSpotter:add_callback()
	if not Network:is_server() then
		return
	end

	if not self._callback then
		self._callback = self._mission_script:add(callback(self, self, "update_spotter"), 0.1)
	end
end

function ElementSpotter:remove_callback()
	if self._callback then
		self._mission_script:remove(self._callback)

		self._callback = nil
	end
end

function ElementSpotter:on_executed(instigator, ...)
	if not self._values.enabled then
		return
	end

	ElementSpotter.super.on_executed(self, instigator, ...)
end

local mvec1 = Vector3()

function ElementSpotter:update_spotter()
	if not self._values.enabled then
		return
	end

	if self._found_units then
		local unit = table.remove(self._found_units, 1)
		self._found_units = #self._found_units > 0 and self._found_units or nil

		if not alive(unit) or unit:character_damage():dead() or not unit:base()._tweak_table then
			return
		end

		if managers.groupai:state():whisper_mode() then
			if not tweak_data.character[unit:base()._tweak_table].silent_priority_shout and not tweak_data.character[unit:base()._tweak_table].priority_shout then
				return
			end
		elseif not tweak_data.character[unit:base()._tweak_table].priority_shout then
			return
		end

		mvector3.set(mvec1, unit:movement():m_head_pos())
		mvector3.subtract(mvec1, self._values.position)
		mvector3.normalize(mvec1)

		local angle = mvector3.angle(self._forward, mvec1)

		if angle < 45 then
			local ray = World:raycast("ray", unit:movement():m_head_pos(), self._values.position, "ray_type", "ai_vision", "slot_mask", managers.slot:get_mask("world_geometry"), "report")

			if not ray then
				if managers.game_play_central:auto_highlight_enemy(unit, false) then
					self:on_executed(unit, "on_outlined")
				end

				self:on_executed(unit, "on_spotted")
			end
		end
	else
		self._found_units = World:find_units_quick("all", managers.slot:get_mask("enemies"))
		self._found_units = #self._found_units > 0 and self._found_units or nil
	end
end
