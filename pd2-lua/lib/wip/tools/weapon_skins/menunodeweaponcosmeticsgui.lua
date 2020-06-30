MenuNodeWeaponCosmeticsGui = MenuNodeWeaponCosmeticsGui or class(MenuNodeGui)
MenuNodeWeaponCosmeticsGui.RESET_VALUES = {
	pattern_pos = 0,
	wear_and_tear = 1,
	cubemap_pattern_control = 0,
	mask_pos_z = 0,
	uv_scale = 1,
	mask_pos_x = 0,
	mask_rot_y = 0,
	mask_rot_z = 0,
	mask_pos_y = 0,
	uv_offset_rot = 0,
	mask_rot_x = 0,
	pattern_tweak = function (vector)
		return vector == 2 and 0 or 1
	end
}

function MenuNodeWeaponCosmeticsGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeWeaponCosmeticsGui.super.init(self, node, layer, parameters)
end

function MenuNodeWeaponCosmeticsGui:mouse_pressed(button, x, y)
	if button == Idstring("1") then
		local row_item = self._highlighted_item and self:row_item(self._highlighted_item)

		if row_item and row_item.gui_panel and row_item.gui_panel:inside(x, y) then
			local key = self._highlighted_item:parameters().key or self._highlighted_item:name()
			local vector = self._highlighted_item:parameters().vector
			local reset_value = MenuNodeWeaponCosmeticsGui.RESET_VALUES[key]

			if reset_value ~= nil then
				if type(reset_value) == "function" then
					self._highlighted_item:set_value(reset_value(vector))
				else
					self._highlighted_item:set_value(reset_value)
				end
			else
				return
			end

			if self._highlighted_item:parameters().callback then
				for _, clbk in pairs(self._highlighted_item:parameters().callback) do
					clbk(self._highlighted_item)
				end
			end
		end
	end
end
