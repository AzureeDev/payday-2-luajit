InfamyManager = InfamyManager or class()
InfamyManager.VERSION = 3

function InfamyManager:init()
	self:_setup()
end

function InfamyManager:_setup(reset)
	if not Global.infamy_manager or reset then
		Global.infamy_manager = {
			points = Application:digest_value(0, true),
			VERSION = InfamyManager.VERSION,
			reset_message = false
		}
		self._global = Global.infamy_manager
		self._global.unlocks = {}

		for item_id, item_name in pairs(tweak_data.infamy.tree) do
			self._global.unlocks[item_name] = false
		end

		self._global.selected_join_stinger = 0
		self._global.join_stingers = {}

		for index = 0, tweak_data.infamy.join_stingers do
			self._global.join_stingers[index] = {
				index = index,
				unlocked = table.contains(tweak_data.infamy.free_join_stingers, index)
			}
		end
	end

	self._global = Global.infamy_manager
end

function InfamyManager:points()
	return Application:digest_value(self._global.points, false)
end

function InfamyManager:aquire_point()
end

function InfamyManager:_set_points(value)
	self._global.points = Application:digest_value(value, true)
end

function InfamyManager:_reset_points()
	self:_set_points(0)
	self:_verify_loaded_data()
end

function InfamyManager:required_points(item)
	return tweak_data.infamy.items[item] and true or false
end

function InfamyManager:reward_player_styles(global_value, category, player_style)
	managers.blackmarket:on_aquired_player_style(player_style)
end

function InfamyManager:reward_suit_variations(global_value, category, player_style, suit_variation)
	managers.blackmarket:on_aquired_suit_variation(player_style, suit_variation)
end

function InfamyManager:reward_gloves(global_value, category, glove_id)
	managers.blackmarket:on_aquired_glove_id(glove_id)
end

function InfamyManager:reward_item(global_value, category, item_id)
	local item_tweak = tweak_data.blackmarket[category][item_id]
	global_value = global_value or item_tweak.global_value or managers.dlc:dlc_to_global_value(item_tweak.dlc) or "normal"

	managers.blackmarket:add_to_inventory(global_value, category, item_id)
end

function InfamyManager:unlock_item(item)
	local infamy_item = tweak_data.infamy.items[item]

	if not infamy_item then
		debug_pause("InfamyManager:unlock_item]: Missing item = '" .. tostring(item) .. "'")

		return
	end

	if self:available(item) and not self:owned(item) then
		for bonus, entry in ipairs(infamy_item.upgrades) do
			self["reward_" .. tostring(entry[2])] or self.reward_item(self, unpack(entry))
		end

		if infamy_item.upgrades.join_stingers then
			for _, stinger_id in ipairs(infamy_item.upgrades.join_stingers) do
				self:unlock_join_stinger(stinger_id)
			end
		end

		self._global.unlocks[item] = true
	end
end

function InfamyManager:owned(item)
	return self._global.unlocks[item] or false
end

function InfamyManager:available(item)
	local current_rank = managers.experience:current_rank()

	for tree_rank, name in pairs(tweak_data.infamy.tree) do
		if item == name then
			return tree_rank <= current_rank
		end
	end

	return false
end

function InfamyManager:select_join_stinger(join_stinger)
	local stinger_data = self._global.join_stingers[join_stinger]

	if stinger_data and stinger_data.unlocked then
		self._global.selected_join_stinger = join_stinger
	end
end

function InfamyManager:selected_join_stinger()
	return self._global.selected_join_stinger
end

function InfamyManager:selected_join_stinger_index()
	local stinger_data = self._global.join_stingers[self._global.selected_join_stinger]

	return stinger_data and stinger_data.index or 0
end

function InfamyManager:is_join_stinger_unlocked(stinger_id)
	local stinger_data = self._global.join_stingers[stinger_id]

	return stinger_data and stinger_data.unlocked or false
end

function InfamyManager:unlock_join_stinger(stinger_id)
	local stinger_data = self._global.join_stingers[stinger_id]

	if stinger_data then
		stinger_data.unlocked = true

		if not self._global.selected_join_stinger then
			self._global.selected_join_stinger = stinger_id
		end
	end
end

