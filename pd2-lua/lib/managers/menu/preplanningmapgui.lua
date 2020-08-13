local function debug_assert(chk, ...)
	if not chk then
		local s = ""

		for i, text in ipairs({
			...
		}) do
			s = s .. "  " .. text
		end

		assert(chk, s)
	end
end

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return text:x(), text:y(), w, h
end

local point_extras = {
	"look_angle",
	"plan",
	"wall_rect"
}
local mvec = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec4 = Vector3()
local mrot = Rotation()
PrePlanningPoint = PrePlanningPoint or class()
PrePlanningPoint.WIDTH = 48
PrePlanningPoint.HEIGHT = 48

function PrePlanningPoint:init(map_panel, element, shape, rotation, active_node, location_index)
	local width = PrePlanningPoint.WIDTH
	local height = PrePlanningPoint.HEIGHT
	self._width = width
	self._height = height
	self._map_width = map_panel:width()
	self._map_height = map_panel:height()
	self._current_size_mod = 1
	local element_position, element_rotation = element:get_orientation()
	local lx = mvector3.x(element_position)
	local ly = mvector3.y(element_position)
	local x, y, w, h = unpack(shape)
	local raw_x = (lx - x) / w - 0.5
	local raw_y = 1 - (ly - y) / h - 0.5
	local ax = math.cos(rotation) * raw_x - math.sin(rotation) * raw_y + 0.5
	local ay = math.sin(rotation) * raw_x + math.cos(rotation) * raw_y + 0.5
	self._active_node = active_node
	self._x = ax
	self._y = ay
	self._element = element
	self._map_panel = map_panel
	self._location_index = location_index
	self._panel = map_panel:panel({
		layer = 10,
		w = width,
		h = height
	})

	self._panel:set_center(self._x * self._map_panel:w(), self._y * self._map_panel:h())

	self._info_box = self._panel:panel({
		w = 100,
		halign = "center",
		alpha = 0,
		valign = "center",
		h = self._panel:h() * 2
	})

	self._info_box:set_left(self._panel:w() + 5)
	self._info_box:set_center_y(self._panel:h() / 2)

	self._extras_panel = map_panel:panel({
		halign = "scale",
		valign = "scale",
		layer = 11
	})

	self._extras_panel:set_center(self._panel:center())

	self._extras = {}
	local yaw = mrotation.yaw(element_rotation)

	local function add_extra_func(type, key)
		local value = tweak_data:get_raw_value("preplanning", "types", type, key)

		if value then
			if key == "look_angle" then
				local angle = math.clamp(value.angle or 90, 0, 89)
				local color = value.color or Color(192, 255, 51, 51) / 255
				local length = value.length or 1
				local look_cone = self._extras[type]:polygon({
					blend_mode = "add",
					name = "look_cone",
					valign = "scale",
					halign = "scale",
					rotation = 0,
					layer = 0,
					color = Color.white
				})

				look_cone:set_center(self._extras[type]:w() / 2, self._extras[type]:h() / 2)

				local min_size = math.min(look_cone:w(), look_cone:h()) * length

				mvector3.set_static(mvec, look_cone:w() / 2, look_cone:h() / 2, 0)
				mrotation.y(element_rotation, mvec2)
				mvector3.set_y(mvec2, -mvector3.y(mvec2))
				mrotation.set_yaw_pitch_roll(mrot, rotation + angle * 0.5, 0, 0)
				mvector3.rotate_with(mvec2, mrot)
				mvector3.multiply(mvec2, min_size)
				mvector3.add(mvec2, mvec)
				mrotation.y(element_rotation, mvec3)
				mvector3.set_y(mvec3, -mvector3.y(mvec3))
				mrotation.set_yaw_pitch_roll(mrot, rotation - angle * 0.5, 0, 0)
				mvector3.rotate_with(mvec3, mrot)
				mvector3.multiply(mvec3, min_size)
				mvector3.add(mvec3, mvec)
				look_cone:add_colored_triangles({
					mvec,
					color,
					mvec2,
					color:with_alpha(0.01),
					mvec3,
					color:with_alpha(0.01)
				})
			elseif key == "plan" then
				local vote_panel = self._extras[type]:panel({
					name = "plan"
				})
				local new_icon = nil
				local x = 0

				for i = 1, managers.criminals.MAX_NR_CRIMINALS do
					new_icon = vote_panel:bitmap({
						texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_voting",
						blend_mode = "normal",
						h = 18,
						w = 18,
						x = x,
						texture_rect = {
							32,
							0,
							24,
							24
						}
					})
					x = new_icon:right() + 1
				end

				vote_panel:set_size(new_icon:right(), new_icon:bottom())
				vote_panel:set_center_x(self._extras[type]:w() / 2)
				vote_panel:set_top(self._extras[type]:h() / 2 + 20)
			elseif key == "wall_rect" then
				local width = value.w or value.width

				if value.real_w or vale.real_width then
					width = value.real_w or vale.real_width
					width = width / w
					width = width * self._extras[type]:w()
				end

				local height = value.h or value.height

				if value.real_h or vale.real_height then
					height = value.real_h or vale.real_height
					height = height / h
					height = height * self._extras[type]:h()
				end

				local panel = self._extras[type]:panel({
					valign = "scale",
					name = "wall_rect",
					halign = "scale"
				})
				local wall = panel:rect({
					blend_mode = "add",
					halign = "scale",
					valign = "scale",
					w = width,
					h = height,
					color = value.color
				})

				if value.right then
					wall:set_right(panel:w() / 2 + value.right)
				elseif value.x or value.left then
					wall:set_left(panel:w() / 2 + (value.x or value.left))
				end

				if value.bottom then
					wall:set_bottom(panel:h() / 2 + value.bottom)
				elseif value.y or value.top then
					wall:set_top(panel:h() / 2 + (value.y or value.top))
				end
			elseif false then
				-- Nothing
			end
		end
	end

	for _, type in ipairs(element:value("allowed_types")) do
		self._extras[type] = self._extras_panel:panel({
			alpha = 0,
			valign = "scale",
			halign = "scale",
			name = type
		})

		for _, key in ipairs(point_extras) do
			add_extra_func(type, key)
		end
	end

	self._is_visible = nil
	self._is_selectable = nil
	self._states = {}
end

function PrePlanningPoint:add_properties(category, type, index)
	if not self._properties then
		local texture_atlas = tweak_data.preplanning.gui.category_icons_path
		local texture_rect = tweak_data.preplanning:get_category_texture_rect(tweak_data:get_raw_value("preplanning", "gui", "category_icons_bg") or 42)
		self._bg = self._panel:bitmap({
			valign = "scale",
			alpha = 0.5,
			layer = 2,
			blend_mode = "add",
			halign = "scale",
			rotation = 360,
			texture = texture_atlas,
			texture_rect = texture_rect,
			w = self._panel:w() * 2,
			h = self._panel:h() * 2
		})

		self._bg:set_center(self._panel:w() / 2, self._panel:h() / 2)

		texture_rect = tweak_data.preplanning:get_category_texture_rect(tweak_data:get_raw_value("preplanning", "categories", category, "icon") or 32)
		self._box = self._panel:bitmap({
			valign = "scale",
			layer = 3,
			blend_mode = "add",
			halign = "scale",
			rotation = 360,
			texture = texture_atlas,
			texture_rect = texture_rect,
			w = self._panel:w(),
			h = self._panel:h()
		})

		if _G.IS_VR then
			self._bg:set_rotation(0)
			self._box:set_rotation(0)
		end

		local type_data = tweak_data:get_raw_value("preplanning", "types", type)

		if type_data and type_data.plan then
			local texture = tweak_data.preplanning.gui.type_icons_path
			local texture_rect = tweak_data.preplanning:get_type_texture_rect(type_data.icon)

			if texture then
				self._plan_icon = self._panel:bitmap({
					halign = "scale",
					valign = "scale",
					blend_mode = "add",
					rotation = 360,
					layer = 4,
					texture = texture,
					texture_rect = texture_rect,
					x = self._panel:w() * 0.25,
					y = self._panel:h() * 0.25,
					w = self._panel:w() * 0.5,
					h = self._panel:h() * 0.5
				})

				self._plan_icon:hide()

				self._plan_type = type

				self._info_box:clear()
				self._info_box:text({
					vertical = "center",
					align = "left",
					rotation = 360,
					blend_mode = "add",
					text = managers.localization:to_upper_text(tostring(type_data.name_id)),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text
				})

				if _G.IS_VR then
					self._plan_icon:set_rotation(0)
				end
			end
		end

		self:_update_reserved()

		self._properties = {
			category = {},
			type = {}
		}
	end

	self._properties.category[category] = true
	self._properties.type[type] = index
end

function PrePlanningPoint:map_position()
	return self._x * self._map_panel:w(), self._y * self._map_panel:h()
end

function PrePlanningPoint:inside(x, y)
	return self._panel:inside(x, y)
end

function PrePlanningPoint:alive()
	return alive(self._panel)
end

function PrePlanningPoint:element()
	return self._element
end

function PrePlanningPoint:set_color(color)
	self._box:set_color(color)
	self._bg:set_color(color)
end

