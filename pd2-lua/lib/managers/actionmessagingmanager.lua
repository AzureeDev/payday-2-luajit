ActionMessagingManager = ActionMessagingManager or class()
ActionMessagingManager.PATH = "gamedata/action_messages"
ActionMessagingManager.FILE_EXTENSION = "action_message"
ActionMessagingManager.FULL_PATH = ActionMessagingManager.PATH .. "." .. ActionMessagingManager.FILE_EXTENSION

function ActionMessagingManager:init()
	self._messages = {}

	self:_parse_messages()
end

function ActionMessagingManager:_parse_messages()
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())

	for _, data in ipairs(list) do
		if data._meta == "message" then
			self:_parse_message(data)
		else
			Application:error("Unknown node \"" .. tostring(data._meta) .. "\" in \"" .. self.FULL_PATH .. "\". Expected \"message\" node.")
		end
	end
end

function ActionMessagingManager:_parse_message(data)
	local id = data.id
	local text_id = data.text_id
	local event = data.event
	local dialog_id = data.dialog_id
	local equipment_id = data.equipment_id
	self._messages[id] = {
		text_id = text_id,
		event = event,
		dialog_id = dialog_id,
		equipment_id = equipment_id
	}
end

function ActionMessagingManager:ids()
	local t = {}

	for id, _ in pairs(self._messages) do
		table.insert(t, id)
	end

	table.sort(t)

	return t
end

function ActionMessagingManager:messages()
	return self._messages
end

function ActionMessagingManager:message(id)
	return self._messages[id]
end

function ActionMessagingManager:show_message(id, instigator)
	if not id or not self:message(id) then
		Application:stack_dump_error("Bad id to show message, " .. tostring(id) .. ".")

		return
	end

	self:_show_message(id, instigator)
end

function ActionMessagingManager:_show_message(id, instigator)
	local msg_data = self:message(id)

	if not msg_data then
		debug_pause_unit(instigator, "ActionMessagingManager:_show_message: Missing action message with id", id)

		return
	end

	local title = instigator:base():nick_name()
	local icon = nil
	local msg = ""

	if msg_data.equipment_id then
		title = title .. " " .. managers.localization:text("message_obtained_equipment")
		local equipment = tweak_data.equipments.specials[msg_data.equipment_id]
		icon = equipment.icon
		msg = managers.localization:text(equipment.text_id)
	else
		title = title .. ":"
		msg = managers.localization:text(self:message(id).text_id)
	end

	managers.hud:present_mid_text({
		time = 4,
		title = utf8.to_upper(title),
		text = utf8.to_upper(msg),
		icon = icon,
		event = self:message(id).event
	})

	if self:message(id).dialog_id then
		managers.dialog:queue_narrator_dialog(self:message(id).dialog_id, {})
	end
end

function ActionMessagingManager:sync_show_message(id, instigator)
	if alive(instigator) and managers.network:session():peer_by_unit(instigator) then
		self:_show_message(id, instigator)
	end
end

function ActionMessagingManager:save(data)
end

function ActionMessagingManager:load(data)
end
