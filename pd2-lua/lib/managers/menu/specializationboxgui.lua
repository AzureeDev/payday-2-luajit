SpecializationBoxGui = SpecializationBoxGui or class(TextBoxGui)
SpecializationBoxGui.TEXT = ""

function SpecializationBoxGui:init(...)
	local ws, title, text, content_data, config = ...
	config.forced_h = 210
	config.w = 600
	config.is_title_outside = true

	SpecializationBoxGui.super.init(self, ...)
end

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	if text:wrap() == true then
		text:set_h(h)
	else
		text:set_size(w, h)
	end

	text:set_position(math.round(text:x()), math.round(text:y()))
end

function SpecializationBoxGui:_create_text_box(ws, title, text, content_data, config)
	local panel = SpecializationBoxGui.super._create_text_box(self, ws, title, text, content_data, config)
	local xp_present = content_data.xp_present
	local available_points = managers.skilltree:get_specialization_value("points")
	local points_present = math.min(content_data.points_present, available_points)
	local conversion_rate_number = math.round(xp_present / points_present)
	local small_text = {
		text = "",
		blend_mode = "add",
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	}
	local medium_text = {
		text = "",
		blend_mode = "add",
		layer = 1,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	}
	local progress_text = self._scroll_panel:text(medium_text)

	progress_text:set_position(10, 30)
	progress_text:set_text(managers.localization:to_upper_text("menu_st_spec_xp_progress"))
	make_fine_text(progress_text)

	local progress_bg = self._scroll_panel:rect({
		alpha = 0.4,
		layer = 1,
		h = progress_text:h(),
		color = Color.black
	})

	progress_bg:set_position(progress_text:right() + 4, progress_text:top())
	progress_bg:set_w(self._scroll_panel:w() - progress_bg:left() - 5)

	local progress_bar = self._scroll_panel:rect({
		alpha = 1,
		blend_mode = "add",
		layer = 2,
		color = Color.white
	})

	progress_bar:set_shape(progress_bg:shape())
	progress_bar:set_w(0)
	progress_bar:grow(0, -4)
	progress_bar:move(2, 0)
	progress_bar:set_center_y(progress_bg:center_y())

	local progress_end = self._scroll_panel:rect({
		alpha = 1,
		blend_mode = "add",
		layer = 3,
		color = Color.white
	})

	progress_end:set_shape(progress_bg:shape())
	progress_end:set_w(2)
	progress_end:grow(0, -4)
	progress_end:set_center_y(progress_bg:center_y())
	progress_end:set_right(progress_bg:right())

	local conversion_rate_text = self._scroll_panel:text(small_text)

	conversion_rate_text:set_text(managers.localization:to_upper_text("menu_st_spec_xp_conversion", {
		rate = string.format("%i:1", conversion_rate_number)
	}))
	make_fine_text(conversion_rate_text)
	conversion_rate_text:set_position(progress_bg:left(), progress_bg:bottom() + 2)

	local w = progress_bg:right() - progress_text:left()
	local exp_panel = self._scroll_panel:panel({
		layer = 2
	})

	exp_panel:set_left(progress_text:left())
	exp_panel:set_w(w / 2 - 10)
	exp_panel:set_top(conversion_rate_text:bottom() + 20)
	exp_panel:set_h(self._scroll_panel:h() - exp_panel:top() - 10)
	BoxGuiObject:new(exp_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local exp_title_text = exp_panel:text(small_text)

	exp_title_text:set_wrap(true)
	exp_title_text:set_word_wrap(true)
	exp_title_text:set_position(5, 5)
	exp_title_text:set_w(exp_panel:w() - 10)
	exp_title_text:set_text(managers.localization:to_upper_text("menu_st_spec_xp_gained"))
	make_fine_text(exp_title_text)

	local exp_count_text = exp_panel:text(medium_text)

	exp_count_text:set_position(exp_title_text:left() + 10, exp_title_text:bottom())
	exp_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(xp_present)))
	make_fine_text(exp_count_text)

	local points_panel = self._scroll_panel:panel({
		layer = 2
	})

	points_panel:set_w(w / 2 - 10)
	points_panel:set_right(progress_bg:right())
	points_panel:set_top(exp_panel:top())
	points_panel:set_h(exp_panel:h())
	BoxGuiObject:new(points_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local points_gained_title_text = points_panel:text(small_text)

	points_gained_title_text:set_position(5, 5)
	points_gained_title_text:set_text(managers.localization:to_upper_text("menu_st_spec_xp_perk_gained"))
	make_fine_text(points_gained_title_text)

	local points_gained_count_text = points_panel:text(medium_text)

	points_gained_count_text:set_position(points_gained_title_text:left() + 10, points_gained_title_text:bottom())
	points_gained_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(0)))
	make_fine_text(points_gained_count_text)

	local available_points_title_text = points_panel:text(small_text)

	available_points_title_text:set_position(points_gained_title_text:left(), points_gained_count_text:bottom() + 2)
	available_points_title_text:set_text(managers.localization:to_upper_text("menu_st_spec_xp_perk_total"))
	make_fine_text(available_points_title_text)

	local available_points_count_text = points_panel:text(medium_text)

	available_points_count_text:set_position(available_points_title_text:left() + 10, available_points_title_text:bottom())
	available_points_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(available_points - points_present)))
	make_fine_text(available_points_count_text)
	self._panel:set_y(math.round(self._panel:y()))
	self._scroll_panel:set_y(math.round(self._scroll_panel:y()))

	self._anim_data = {
		progress_width = 0,
		start_points_present = 0,
		points_present = 0,
		goto_end = false,
		start_progress_width = 0,
		end_xp_present = 0,
		progress_bar = progress_bar,
		end_progress_width = progress_end:right() - progress_bar:left(),
		exp_count_text = exp_count_text,
		points_gained_count_text = points_gained_count_text,
		available_points_count_text = available_points_count_text,
		start_xp_present = xp_present,
		xp_present = xp_present,
		end_points_present = points_present,
		start_available_points_present = available_points - points_present,
		end_available_points_present = available_points,
		available_points_present = available_points - points_present,
		conversion_rate = conversion_rate_number
	}
	local xp_present = content_data.xp_present
	local points_present = content_data.points_present
	local conversion_rate_number = math.round(xp_present / points_present)
