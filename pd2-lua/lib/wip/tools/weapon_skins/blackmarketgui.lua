if BlackMarketGui then
	local old_update_info_text = BlackMarketGui.update_info_text

	function BlackMarketGui:update_info_text()
		old_update_info_text(self)

		local slot_data = self._slot_data
		local allow_categories = {
			"primaries",
			"secondaries",
			"armors",
			"masks"
		}

		if table.contains(allow_categories, slot_data.category) and not slot_data.not_moddable then
			if not alive(self._weapon_customize_button) then
				self._weapon_customize_button = self._panel:rect({
					blend_mode = "add",
					w = 64,
					h = 64,
					alpha = 0.9,
					color = Color.blue
				})

				self._weapon_customize_button:set_right(self._panel:w())
			end

			self._weapon_customize_button:show()
		elseif alive(self._weapon_customize_button) then
			self._weapon_customize_button:hide()
		end
	end

	local old_mouse_moved = BlackMarketGui.mouse_moved

	function BlackMarketGui:mouse_moved(o, x, y)
		local used, pointer = old_mouse_moved(self, o, x, y)

		if alive(self._weapon_customize_button) then
			if not used then
				self._weapon_customize_inside = self._weapon_customize_button and self._weapon_customize_button:visible() and self._weapon_customize_button:inside(x, y)

				if self._weapon_customize_inside then
					used = true
					pointer = "link"

					self._weapon_customize_button:set_color(Color.green)
				else
					self._weapon_customize_button:set_color(Color.blue)
				end
			else
				self._weapon_customize_inside = false
			end
		end

		return used, pointer
	end

	local old_mouse_pressed = BlackMarketGui.mouse_pressed

	function BlackMarketGui:mouse_pressed(button, x, y)
		old_mouse_pressed(self, button, x, y)

		if alive(self._weapon_customize_button) and self._weapon_customize_inside then
			local slot_data = self._slot_data

			self:set_enabled(false)

			if slot_data.category == "primaries" or slot_data.category == "secondaries" then
				managers.blackmarket:view_weapon(self._slot_data.category, self._slot_data.slot, function ()
					managers.menu:open_node("debug_shiny", {
						{
							category = self._slot_data.category,
							slot = self._slot_data.slot
						}
					})
				end, true, BlackMarketGui.get_crafting_custom_data())
			elseif slot_data.category == "armors" then
				managers.menu:open_node("debug_shiny_armour", {
					{
						armour = true
					}
				})
			elseif slot_data.category == "masks" then
				managers.menu:open_node("debug_mask_position", {
					{
						character = managers.blackmarket:equipped_character(),
						mask = managers.blackmarket:equipped_mask()
					}
				})
			end
		end
	end
end
