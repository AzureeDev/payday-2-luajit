MenuSceneGui = MenuSceneGui or class()

function MenuSceneGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()

	if not managers.menu:is_pc_controller() then
		self:_setup_controller_input()
	end
end

function MenuSceneGui:_setup_controller_input()
	self._left_axis_vector = Vector3()
	self._right_axis_vector = Vector3()

	self._ws:connect_controller(managers.menu:active_menu().input:get_controller(), true)
	self._panel:axis_move(callback(self, self, "_axis_move"))
end

function MenuSceneGui:_destroy_controller_input()
	self._ws:disconnect_all_controllers()

	if alive(self._panel) then
		self._panel:axis_move(nil)
	end
end

function MenuSceneGui:_axis_move(o, axis_name, axis_vector, controller)
	if axis_name == Idstring("left") then
		mvector3.set(self._left_axis_vector, axis_vector)
	elseif axis_name == Idstring("right") then
		mvector3.set(self._right_axis_vector, axis_vector)
	end
end

function MenuSceneGui:update(t, dt)
	if self._shown_infamy_text_t then
		if self._shown_infamy_text_t <= t then
			self._shown_infamy_text_t = nil
			local current_rank = managers.experience:current_rank()
			local infamous_string = managers.localization:to_upper_text(current_rank == 0 and "menu_infamy_rank_reached" or "menu_infamy_rank_increased", {
				infamy_rank = tostring(current_rank + 1)
			})
			self._infamy_increased_text = self._panel:text({
				vertical = "top",
				align = "center",
				layer = 1,
				text = infamous_string,
				font = tweak_data.menu.pd2_large_font,
				font_size = tweak_data.menu.pd2_large_font_size
			})

			self._infamy_increased_text:move(0, self._panel:h() * 0.1)
		end
	elseif managers.menu_scene:infamy_card_shown() and not alive(self._infamy_increased_text) then
		self._shown_infamy_text_t = t + 4
	end

	if alive(self._infamy_increased_text) then
		-- Nothing
	end

	if managers.menu:is_pc_controller() then
		return
	end

	if mvector3.is_zero(self._left_axis_vector) then
		managers.menu_scene:stop_controller_move()
	else
		local x = mvector3.x(self._left_axis_vector)
		local y = mvector3.y(self._left_axis_vector)

		managers.menu_scene:controller_move(x * dt, y * dt)
	end

	if mvector3.is_zero(self._right_axis_vector) then
		managers.menu_scene:stop_controller_zoom()
	else
		local x = mvector3.x(self._right_axis_vector)
		local y = mvector3.y(self._right_axis_vector)

		managers.menu_scene:controller_zoom(x * dt, y * dt)
	end
end

function MenuSceneGui:close()
	self:_destroy_controller_input()

	if alive(self._panel) then
		self._ws:panel():remove(self._panel)

		self._panel = nil
	end

	if alive(self._fullscreen_panel) then
		self._fullscreen_ws:panel():remove(self._fullscreen_panel)

		self._fullscreen_panel = nil
	end
end
