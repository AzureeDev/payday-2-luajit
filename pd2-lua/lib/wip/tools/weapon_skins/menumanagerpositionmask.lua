core:import("CoreMenuData")
core:import("CoreMenuLogic")
core:import("CoreMenuInput")
core:import("CoreMenuRenderer")

local function serializeTable(table_prefix, val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0
	local tmp = string.rep("\t", depth)

	if depth == 1 then
		tmp = tmp .. table_prefix .. "."
	end

	local lines, sort_lines = nil

	if depth == 0 then
		lines = {}
		sort_lines = {
			"offsets"
		}
	end

	if name then
		tmp = tmp .. name .. " = "
	end

	if type(val) == "table" then
		tmp = tmp .. (name and "{" or "") .. "\n"

		if #val > 0 then
			for k, v in ipairs(val) do
				tmp = tmp .. serializeTable(table_prefix, v, nil, true, depth + 1) .. (name and "," or "") .. "\n"
			end
		else
			for k, v in pairs(val) do
				local kname = k

				if depth == 2 and type(v) == "table" then
					kname = string.format("[Idstring(%q):key()]", Idstring.lookup(k):s())
				end

				if depth == 0 then
					lines[k] = serializeTable(table_prefix, v, kname, skipnewlines, depth + 1) .. (name and "," or "") .. (not skipnewlines and "\n" or "")
				else
					tmp = tmp .. serializeTable(table_prefix, v, kname, skipnewlines, depth + 1) .. (name and "," or "") .. (not skipnewlines and "\n" or "")
				end
			end
		end

		tmp = tmp .. string.rep("\t", depth) .. (name and "}" or "")
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	elseif type(val) == "userdata" and val.s then
		tmp = tmp .. "Idstring(\"" .. val:s() .. "\")"
	elseif type(val) == "userdata" and val.tostring then
		tmp = tmp .. val:tostring()
	else
		tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	if depth == 0 then
		for _, key in ipairs(sort_lines) do
			if lines[key] then
				tmp = tmp .. lines[key]
			end
		end
	end

	return tmp
end

local old_init = MenuManager.init

function MenuManager:init(is_start_menu)
	old_init(self, is_start_menu)

	if self._registered_menus.menu_main then
		self:_create_custom_node([[
			<node name="debug_mask_position" sync_state="blackmarket" scene_state="inventory" gui_class="MenuNodeWeaponCosmeticsGui" menu_components="" topic_id="menu_crimenet" modifier="MenuPositionMaskInitiator" align_line_proportions="0.65">
				<legend name="menu_legend_manual_switch_page"/>
				<legend name="menu_legend_select"/>
				<legend name="menu_legend_back"/>
				
				<default_item name="back"/>
			</node>
			]])
	end
end

local old_update = MenuManager.update

function MenuManager:update(t, dt, ...)
	old_update(self, t, dt, ...)

	if managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node() then
		local params = managers.menu:active_menu().logic:selected_node():parameters()

		if params and params.name == "debug_mask_position" then
			MenuCallbackHandler:debug_draw_mask_guides()
		end
	end
end

MenuPositionMaskInitiator = MenuPositionMaskInitiator or class(MenuInitiatorBase)
MenuPositionMaskInitiator.POSITION_EXTENTS = {
	-25,
	25
}
MenuPositionMaskInitiator.POSITION_STEP = 0.01
MenuPositionMaskInitiator.ROTATION_EXTENTS = {
	-180,
	180
}
MenuPositionMaskInitiator.ROTATION_STEP = 0.1

function MenuPositionMaskInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	node:clean_items()

	if not node:item("divider_end") then
		local pos_x = self:create_slider(node, {
			localize = false,
			text_id = "Mask Position X",
			name = "mask_pos_x",
			callback = "debug_update_mask_preview",
			show_value = true,
			min = MenuPositionMaskInitiator.POSITION_EXTENTS[1],
			max = MenuPositionMaskInitiator.POSITION_EXTENTS[2],
			step = MenuPositionMaskInitiator.POSITION_STEP
		})

		pos_x:set_slider_color(Color(0.4, 1, 0, 0))
		pos_x:set_slider_highlighted_color(Color(0.6, 1, 0, 0))

		local pos_y = self:create_slider(node, {
			localize = false,
			text_id = "Mask Position Y",
			name = "mask_pos_y",
			callback = "debug_update_mask_preview",
			show_value = true,
			min = MenuPositionMaskInitiator.POSITION_EXTENTS[1],
			max = MenuPositionMaskInitiator.POSITION_EXTENTS[2],
			step = MenuPositionMaskInitiator.POSITION_STEP
		})

		pos_y:set_slider_color(Color(0.4, 0, 1, 0))
		pos_y:set_slider_highlighted_color(Color(0.6, 0, 1, 0))

		local pos_z = self:create_slider(node, {
			localize = false,
			text_id = "Mask Position Z",
			name = "mask_pos_z",
			callback = "debug_update_mask_preview",
			show_value = true,
			min = MenuPositionMaskInitiator.POSITION_EXTENTS[1],
			max = MenuPositionMaskInitiator.POSITION_EXTENTS[2],
			step = MenuPositionMaskInitiator.POSITION_STEP
		})

		pos_z:set_slider_color(Color(0.4, 0, 0, 1))
		pos_z:set_slider_highlighted_color(Color(0.6, 0, 0, 1))

		local pos_widget = self:create_toggle(node, {
			enabled = true,
			name = "draw_pos",
			localize = false,
			text_id = "Draw Position Widget"
		})

		pos_widget:set_value("off")
		self:create_divider(node, "rot")

		local rot_x = self:create_slider(node, {
			localize = false,
			text_id = "Mask Rotation X",
			name = "mask_rot_x",
			callback = "debug_update_mask_preview",
			show_value = true,
			min = MenuPositionMaskInitiator.ROTATION_EXTENTS[1],
			max = MenuPositionMaskInitiator.ROTATION_EXTENTS[2],
			step = MenuPositionMaskInitiator.ROTATION_STEP
		})

		rot_x:set_slider_color(Color(0.4, 1, 0, 0))
		rot_x:set_slider_highlighted_color(Color(0.6, 1, 0, 0))

		local rot_y = self:create_slider(node, {
			localize = false,
			text_id = "Mask Rotation Y",
			name = "mask_rot_y",
			callback = "debug_update_mask_preview",
			show_value = true,
			min = MenuPositionMaskInitiator.ROTATION_EXTENTS[1],
			max = MenuPositionMaskInitiator.ROTATION_EXTENTS[2],
			step = MenuPositionMaskInitiator.ROTATION_STEP
		})

		rot_y:set_slider_color(Color(0.4, 0, 1, 0))
		rot_y:set_slider_highlighted_color(Color(0.6, 0, 1, 0))

		local rot_z = self:create_slider(node, {
			localize = false,
			text_id = "Mask Rotation Z",
			name = "mask_rot_z",
			callback = "debug_update_mask_preview",
			show_value = true,
			min = MenuPositionMaskInitiator.ROTATION_EXTENTS[1],
			max = MenuPositionMaskInitiator.ROTATION_EXTENTS[2],
			step = MenuPositionMaskInitiator.ROTATION_STEP
		})

		rot_z:set_slider_color(Color(0.4, 0, 0, 1))
		rot_z:set_slider_highlighted_color(Color(0.6, 0, 0, 1))

		local rot_widget = self:create_toggle(node, {
			enabled = true,
			name = "draw_rot",
			localize = false,
			text_id = "Draw Rotation Widget"
		})

		rot_widget:set_value("off")
		self:create_divider(node, "copy")
		self:create_item(node, {
			localize = false,
			name = "copy_skin",
			enabled = true,
			text_id = "Copy to Clipboard",
			callback = "debug_copy_mask_positions"
		})
		self:create_divider(node, "end")
		self:add_back_button(node)
		pos_x:set_value(0)
		pos_y:set_value(0)
		pos_z:set_value(0)
		rot_x:set_value(0)
		rot_y:set_value(0)
		rot_z:set_value(0)
	end

	return node
end

function MenuCallbackHandler:debug_is_equipped_mask(mask_data)
	local mask_tweak = tweak_data.blackmarket.masks[managers.blackmarket:equipped_mask().mask_id]

	if mask_tweak and mask_tweak.characters then
		local char = managers.blackmarket:get_real_character()

		return mask_data.mask_id == mask_tweak.characters[char]
	end

	return mask_data.mask_id == managers.blackmarket:equipped_mask().mask_id
end

function MenuCallbackHandler:debug_update_mask_preview(item)
	local pos_x = managers.menu:active_menu().logic:selected_node():item("mask_pos_x")
	local pos_y = managers.menu:active_menu().logic:selected_node():item("mask_pos_y")
	local pos_z = managers.menu:active_menu().logic:selected_node():item("mask_pos_z")
	local pos = Vector3(pos_x:value(), pos_y:value(), pos_z:value())
	local rot_x = managers.menu:active_menu().logic:selected_node():item("mask_rot_x")
	local rot_y = managers.menu:active_menu().logic:selected_node():item("mask_rot_y")
	local rot_z = managers.menu:active_menu().logic:selected_node():item("mask_rot_z")
	local rot = Rotation(rot_x:value(), rot_y:value(), rot_z:value())

	if managers.menu_scene then
		for _, mask_data in pairs(managers.menu_scene._mask_units) do
			if self:debug_is_equipped_mask(mask_data) then
				managers.menu_scene:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, pos, rot)
				managers.menu_scene:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, pos, rot)
			end
		end
	end
