ModifierAssaultExtender = ModifierAssaultExtender or class(BaseModifier)
ModifierAssaultExtender._type = "ModifierAssaultExtender"
ModifierAssaultExtender.name_id = "none"
ModifierAssaultExtender.desc_id = "menu_cs_modifier_assault_extender"
ModifierAssaultExtender.default_value = "duration"

function ModifierAssaultExtender:init(data)
	ModifierAssaultExtender.super.init(self, data)

	self._sustain_start_time = 0
	self._base_duration = 0
	self._hostage_time = 0
	self._hostage_count = 0
	self._hostage_average_count = 0
	self._hostage_last_update = 0
end

function ModifierAssaultExtender:_update_hostage_time()
	local now = TimerManager:game():time()
	local diff = now - self._hostage_last_update
	self._hostage_time = self._hostage_time + diff * self._hostage_count
	self._hostage_average_count = self._hostage_time / (now - self._sustain_start_time)
	self._hostage_last_update = now
end

function ModifierAssaultExtender:_update_hostage_count()
	local num_hostages = managers.groupai:state():hostage_count()
	local num_minions = managers.groupai:state():get_amount_enemies_converted_to_criminals()
	self._hostage_count = math.min(num_hostages + num_minions, self:value("max_hostages"))
end

function ModifierAssaultExtender:OnHostageCountChanged()
	self:_update_hostage_time()
	self:_update_hostage_count()
end

function ModifierAssaultExtender:OnMinionAdded()
	self:_update_hostage_time()
	self:_update_hostage_count()
end

function ModifierAssaultExtender:OnMinionRemoved()
	self:_update_hostage_time()
	self:_update_hostage_count()
end

function ModifierAssaultExtender:OnEnterSustainPhase(duration)
	local now = TimerManager:game():time()
	self._sustain_start_time = now
	self._base_duration = duration
	self._hostage_time = 0
	self._hostage_last_update = now
end

function ModifierAssaultExtender:modify_value(id, value, ...)
	if id == "GroupAIStateBesiege:SustainEndTime" then
		self:_update_hostage_time()

		local now = TimerManager:game():time()
		local extension = self:value("duration") * 0.01
		local deduction = self:value("deduction") * 0.01 * self._hostage_average_count
		local value = value + self._base_duration * (extension - deduction)

		return value
	elseif id == "GroupAIStateBesiege:SustainSpawnAllowance" then
		self:_update_hostage_time()

		local now = TimerManager:game():time()
		local base_pool = ...
		local extension = self:value("spawn_pool") * 0.01
		local deduction = self:value("deduction") * 0.01 * self._hostage_average_count
		local value = value + math.floor(base_pool * (extension - deduction))

		return value
	end

	return value
end
