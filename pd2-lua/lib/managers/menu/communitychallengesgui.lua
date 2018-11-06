require("lib/utils/gui/GUIObjectWrapper")
require("lib/utils/gui/FineText")

Tween = Tween or class()

function Tween:init(target, name, opts)
	opts = opts or {}
	self._target = target
	self._name = name
	self._from = opts.from or target[name]
	self._to = opts.to or target[name]
	self._duration = opts.duration or 0
	self._delay = opts.delay or 0
	self._ease = opts.ease or Tween.ease_linear
	self._time = 0
	self._finished = false
end

function Tween:update(t, dt)
	if not self._finished then
		self._time = self._time + dt
		local time = math.max(self._time - self._delay, 0)

		if time < self._duration then
			self._target[self._name] = self._ease(self._from, self._to, time / self._duration)
		else
			self._time = self._duration + self._delay
			self._finished = true
			self._target[self._name] = self._to
		end
	end
end

function Tween:finished()
	return self._finished
end

function Tween.ease_linear(from, to, t)
	return from * (1 - t) + to * t
end

function Tween.ease_out(from, to, t)
	return (from - to) * t * (t - 2) + from
end

local function make_value_string(number, additional_zeroes)
	if number == 0 then
		return "0"
	end

	local num_string = string.format("%.0f", number)
	num_string = num_string .. string.rep("0", additional_zeroes)
	local len = #num_string
	local i = len
	local result = ""

	while i > 0 do
		if (len - i) % 3 == 0 and i < len then
			result = "," .. result
		end

		result = num_string:sub(i, i) .. result
		i = i - 1
	end

	return result
end

local function make_roman_numerals(number)
	number = math.floor(number)

	if number < 1 or number > 3999 then
		return ""
	end

	local roman = ""

	while number >= 1000 do
		roman = roman .. "M"
		number = number - 1000
	end

	while number >= 900 do
		roman = roman .. "CM"
		number = number - 900
	end

	while number >= 500 do
		roman = roman .. "D"
		number = number - 500
	end

	while number >= 400 do
		roman = roman .. "CD"
		number = number - 400
	end

	while number >= 100 do
		roman = roman .. "C"
		number = number - 100
	end

	while number >= 90 do
		roman = roman .. "XC"
		number = number - 90
	end

	while number >= 50 do
		roman = roman .. "L"
		number = number - 50
	end

	while number >= 40 do
		roman = roman .. "XL"
		number = number - 40
	end

	while number >= 10 do
		roman = roman .. "X"
		number = number - 10
	end

	while number >= 9 do
		roman = roman .. "IX"
		number = number - 9
	end

	while number >= 5 do
		roman = roman .. "V"
		number = number - 5
	end

	while number >= 4 do
		roman = roman .. "IV"
		number = number - 4
	end

	while number >= 1 do
		roman = roman .. "I"
		number = number - 1
	end

	return roman
end

CommunityChallengeProgressBar = CommunityChallengeProgressBar or class(GUIObjectWrapper)

function CommunityChallengeProgressBar:init(parent, config)
	local panel = parent:panel()

	self.super.init(self, panel)

	self._panel = panel
	self._title = config.title or ""
	self._statistic_id = config.statistic_id or ""
	self._target_value = config.target_value or 0
	self._current_value = config.current_value or 0
	self._additional_zeroes = config.additional_zeroes or 0
	self._value_tween = Tween:new(self, "_current_value")
	self._width = config.width or 300
	self._height = 43
	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local color_text = tweak_data.menu.default_font_row_item_color
	local color_emphasis = tweak_data.screen_colors.button_stage_3
	local color_muted = Color(0.5, 1, 1, 1)
	local color_fill = Color(0.5, 0, 0.6667, 1)

	panel:set_size(self._width, self._height)

	self._title_text = FineText:new(panel, {
		text = self._title,
		font = font,
		font_size = font_size,
		color = color_text
	})
	self._stage_text = FineText:new(panel, {
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_community_challenges_stage", {
			stage = "I"
		}),
		font = font,
		font_size = font_size,
		color = color_emphasis
	})
	self._progress_text = FineText:new(panel, {
		text = self:_make_progress_text(),
		font = font,
		font_size = font_size,
		color = color_muted
	})
	self._exp_icon = panel:bitmap({
		texture = "guis/textures/pd2/community_challenges/experience_bonus_icon"
	})
	self._progress_fill = panel:rect({
		blend_mode = "add",
		layer = -1,
		color = color_fill
	})

	self:layout()
