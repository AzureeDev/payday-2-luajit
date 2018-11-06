InfamyManager = InfamyManager or class()
InfamyManager.VERSION = 1

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
	end

	self._global = Global.infamy_manager
end

function InfamyManager:points()
	return Application:digest_value(self._global.points, false)
end

function InfamyManager:aquire_point()
	self:_set_points(self:points() + 1)
end

function InfamyManager:_set_points(value)
	self._global.points = Application:digest_value(value, true)
end

function InfamyManager:_reset_points()
	local points = math.abs(self:points())

	for item, unlocked in pairs(self._global.unlocks) do
		if unlocked then
			points = points + Application:digest_value(tweak_data.infamy.items[item].cost, false)
		end
	end

	Global.infamy_manager = nil

	self:_setup(true)
	self:_set_points(points)
	self:_verify_loaded_data()
end

function InfamyManager:required_points(item)
	if tweak_data.infamy.items[item] then
		return Application:digest_value(tweak_data.infamy.items[item].cost, false) <= self:points()
	end
end

function InfamyManager:unlock_item(item)
	local infamy_item = tweak_data.infamy.items[item]

	if not infamy_item then
		debug_pause("InfamyManager:unlock_item]: Missing item = '" .. tostring(item) .. "'")

		return
	end

	if Application:digest_value(infamy_item.cost, false) <= self:points() then
		for bonus, item in ipairs(infamy_item.upgrades) do
			local global_value = item[1]
			local category = item[2]
			local item_id = item[3]
			local item_tweak = tweak_data.blackmarket[category][item_id]

			managers.blackmarket:add_to_inventory(global_value or item_tweak.global_value or "normal", category, item_id)
		end

		self:_set_points(self:points() - Application:digest_value(infamy_item.cost, false))

		self._global.unlocks[item] = true
	end
end

function InfamyManager:owned(item)
	return self._global.unlocks[item] or false
end

function InfamyManager:available(item)
	local tier_count = 0
	local points_curr_tier = 0
	local points_prev_tier = 0

	if item == "infamy_root" then
		return true
	end

	local tree_cols = tweak_data.infamy.tree_cols or 3
	local tree_rows = tweak_data.infamy.tree_rows or 3
	local up, down, left, right, new_x, new_y = nil

	for index, name in pairs(tweak_data.infamy.tree) do
		if item == name then
			local item_x = (index - 1) % tree_cols + 1
			local item_y = math.floor((index - 1) / tree_cols) + 1
			new_x = math.clamp(item_x + 0, 1, tree_cols)
			new_y = math.clamp(item_y - 1, 1, tree_rows)
			up = (new_y - 1) * tree_cols + new_x

			if self._global.unlocks[tweak_data.infamy.tree[up]] then
				return true
			end

			new_x = math.clamp(item_x + 0, 1, tree_cols)
			new_y = math.clamp(item_y + 1, 1, tree_rows)
			down = (new_y - 1) * tree_cols + new_x

			if self._global.unlocks[tweak_data.infamy.tree[down]] then
				return true
			end

			new_x = math.clamp(item_x - 1, 1, tree_cols)
			new_y = math.clamp(item_y + 0, 1, tree_rows)
			left = (new_y - 1) * tree_cols + new_x

			if self._global.unlocks[tweak_data.infamy.tree[left]] then
				return true
			end

			new_x = math.clamp(item_x + 1, 1, tree_cols)
			new_y = math.clamp(item_y + 0, 1, tree_rows)
			right = (new_y - 1) * tree_cols + new_x

			if self._global.unlocks[tweak_data.infamy.tree[right]] then
				return true
			end

			return false
		end
	end

	return false
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
		VERSION = self._global.VERSION or 0,
		reset_message = self._global.reset_message
	}
	data.InfamyManager = state
end

function InfamyManager:load(data, version)
	local state = data.InfamyManager

	if state then
		self._global.points = state.points

		for item_id, item_data in pairs(state.unlocks) do
			self._global.unlocks[item_id] = item_data
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
	local assumed_points = managers.experience:current_rank()
	local points = assumed_points
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
		elseif unlocked then
			points = points - Application:digest_value(tweak_data.infamy.items[item].cost, false)
		end
	end

	if points < 0 then
		Application:error("[InfamyManager:_verify_loaded_data] There is more infamy points unlocked then the amount of points given. Resetting unlockes!")
		self:_reset_points()
	elseif self:points() ~= points then
		Application:error("[InfamyManager:_verify_loaded_data] Points do not match", "saved_points", self:points(), "assumed_points", points)
		self:_set_points(points)
	end
end

function InfamyManager:reset()
	Global.infamy_manager = nil

	self:_setup()
end