function InfamyManager:get_unlocked_join_stingers()
	local unlocked_stingers = {}
	local stinger_data = nil

	for index = 0, tweak_data.infamy.join_stingers do
		stinger_data = self._global.join_stingers[index]

		if stinger_data.unlocked then
			table.insert(unlocked_stingers, index)
		end
	end

	return unlocked_stingers
end

function InfamyManager:get_all_join_stingers()
	local all_stingers = {}
	local join_stinger_data = nil

	for index = 0, tweak_data.infamy.join_stingers do
		join_stinger_data = self._global.join_stingers[index]

		table.insert(all_stingers, {
			id = index,
			unlocked = join_stinger_data.unlocked
		})
	end

	return all_stingers
end

function InfamyManager:get_join_stinger_name_id(stinger_name)
	local item_id = string.format("infamy_stinger_%03d", stinger_name)
	local item_tweak = tweak_data.infamy.items[item_id]

	return item_tweak and item_tweak.name_id or "menu_" .. item_id .. "_name"
end

function InfamyManager:get_infamy_card_id_and_rect()
	local texture_id = "guis/dlcs/infamous/textures/pd2/infamous_tree/infamy_card_display"
	local inf_rank = math.min(managers.experience:current_rank(), tweak_data.infamy.ranks - 1) - 1
	local x_pos = 38 + (inf_rank - inf_rank % 100 - (inf_rank - inf_rank % 400)) / 100 * 256
	local y_pos = (inf_rank - inf_rank % 400) / 400 * 256
	local texture_rect = {
		x_pos,
		y_pos,
		180,
		256
	}

	return texture_id, texture_rect
end

function InfamyManager:reset_items()
	self:_reset_points()

	self._global.VERSION = InfamyManager.VERSION
	self._global.reset_message = true
end

function InfamyManager:check_reset_message()
	local show_reset_message = self._global.reset_message and true or false

	if show_reset_message then
		managers.menu:show_infamytree_reseted()

		self._global.reset_message = false

		MenuCallbackHandler:save_progress()
	end
end

function InfamyManager:save(data)
	local state = {
		points = self._global.points,
		unlocks = self._global.unlocks,
		selected_join_stinger = self._global.selected_join_stinger,
		VERSION = self._global.VERSION or 0,
		reset_message = self._global.reset_message
	}
	data.InfamyManager = state
end

function InfamyManager:load(data, version)
	local state = data.InfamyManager

	if state then
		self._global.points = state.points
		self._global.selected_join_stinger = state.selected_join_stinger
		local infamy_item = nil

		for item_id, unlocked in pairs(state.unlocks) do
			self._global.unlocks[item_id] = unlocked
			infamy_item = tweak_data.infamy.items[item_id]

			if unlocked and infamy_item and infamy_item.upgrades.join_stingers then
				for _, join_stinger in ipairs(infamy_item.upgrades.join_stingers) do
					self:unlock_join_stinger(join_stinger)

					if not self._global.selected_join_stinger then
						self._global.selected_join_stinger = join_stinger
					end
				end
			end
		end

		self._global.VERSION = state.VERSION
		self._global.reset_message = state.reset_message

		if not self._global.VERSION or self._global.VERSION < InfamyManager.VERSION then
			managers.savefile:add_load_done_callback(callback(self, self, "reset_items"))
		end

		self:_verify_loaded_data()
	end
end

function InfamyManager:_verify_loaded_data()
	local tree_map = {}

	for i, item in ipairs(tweak_data.infamy.tree) do
		tree_map[item] = i
	end

	for item, unlocked in pairs(clone(self._global.unlocks)) do
		if not tweak_data.infamy.items[item] then
			Application:error("[InfamyManager:_verify_loaded_data] Removing non-existing Infamy Item", item)

			self._global.unlocks[item] = nil
		elseif not tree_map[item] then
			Application:error("[InfamyManager:_verify_loaded_data] Removing unused Infamy Item", item)

			self._global.unlocks[item] = nil
		end
	end

	if not self:is_join_stinger_unlocked(self._global.selected_join_stinger) then
		self._global.selected_join_stinger = nil

		for id, data in pairs(self._global.join_stingers) do
			if data.unlocked then
				self._global.selected_join_stinger = id

				break
			end
		end
	end
end

function InfamyManager:reset()
	Global.infamy_manager = nil

	self:_setup()
end