end

function CommunityChallengeProgressBar:config(config)
	self._target_value = config.target_value or 0
	self._additional_zeroes = config.additional_zeroes or 0

	self._value_tween:init(self, "_current_value", {
		duration = 2,
		to = config.current_value or 0,
		delay = 0.1 * (config.index or 0),
		ease = Tween.ease_out
	})

	local stage_roman = make_roman_numerals(config.stage or 1)
	local stage_text = managers.localization:to_upper_text("menu_community_challenges_stage", {
		stage = stage_roman
	})

	self._stage_text:set_text(stage_text)
	self._progress_text:set_text(self:_make_progress_text())
	self:layout()
end

function CommunityChallengeProgressBar:layout()
	self._title_text:set_lefttop(5, 1)
	self._progress_text:set_leftbottom(5, self._height - 1)
	self._stage_text:set_lefttop(self._title_text:right() + 5, 1)

	local fill_max_width = self._width - self._exp_icon:width() - 10
	local fill_ratio = self._target_value > 0 and self._current_value / self._target_value or 1

	self._progress_fill:set_width(fill_max_width * fill_ratio)
	self._exp_icon:set_right(self._width)
	self._exp_icon:set_center_y(math.round(self._height * 0.5))
end

function CommunityChallengeProgressBar:update(t, dt)
	if not self._value_tween:finished() then
		self._value_tween:update(t, dt)

		self._current_value = math.round(self._current_value)

		self._progress_text:set_text(self:_make_progress_text())
		self:layout()
	end
end

function CommunityChallengeProgressBar:_make_progress_text()
	local current = make_value_string(self._current_value, self._additional_zeroes)
	local target = make_value_string(self._target_value, self._additional_zeroes)

	return current .. " / " .. target
end

function CommunityChallengeProgressBar:get_statistic_id()
	return self._statistic_id
end

CommunityChallengeProgressTotal = CommunityChallengeProgressTotal or class(GUIObjectWrapper)

function CommunityChallengeProgressTotal:init(parent, config)
	local panel = parent:panel()

	self.super.init(self, panel)

	self._panel = panel
	self._title = config.title or ""
	self._statistic_id = config.statistic_id or ""
	self._total_value = config.total_value or 0
	self._additional_zeroes = config.additional_zeroes or 0
	self._width = config.width or 300
	self._height = 43
	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local color_text = tweak_data.menu.default_font_row_item_color
	local color_emphasis = tweak_data.screen_colors.button_stage_3
	local color_muted = Color(0.5, 1, 1, 1)
	local color_fill = Color(0.5, 0, 0.6667, 1)

	panel:set_size(self._width, self._height)

	self._title_text = FineText:new(panel, {
		text = self._title,
		font = font,
		font_size = font_size,
		color = color_text
	})
	self._stage_text = FineText:new(panel, {
		blend_mode = "add",
		text = managers.localization:to_upper_text("menu_community_challenges_stage", {
			stage = "I"
		}),
		font = font,
		font_size = font_size,
		color = color_emphasis
	})
	self._progress_text = FineText:new(panel, {
		text = self:_make_progress_text(),
		font = font,
		font_size = font_size,
		color = color_muted
	})

	self:layout()
end

function CommunityChallengeProgressTotal:config(config)
	self._total_value = config.total_value or 0
	self._additional_zeroes = config.additional_zeroes or 0
	local stage_roman = make_roman_numerals(config.stage or 1)
	local stage_text = managers.localization:to_upper_text("menu_community_challenges_stage", {
		stage = stage_roman
	})

	self._stage_text:set_text(stage_text)
	self._progress_text:set_text(self:_make_progress_text())
	self:layout()
end

function CommunityChallengeProgressTotal:layout()
	self._title_text:set_lefttop(5, 1)
	self._progress_text:set_leftbottom(5, self._height - 1)
	self._stage_text:set_lefttop(self._title_text:right() + 5, 1)
end

function CommunityChallengeProgressTotal:update(t, dt)
end

function CommunityChallengeProgressTotal:_make_progress_text()
	local total = make_value_string(self._total_value, self._additional_zeroes)

	return "Total: " .. total
end

