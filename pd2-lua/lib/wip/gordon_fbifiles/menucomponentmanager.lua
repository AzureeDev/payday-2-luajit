if MenuComponentManager then
	require("lib/wip/gordon_fbifiles/managers/menu/ChartGuiFactory")
	require("lib/wip/gordon_fbifiles/managers/menu/PlayerStatsGui")

	local old_init = MenuComponentManager.init

	function MenuComponentManager:init()
		old_init(self)

		self._active_components.player_stats = {
			create = callback(self, self, "create_player_stats_gui"),
			close = callback(self, self, "close_player_stats_gui")
		}
		self._chart_factory = ChartGuiFactory:new()
	end

	function MenuComponentManager:create_pie_chart(panel, data, optional_params)
		return self._chart_factory:create_pie(panel, data, optional_params)
	end

	local old_mouse_moved = MenuComponentManager.mouse_moved

	function MenuComponentManager:mouse_moved(o, x, y)
		local used, wanted_pointer = old_mouse_moved(self, o, x, y)

		if used then
			return used, wanted_pointer
		end

		if self._player_stats_gui then
			local used, pointer = self._player_stats_gui:mouse_moved(o, x, y)
			wanted_pointer = pointer or wanted_pointer

			if used then
				return true, wanted_pointer
			end
		end

		return false, wanted_pointer
	end

	local old_mouse_pressed = MenuComponentManager.mouse_pressed

	function MenuComponentManager:mouse_pressed(o, button, x, y)
		local used = old_mouse_pressed(self, o, button, x, y)

		if used then
			return used
		end

		if self._player_stats_gui and self._player_stats_gui:mouse_pressed(button, x, y) then
			return true
		end
	end

	local old_mouse_released = MenuComponentManager.mouse_released

	function MenuComponentManager:mouse_released(o, button, x, y)
		local used = old_mouse_released(self, o, button, x, y)

		if used then
			return used
		end

		if self._player_stats_gui and self._player_stats_gui:mouse_released(button, x, y) then
			return true
		end
	end

	local old_input_focus = MenuComponentManager.input_focus

	function MenuComponentManager:input_focus()
		local input_focus = old_input_focus(self)

		if input_focus then
			return input_focus
		end

		if self._player_stats_gui then
			input_focus = self._player_stats_gui:input_focus()

			if input_focus then
				return input_focus
			end
		end
	end

	function MenuComponentManager:create_player_stats_gui(node)
		self:_create_player_stats_gui(node)
	end

	function MenuComponentManager:_create_player_stats_gui(node)
		self:close_player_stats_gui()

		self._player_stats_gui = PlayerStatsGui:new(self._ws, self._fullscreen_ws, node)
	end

	function MenuComponentManager:close_player_stats_gui()
		if self._player_stats_gui then
			self._player_stats_gui:close()

			self._player_stats_gui = nil
		end
	end

	function MenuComponentManager:back_callback_player_stats_gui()
		if self._player_stats_gui then
			return self._player_stats_gui:back_callback()
		end
	end
end
