core:import("CoreMissionScriptElement")

ElementPlayerCharacterTrigger = ElementPlayerCharacterTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlayerCharacterTrigger:init(...)
	ElementPlayerCharacterTrigger.super.init(self, ...)
end

function ElementPlayerCharacterTrigger:on_script_activated()
	ElementPlayerCharacterTrigger.super.on_script_activated(self)

	local is_host = Network:is_server() or Global.game_settings.single_player

	if is_host then
		managers.criminals:add_listener(string.format("add_criminal_event_%s", tostring(self._id)), {
			"on_criminal_added"
		}, callback(self, self, "on_criminal_added"))
		managers.criminals:add_listener(string.format("rmv_criminal_event_%s", tostring(self._id)), {
			"on_criminal_removed"
		}, callback(self, self, "on_criminal_removed"))
	end
end

function ElementPlayerCharacterTrigger:on_criminal_added(name, unit, peer_id, ai)
	if not self:value("trigger_on_left") and self:value("character") == name then
		self:on_executed()
	end
end

function ElementPlayerCharacterTrigger:on_criminal_removed(data)
	local name = data.name

	if self:value("trigger_on_left") and self:value("character") == name then
		self:on_executed()
	end
end

function ElementPlayerCharacterTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementPlayerStateTrigger.super.on_executed(self, self._unit or instigator)
end

ElementPlayerCharacterFilter = ElementPlayerCharacterFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlayerCharacterFilter:init(...)
	ElementPlayerCharacterFilter.super.init(self, ...)
end

function ElementPlayerCharacterFilter:on_script_activated()
	ElementPlayerCharacterFilter.super.on_script_activated(self)

	if self:value("execute_on_startup") then
		self:on_executed()
	end
end

function ElementPlayerCharacterFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local char_taken = self:is_character_taken(instigator)
	local require_char = self:value("require_presence")

	if char_taken and not require_char or require_char and not char_taken then
		return
	end

	ElementPlayerStateTrigger.super.on_executed(self, self._unit or instigator)
end

function ElementPlayerCharacterFilter:is_character_taken(instigator)
	if self:value("check_instigator") then
		return managers.criminals:character_name_by_unit(instigator) == self:value("character")
	else
		return managers.criminals:is_taken(self:value("character"))
	end
end