function CommunityChallengeProgressTotal:get_statistic_id()
	return self._statistic_id
end

CommunityChallengesGui = CommunityChallengesGui or class(GUIObjectWrapper)

function CommunityChallengesGui:init(parent)
	local panel = parent:panel()

	self.super.init(self, panel)

	self._panel = panel
	local width = 346

	panel:set_size(width, 100)

	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local color_text = tweak_data.menu.default_font_row_item_color
	local color_muted = Color(0.5, 1, 1, 1)
	local progress_bar_width = panel:width() - 20
	self._title_text = FineText:new(panel, {
		text = managers.localization:to_upper_text("menu_community_challenges_title"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = color_text
	})
	self._stats_container = panel:panel()
	self._progress_bars = {}

	for _, challenge in ipairs(tweak_data.community_challenges) do
		self:add_progress_bar({
			total_value = 0,
			current_value = 0,
			title = managers.localization:to_upper_text(challenge.text_id),
			statistic_id = challenge.statistic_id,
			target_value = challenge.base_target,
			width = progress_bar_width
		})
	end

	local active_bonus = managers.community_challenges:get_active_experience_bonus()
	self._total_bonus_text = FineText:new(self._stats_container, {
		text = managers.localization:to_upper_text("menu_community_challenges_active_bonus", {
			bonus = active_bonus * 100
		}),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = color_text
	})
	self._info_text = FineText:new(self._stats_container, {
		text = managers.localization:to_upper_text("menu_community_challenges_info_ended", {
			bonus = CommunityChallengesManager.PER_CHALLENGE_BONUS * 100
		}),
		font = tweak_data.menu.pd2_tiny_font,
		font_size = tweak_data.menu.pd2_tiny_font_size,
		color = color_muted
	})

	self:layout()

	self._bg_fill = self._stats_container:rect({
		layer = -1,
		color = Color(0.3, 0, 0, 0)
	})
	self._bg_box = BoxGuiObject:new(self._stats_container, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local challenge_data = managers.community_challenges:get_challenge_data()

	if challenge_data then
		self:consume_community_challenges_data(challenge_data)
	end

	managers.community_challenges:add_event_listener(Message.OnCommunityChallengeDataReceived, "CommunityChallengesGui:consume_community_challenges_data", callback(self, self, "consume_community_challenges_data"))
	managers.community_challenges:fetch_community_challenge_data()
end

function CommunityChallengesGui:close()
	if self._panel and alive(self._panel) then
		self._panel:parent():remove(self._panel)

		self._panel = nil
	end

	managers.community_challenges:remove_event_listener(Message.OnCommunityChallengeDataReceived, "CommunityChallengesGui:consume_community_challenges_data")
end

function CommunityChallengesGui:layout()
	for i, pbar in ipairs(self._progress_bars) do
		local zi = i - 1

		pbar:set_position(10, 10 + zi * 43 + zi * 5)
	end

	local last_pbar = self._progress_bars[#self._progress_bars]

	self._total_bonus_text:set_top(last_pbar:bottom() + 5)
	self._info_text:set_top(self._total_bonus_text:bottom())
	self._total_bonus_text:set_right(self:width() - 10)
	self._info_text:set_right(self:width() - 10)
	self._stats_container:set_height(self._info_text:bottom() + 10)
	self._stats_container:set_top(self._title_text:bottom() + 10)

	local full_height = self._stats_container:bottom() - self._title_text:top()

	self._panel:set_height(full_height)
end

function CommunityChallengesGui:update(t, dt)
	for _, pbar in ipairs(self._progress_bars) do
		pbar:update(t, dt)
	end
end

function CommunityChallengesGui:add_progress_bar(config)
	local progress_bar = CommunityChallengeProgressTotal:new(self._stats_container, config)

	table.insert(self._progress_bars, progress_bar)
end

function CommunityChallengesGui:consume_community_challenges_data(data)
	for i, pbar in ipairs(self._progress_bars) do
		local challenge = data[pbar:get_statistic_id()]

		if challenge then
			local config = clone(challenge)
			config.index = i - 1

			pbar:config(config)
		end
	end

	local active_bonus = managers.community_challenges:get_active_experience_bonus()

	self._total_bonus_text:set_text(managers.localization:to_upper_text("menu_community_challenges_active_bonus", {
		bonus = math.round(active_bonus * 100)
	}))
	self:layout()
end
