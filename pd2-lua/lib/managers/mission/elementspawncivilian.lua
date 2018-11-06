core:import("CoreMissionScriptElement")

ElementSpawnCivilian = ElementSpawnCivilian or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSpawnCivilian:init(...)
	ElementSpawnCivilian.super.init(self, ...)

	self._enemy_name = self._values.enemy and Idstring(self._values.enemy) or Idstring("units/characters/civilians/dummy_civilian_1/dummy_civilian_1")
	self._units = {}

	self:_finalize_values()
end

function ElementSpawnCivilian:_finalize_values()
	self._values.state = self:value("state")
	local state_index = table.index_of(CopActionAct._act_redirects.civilian_spawn, self._values.state)
	self._values.state = state_index ~= -1 and state_index or nil
	self._values.force_pickup = self._values.force_pickup ~= "none" and self._values.force_pickup or nil
	self._values.team = self._values.team ~= "default" and self._values.team or nil
end

function ElementSpawnCivilian:enemy_name()
	return self._enemy_name
end

function ElementSpawnCivilian:units()
	return self._units
end

function ElementSpawnCivilian:produce(params)
	if not managers.groupai:state():is_AI_enabled() then
		return
	end

	local default_team_id = params and params.team or self._values.team or tweak_data.levels:get_default_team_ID("non_combatant")
	local unit = safe_spawn_unit(self._enemy_name, self:get_orientation())
	unit:unit_data().mission_element = self

	table.insert(self._units, unit)

	if self._values.state then
		local state = CopActionAct._act_redirects.civilian_spawn[self._values.state]

		if unit:brain() then
			local action_data = {
				align_sync = true,
				body_part = 1,
				type = "act",
				variant = state
			}
			local spawn_ai = {
				init_state = "idle",
				objective = {
					interrupt_health = 1,
					interrupt_dis = -1,
					type = "act",
					action = action_data
				}
			}

			unit:brain():set_spawn_ai(spawn_ai)
		else
			unit:base():play_state(state)
		end
	end

	if self._values.force_pickup then
		unit:character_damage():set_pickup(self._values.force_pickup)
	end

	unit:movement():set_team(managers.groupai:state():team_data(default_team_id))
	self:event("spawn", unit)

	return unit
end

function ElementSpawnCivilian:event(name, unit)
	if self._events and self._events[name] then
		for _, callback in ipairs(self._events[name]) do
			callback(unit)
		end
	end
end

function ElementSpawnCivilian:add_event_callback(name, callback)
	self._events = self._events or {}
	self._events[name] = self._events[name] or {}

	table.insert(self._events[name], callback)
end

function ElementSpawnCivilian:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not managers.groupai:state():is_AI_enabled() and not Application:editor() then
		return
	end

	local unit = self:produce()

	ElementSpawnCivilian.super.on_executed(self, unit)
end

function ElementSpawnCivilian:unspawn_all_units()
	ElementSpawnEnemyDummy.unspawn_all_units(self)
end

function ElementSpawnCivilian:kill_all_units()
	ElementSpawnEnemyDummy.kill_all_units(self)
end

function ElementSpawnCivilian:execute_on_all_units(func)
	ElementSpawnEnemyDummy.execute_on_all_units(self, func)
end