function PrePlanningPoint:set_state(...)
	local states = {
		...
	}

	debug_assert(#states % 2 == 0, "[PrePlanningPoint:set_state] State is missing value", inspect(states))

	local state, value = nil

	for i = 1, #states - 1, 2 do
		state = states[i]
		value = states[i + 1]

		if self._states[state] ~= value then
			self._states[state] = value
		end
	end
end

function PrePlanningPoint:flash()
	if alive(self._box) and alive(self._bg) then
		local function flash_anim(panel)
			local start_color = tweak_data.screen_colors.text
			local s = 0

			local function f(t)
				s = math.min(1, math.sin(t * 180) * 2)

				self._box:set_color(math.lerp(start_color, tweak_data.screen_colors.important_1, s))
				self._bg:set_color(math.lerp(start_color, tweak_data.screen_colors.important_1, s))
			end

			local seconds = 0.5
			local t = 0

			while true do
				local dt = coroutine.yield()

				if dt == 0 then
					dt = TimerManager:main():delta_time()
				end

				t = t + dt

				if seconds <= t then
					break
				end

				f(t / seconds, t)
			end

			self._box:set_color(start_color)
			self._bg:set_color(start_color)
		end

		self._box:stop()
		self._box:animate(flash_anim)
	end
end

function PrePlanningPoint:dirty()
	if not self._need_update then
		self._need_update = true

		self:update_me()
	end
end

function PrePlanningPoint:_update_reserved()
	local reserved_data = self._element and managers.preplanning:get_reserved_mission_element(self._element:id()) or false

	if not self._active_node.current_viewing and self._reserved_data ~= reserved_data then
		self._reserved_data = reserved_data
		local type = self._reserved_data and self._reserved_data.pack[1]
		local peer_id = self._reserved_data and self._reserved_data.peer_id

		if alive(self._reserved_icon) then
			self._reserved_icon:parent():remove(self._reserved_icon)

			self._reserved_icon = nil
		end

		if type then
			local type_data = tweak_data:get_raw_value("preplanning", "types", type) or {}
			local texture = tweak_data.preplanning.gui.type_icons_path
			local texture_rect = tweak_data.preplanning:get_type_texture_rect(type_data.icon)

			if texture then
				self._reserved_icon = self._panel:bitmap({
					halign = "scale",
					valign = "scale",
					blend_mode = "add",
					rotation = 360,
					layer = 4,
					texture = texture,
					texture_rect = texture_rect,
					x = self._panel:w() * 0.25,
					y = self._panel:h() * 0.25,
					w = self._panel:w() * 0.5,
					h = self._panel:h() * 0.5
				})
			end

			self._info_box:clear()
			self._info_box:text({
				vertical = "center",
				align = "left",
				rotation = 360,
				blend_mode = "add",
				text = managers.localization:to_upper_text(tostring(type_data.name_id)),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = tweak_data.screen_colors.text
			})
		end

		if peer_id then
			self._bg:set_color(tweak_data.preplanning_peer_colors[peer_id])
		else
			self._bg:set_color(Color.white)
		end
	elseif self._active_node.current_viewing and not self._reserved_data then
		local finished_preplan = managers.preplanning:get_finished_preplan()

		for _, data in pairs(finished_preplan) do
			if data[self._location_index] and data[self._location_index][self._element:id()] then
				local type = data[self._location_index][self._element:id()]
				local type_data = tweak_data:get_raw_value("preplanning", "types", type) or {}
				local texture = tweak_data.preplanning.gui.type_icons_path
				local texture_rect = tweak_data.preplanning:get_type_texture_rect(type_data.icon)
				self._reserved_data = {
					peer_id = 1,
					pack = {
						type,
						0
					}
				}
				self._viewing_only = type

				if alive(self._reserved_icon) then
					self._reserved_icon:parent():remove(self._reserved_icon)

					self._reserved_icon = nil
				end

				if texture then
					self._reserved_icon = self._panel:bitmap({
						halign = "scale",
						valign = "scale",
						blend_mode = "add",
						rotation = 360,
						layer = 4,
						texture = texture,
						texture_rect = texture_rect,
						x = self._panel:w() * 0.25,
						y = self._panel:h() * 0.25,
						w = self._panel:w() * 0.5,
						h = self._panel:h() * 0.5
					})
				end

				self._bg:set_color(tweak_data.preplanning_peer_colors[1])
				self._info_box:clear()
				self._info_box:text({
					vertical = "center",
					align = "left",
					rotation = 360,
					blend_mode = "add",
					text = managers.localization:to_upper_text(tostring(type_data.name_id)),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.text
				})

				break
			end
		end
	end
end

function PrePlanningPoint:_update_extra()
	local alpha = 0
	local is_selected = self._active_node.node:selected_item() and self._active_node.node:selected_item():name() == self._element:id()
	local is_current_type, is_reserved = nil

	for type, extra in pairs(self._extras) do
		alpha = 0

		if self._viewing_only then
			alpha = 1
		elseif self._active_node.current_plan and self._properties.category[self._active_node.current_plan] or self._has_majority then
			alpha = 1
		else
			is_current_type = self._active_node.current_type == type
			is_reserved = self._viewing_only or self._reserved_data and self._reserved_data.pack[1] == type

			if is_selected then
				if is_current_type then
					alpha = 0.75
				else
					alpha = 0
				end
			elseif is_reserved then
				alpha = 0.5
			elseif is_current_type then
				alpha = 0.1
			else
				alpha = 0
			end
		end

		extra:set_alpha(alpha)
		extra:set_visible(alpha > 0)

		local plan_gui = extra:child("plan")

		if self._plan_icon and plan_gui then
			plan_gui:set_visible(not self._active_node.current_plan or self._properties.category[self._active_node.current_plan])

			local index = self._properties.type[type]

			if index then
				local plan = tweak_data:get_raw_value("preplanning", "types", type, "plan")

				if plan then
					local votes = managers.preplanning:get_votes_on_element(plan, type, index) or {}

					for i = 1, plan_gui:num_children() do
						plan_gui:children()[i]:set_texture_rect(32, 0, 24, 24)
					end

					for peer_id, voted in pairs(votes.players or {}) do
						if voted then
							plan_gui:children()[peer_id]:set_texture_rect(0, 0, 24, 24)
						end
					end
				end
			end
		end
	end
end

function PrePlanningPoint:_update_position()
	if self._panel:visible() then
		local diff_width = 1 - self._map_width / self._map_panel:width()
		local diff_height = 1 - self._map_height / self._map_panel:height()

		self._panel:set_width((self._width + self._width * diff_width * 0.018) * (self._current_size_mod or 1))
		self._panel:set_height((self._height + self._height * diff_height * 0.018) * (self._current_size_mod or 1))
		self._panel:set_center(self._map_panel:w() * self._x, self._map_panel:h() * self._y)

		if self._box and self._box:alpha() > 0 then
			for type, extra in pairs(self._extras) do
				if extra:child("plan") then
					extra:child("plan"):set_center_x(extra:w() / 2)
					extra:child("plan"):set_world_top(self._box:world_bottom() + 5)
				end
			end
		end
	end
end

function PrePlanningPoint:update_me()
	if self._need_update then
		self._need_update = false

		self:_update_reserved()
		self:_update_state()
		self:_update_extra()
		self:_update_position()
	end
end

function PrePlanningPoint:animate_size_mod(o)
	local dt, step, diff = nil
	local done = false

	while not done do
		dt = coroutine.yield()

		if dt == 0 then
			dt = TimerManager:main():delta_time()
		end

		step = dt * 7.5

		if self._current_size_mod ~= self._size_mod then
			diff = self._size_mod - self._current_size_mod
			self._current_size_mod = math.abs(diff) <= step and self._size_mod or math.lerp(self._current_size_mod, self._size_mod, step)

			self:_update_position()
		end

		if self._info_box:alpha() ~= self._info_box_alpha then
			self._info_box:set_alpha(math.step(self._info_box:alpha(), self._info_box_alpha, step))
		end

		done = self._current_size_mod == self._size_mod and self._info_box:alpha() == self._info_box_alpha
	end
end

function PrePlanningPoint:_set_size_mod(size_mod)
	local info_box_alpha = self._current_state ~= Idstring("hidden") and self._mouse_selected and 1 or 0

	if self._size_mod ~= size_mod or info_box_alpha ~= self._info_box_alpha then
		self._info_box_alpha = info_box_alpha
		self._size_mod = size_mod

		self._panel:stop()

		if self._current_size_mod ~= self._size_mod or self._info_box:alpha() ~= self._info_box_alpha then
			self._panel:animate(callback(self, self, "animate_size_mod"))
		end
	end
end

function PrePlanningPoint:_enable_size_mod()
	self:_set_size_mod(1.2, true)
end

function PrePlanningPoint:_disable_size_mod()
	if self._size_mod then
		self._size_mod = 1
		self._current_size_mod = 1

		self._panel:stop()
	end
end

function PrePlanningPoint:_set_selected()
	local ids = alive(self._reserved_icon) and Idstring("selected_reserved") or self._has_majority and self._selected and Idstring("selected_majority") or Idstring("selected")

	if self._current_state ~= ids then
		self._bg:show()
		self._box:set_alpha(1)
		self._bg:set_alpha(0.45)

		if alive(self._reserved_icon) then
			self._reserved_icon:set_alpha(1)
			self._bg:set_alpha(0.65)
		elseif self._has_majority and self._selected then
			self._bg:set_alpha(0.65)
		end

		self._current_state = ids
	end
end

function PrePlanningPoint:_set_selectable()
	local ids = alive(self._reserved_icon) and Idstring("selectable_reserved") or Idstring("selectable")

	if self._current_state ~= ids then
		self._box:set_alpha(0.9)
		self._bg:set_alpha(0.45)

		if alive(self._reserved_icon) then
			self._reserved_icon:set_alpha(0.9)
			self._bg:show()
		elseif self._plan_icon and not self._plan_icon:visible() then
			self._box:set_alpha(0.9)
			self._bg:hide()
		else
			self._bg:hide()
		end

		self._current_state = ids
	end
end

function PrePlanningPoint:_set_visible()
	local ids = alive(self._reserved_icon) and Idstring("visible_reserved") or Idstring("visible")

	if self._current_state ~= ids then
		self._box:set_alpha(0.5)
		self._bg:set_alpha(0.45)

		if alive(self._reserved_icon) then
			self._reserved_icon:set_alpha(0.5)
			self._bg:show()
		elseif self._plan_icon and not self._plan_icon:visible() then
			self._box:set_alpha(0.7)
			self._bg:hide()
		else
			self._bg:hide()
		end

		self._current_state = ids
	end
end

function PrePlanningPoint:_set_hidden()
	local ids = alive(self._reserved_icon) and Idstring("hidden_reserved") or Idstring("hidden")

	if self._current_state ~= ids then
		self._bg:set_alpha(0.45)

		if alive(self._reserved_icon) then
			self._bg:show()
			self._box:set_alpha(0.5)
			self._reserved_icon:set_alpha(0.5)
		else
			self._bg:hide()
			self._box:set_alpha(0)
		end

		self._current_state = ids
	end
end

function PrePlanningPoint:_update_state()
	local selected = self._active_node.node:selected_item() and self._active_node.node:selected_item():name() == self._element:id()
	self._selected = selected

	if self._plan_icon then
		local has_majority = false

		self._plan_icon:set_visible(self._viewing_only)

		local current_majority_votes = managers.preplanning:get_current_majority_votes()

		for plan, data in pairs(current_majority_votes) do
			local type, index = unpack(data)
			local id = managers.preplanning:get_mission_element_id(type, index)

			if id == self._element:id() then
				has_majority = not self._active_node.current_plan or self._properties.category[self._active_node.current_plan]

				self._plan_icon:set_visible(true)

				break
			end
		end

		self._has_majority = has_majority
		local selectable = self._active_node.current_plan and (self._properties.category[self._active_node.current_plan] or self._plan_icon:visible())

		if has_majority then
			self:_set_selected()
			self:_set_size_mod(selected and 1.2 or 1.1)
		elseif selected then
			self:_set_selectable()
			self:_set_size_mod(1.2)
		elseif selectable then
			self:_set_visible()
			self:_set_size_mod(self._plan_icon:visible() and 1 or 0.8)
		else
			self:_set_hidden()
			self:_set_size_mod(1)
		end

		self._plan_icon:set_alpha(self._box:alpha())
	else
		local selectable = self._viewing_only or self._properties.type[self._active_node.current_type]
		local category_selected = self._properties.category[self._active_node.current_category] and self._active_node.node:selected_item() and self._properties.type[self._active_node.node:selected_item():name()]
		local visible = self._properties.type[self._active_node.current_type] or self._properties.category[self._active_node.current_category]

		if selected then
			self:_set_selected()
			self:_set_size_mod(1.2)
		elseif selectable then
			self:_set_selectable()
			self:_set_size_mod(alive(self._reserved_icon) and 1 or 0.8)
		elseif category_selected then
			self:_set_visible()
			self:_set_size_mod(1.1)
		elseif visible then
			self:_set_visible()
			self:_set_size_mod(1)
		else
			self:_set_hidden()
			self:_set_size_mod(1)
		end
	end
end

function PrePlanningPoint:_state_color()
	if not self._states.visible then
		return Color(0.5, 1, 1, 1)
	elseif not self._states.selected then
		return tweak_data.screen_colors.text
	else
		return tweak_data.screen_colors.button_stage_2
	end

	return Color.red
end

function PrePlanningPoint:_chk_mouse_pos(x, y)
	if not self:inside(x, y) then
		return false
	end

	if self._viewing_only then
		return true
	end

	if self._plan_icon and self._plan_icon:visible() then
		return true
	end

	if self._reserved_data then
		return true
	end

	if not self._properties.type[self._active_node.current_type] and (not self._active_node.current_plan or not self._properties.category[self._active_node.current_category]) then
		return false
	end

	return true
end

function PrePlanningPoint:select_mouse_over()
	if not self._active_node.current_type then
		if self._active_node.current_plan then
			-- Nothing
		elseif self._active_node.current_category then
			if self._reserved_data then
				MenuCallbackHandler:select_preplanning_item_by_id(self._reserved_data.pack[1])
			end
		elseif not self._active_node.current_viewing and not self._active_node.current_custom then
			local id = nil

			if self._reserved_data then
				id = tweak_data:get_raw_value("preplanning", "types", self._reserved_data.pack[1], "category")
			elseif self._plan_type then
				id = tweak_data:get_raw_value("preplanning", "types", self._plan_type, "plan")
			end

			if id then
				MenuCallbackHandler:select_preplanning_item_by_id(id)
			end
		end
	end
end

function PrePlanningPoint:mouse_moved(x, y, used)
	local mouse_check = self:_chk_mouse_pos(x, y)
	local mouse_selected = mouse_check and not used
	local is_in_menu = self._active_node.current_type and self._properties.type[self._active_node.current_type] or self._active_node.current_plan and self._properties.category[self._active_node.current_category]

	if self._mouse_selected ~= mouse_selected then
		self._mouse_selected = mouse_selected

		self:dirty()

		if not is_in_menu and self._mouse_selected then
			managers.menu_component:post_event("highlight")
		end
	end

	if mouse_check then
		return true, "link", is_in_menu
	end
end

function PrePlanningPoint:mouse_pressed(x, y)
	if not self:_chk_mouse_pos(x, y) then
		return
	end

	self._pressed = true

	return true
end

function PrePlanningPoint:mouse_released(x, y)
	if not self._pressed then
		return false
	end

	self._pressed = false

	if not self:_chk_mouse_pos(x, y) then
		return false
	end

	managers.menu_component:post_event("menu_enter")

	if self._active_node.current_viewing and self._viewing_only then
		MenuCallbackHandler:select_preplanning_item_by_id(self._element:id())
	elseif self._active_node.current_plan and self._properties.category[self._active_node.current_plan] then
		MenuCallbackHandler:vote_preplanning_mission_element_by_id(self._element:id())
	elseif self._active_node.current_type and self._properties.type[self._active_node.current_type] then
		if self._reserved_data then
			MenuCallbackHandler:unreserve_preplanning_mission_element_by_id(self._element:id())
		else
			MenuCallbackHandler:reserve_preplanning_mission_element_by_id(self._element:id())
		end
	elseif self._reserved_data then
		local category = tweak_data:get_raw_value("preplanning", "types", self._reserved_data.pack[1], "category")

		if category then
			MenuCallbackHandler:open_preplanning_to_type(category, self._reserved_data.pack[1], self._element:id())
		end
	elseif self._plan_type then
		local plan = tweak_data:get_raw_value("preplanning", "types", self._plan_type, "plan")

		if plan then
			MenuCallbackHandler:open_preplanning_to_plan(plan, self._element:id())
		end
	end

	return true
end

PrePlanningCustomPoint = PrePlanningCustomPoint or class(PrePlanningPoint)

function PrePlanningCustomPoint:init(map_panel, data, texture_width, texture_height, location_rotation, active_node, name)
	local width = PrePlanningPoint.WIDTH
	local height = PrePlanningPoint.HEIGHT
	self._width = width
	self._height = height
	self._map_width = map_panel:width()
	self._map_height = map_panel:height()
	self._current_size_mod = 1
	self._active_node = active_node
	self._map_panel = map_panel
	self._name = name
	local icon = data.icon or 11
	local texture_rect = tweak_data.preplanning:get_custom_texture_rect(icon)
	local texture = tweak_data.preplanning.gui.custom_icons_path
	local x = data.x or self._map_width / 2
	local y = data.y or self._map_height / 2
	local text_id = data.text_id
	local text = text_id and managers.localization:text(text_id) or " "

	if data.to_upper then
		text = utf8.to_upper(text)
	end

	local rotation = data.rotation or 0
	local post_event = data.post_event or false
	self._post_event = post_event
	local raw_x = x / texture_width - 0.5
	local raw_y = y / texture_height - 0.5
	local ax = math.cos(location_rotation) * raw_x - math.sin(location_rotation) * raw_y + 0.5
	local ay = math.sin(location_rotation) * raw_x + math.cos(location_rotation) * raw_y + 0.5
	self._x = ax
	self._y = ay
	self._panel = self._map_panel:panel({
		alpha = 0.9,
		layer = 4
	})

	self._panel:set_center(self._map_panel:w() * self._x, self._map_panel:h() * self._y)

	local gui_icon = self._panel:bitmap({
		name = "icon",
		valign = "scale",
		blend_mode = "add",
		halign = "scale",
		rotation = 0,
		texture = texture,
		texture_rect = texture_rect,
		w = width,
		h = height
	})

	gui_icon:set_center(self._panel:w() / 2, self._panel:h() / 2)

	self._info_box = self._panel:text({
		blend_mode = "add",
		name = "text",
		halign = "center",
		rotation = 360,
		valign = "center",
		text = text,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(self._info_box)
	self._info_box:set_rotation(rotation + location_rotation == 0 and 360 or rotation + location_rotation)
	self._info_box:set_left(gui_icon:right() + 5)
	self._info_box:set_center_y(gui_icon:center_y())
	self._info_box:set_alpha(0)

	local texture = tweak_data.preplanning.gui.category_icons_path
	local texture_rect = tweak_data.preplanning:get_category_texture_rect(32)
	self._talk_icon = self._panel:bitmap({
		name = "talk",
		valign = "scale",
		blend_mode = "add",
		halign = "scale",
		rotation = 0,
		texture = texture,
		texture_rect = texture_rect,
		w = width,
		h = height
	})

	self._talk_icon:set_center(self._panel:w() / 2, self._panel:h() / 2)
	self._talk_icon:hide()
end

function PrePlanningCustomPoint:name()
	return self._name
end

function PrePlanningCustomPoint:_update_reserved()
end

function PrePlanningCustomPoint:_update_state()
	local selected = self._mouse_selected or self._active_node.current_custom and self._active_node.node:selected_item() and self._active_node.node:selected_item():name() == self._name
	local visible = self._active_node.current_custom == "custom_points"
	self._selected = selected

	if selected then
		self:_set_selected()
		self:_set_size_mod(1.2)
	elseif visible then
		self:_set_visible()
		self:_set_size_mod(1)
	else
		self:_set_hidden()
		self:_set_size_mod(1)
	end
end

function PrePlanningCustomPoint:_update_extra()
end

function PrePlanningCustomPoint:_update_position()
	if self._panel:visible() then
		local diff_width = 1 - self._map_width / self._map_panel:width()
		local diff_height = 1 - self._map_height / self._map_panel:height()

		self._panel:set_width((self._map_width + self._map_width * diff_width * 0.018) * (self._current_size_mod or 1))
		self._panel:set_height((self._map_height + self._map_height * diff_height * 0.018) * (self._current_size_mod or 1))
		self._panel:set_center(self._map_panel:w() * self._x, self._map_panel:h() * self._y)
	end
end

function PrePlanningCustomPoint:_set_selected()
	local ids = Idstring("selected")

	if self._current_state ~= ids then
		self._panel:show()
		self._panel:set_alpha(1)

		self._current_state = ids
	end
end

function PrePlanningCustomPoint:_set_visible()
	local ids = Idstring("visible")

	if self._current_state ~= ids then
		self._panel:show()
		self._panel:set_alpha(0.9)

		self._current_state = ids
	end
end

function PrePlanningCustomPoint:_set_hidden()
	local ids = Idstring("hidden")

	if self._current_state ~= ids then
		self._panel:hide()

		self._current_state = ids
	end
end

function PrePlanningCustomPoint:inside(x, y)
	return self._panel:child("icon"):inside(x, y)
end

function PrePlanningCustomPoint:_chk_mouse_pos(x, y)
	if not self:inside(x, y) then
		return false
	end

	return self._active_node.current_custom and self._active_node.current_custom == "custom_points"
end

function PrePlanningCustomPoint:element()
	return false
end

function PrePlanningCustomPoint:mouse_moved(x, y, used)
	local mouse_check = self:_chk_mouse_pos(x, y)
	local mouse_selected = mouse_check and not used

	if self._mouse_selected ~= mouse_selected then
		self._mouse_selected = mouse_selected

		self:dirty()
	end

	if mouse_check then
		return true, self._post_event and "link" or "arrow", true, true
	end
end

function PrePlanningCustomPoint:mouse_pressed(x, y)
	if not self:_chk_mouse_pos(x, y) then
		return
	end

	self._pressed = true

	return true
end

function PrePlanningCustomPoint:mouse_released(x, y)
	if not self._pressed then
		return false
	end

	self._pressed = false

	if not self:_chk_mouse_pos(x, y) then
		return false
	end

	managers.menu_component:post_event("menu_enter")

	if self._post_event then
		managers.menu_component:preplanning_post_event(self._post_event, self._name, true)
		self:start_custom_talk()
	end

	return true
end

function PrePlanningCustomPoint:start_custom_talk()
	if self._talk_icon then
		self._talk_icon:show()
		self._talk_icon:set_rotation(0)
		self._talk_icon:animate(function (o)
			local dt = nil
			local rotation = 0

			while true do
				dt = coroutine.yield()

				if dt == 0 then
					dt = TimerManager:main():delta_time()
				end

				rotation = (rotation + 250 * dt) % 360

				self._talk_icon:set_rotation(rotation)
			end
		end)
	end
end

function PrePlanningCustomPoint:stop_custom_talk()
	if self._talk_icon then
		self._talk_icon:hide()
		self._talk_icon:stop()
	end
end

PrePlanningLocation = PrePlanningLocation or class()

function PrePlanningLocation:init(panel, index, size, active_node)
	self._active_node = active_node
	self._location = managers.preplanning:get_location_by_index(index)
	local location_group = managers.preplanning:convert_location_index_to_group(index)
	local location_rotation = self._location.rotation or 0
	local map_texture = self._location.texture
	local map_render_template = self._location.render_template
	local map_x = self._location.map_x or 0
	local map_y = self._location.map_y or 0
	local map_size = self._location.map_size or 1
	local map_width = self._location.map_width or map_size
	local map_height = self._location.map_height or map_size
	local x1 = self._location.x1 or 0
	local x2 = self._location.x2 or 0
	local y1 = self._location.y1 or 0
	local y2 = self._location.y2 or 0
	self._shape = {
		x1,
		y1,
		math.abs(x2 - x1),
		math.abs(y2 - y1)
	}
	self._rotation = location_rotation == 0 and 360 or location_rotation
	self._map_panel = panel
	self._panel = self._map_panel:panel({
		halign = "scale",
		alpha = 0.9,
		valign = "scale",
		w = size * map_width,
		h = size * map_height,
		name = location_group
	})

	self._panel:set_center(self._map_panel:w() / 2 + map_x * size * 1, self._map_panel:h() / 2 + map_y * size * 1)

	self._map = self._panel:bitmap({
		name = "map",
		blend_mode = "add",
		halign = "scale",
		rotation = 360,
		valign = "scale",
		texture = map_texture,
		w = self._panel:w(),
		h = self._panel:h(),
		render_template = map_render_template
	})

	if _G.IS_VR then
		self._map:set_rotation(0)
	end

	local texture_width = self._map:texture_width()
	local texture_height = self._map:texture_height()
	local rot_cos = math.cos(-self._rotation)
	local rot_sin = math.sin(-self._rotation)
	local tl_x = 1 - (rot_cos * 0.5 - rot_sin * 0.5 + 0.5)
	local tl_y = 1 - (rot_sin * 0.5 + rot_cos * 0.5 + 0.5)
	local tr_x = 1 - (rot_cos * -0.5 - rot_sin * 0.5 + 0.5)
	local tr_y = 1 - (rot_sin * -0.5 + rot_cos * 0.5 + 0.5)
	local bl_x = 1 - (rot_cos * 0.5 - rot_sin * -0.5 + 0.5)
	local bl_y = 1 - (rot_sin * 0.5 + rot_cos * -0.5 + 0.5)
	local br_x = 1 - (rot_cos * -0.5 - rot_sin * -0.5 + 0.5)
	local br_y = 1 - (rot_sin * -0.5 + rot_cos * -0.5 + 0.5)

	mvector3.set_static(mvec, tl_x * texture_width, tl_y * texture_height, 0)
	mvector3.set_static(mvec2, tr_x * texture_width, tr_y * texture_height, 0)
	mvector3.set_static(mvec3, bl_x * texture_width, bl_y * texture_height, 0)
	mvector3.set_static(mvec4, br_x * texture_width, br_y * texture_height, 0)
	self._map:set_texture_coordinates(mvec, mvec2, mvec3, mvec4)

	self._name = self._location.name_id and managers.localization:text(self._location.name_id) or "MISSING NAME_ID"
	self._index = index
	self._group = location_group
	self._points = {}
	self._points_by_type = {}
	self._points_by_category = {}
	self._custom_points = {}
	self._active = true
end

function PrePlanningLocation:skip_for_grid()
	return self._location.skip_for_grid
end

function PrePlanningLocation:name()
	return self._name
end

function PrePlanningLocation:index()
	return self._index
end

function PrePlanningLocation:group()
	return self._group
end

function PrePlanningLocation:points()
	return self._points
end

function PrePlanningLocation:map_rotation()
	return self._rotation
end

function PrePlanningLocation:map_shape()
	return self._panel:shape()
end

function PrePlanningLocation:map_texture_size()
	return self._map:texture_width(), self._map:texture_height()
end

function PrePlanningLocation:flash_error(id)
	if self._points[id] then
		self._points[id]:flash()
	end
end

function PrePlanningLocation:start_custom_talk(id)
	if self._custom_points[id] then
		self._custom_points[id]:start_custom_talk()
	end
end

function PrePlanningLocation:stop_custom_talk(id)
	if self._custom_points[id] then
		self._custom_points[id]:stop_custom_talk()
	end
end

function PrePlanningLocation:get_point_map_position(id)
	if self._active_node.current_custom then
		if self._custom_points[id] then
			local x, y = self._custom_points[id]:map_position()

			return x + self._panel:x(), y + self._panel:y(), self._group
		end
	elseif self._points[id] then
		local x, y = self._points[id]:map_position()

		return x + self._panel:x(), y + self._panel:y(), self._group
	end
end

function PrePlanningLocation:add_point(category, type, index, element)
	self._points_by_type[type] = self._points_by_type[type] or {}
	self._points_by_category[category] = self._points_by_category[category] or {}
	self._points_by_category[category][type] = self._points_by_category[category][type] or {}

	debug_assert(not self._points_by_type[type][index], "[PrePlanningLocation:add_point] Point already added to location!", "location", self._group, "category", category, "type", type, "index", index, "id", element:id(), "editor_name", element:editor_name())
	debug_assert(not self._points_by_category[category][type][index], "[PrePlanningLocation:add_point] Point already added to location!", "location", self._group, "category", category, "type", type, "index", index, "id", element:id(), "editor_name", element:editor_name())

	if self._points[element:id()] then
		self._points_by_type[type][index] = self._points[element:id()]
		self._points_by_category[category][type][index] = self._points[element:id()]

		self._points[element:id()]:add_properties(category, type, index)
	else
		local new_point = PrePlanningPoint:new(self._panel, element, self._shape, self._rotation, self._active_node, self._index)

		new_point:add_properties(category, type, index)

		self._points[element:id()] = new_point
		self._points_by_type[type][index] = new_point
		self._points_by_category[category][type][index] = new_point
	end
end

function PrePlanningLocation:add_custom_point(custom_point, index)
	local name = tostring(self._index) .. "_" .. tostring(index)

	if not self._custom_points[name] then
		self._custom_points[name] = PrePlanningCustomPoint:new(self._panel, custom_point, self._map:texture_width(), self._map:texture_height(), self._rotation, self._active_node, name)
	end
end

function PrePlanningLocation:set_active(active)
	return

	active = not not active

	if self._active ~= active then
		self._active = active

		self._panel:set_visible(self._active)
	end
end

function PrePlanningLocation:_get_point(type, id)
	if type then
		if self._points_by_type[type] then
			for i, point in pairs(self._points_by_type[type]) do
				if point:element():id() == id then
					return point
				end
			end
		end
	else
		for i, point in pairs(self._points) do
			if point:element():id() == id then
				return point
			end
		end
	end
end

function PrePlanningLocation:update_element(type, id)
	if id then
		local point = self:_get_point(type, id)

		if point then
			point:dirty()
		end
	else
		self:update_me()
	end
end

function PrePlanningLocation:update_me()
	self:clear_active_points()

	for i, point in pairs(self._points) do
		point:dirty()
	end

	for i, custom_point in pairs(self._custom_points) do
		custom_point:dirty()
	end
end

function PrePlanningLocation:_update_active_points()
	local current_type = self._active_node.current_type
	local current_category = self._active_node.current_category
	local current_plan = self._active_node.current_plan
	local current_custom = self._active_node.current_custom
	local current_viewing = self._active_node.current_viewing
	local t = {}
	local active_points = {}

	if current_viewing then
		for id, point in pairs(self._points) do
			if point._viewing_only then
				table.insert(active_points, point)
			end
		end
	else
		if current_type and self._points_by_type[current_type] then
			for i, point in pairs(self._points_by_type[current_type]) do
				t[point:element():id()] = true
			end
		end

		if current_category and self._points_by_category[current_category] then
			for category, points in pairs(self._points_by_category[current_category]) do
				for i, point in pairs(points) do
					t[point:element():id()] = true
				end
			end
		end

		for id, point in pairs(self._points) do
			if point._plan_icon and point._plan_icon:visible() or point._reserved_data then
				t[point:element():id()] = true
			end
		end

		for id, _ in pairs(t) do
			if self._points[id] then
				table.insert(active_points, self._points[id])
			end
		end

		if current_custom then
			for i, custom_point in pairs(self._custom_points) do
				table.insert(active_points, custom_point)
			end
		end
	end

	if self._selected_point and not table.contains(active_points, self._selected_point) then
		table.insert(active_points, self._selected_point)
	end

	self._active_points = active_points

	return self._active_points
end

function PrePlanningLocation:clear_active_points()
	self._active_points = nil
end

function PrePlanningLocation:_get_active_points()
	return self._active_points or self:_update_active_points()
end

function PrePlanningLocation:mouse_moved(x, y)
	local used, icon, eused, eicon, eother, remember_point = nil

	for _, point in ipairs(self:_get_active_points()) do
		eused, eicon, eother, remember_point = point:mouse_moved(x, y, used)

		if eused and not used then
			icon = eicon
			used = eused

			if remember_point and self._selected_point ~= point then
				self._selected_point = point

				self:clear_active_points()
			end

			if eother then
				if point:element() then
					if self._active_node.current_plan or self._active_node.current_type then
						MenuCallbackHandler:select_preplanning_item_by_id(point:element():id())
					else
						point:select_mouse_over()
					end
				elseif self._active_node.current_custom then
					MenuCallbackHandler:select_preplanning_item_by_id(point:name())
				end
			end
		end
	end

	return used, icon
end

function PrePlanningLocation:mouse_pressed(x, y)
	for _, point in ipairs(self:_get_active_points()) do
		if point:mouse_pressed(x, y) then
			return true
		end
	end
end

function PrePlanningLocation:mouse_released(x, y)
	for _, point in ipairs(self:_get_active_points()) do
		if point:mouse_released(x, y) then
			return true
		end
	end
end

function PrePlanningLocation:set_selected_point(element_id)
	self:update_me()
end

PrePlanningMapGui = PrePlanningMapGui or class()

function PrePlanningMapGui:init(saferect_ws, fullscreen_ws, node)
	self:setup(saferect_ws, fullscreen_ws, node)
end

function PrePlanningMapGui:setup(saferect_ws, fullscreen_ws, node)
	debug_assert(managers.preplanning:num_active_locations() > 0, "[PrePlanningMapGui:init] This level have on locations", "level_id", managers.job:current_level_id())

	self._saferect_root_panel = saferect_ws:panel()
	self._panel = self._saferect_root_panel:panel({
		layer = 45,
		name = "PrePlanningMapGui"
	})
	self._fullscreen_root_panel = fullscreen_ws:panel()
	self._fullscreen_panel = self._fullscreen_root_panel:panel({
		layer = 40,
		name = "PrePlanningMapGui"
	})
	self._text_buttons = {}
	self._is_pc_controller = managers.menu:is_pc_controller()
	self._active_node = {
		node = node
	}

	self:_setup_blackborders()

	if managers and managers.viewport then
		self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
	end

	local full_16_9 = managers.gui_data:full_16_9_size()

	self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur_top",
		render_template = "VertexColorTexturedBlur3D",
		rotation = 360,
		x = 0,
		w = self._fullscreen_root_panel:w(),
		h = full_16_9.convert_y * 2,
		y = -full_16_9.convert_y,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER + 1
	})
	self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur_right",
		render_template = "VertexColorTexturedBlur3D",
		rotation = 360,
		y = 0,
		w = full_16_9.convert_x * 2,
		h = self._fullscreen_root_panel:h(),
		x = self._fullscreen_root_panel:w() - full_16_9.convert_x,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER + 1
	})
	self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur_bottom",
		render_template = "VertexColorTexturedBlur3D",
		rotation = 360,
		x = 0,
		w = self._fullscreen_root_panel:w(),
		h = full_16_9.convert_y * 2,
		y = self._fullscreen_root_panel:h() - full_16_9.convert_y,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER + 1
	})
	self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur_left",
		render_template = "VertexColorTexturedBlur3D",
		rotation = 360,
		y = 0,
		w = full_16_9.convert_x * 2,
		h = self._fullscreen_root_panel:h(),
		x = -full_16_9.convert_x,
		layer = tweak_data.gui.CRIMENET_CHAT_LAYER + 1
	})
	self._panel:rect({
		blend_mode = "add",
		name = "top_line",
		h = 2,
		y = 0,
		x = 0,
		layer = 1000,
		w = self._panel:w(),
		color = tweak_data.screen_colors.crimenet_lines
	})
	self._panel:rect({
		blend_mode = "add",
		name = "bottom_line",
		h = 2,
		y = 0,
		x = 0,
		layer = 1000,
		w = self._panel:w(),
		color = tweak_data.screen_colors.crimenet_lines
	}):set_bottom(self._panel:h())
	self._panel:rect({
		blend_mode = "add",
		name = "right_line",
		y = 0,
		w = 2,
		x = 0,
		layer = 1000,
		h = self._panel:h(),
		color = tweak_data.screen_colors.crimenet_lines
	}):set_right(self._panel:w())
	self._panel:rect({
		blend_mode = "add",
		name = "left_line",
		y = 0,
		w = 2,
		x = 0,
		layer = 1000,
		h = self._panel:h(),
		color = tweak_data.screen_colors.crimenet_lines
	})
	self._fullscreen_panel:rect({
		name = "bg",
		alpha = 0.95,
		layer = -10,
		color = Color.black
	})
	self._fullscreen_panel:bitmap({
		texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/map_vignette",
		name = "vignette",
		rotation = 360,
		blend_mode = "mul",
		y = -5,
		x = -5,
		layer = 6,
		color = Color(0.2, 1, 1, 1),
		w = self._fullscreen_panel:w() + 10,
		h = self._fullscreen_panel:h() + 10
	})

	self._scanline = self._fullscreen_panel:bitmap({
		texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/scanline",
		name = "scanline",
		h = 128,
		wrap_mode = "wrap",
		layer = 7,
		blend_mode = "add",
		texture_rect = {
			0,
			0,
			self._fullscreen_panel:w(),
			64
		}
	})

	self._scanline:set_bottom(-math.random(100))

	local title_text = self._panel:text({
		name = "title_text",
		blend_mode = "add",
		y = 10,
		x = 10,
		layer = 15,
		text = managers.localization:to_upper_text("menu_preplanning_title", {
			level = managers.localization:text(managers.job:current_level_data().name_id)
		}),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(title_text)
	title_text:set_center_x(self._panel:w() / 2)
	title_text:set_top(10)

	local current_budget, total_budget = managers.preplanning:get_current_budget()
	local budget_text = self._panel:text({
		name = "budget_text",
		blend_mode = "add",
		x = 10,
		layer = 15,
		text = managers.localization:to_upper_text("menu_pp_budget", {
			current = string.format("%.2d", total_budget - current_budget),
			total = string.format("%.2d", total_budget)
		}),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		y = title_text:top()
	})

	make_fine_text(budget_text)
	budget_text:set_position(10, title_text:top())

	local total_cost = self._panel:text({
		name = "total_cost",
		blend_mode = "add",
		layer = 15,
		text = managers.localization:to_upper_text("menu_pp_total_cost", {
			money = managers.experience:cash_string(managers.money:get_preplanning_total_cost())
		}),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(total_cost)
	total_cost:set_position(10, budget_text:bottom())

	local button = self:create_text_button({
		special_button = "menu_toggle_pp_breakdown",
		left = 10,
		top = total_cost:bottom() + 10,
		clbk = callback(self, self, "toggle_breakdown"),
		text = managers.localization:to_upper_text("menu_pp_show_breakdown", {
			BTN_X = managers.localization:btn_macro("menu_toggle_pp_breakdown")
		})
	})
	self._breakdown_button = button

	self._breakdown_button:hide()

	local breakdown_panel = self._panel:panel({
		layer = 15,
		name = "breakdown_panel"
	})

	breakdown_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur",
		halign = "scale",
		layer = -1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = breakdown_panel:w(),
		h = breakdown_panel:h()
	})
	breakdown_panel:rect({
		alpha = 0.3,
		valign = "scale",
		halign = "scale",
		rotation = 360,
		layer = 0,
		color = Color.black
	})
	BoxGuiObject:new(breakdown_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	breakdown_panel:set_position(button:left(), button:bottom())
	breakdown_panel:hide()
	self:_update_breakdown()

	self._location_size = math.min(self._panel:w(), self._panel:h())
	self._map_size = math.max(self._panel:w(), self._panel:h()) * 20
	self._map_panel = self._panel:panel({
		alpha = 0.9,
		name = "map",
		layer = 0,
		w = self._map_size,
		h = self._map_size
	})

	self._map_panel:set_center(self._panel:w() / 2, self._panel:h() / 2)

	self._map_x, self._map_y = self._map_panel:position()
	self._map_zoom = 1
	local location_data = managers.preplanning:current_location_data()
	self._post_event_prefix = (location_data.post_event_prefix or "gus") .. "_"
	local location_indexed = {}
	self._locations = {}
	self._current_location = false
	local button_panel, bleft, bright, btop, bbottom, new_location = nil

	for i = 1, managers.preplanning:num_active_locations() do
		new_location = PrePlanningLocation:new(self._map_panel, i, self._location_size, self._active_node)

		debug_assert(not self._locations[new_location:group()], "[PrePlanningMapGui:init] Location already taken!", "location", new_location:group(), "new index", i)

		self._locations[new_location:group()] = new_location
		location_indexed[i] = new_location
	end

	local types = managers.preplanning:types_with_mission_elements()
	local location_group, location, category = nil

	for _, type in ipairs(types) do
		category = tweak_data:get_raw_value("preplanning", "types", type, "category") or "default"

		if managers.preplanning:is_type_position_important(type) then
			for index, element in ipairs(managers.preplanning:get_mission_elements_by_type(type)) do
				location_group = element:value("location_group")
				location = self._locations[location_group]

				debug_assert(location, "[PrePlanningMapGui:init] Location is missing in GUI!", "location", location_group)
				location:add_point(category, type, index, element)
			end
		end
	end

	for location_index, custom_points in pairs(managers.preplanning:get_current_custom_points()) do
		if location_indexed[location_index] then
			for i, custom_point in pairs(custom_points) do
				location_indexed[location_index]:add_custom_point(custom_point, i)
			end
		end
	end

	local grid_width = 1
	local grid_height = 1
	local center_x = self._map_panel:w() / 2
	local center_y = self._map_panel:h() / 2
	local x, y, w, h = nil
	local a = 2
	local gw = 0
	local gh = 0
	local li = 0

	for location_group, location in pairs(self._locations) do
		if not location:skip_for_grid() then
			x, y, w, h = location:map_shape()
			li = li + 1
			gw = gw + w
			gh = gh + h
			grid_width = math.max(grid_width, math.abs(x - center_x), math.abs(x + w - center_x))
			grid_height = math.max(grid_height, math.abs(y - center_y), math.abs(y + h - center_y))
		end
	end

	gw = li > 0 and gw / li or 0
	gh = li > 0 and gh / li or 0
	local gw_mul = location_data.grid_width_mul or 1.5
	local gh_mul = location_data.grid_height_mul or 0.5
	grid_width = grid_width * 2 + gw * gw_mul
	grid_height = grid_height * 2 + gh * gh_mul
	local tx, ty, tw, th = nil
	local M = grid_width
	local L = self._location_size
	local C = 1280
	tw = M * C / L
	tx = -(tw - C) / 2
	local M = grid_height
	local L = self._location_size
	local C = 1280
	th = M * C / L
	ty = -(th - C) / 2
	local grid_texture_rect = {
		tx,
		ty,
		tw,
		th
	}
	self._grid_width = grid_width
	self._grid_height = grid_height
	self._grid_panel = self._panel:panel({
		w = self._grid_width,
		h = self._grid_height
	})

	self._grid_panel:set_center(self._map_panel:center())

	self._map_grid = self._grid_panel:bitmap({
		texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/bg_grid",
		layer = -1,
		valign = "scale",
		wrap_mode = "wrap",
		blend_mode = "add",
		halign = "scale",
		rotation = 0,
		w = self._grid_width,
		h = self._grid_height,
		texture_rect = grid_texture_rect
	})
	local ratio = self._fullscreen_panel:w() / self._fullscreen_panel:h()
	local safe_scaled_size = managers.gui_data:corner_scaled_size()
	local min_zoom = location_data.min_zoom or 1
	local max_zoom = location_data.max_zoom or 5

	if grid_height < grid_width / ratio then
		min_zoom = (self._location_size + safe_scaled_size.y * 2) / grid_height
	else
		min_zoom = (self._location_size + safe_scaled_size.x * 2) / (grid_width / ratio)
	end

	self._min_zoom = math.lerp(min_zoom, 1, math.clamp(location_data.min_zoom or 0.5, 0, 1))
	self._max_zoom = max_zoom
	self._num_draw_points = 0
	self._peer_draw_lines = {}
	self._peer_draw_line_index = {}

	for i = 1, managers.criminals.MAX_NR_CRIMINALS do
		self._peer_draw_lines[i] = {}
		self._peer_draw_line_index[i] = false

		self._grid_panel:panel({
			valign = "scale",
			halign = "scale",
			name = tostring(i)
		})
	end

	self._enabled = false
	self._drawing_panel = self._panel:panel({
		w = 400,
		layer = 15,
		h = 100,
		visible = false
	})
	local cx, cy, cw, ch = managers.menu_component:get_game_chat_button_shape()
	self._drawboard_button = self:create_text_button({
		special_button = "menu_toggle_pp_drawboard",
		left = cx and cx + cw + 5 or 10,
		bottom = self._panel:h() - 10,
		clbk = callback(self, self, "toggle_drawboard"),
		text = managers.localization:to_upper_text("menu_pp_show_drawboard", {
			BTN_Y = managers.localization:btn_macro("menu_toggle_pp_drawboard")
		})
	})

	self._drawboard_button:hide()

	local drawing_tooltip = self._drawing_panel:text({
		text = " ",
		name = "tooltip",
		blend_mode = "add",
		layer = 1,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(drawing_tooltip)
	self._drawing_panel:set_h(35 + drawing_tooltip:h())

	local offset = 0
	local button = nil
	local texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/drawtools_atlas"
	local params = {
		top = 0,
		layer = 1,
		texture = texture,
		panel = self._drawing_panel,
		mouse_over_clbk = callback(self, self, "set_draw_tooltip_clbk")
	}

	if Network:is_server() and not Global.game_settings.single_player then
		params.texture_rect_on = {
			4,
			32,
			24,
			24
		}
		params.texture_rect_off = {
			4,
			4,
			24,
			24
		}
		params.clbk = callback(self, self, "erase_drawing")
		params.left = (button and button:right() + 5 or 0) + offset
		params.name = managers.localization:text("menu_pp_draw_clear_all")
		button = self:create_text_button(params)
		self._clear_all_button = button
	end

	params.texture_rect_on = {
		32,
		32,
		24,
		24
	}
	params.texture_rect_off = {
		32,
		4,
		24,
		24
	}
	params.clbk = callback(self, self, "erase_drawing")
	params.left = (button and button:right() + 5 or 0) + offset
	params.name = managers.localization:text("menu_pp_draw_erase")
	button = self:create_text_button(params)
	self._erase_button = button
	params.texture_rect_on = {
		60,
		32,
		24,
		24
	}
	params.texture_rect_off = {
		60,
		4,
		24,
		24
	}
	params.clbk = callback(self, self, "undo_drawing")
	params.left = (button and button:right() + 5 or 0) + offset
	params.name = managers.localization:text("menu_pp_draw_undo")
	button = self:create_text_button(params)
	self._undo_button = button
	local button_index = nil
	offset = 10
	self._peer_buttons = {}

	for i = 1, managers.criminals.MAX_NR_CRIMINALS do
		params.texture_rect_on = {
			88,
			32,
			24,
			24
		}
		params.texture_rect_off = {
			88,
			4,
			24,
			24
		}
		params.clbk = callback(self, self, "toggle_drawing_clbk")
		params.left = (button and button:right() + 5 or 0) + offset
		params.color = tweak_data.chat_colors[i] or tweak_data.chat_colors[#tweak_data.chat_colors]
		params.value = i
		offset = 0
		button, button_index = self:create_text_button(params)

		table.insert(self._peer_buttons, button_index)
	end

	self._drawing_panel:set_w(button:right())
	self._drawing_panel:set_left(10)
	self._drawing_panel:set_bottom(self._drawboard_button:top())
	drawing_tooltip:set_rotation(360)
	drawing_tooltip:set_w(self._drawing_panel:w())
	drawing_tooltip:set_left(0)
	drawing_tooltip:set_bottom(self._drawing_panel:h())

	local drawing_ink = self._drawing_panel:rect({
		blend_mode = "add",
		name = "draw_ink",
		h = 4,
		alpha = 0.9,
		layer = 1,
		w = self._drawing_panel:w(),
		color = Color.white
	})
	local drawing_bg = self._drawing_panel:rect({
		name = "draw_bg",
		h = 4,
		alpha = 0.4,
		layer = 0,
		w = self._drawing_panel:w(),
		color = Color.white
	})
	local drawing_end = self._drawing_panel:rect({
		w = 2,
		name = "draw_end",
		h = 4,
		layer = 2,
		color = Color.white
	})

	drawing_ink:set_bottom(drawing_tooltip:top() - 2)
	drawing_ink:set_left(0)
	drawing_bg:set_shape(drawing_ink:shape())
	drawing_end:set_top(drawing_ink:top())
	drawing_end:set_right(self._drawing_panel:w())
	self:_update_drawboard()
end

function PrePlanningMapGui:resolution_changed()
	self:_setup_blackborders()
end

function PrePlanningMapGui:_setup_blackborders()
	if self._blackborder_workspace then
		managers.gui_data:destroy_workspace(self._blackborder_workspace)

		self._blackborder_workspace = nil
	end

	self._blackborder_workspace = managers.gui_data:create_fullscreen_workspace()
	local top_border = self._blackborder_workspace:panel():rect({
		name = "top_border",
		rotation = 360,
		layer = tweak_data.gui.MOUSE_LAYER - 100,
		color = Color.black
	})
	local bottom_border = self._blackborder_workspace:panel():rect({
		name = "bottom_border",
		rotation = 360,
		layer = tweak_data.gui.MOUSE_LAYER - 100,
		color = Color.black
	})
	local left_border = self._blackborder_workspace:panel():rect({
		name = "left_border",
		rotation = 360,
		layer = tweak_data.gui.MOUSE_LAYER - 100,
		color = Color.black
	})
	local right_border = self._blackborder_workspace:panel():rect({
		name = "right_border",
		rotation = 360,
		layer = tweak_data.gui.MOUSE_LAYER - 100,
		color = Color.black
	})
	local gui_width, gui_height = managers.gui_data:get_base_res()

	managers.gui_data:layout_fullscreen_workspace(self._blackborder_workspace)

	local border_w = self._blackborder_workspace:panel():w()
	local border_h = (self._blackborder_workspace:panel():h() - gui_height) / 2

	top_border:set_position(0, -2)
	top_border:set_size(border_w, border_h + 2)
	bottom_border:set_position(0, gui_height + border_h)
	bottom_border:set_size(border_w, border_h + 2)

	local border_w = (self._blackborder_workspace:panel():w() - gui_width) / 2
	local border_h = self._blackborder_workspace:panel():h()

	left_border:set_left(0)
	left_border:set_size(border_w, border_h + 2)
	right_border:set_size(border_w, border_h + 2)
	right_border:set_right(self._blackborder_workspace:panel():w())
end

function PrePlanningMapGui:set_drawboard_button_position(x, y)
	if self._drawboard_button then
		self._drawboard_button:set_position(x, y)
		self._drawing_panel:set_left(10)
		self._drawing_panel:set_bottom(self._drawboard_button:top())
	end
end

function PrePlanningMapGui:hide_drawboard()
	if self._drawing_panel:visible() then
		self._drawing_panel:hide()

		if self._drawboard_button then
			local text = self._drawboard_button:child("button_text")

			text:set_text(self._drawing_panel:visible() and managers.localization:to_upper_text("menu_pp_hide_drawboard", {
				BTN_Y = managers.localization:btn_macro("menu_toggle_pp_drawboard")
			}) or managers.localization:to_upper_text("menu_pp_show_drawboard", {
				BTN_Y = managers.localization:btn_macro("menu_toggle_pp_drawboard")
			}))
			make_fine_text(text)
			self._drawboard_button:set_size(text:size())
		end
	end
end

function PrePlanningMapGui:toggle_drawboard(button)
	self._drawing_panel:set_visible(not self._drawing_panel:visible())

	if self._drawboard_button then
		local text = self._drawboard_button:child("button_text")

		text:set_text(self._drawing_panel:visible() and managers.localization:to_upper_text("menu_pp_hide_drawboard", {
			BTN_Y = managers.localization:btn_macro("menu_toggle_pp_drawboard")
		}) or managers.localization:to_upper_text("menu_pp_show_drawboard", {
			BTN_Y = managers.localization:btn_macro("menu_toggle_pp_drawboard")
		}))
		make_fine_text(text)
		self._drawboard_button:set_size(text:size())
	end

	managers.menu_component:set_crimenet_chat_gui(false)

	return true
end

function PrePlanningMapGui:_update_drawboard()
	local drawing_panel, button, peer = nil

	for peer_id, index in ipairs(self._peer_buttons) do
		button = self._text_buttons[index]

		if button then
			peer = managers.network:session() and managers.network:session():peer(peer_id)

			button.panel:set_visible(not not peer)

			if peer then
				button.name = managers.localization:text(button.panel:visible() and "menu_pp_draw_hide" or "menu_pp_draw_show", {
					name = peer:name()
				})

				if button.highlighted then
					self:set_draw_tooltip_clbk(button)
				end

				drawing_panel = self._grid_panel:child(tostring(peer_id))

				if alive(drawing_panel) then
					if drawing_panel:visible() then
						button.icon_on = {
							88,
							32,
							24,
							24
						}
						button.icon_off = {
							88,
							4,
							24,
							24
						}
					else
						button.icon_on = {
							88,
							4,
							24,
							24
						}
						button.icon_off = {
							88,
							32,
							24,
							24
						}
					end
				end
			end
		end
	end

	if alive(self._undo_button) then
		self._undo_button:child("button_text"):set_color(self._num_draw_points == 0 and Color(1, 0.5, 0.5, 0.5) or Color.white)
	end

	if alive(self._erase_button) then
		self._erase_button:child("button_text"):set_color(self._num_draw_points == 0 and Color(1, 0.5, 0.5, 0.5) or Color.white)
	end
end

function PrePlanningMapGui:set_draw_tooltip_clbk(button)
	local peer_id = managers.network:session():local_peer():id()
	local can_draw = alive(self._grid_panel:child(tostring(peer_id))) and self._grid_panel:child(tostring(peer_id)):visible()
	local text = button and button.name or can_draw and managers.localization:text("menu_pp_draw_default") or managers.localization:text("menu_pp_draw_no_draw")

	self._drawing_panel:child("tooltip"):set_text(utf8.to_upper(text))
end

function PrePlanningMapGui:toggle_breakdown(button)
	local breakdown_panel = self._panel:child("breakdown_panel")

	breakdown_panel:set_visible(not breakdown_panel:visible())
	button.text:set_text(breakdown_panel:visible() and managers.localization:to_upper_text("menu_pp_hide_breakdown", {
		BTN_X = managers.localization:btn_macro("menu_toggle_pp_breakdown")
	}) or managers.localization:to_upper_text("menu_pp_show_breakdown", {
		BTN_X = managers.localization:btn_macro("menu_toggle_pp_breakdown")
	}))
	make_fine_text(button.text)
	button.panel:set_size(button.text:size())

	return true
end

function PrePlanningMapGui:_update_breakdown()
	local breakdown_panel = self._panel:child("breakdown_panel")

	breakdown_panel:clear()

	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local current_plans, current_types = managers.preplanning:get_current_preplan()
	local width = 0
	local height = 0
	local title_text, last_text, text, t = nil

	if current_plans and #current_plans > 0 then
		for _, data in ipairs(current_plans) do
			title_text = breakdown_panel:text({
				blend_mode = "add",
				layer = 0,
				text = utf8.to_upper(managers.preplanning:get_category_name_by_type(data.type)) .. ":",
				font = font,
				font_size = font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(title_text)
			title_text:set_position(10, last_text and last_text:bottom() + 5 or 10)

			width = math.max(width, title_text:right())
			height = math.max(height, title_text:bottom())
			last_text = title_text
			text = breakdown_panel:text({
				blend_mode = "add",
				layer = 0,
				text = managers.preplanning:get_type_name(data.type),
				font = font,
				font_size = font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(text)
			text:set_position(20, last_text:bottom())

			width = math.max(width, text:right())
			height = math.max(height, text:bottom())
			last_text = text
		end
	end

	local category, ct = nil

	if current_types and #current_types > 0 then
		t = {}

		for _, data in ipairs(current_types) do
			t[data.type] = (t[data.type] or 0) + 1
		end

		ct = {}

		for type, count in pairs(t) do
			category = managers.preplanning:get_category_by_type(type)
			ct[category] = ct[category] or {}

			table.insert(ct[category], type)
		end

		local count = nil

		for category, types in pairs(ct) do
			title_text = breakdown_panel:text({
				blend_mode = "add",
				layer = 0,
				text = utf8.to_upper(managers.preplanning:get_category_name(category)) .. ":",
				font = font,
				font_size = font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(title_text)
			title_text:set_position(10, last_text and last_text:bottom() + 5 or 10)

			width = math.max(width, title_text:right())
			height = math.max(height, title_text:bottom())
			last_text = title_text

			for _, type in ipairs(types) do
				count = t[type]
				text = breakdown_panel:text({
					blend_mode = "add",
					layer = 0,
					text = (count > 1 and tostring(count) .. "x " or "") .. managers.preplanning:get_type_name(type),
					font = font,
					font_size = font_size,
					color = tweak_data.screen_colors.text
				})

				make_fine_text(text)
				text:set_position(20, last_text:bottom())

				width = math.max(width, text:right())
				height = math.max(height, text:bottom())
				last_text = text
			end
		end
	end

	breakdown_panel:set_size(width + 10, height + 10)
	breakdown_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur",
		halign = "scale",
		layer = -2,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = breakdown_panel:w(),
		h = breakdown_panel:h()
	})
	breakdown_panel:rect({
		alpha = 0.3,
		valign = "scale",
		halign = "scale",
		rotation = 360,
		layer = -1,
		color = Color.black
	})
	BoxGuiObject:new(breakdown_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	breakdown_panel:set_alpha(width > 0 and 1 or 0)
end

function PrePlanningMapGui:sync_draw_point(peer_id, x, y)
	local line_index = self._peer_draw_line_index[peer_id]

	if line_index and alive(self._grid_panel:child(tostring(peer_id))) then
		local data = self._peer_draw_lines[peer_id][line_index]

		if data then
			local points = data
			local gui = data.gui

			if #points == 0 or points[#points - 1] ~= x or points[#points] ~= y then
				table.insert(points, x)
				table.insert(points, y)

				if #points >= 4 then
					if not data.gui then
						local line_points = {}
						local px, py = nil

						for i = 1, #points - 1, 2 do
							px = points[i] * self._grid_panel:w()
							py = points[i + 1] * self._grid_panel:h()

							table.insert(line_points, Vector3(px, py, 0))
						end

						data.gui = self._grid_panel:child(tostring(peer_id)):polyline({
							blend_mode = "add",
							layer = 2,
							halign = "scale",
							valign = "scale",
							points = line_points,
							line_width = data.line_width,
							color = tweak_data.preplanning_peer_colors[data.color_index]
						})
					else
						mvector3.set_static(mvec, x * self._grid_panel:w(), y * self._grid_panel:h(), 0)
						data.gui:add_point(mvec)
					end
				end
			end
		end
	end
end

function PrePlanningMapGui:sync_start_drawing(peer_id, width, color_index)
	print("sync_start_drawing", peer_id, width, color_index)
	table.insert(self._peer_draw_lines[peer_id], {
		gui = false,
		line_width = width,
		color_index = color_index
	})

	self._peer_draw_line_index[peer_id] = #self._peer_draw_lines[peer_id]
end

function PrePlanningMapGui:sync_end_drawing(peer_id)
	print("sync_end_drawing", peer_id)

	self._peer_draw_line_index[peer_id] = nil
end

function PrePlanningMapGui:sync_undo_drawing(peer_id)
	local draws = self._peer_draw_lines[peer_id]

	if draws then
		local last_draw = table.remove(draws, #draws)

		if last_draw and alive(last_draw.gui) then
			last_draw.gui:parent():remove(last_draw.gui)
		end

		last_draw = nil
	end
end

function PrePlanningMapGui:sync_erase_drawing(peer_id)
	local draws = self._peer_draw_lines[peer_id]

	if draws then
		for i, data in ipairs(draws) do
			if alive(data.gui) then
				data.gui:parent():remove(data.gui)
			end
		end
	end

	self._peer_draw_lines[peer_id] = {}
	self._peer_draw_line_index[peer_id] = nil
end

function PrePlanningMapGui:set_num_draw_points(num)
	self._num_draw_points = num
	local ink = self._drawing_panel:child("draw_ink")

	if alive(ink) then
		ink:set_w((1 - self._num_draw_points / tweak_data.preplanning.gui.MAX_DRAW_POINTS) * self._drawing_panel:w())
	end

	self:_update_drawboard()
end

function PrePlanningMapGui:undo_drawing()
	local peer_id = managers.network:session():local_peer():id()
	local draws = self._peer_draw_lines[peer_id]

	if draws then
		local last_draw = draws[#draws]

		if last_draw and alive(last_draw.gui) then
			self:set_num_draw_points(self._num_draw_points - #last_draw / 2)
		end
	end

	managers.network:session():send_to_peers_synched("draw_preplanning_event", 3, 1, 1)
	self:sync_undo_drawing(peer_id)

	return true
end

function PrePlanningMapGui:erase_drawing()
	local peer_id = managers.network:session():local_peer():id()

	self:set_num_draw_points(0)
	managers.network:session():send_to_peers_synched("draw_preplanning_event", 4, 1, 1)
	self:sync_erase_drawing(peer_id)

	return true
end

function PrePlanningMapGui:start_drawing()
	if tweak_data.preplanning.gui.MAX_DRAW_POINTS <= self._num_draw_points then
		return
	end

	local peer_id = managers.network:session():local_peer():id()

	if not self._draw_mode and alive(self._grid_panel:child(tostring(peer_id))) and self._grid_panel:child(tostring(peer_id)):visible() then
		self._draw_mode = true
		self._last_draw_t = nil
		local line_width = 2
		local line_color_index = peer_id

		managers.network:session():send_to_peers_synched("draw_preplanning_event", 1, line_width, line_color_index)
		self:sync_start_drawing(peer_id, line_width, line_color_index)
		managers.menu_component:post_event("slider_grab")
	end
end

function PrePlanningMapGui:end_drawing()
	if self._draw_mode then
		self._draw_mode = false
		self._last_draw_t = nil
		local peer_id = managers.network:session():local_peer():id()

		managers.network:session():send_to_peers_synched("draw_preplanning_event", 2, 1, 1)
		self:sync_end_drawing(peer_id)
		managers.menu_component:post_event("slider_release")
	end
end

function PrePlanningMapGui:_draw_point(x, y)
	if self._mouse_moved then
		if tweak_data.preplanning.gui.MAX_DRAW_POINTS <= self._num_draw_points then
			self:end_drawing()

			return
		end

		local px = (x - self._grid_panel:x()) / self._grid_panel:w()
		local py = (y - self._grid_panel:y()) / self._grid_panel:h()
		local sync_step = 10000
		px = math.round(px * sync_step) / sync_step
		py = math.round(py * sync_step) / sync_step
		px = math.clamp(px, 0, 1)
		py = math.clamp(py, 0, 1)

		self:set_num_draw_points(self._num_draw_points + 1)

		local peer_id = managers.network:session():local_peer():id()

		managers.network:session():send_to_peers_synched("draw_preplanning_point", px, py)
		self:sync_draw_point(peer_id, px, py)
	end
end

function PrePlanningMapGui:toggle_drawing_clbk(data)
	if data then
		return self:toggle_drawing(data.value)
	end
end

function PrePlanningMapGui:toggle_drawing(peer_id)
	local panel = self._grid_panel:child(tostring(peer_id))

	if alive(panel) then
		panel:set_visible(not panel:visible())
		self:_update_drawboard()

		return true
	end

	return false
end

local seconds_per_draw = 0.016666666666666666

function PrePlanningMapGui:update_drawing(t, dt)
	if self._draw_mode then
		self._last_draw_t = self._last_draw_t or t - seconds_per_draw
		local time_diff = t - self._last_draw_t

		if seconds_per_draw < time_diff then
			self._last_draw_t = t
			local mx, my = managers.mouse_pointer:modified_mouse_pos()

			self:_draw_point(mx, my)
		end
	end
end

function PrePlanningMapGui:set_drawings(peer_draw_lines, peer_draw_line_index)
	for peer_id, _ in pairs(self._peer_draw_lines) do
		self:sync_erase_drawing(peer_id)
	end

	self._peer_draw_lines = peer_draw_lines
	self._peer_draw_line_index = peer_draw_line_index
	local points = nil

	for peer_id, lines in pairs(self._peer_draw_lines) do
		for _, data in ipairs(lines) do
			points = data

			if #points >= 4 then
				local line_points = {}
				local px, py = nil

				for i = 1, #points - 1, 2 do
					px = points[i] * self._grid_panel:w()
					py = points[i + 1] * self._grid_panel:h()

					table.insert(line_points, Vector3(px, py, 0))
				end

				if not data.gui then
					data.gui = self._grid_panel:child(tostring(peer_id)):polyline({
						blend_mode = "add",
						layer = 2,
						halign = "scale",
						valign = "scale",
						points = line_points,
						line_width = data.line_width,
						color = tweak_data.preplanning_peer_colors[data.color_index]
					})
				else
					data.gui:set_points(line_points)
				end
			end
		end
	end
end

function PrePlanningMapGui:get_drawings()
	local peer_draw_lines = deep_clone(self._peer_draw_lines)
	local peer_draw_line_index = deep_clone(self._peer_draw_line_index)

	for peer_id, lines in pairs(peer_draw_lines) do
		for _, data in ipairs(lines) do
			data.gui = nil
		end
	end

	return peer_draw_lines, peer_draw_line_index
end

function PrePlanningMapGui._flash_anim(text, start_color)
	start_color = start_color or tweak_data.screen_colors.text
	local s = 0

	local function f(t)
		s = math.min(1, math.sin(t * 180) * 2)

		text:set_color(math.lerp(start_color, tweak_data.screen_colors.important_1, s))
	end

	local seconds = 0.5
	local t = 0

	while true do
		local dt = coroutine.yield()

		if dt == 0 then
			dt = TimerManager:main():delta_time()
		end

		t = t + dt

		if seconds <= t then
			break
		end

		f(t / seconds, t)
	end

	f(1, seconds)
	text:set_color(start_color)
end

function PrePlanningMapGui:flash_error(element_id, budget, money, ...)
	managers.menu_component:post_event("menu_error")

	for i, location in pairs(self._locations) do
		location:flash_error(element_id)
	end

	if budget then
		local budget_text = self._panel:child("budget_text")

		budget_text:stop()
		budget_text:animate(self._flash_anim)
	end

	if money then
		local total_cost = self._panel:child("total_cost")

		total_cost:stop()
		total_cost:animate(self._flash_anim)
	end
end

function PrePlanningMapGui:set_location_clbk(button)
	if button and button.value then
		return self:set_location(button.value:group())
	end
end

function PrePlanningMapGui:start_custom_talk(id)
	for i, location in pairs(self._locations) do
		location:start_custom_talk(id)
	end
end

function PrePlanningMapGui:stop_custom_talk(id)
	for i, location in pairs(self._locations) do
		location:stop_custom_talk(id)
	end
end

function PrePlanningMapGui:post_event_end_clbk(type, event, cookie)
	if cookie then
		self:stop_custom_talk(cookie)
	end
end

function PrePlanningMapGui:post_event(event, custom_end_id, ignore_prefix)
	local prefix_string = ignore_prefix and "" or self._post_event_prefix

	if custom_end_id then
		managers.briefing:post_event(prefix_string .. tostring(event), {
			show_subtitle = true,
			cookie = custom_end_id,
			listener = {
				end_of_event = true,
				clbk = callback(self, self, "post_event_end_clbk")
			}
		})
	else
		managers.briefing:post_event_simple(prefix_string .. tostring(event))
	end
end

function PrePlanningMapGui:stop_event()
	managers.briefing:stop_event()
end

function PrePlanningMapGui:set_location(group)
	if not self._enabled or self._one_frame_input_delay then
		return
	end

	if not self._locations[group] then
		return
	end

	if group ~= self._current_location then
		self._current_location = group

		for i, location in pairs(self._locations) do
			location:set_active(i == self._current_location)
		end

		return true
	end
end

function PrePlanningMapGui:set_selected_element_item(item)
	if not self._enabled then
		return
	end

	if item then
		local selected_mission_element = item:name()

		for i, location in pairs(self._locations) do
			location:set_selected_point(selected_mission_element)
		end
	end
end

function PrePlanningMapGui:set_selected_element_index(index)
	return

	for i, data in ipairs(self._elements) do
		if data.gui:set_selected(i == index) then
			MenuCallbackHandler:set_preplanning_element(self._elements[index].element)
		end
	end
end

function PrePlanningMapGui:update_element(type, id)
	local current_budget, total_budget = managers.preplanning:get_current_budget()

	self._panel:child("budget_text"):set_text(managers.localization:to_upper_text("menu_pp_budget", {
		current = string.format("%.2d", total_budget - current_budget),
		total = string.format("%.2d", total_budget)
	}))
	make_fine_text(self._panel:child("budget_text"))
	self._panel:child("total_cost"):set_text(managers.localization:to_upper_text("menu_pp_total_cost", {
		money = managers.experience:cash_string(managers.money:get_preplanning_total_cost())
	}))
	make_fine_text(self._panel:child("total_cost"))
	self:_update_drawboard()
	self:_update_breakdown()

	if not self._active_node.node or not self._enabled then
		return
	end

	for i, location in pairs(self._locations) do
		location:update_element(type, id)
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node_stack()
	end
end

function PrePlanningMapGui:create_text_button(params)
	local left = params.left or params.x
	local right = params.right
	local top = params.top or params.y
	local bottom = params.bottom
	local text = params.text or params.text_id and managers.localization:text(params.text_id)

	if params.text_to_upper then
		text = utf8.to_upper(text)
	end

	local mouse_over_clbk = params.mouse_over_clbk
	local clbk = params.clbk
	local layer = params.layer or 15
	local hide_blur = params.hide_blur
	local disabled = params.disabled
	local value = params.value
	local font = params.font or tweak_data.menu.pd2_small_font
	local font_size = params.font_size or tweak_data.menu.pd2_small_font_size
	local panel = params.panel or self._panel
	local special_button = params.special_button
	local texture = params.texture
	local texture_rect_on = params.texture_rect_on
	local texture_rect_off = params.texture_rect_off
	local color = params.color
	local name = params.name
	local is_win32 = SystemInfo:platform() == Idstring("WIN32")
	local button_panel = panel:panel({
		x = left,
		y = top,
		layer = layer,
		visible = not disabled
	})
	local gui_blur = button_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "button_blur",
		halign = "scale",
		valign = "scale",
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		visible = not hide_blur
	})
	local gui_text, gui_icon = nil

	if text then
		gui_text = button_panel:text({
			name = "button_text",
			blend_mode = "add",
			layer = 0,
			text = text,
			font = font,
			font_size = font_size,
			color = params.selected and tweak_data.screen_colors.text or tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(gui_text)
		button_panel:set_size(gui_text:size())
	elseif texture then
		gui_icon = button_panel:bitmap({
			name = "button_text",
			texture = texture,
			texture_rect = texture_rect_off,
			color = color
		})

		button_panel:set_size(gui_icon:size())
	end

	gui_blur:set_size(button_panel:size())

	if right then
		button_panel:set_right(right)
	end

	if bottom then
		button_panel:set_bottom(bottom)
	end

	table.insert(self._text_buttons, {
		highlighted = false,
		name = name,
		panel = button_panel,
		text = gui_text,
		icon = gui_icon,
		icon_on = texture_rect_on,
		icon_off = texture_rect_off,
		special_button = special_button,
		blur = gui_blur,
		clbk = clbk,
		mouse_over_clbk = mouse_over_clbk,
		value = value
	})

	return button_panel, #self._text_buttons
end

function PrePlanningMapGui:set_active_node(node)
	if not self._enabled or self._active_node.node ~= node then
		self._active_node.node = node
		self._active_node.current_type = node:parameters().current_type or false
		self._active_node.current_category = node:parameters().current_category or false
		self._active_node.current_plan = node:parameters().current_plan or false
		self._active_node.current_custom = node:parameters().current_custom or false
		self._active_node.current_viewing = node:parameters().current_viewing or false
		self._one_frame_input_delay = true

		self._panel:show()
		self._fullscreen_panel:show()
		self._blackborder_workspace:show()

		if not self._enabled then
			self._enabled = true
			self._in_viewing_mode = not not self._active_node.current_viewing

			self._panel:child("budget_text"):set_visible(not self._active_node.current_viewing)
			self._panel:child("total_cost"):set_visible(not self._active_node.current_viewing)
			self._drawboard_button:set_visible(self._is_pc_controller and not self._active_node.current_viewing)
			self._breakdown_button:set_visible(not self._active_node.current_viewing)

			if self._in_viewing_mode then
				self._panel:text({
					alpha = 0.9,
					blend_mode = "add",
					y = 10,
					x = 10,
					layer = 15,
					text = managers.localization:to_upper_text("menu_preplanning_heist_started"),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					color = tweak_data.screen_colors.important_1
				})
			end

			managers.menu_component:play_transition(true)
			self:post_event("preplan_01")

			local location_data = managers.preplanning:current_location_data()
			local start_location = location_data.start_location

			if managers.menu:is_pc_controller() and start_location then
				local location_group = start_location.group
				local location = self._locations[location_group]

				if location then
					if start_location.zoom then
						self:_set_zoom(start_location.zoom, self._panel:w() / 2, self._panel:h() / 2, true)
					end

					local texture_width, texture_height = location:map_texture_size()
					local x = start_location.x or texture_width / 2
					local y = start_location.y or texture_height / 2
					local rotation = location:map_rotation()
					local raw_x = x / texture_width - 0.5
					local raw_y = y / texture_height - 0.5
					local ax = math.cos(rotation) * raw_x - math.sin(rotation) * raw_y + 0.5
					local ay = math.sin(rotation) * raw_x + math.cos(rotation) * raw_y + 0.5
					local mx, my, mw, mh = location:map_shape()
					local px = mx + ax * mw
					local py = my + ay * mh

					self:set_map_position(px, py, location_group, false)
				end
			end

			managers.preplanning:on_preplanning_open()
		end

		if not managers.menu:is_pc_controller() then
			local node_name = node:parameters().name

			if node_name == "preplanning" then
				self._lerp_map = {
					x = self._panel:w() / 2 - self._map_panel:w() / 2,
					y = self._panel:h() / 2 - self._map_panel:h() / 2,
					clbk = callback(self, self, "set_lerp_zoom", 0)
				}
			elseif node_name == "preplanning_category" then
				self._lerp_map = {
					x = self._panel:w() / 2 - self._map_panel:w() / 2,
					y = self._panel:h() / 2 - self._map_panel:h() / 2,
					clbk = callback(self, self, "set_lerp_zoom", 0)
				}
			elseif node_name == "preplanning_type" then
				-- Nothing
			elseif node_name == "preplanning_plan" then
				-- Nothing
			elseif node_name == "preplanning_custom" then
				-- Nothing
			end
		end

		if self._active_node.current_type then
			local post_event = tweak_data:get_raw_value("preplanning", "types", self._active_node.current_type, "post_event")

			if post_event then
				managers.menu_component:preplanning_post_event(post_event)
			end
		end

		self:set_location(managers.preplanning:first_location_group())

		for i, location in pairs(self._locations) do
			location:update_me()
		end
	end
end

function PrePlanningMapGui:enabled()
	return self._enabled
end

function PrePlanningMapGui:disable()
	if self._enabled then
		self._enabled = false
		self._active_node.node = nil

		self:stop_event()

		self._released_map = nil
		self._grabbed_map = nil
		self._one_scroll_out_delay = nil
		self._draw_mode = nil
		self._lerp_map = nil

		self._panel:hide()
		self._fullscreen_panel:hide()
		self._blackborder_workspace:hide()
		self:post_event("preplan_18")
	end
end

function PrePlanningMapGui:update(t, dt)
	if not self._enabled then
		return
	end

	if not self._is_pc_controller and (not managers.system_menu or not managers.system_menu:is_active() or not not managers.system_menu:is_closing()) then
		local axis_x, axis_y = managers.menu_component:get_right_controller_axis()

		if axis_x ~= 0 or axis_y ~= 0 then
			local speed = dt * 500

			self:_move_map_position(-axis_x * speed, axis_y * speed)

			self._lerp_map = nil
			self._lerp_zoom = nil
		end
	end

	if self._rasteroverlay then
		self._rasteroverlay:set_texture_rect(0, -math.mod(Application:time() * 5, 32), 32, 640)
	end

	if self._scanline then
		self._scanline:move(0, 50 * dt)

		if self._scanline:top() >= self._fullscreen_panel:h() + 25 then
			self._scanline:set_bottom(-25)
		end
	end

	local size_min, width_padding, height_padding, left, right, top, bottom, mleft, mright, mtop, mbottom = nil

	if self._released_map or not self._grabbed_map then
		size_min = math.min(self._panel:w(), self._panel:h())
		width_padding = (self._panel:w() - size_min) / 2
		height_padding = (self._panel:h() - size_min) / 2
		local safe_scaled_size = managers.gui_data:corner_scaled_size()
		left = self._panel:w() * 0
		right = self._panel:w() * 1
		top = self._panel:h() * 0
		bottom = self._panel:h() * 1
		mleft = -(left - self._grid_panel:left() - safe_scaled_size.x)
		mright = -(right - self._grid_panel:right() + safe_scaled_size.x)
		mtop = -(top - self._grid_panel:top() - safe_scaled_size.y)
		mbottom = -(bottom - self._grid_panel:bottom() + safe_scaled_size.y)

		if self._lerp_map then
			if mleft >= -5 or mright <= 5 then
				self._lerp_map.x = self._map_x
			end

			if mtop >= -5 or mbottom <= 5 then
				self._lerp_map.y = self._map_y
			end

			local speed = 5
			local step = dt * speed
			local dx = self._lerp_map.x - self._map_x
			local dy = self._lerp_map.y - self._map_y

			if dx ~= 0 or dy ~= 0 then
				local mx = math.abs(dx) <= step and dx or math.lerp(0, dx, step)
				local my = math.abs(dy) <= step and dy or math.lerp(0, dy, step)

				self:_move_map_position(mx, my)

				if self._lerp_map.clbk and math.abs(mx) < 1 and math.abs(my) < 1 then
					self._lerp_map.x = self._map_x
					self._lerp_map.y = self._map_y
				end
			else
				if self._lerp_map.clbk then
					self._lerp_map.clbk()
				end

				self._lerp_map = nil
			end
		end

		if self._lerp_zoom then
			local speed = 10
			local step = dt * speed
			local dz = self._lerp_zoom - self._map_zoom

			if dz ~= 0 then
				local mz = math.abs(dz) <= step and self._lerp_zoom or math.lerp(self._map_zoom, self._lerp_zoom, step)

				self:_set_zoom(mz, self._panel:w() / 2, self._panel:h() / 2)
			else
				self._lerp_zoom = nil
			end
		end
	else
		self._lerp_map = nil
		self._lerp_zoom = nil
	end

	if self._released_map then
		self._released_map.dx = math.lerp(self._released_map.dx, 0, dt * 2)
		self._released_map.dy = math.lerp(self._released_map.dy, 0, dt * 2)

		self:_move_map_position(self._released_map.dx, self._released_map.dy)

		if mleft >= -5 or mright <= 5 then
			self._released_map.dx = 0
		end

		if mtop >= -5 or mbottom <= 5 then
			self._released_map.dy = 0
		end

		self._released_map.t = self._released_map.t - dt

		if self._released_map.t < 0 then
			self._released_map = nil
		end
	end

	if not self._grabbed_map then
		local speed = 2
		local step = dt * speed
		local padding = 25

		if mleft > -padding then
			local mx = math.lerp(0, -padding - mleft, step)

			self:_move_map_position(mx, 0)

			if self._lerp_map and mx > 0 then
				self._lerp_map.x = self._map_x
			end
		end

		if mright < padding then
			local mx = math.lerp(0, padding - mright, step)

			self:_move_map_position(mx, 0)

			if self._lerp_map and mx < 0 then
				self._lerp_map.x = self._map_x
			end
		end

		if mtop > -padding then
			local my = math.lerp(0, -padding - mtop, step)

			self:_move_map_position(0, my)

			if self._lerp_map and my > 0 then
				self._lerp_map.y = self._map_y
			end
		end

		if mbottom < padding then
			local my = math.lerp(0, padding - mbottom, step)

			self:_move_map_position(0, my)

			if self._lerp_map and my < 0 then
				self._lerp_map.y = self._map_y
			end
		end
	end

	self:update_drawing(t, dt)

	self._one_frame_input_delay = false
end

function PrePlanningMapGui:set_map_position_to_item(item)
	if not self._enabled then
		return
	end

	for i, location in pairs(self._locations) do
		local x, y, group = location:get_point_map_position(item:name())

		if x and y and group then
			self:set_map_position(x, y, group, true)

			break
		end
	end
end

function PrePlanningMapGui:set_map_position(x, y, location, lerp)
	if not self._enabled then
		return
	end

	if type(location) == "string" then
		for i, d in ipairs(tweak_data.preplanning.location_groups) do
			if d == self._location_group then
				location = i

				break
			end
		end
	end

	if lerp then
		managers.menu_component:post_event("prompt_enter")

		self._lerp_map = {
			x = self._panel:w() * 0.5 - x,
			y = self._panel:h() * 0.5 - y
		}

		if location then
			self:set_location(location)
		end
	else
		self:_set_map_position(self._panel:w() * 0.5 - x, self._panel:h() * 0.5 - y, location)
	end
end

function PrePlanningMapGui:_set_map_position(x, y, location)
	self._map_panel:set_position(x, y)
	self._grid_panel:set_center(self._map_panel:center())

	local left = self._panel:w() * 0
	local right = self._panel:w() * 1
	local top = self._panel:h() * 0
	local bottom = self._panel:h() * 1
	local safe_scaled_size = managers.gui_data:corner_scaled_size()

	if left - self._grid_panel:left() - safe_scaled_size.x < 0 then
		self._map_panel:move(left - self._grid_panel:left() - safe_scaled_size.x, 0)
	end

	if right - self._grid_panel:right() + safe_scaled_size.x > 0 then
		self._map_panel:move(right - self._grid_panel:right() + safe_scaled_size.x, 0)
	end

	if top - self._grid_panel:top() - safe_scaled_size.y < 0 then
		self._map_panel:move(0, top - self._grid_panel:top() - safe_scaled_size.y)
	end

	if bottom - self._grid_panel:bottom() + safe_scaled_size.y > 0 then
		self._map_panel:move(0, bottom - self._grid_panel:bottom() + safe_scaled_size.y)
	end

	self._map_x, self._map_y = self._map_panel:position()

	self._grid_panel:set_center(self._map_panel:center())

	if location then
		self:set_location(location)
	end
end

function PrePlanningMapGui:_move_map_position(mx, my)
	self:_set_map_position(self._map_x + mx, self._map_y + my)
end

function PrePlanningMapGui:set_lerp_zoom(zoom)
	local min = self._min_zoom or 1
	local max = self._max_zoom or 5
	local new_zoom = math.clamp(zoom, min, max)

	if self._map_zoom ~= new_zoom then
		self._lerp_zoom = new_zoom
	end
end

function PrePlanningMapGui:_set_zoom(zoom, x, y, ignore_update)
	local min = self._min_zoom or 1
	local max = self._max_zoom or 5
	self._lerp_map = nil
	local new_zoom = math.clamp(zoom, min, max)

	if self._map_zoom ~= new_zoom then
		local w1, h1 = self._map_panel:size()
		local wx1 = (x - self._map_x) / w1
		local wy1 = (y - self._map_y) / h1
		self._map_zoom = new_zoom

		self._map_panel:set_size(self._map_size * self._map_zoom, self._map_size * self._map_zoom)
		self._grid_panel:set_size(self._grid_width * self._map_zoom, self._grid_height * self._map_zoom)

		local w2, h2 = self._map_panel:size()

		self:_move_map_position((w1 - w2) * wx1, (h1 - h2) * wy1)

		if not ignore_update then
			for i, location in pairs(self._locations) do
				location:update_me()
			end
		end

		return true
	else
		self._one_scroll_in_delay = true
	end

	return false
end

function PrePlanningMapGui:_change_zoom(zoom, x, y)
	return self:_set_zoom(self._map_zoom * zoom, x, y)
end

function PrePlanningMapGui:zoom_out(x, y)
	if self:_change_zoom(0.9, x, y) then
		managers.menu_component:post_event("zoom_out")
	end
end

function PrePlanningMapGui:zoom_in(x, y)
	if self:_change_zoom(1.1, x, y) then
		managers.menu_component:post_event("zoom_in")
	end
end

function PrePlanningMapGui:mouse_moved(o, x, y)
	if not self._enabled or self._one_frame_input_delay then
		return false, "arrow"
	end

	self._mouse_moved = not self._last_x or not self._last_y or self._last_x ~= x or self._last_y ~= y
	self._last_x = x
	self._last_y = y

	if self._active_node and not self._active_node.current_viewing then
		if self._draw_mode then
			if not ctrl() then
				self:end_drawing()
			else
				return true, "link"
			end
		elseif ctrl() then
			return true, "link"
		elseif alt() then
			-- Nothing
		elseif shift() then
			-- Nothing
		end
	end

	local fx, fy = managers.gui_data:safe_to_full_16_9(x, y)
	local used = false
	local icon = "arrow"

	if self._panel:inside(x, y) then
		local tooltip_mouse_over = false

		for _, button in ipairs(self._text_buttons) do
			if alive(button.panel) and button.panel:tree_visible() then
				if button.panel:inside(x, y) then
					if not button.highlighted then
						button.highlighted = true

						managers.menu_component:post_event("highlight")

						if alive(button.text) then
							button.text:set_color(tweak_data.screen_colors.button_stage_2)
						end

						if alive(button.icon) and button.icon_on then
							button.icon:set_texture_rect(unpack(button.icon_on))
						end

						if button.mouse_over_clbk then
							button:mouse_over_clbk()
						end
					end

					tooltip_mouse_over = true
					icon = "link"
					used = true
				elseif button.highlighted then
					button.highlighted = false

					if alive(button.text) then
						button.text:set_color(tweak_data.screen_colors.button_stage_3)
					end

					if alive(button.icon) and button.icon_off then
						button.icon:set_texture_rect(unpack(button.icon_off))
					end
				end
			end
		end

		if not tooltip_mouse_over then
			self:set_draw_tooltip_clbk()
		end

		if not used then
			local eused, eicon = nil

			for i, location in pairs(self._locations) do
				eused, eicon = location:mouse_moved(x, y)

				if eused then
					self:set_selected_element_index(i)

					icon = eicon
					used = eused
				end
			end
		end
	end

	if not used and self._grabbed_map then
		local left = self._grabbed_map.x < x
		local right = not left
		local up = self._grabbed_map.y < y
		local down = not up
		local mx = x - self._grabbed_map.x
		local my = y - self._grabbed_map.y

		table.insert(self._grabbed_map.dirs, 1, {
			mx,
			my
		})

		self._grabbed_map.dirs[10] = nil

		self:_move_map_position(mx, my)

		self._grabbed_map.x = x
		self._grabbed_map.y = y

		return true, "grab"
	end

	if not used and self._panel:inside(x, y) then
		icon = "hand"
		used = true
	end

	return used, icon or "arrow"
end

function PrePlanningMapGui:mouse_pressed(button, x, y)
	if not self._enabled or self._one_frame_input_delay then
		return
	end

	local fx, fy = managers.gui_data:safe_to_full_16_9(x, y)
	local inside = self._panel:inside(x, y)

	if inside then
		if button == Idstring("0") then
			if not self._active_node or not self._active_node.current_viewing then
				if ctrl() then
					self:start_drawing()

					return
				elseif alt() then
					-- Nothing
				elseif shift() then
					-- Nothing
				end
			end

			for _, button in ipairs(self._text_buttons) do
				if alive(button.panel) and button.panel:tree_visible() and button.panel:inside(x, y) then
					if button.clbk and button:clbk() then
						managers.menu_component:post_event("menu_enter")
					end

					return true
				end
			end

			for i, location in pairs(self._locations) do
				if location:mouse_pressed(x, y) then
					return true
				end
			end
		elseif button == Idstring("mouse wheel down") then
			if self._one_scroll_out_delay then
				self._one_scroll_out_delay = nil
			end

			self:zoom_out(x, y)

			return true
		elseif button == Idstring("mouse wheel up") then
			if self._one_scroll_in_delay then
				self._one_scroll_in_delay = nil
			end

			self:zoom_in(x, y)

			return true
		end
	end

	if button == Idstring("0") and self._panel:inside(x, y) then
		self._released_map = nil
		self._grabbed_map = {
			x = x,
			y = y,
			dirs = {}
		}
	end
end

function PrePlanningMapGui:mouse_released(button, x, y)
	if not self._enabled or self._one_frame_input_delay then
		return
	end

	if button ~= Idstring("0") then
		return
	end

	if not self._active_node or not self._active_node.current_viewing then
		self:end_drawing()
	end

	local fx, fy = managers.gui_data:safe_to_full_16_9(x, y)

	if self._grabbed_map and #self._grabbed_map.dirs > 0 then
		local dx = 0
		local dy = 0

		for _, values in ipairs(self._grabbed_map.dirs) do
			dx = dx + values[1]
			dy = dy + values[2]
		end

		dx = dx / #self._grabbed_map.dirs
		dy = dy / #self._grabbed_map.dirs
		self._released_map = {
			t = 2,
			dx = dx,
			dy = dy
		}
		self._grabbed_map = nil
	end

	for i, location in pairs(self._locations) do
		if location:mouse_released(x, y) then
			return true
		end
	end
end

function PrePlanningMapGui:special_btn_pressed(button)
	if not self._enabled or self._one_frame_input_delay then
		return
	end

	for _, text_button in ipairs(self._text_buttons) do
		if text_button.panel and text_button.panel:visible() and text_button.special_button and Idstring(text_button.special_button) == button and text_button.clbk and text_button:clbk() then
			managers.menu_component:post_event("menu_enter")
		end
	end
end

function PrePlanningMapGui:confirm_pressed()
end

function PrePlanningMapGui:next_page()
	if not self._enabled or self._one_frame_input_delay then
		return
	end

	self:zoom_in(self._panel:w() / 2, self._panel:h() / 2)
end

function PrePlanningMapGui:previous_page()
	if not self._enabled or self._one_frame_input_delay then
		return
	end

	self:zoom_out(self._panel:w() / 2, self._panel:h() / 2)
end

function PrePlanningMapGui:input_focus()
	return self._enabled and self._grabbed_map and true or false
end

function PrePlanningMapGui:close()
	self:stop_event()
	self._saferect_root_panel:remove(self._panel)
	self._fullscreen_root_panel:remove(self._fullscreen_panel)
	managers.gui_data:destroy_workspace(self._blackborder_workspace)

	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end
end