end

function SpecializationBoxGui:chk_close()
	if not self._anim_data or self._anim_data.conversion_ended then
		return true
	end

	self._anim_data.goto_end = true

	return false
end

function SpecializationBoxGui._update(o, self)
	local init_done = false

	while not init_done do
		init_done = not not self._anim_data

		coroutine.yield()
	end

	wait(1)

	local dt = nil
	local speed = math.max(5, self._anim_data.end_points_present / 20)

	managers.menu_component:post_event("count_1")

	while self._anim_data and not self._anim_data.goto_end and (self._anim_data.xp_present ~= self._anim_data.end_xp_present or self._anim_data.points_present ~= self._anim_data.end_points_present) do
		dt = coroutine.yield()
		self._anim_data.xp_present = math.step(self._anim_data.xp_present, self._anim_data.end_xp_present, self._anim_data.conversion_rate * dt * speed)
		self._anim_data.points_present = math.step(self._anim_data.points_present, self._anim_data.end_points_present, dt * speed)
		self._anim_data.available_points_present = self._anim_data.start_available_points_present + self._anim_data.points_present

		self._anim_data.exp_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(math.round(self._anim_data.xp_present))))
		make_fine_text(self._anim_data.exp_count_text)
		self._anim_data.points_gained_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(math.round(self._anim_data.points_present))))
		make_fine_text(self._anim_data.points_gained_count_text)
		self._anim_data.available_points_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(math.round(self._anim_data.available_points_present))))
		make_fine_text(self._anim_data.available_points_count_text)

		self._anim_data.progress_width = math.lerp(self._anim_data.start_progress_width, self._anim_data.end_progress_width, self._anim_data.points_present / self._anim_data.end_points_present)

		self._anim_data.progress_bar:set_width(self._anim_data.progress_width)

		speed = speed + speed * 0.2 * dt
	end

	managers.menu_component:post_event("count_1_finished")
	self._anim_data.exp_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(math.round(self._anim_data.end_xp_present))))
	make_fine_text(self._anim_data.exp_count_text)
	self._anim_data.points_gained_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(math.round(self._anim_data.end_points_present))))
	make_fine_text(self._anim_data.points_gained_count_text)
	self._anim_data.available_points_count_text:set_text(managers.money:add_decimal_marks_to_string(tostring(math.round(self._anim_data.end_available_points_present))))
	make_fine_text(self._anim_data.available_points_count_text)
	self._anim_data.progress_bar:set_width(self._anim_data.end_progress_width)

	self._anim_data.conversion_ended = true
end