end

function MenuCallbackHandler:debug_copy_mask_positions()
	local pos_x = managers.menu:active_menu().logic:selected_node():item("mask_pos_x")
	local pos_y = managers.menu:active_menu().logic:selected_node():item("mask_pos_y")
	local pos_z = managers.menu:active_menu().logic:selected_node():item("mask_pos_z")
	local pos = Vector3(pos_x:value(), pos_y:value(), pos_z:value())
	local rot_x = managers.menu:active_menu().logic:selected_node():item("mask_rot_x")
	local rot_y = managers.menu:active_menu().logic:selected_node():item("mask_rot_y")
	local rot_z = managers.menu:active_menu().logic:selected_node():item("mask_rot_z")
	local rot = Rotation(rot_x:value(), rot_y:value(), rot_z:value())
	local mask_id = managers.blackmarket:equipped_mask().mask_id
	local char = managers.blackmarket:get_real_character()
	local mask_tweak = tweak_data.blackmarket.masks[mask_id]

	if mask_tweak and mask_tweak.characters then
		mask_id = mask_tweak.characters[char] or mask_id
	end

	local mask_tweak = tweak_data.blackmarket.masks[mask_id]
	mask_tweak.offsets = mask_tweak.offsets or {}
	mask_tweak.offsets[char] = {
		pos,
		rot
	}
	local prefix = "self.masks." .. mask_id
	local text = serializeTable(prefix, mask_tweak)

	Application:set_clipboard(text)
