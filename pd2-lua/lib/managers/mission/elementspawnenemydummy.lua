core:import("CoreMissionScriptElement")

ElementSpawnEnemyDummy = ElementSpawnEnemyDummy or class(CoreMissionScriptElement.MissionScriptElement)
ElementSpawnEnemyDummy._unit_destroy_clbk_key = "ElementSpawnEnemyDummy"
ElementSpawnEnemyDummy.ACCESSIBILITIES = {
	"any",
	"walk",
	"acrobatic"
}

function ElementSpawnEnemyDummy:init(...)
	ElementSpawnEnemyDummy.super.init(self, ...)

	self._enemy_name = self._values.enemy and Idstring(self._values.enemy) or Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
	self._values.enemy = nil
	self._units = {}
	self._events = {}

	self:_finalize_values()
end

function ElementSpawnEnemyDummy:_finalize_values()
	local values = self._values
	values.spawn_action = self:value("spawn_action")

	local function _save_boolean(name_in)
		values[name_in] = values[name_in] or nil
	end

	local function _nil_if_none(name_in)
		if not values[name_in] or values[name_in] == "none" then
			values[name_in] = nil
		end
	end

	local function _index_or_nil(table_in, name_in)
		local found_index = table.index_of(table_in, values[name_in])
		values[name_in] = found_index ~= -1 and found_index or nil
	end

	_nil_if_none("force_pickup")
	_index_or_nil(CopActionAct._act_redirects.enemy_spawn, "spawn_action")
	_index_or_nil(CopActionAct._act_redirects.civilian_spawn, "state")
	_save_boolean("participate_to_group_ai")
	_index_or_nil(self.ACCESSIBILITIES, "accessibility")

	values.voice = values.voice and values.voice ~= 0 and values.voice or nil

	if values.team == "default" then
		values.team = nil
	end

	self._values = clone(values)
end

function ElementSpawnEnemyDummy:enemy_name()
	return self._enemy_name
end

function ElementSpawnEnemyDummy:units()
	return self._units
end

function ElementSpawnEnemyDummy:produce(params)
	if not managers.groupai:state():is_AI_enabled() then
		return
	end

	local unit = nil

	if params and params.name then
		unit = safe_spawn_unit(params.name, self:get_orientation())
		local spawn_ai = self:_create_spawn_AI_parametric(params.stance, params.objective, self._values)

		unit:brain():set_spawn_ai(spawn_ai)
	else
		local enemy_name = self:value("enemy") or self._enemy_name
		unit = safe_spawn_unit(enemy_name, self:get_orientation())
		local objective = nil
		local action = self._create_action_data(CopActionAct._act_redirects.enemy_spawn[self._values.spawn_action])
		local stance = managers.groupai:state():enemy_weapons_hot() and "cbt" or "ntl"

		if action.type == "act" then
			objective = {
				type = "act",
				action = action,
				stance = stance
			}
		end

		local spawn_ai = {
			init_state = "idle",
			objective = objective
		}

		unit:brain():set_spawn_ai(spawn_ai)

		local team_id = params and params.team or self._values.team or tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")

		if self._values.participate_to_group_ai then
			managers.groupai:state():assign_enemy_to_group_ai(unit, team_id)
		else
			managers.groupai:state():set_char_team(unit, team_id)
		end

		if self._values.voice then
			unit:sound():set_voice_prefix(self._values.voice)
		end
	end

	unit:base():add_destroy_listener(self._unit_destroy_clbk_key, callback(self, self, "clbk_unit_destroyed"))

	unit:unit_data().mission_element = self

	table.insert(self._units, unit)
	self:event("spawn", unit)

	if self._values.force_pickup and self._values.force_pickup ~= "none" then
		local pickup_name = self._values.force_pickup ~= "no_pickup" and self._values.force_pickup or nil

		unit:character_damage():set_pickup(pickup_name)
	end

	return unit
end

function ElementSpawnEnemyDummy:clbk_unit_destroyed(unit)
	local u_key = unit:key()

	for i, owned_unit in ipairs(self._units) do
		if owned_unit:key() == u_key then
			table.remove(self._units, i)
		end
	end
end

function ElementSpawnEnemyDummy:event(name, unit)
	if self._events[name] then
		for _, callback in ipairs(self._events[name]) do
			callback(unit)
		end
	end
end

function ElementSpawnEnemyDummy:add_event_callback(name, callback)
	self._events[name] = self._events[name] or {}

	table.insert(self._events[name], callback)
end

function ElementSpawnEnemyDummy:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not managers.groupai:state():is_AI_enabled() and not Application:editor() then
		return
	end

	local unit = self:produce()

	ElementSpawnEnemyDummy.super.on_executed(self, unit)
end

function ElementSpawnEnemyDummy:_create_spawn_AI_parametric(stance, objective, spawn_properties)
	local entry_action = self._create_action_data(CopActionAct._act_redirects.enemy_spawn[self._values.spawn_action])

	if entry_action.type == "act" then
		local followup_objective = objective
		objective = {
			type = "act",
			action = entry_action,
			followup_objective = followup_objective
		}
	end

	return {
		init_state = "idle",
		stance = stance,
		objective = objective,
		params = {
			scan = true
		}
	}
end

function ElementSpawnEnemyDummy._create_action_data(anim_name)
	if not anim_name or anim_name == "none" then
		return {
			sync = true,
			body_part = 1,
			type = "idle"
		}
	else
		return {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = anim_name,
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				walk = -1
			}
		}
	end
end

function ElementSpawnEnemyDummy:unspawn_all_units()
	for _, unit in ipairs(self._units) do
		if alive(unit) then
			unit:brain():set_active(false)
			unit:base():set_slot(unit, 0)
		end
	end
end

function ElementSpawnEnemyDummy:kill_all_units()
	for _, unit in ipairs(self._units) do
		if alive(unit) then
			unit:character_damage():damage_mission({
				damage = 1000,
				forced = true
			})
		end
	end
end

function ElementSpawnEnemyDummy:execute_on_all_units(func)
	for _, unit in ipairs(self._units) do
		if alive(unit) then
			func(unit)
		end
	end
end

function ElementSpawnEnemyDummy:accessibility()
	return self.ACCESSIBILITIES[self._values.accessibility]
end