end

function MenuCallbackHandler:debug_draw_mask_guides()
	self._mask_guide_brushes = self._mask_guide_brushes or {
		red = Draw:brush(Color.red:with_alpha(0.5)),
		blue = Draw:brush(Color.blue:with_alpha(0.5)),
		green = Draw:brush(Color.green:with_alpha(0.5))
	}
	local draw_pos = managers.menu:active_menu().logic:selected_node():item("draw_pos")
	local draw_rot = managers.menu:active_menu().logic:selected_node():item("draw_rot")

	if managers.menu_scene then
		for _, mask_data in pairs(managers.menu_scene._mask_units) do
			if self:debug_is_equipped_mask(mask_data) then
				if draw_pos and draw_pos:value() == "on" then
					local pos = mask_data.mask_unit:position()
					local dist = 20
					local size = 0.5

					self._mask_guide_brushes.red:cylinder(pos + mask_data.mask_unit:rotation():x() * dist, pos, size)
					self._mask_guide_brushes.green:cylinder(pos + mask_data.mask_unit:rotation():y() * dist, pos, size)
					self._mask_guide_brushes.blue:cylinder(pos + mask_data.mask_unit:rotation():z() * dist, pos, size)
				end

				if draw_rot and draw_rot:value() == "on" then
					self._mask_guide_brushes.red:circle(mask_data.mask_unit:position(), 20, 1, mask_data.mask_unit:rotation():z())
					self._mask_guide_brushes.green:circle(mask_data.mask_unit:position(), 20, 1, mask_data.mask_unit:rotation():x())
					self._mask_guide_brushes.blue:circle(mask_data.mask_unit:position(), 20, 1, mask_data.mask_unit:rotation():y())
				end
			end
		end
	end
end
