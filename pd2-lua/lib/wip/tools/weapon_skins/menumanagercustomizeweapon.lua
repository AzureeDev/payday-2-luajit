core:import("CoreMenuData")
core:import("CoreMenuLogic")
core:import("CoreMenuInput")
core:import("CoreMenuRenderer")

local old_init = MenuManager.init

function MenuManager:init(is_start_menu)
	old_init(self, is_start_menu)

	if self._registered_menus.menu_main then
		self:_create_custom_node([[
			<node name="debug_shiny" sync_state="blackmarket" scene_state="blackmarket_customize" gui_class="MenuNodeWeaponCosmeticsGui" menu_components="" topic_id="menu_crimenet" modifier="MenuCustomizeWeaponInitiator" align_line_proportions="0.65">
				<legend name="menu_legend_manual_switch_page"/>
				<legend name="menu_legend_select"/>
				<legend name="menu_legend_back"/>
				
				<default_item name="back"/>
			</node>
			]])
		self:_create_custom_node([[
			<node name="debug_shiny_armour" sync_state="blackmarket" scene_state="blackmarket_customize_armour" gui_class="MenuNodeWeaponCosmeticsGui" menu_components="" topic_id="menu_crimenet" modifier="MenuCustomizeWeaponInitiator" align_line_proportions="0.65">
				<legend name="menu_legend_manual_switch_page"/>
				<legend name="menu_legend_select"/>
				<legend name="menu_legend_back"/>
				
				<default_item name="back"/>
			</node>
			]])
	end
end

function MenuManager:_create_custom_node(node_string)
	local c = ScriptSerializer:from_custom_xml(node_string)
	local type = c._meta

	if type == "node" then
		local node_class = CoreMenuNode.MenuNode
		local type = c.type

		if type then
			node_class = CoreSerialize.string_to_classtable(type)
		end

		local name = c.name

		if name then
			local node = node_class:new(c)

			node:set_callback_handler(self._registered_menus.menu_main.callback_handler)

			self._registered_menus.menu_main.data._nodes[name] = node
		else
			Application:error("Menu node without name in '" .. menu_id .. "' in '" .. file_path .. "'")
		end
	elseif type == "default_node" then
		self._default_node_name = c.name
	end
end

MenuCustomizeWeaponInitiator = MenuCustomizeWeaponInitiator or class(MenuInitiatorBase)

function MenuCustomizeWeaponInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	node:clean_items()

	if not node:item("divider_end") then
		local func = "modify_node_" .. (data.menu or "main")

		if self[func] then
			self[func](self, node, data)
		end

		self:create_divider(node, "end")
		self:add_back_button(node)
	end

	return node
end

function MenuCustomizeWeaponInitiator:_apply_cosmetics_to_weapon(data)
	local crafted = managers.blackmarket:get_crafted_category_slot(data.category, data.slot)
	local old_cosmetics_data = Global.shiny_debug and Global.shiny_debug.cosmetics_data
	Global.shiny_debug = {
		type = "weapon",
		next_node = "debug_shiny",
		slot = data.slot,
		category = data.category,
		weapon_unit = managers.menu_scene._item_unit.unit,
		second_weapon_unit = managers.menu_scene._item_unit.second_unit
	}

	if not old_cosmetics_data or old_cosmetics_data.weapon_id ~= crafted.weapon_id or not old_cosmetics_data then
		local new_cosmetics_data = {
			wear_and_tear = 1,
			weapon_id = crafted.weapon_id,
			parts = {}
		}
	end

	Global.shiny_debug.weapon_unit:base()._cosmetics_data = new_cosmetics_data
	Global.shiny_debug.cosmetics_data = Global.shiny_debug.weapon_unit:base()._cosmetics_data

	Global.shiny_debug.weapon_unit:base():_apply_cosmetics(function ()
	end)

	if Global.shiny_debug.second_weapon_unit then
		Global.shiny_debug.second_weapon_unit:base()._cosmetics_data = new_cosmetics_data

		Global.shiny_debug.second_weapon_unit:base():_apply_cosmetics(function ()
		end)
	end
end

function MenuCustomizeWeaponInitiator:_apply_cosmetics_to_armour(data)
	local old_cosmetics_data = Global.shiny_debug and Global.shiny_debug.cosmetics_data
	local new_cosmetics_data = {}

	if Global.shiny_debug and Global.shiny_debug.type == "armour" and old_cosmetics_data then
		new_cosmetics_data = old_cosmetics_data
	end

	Global.shiny_debug = {
		next_node = "debug_shiny_armour",
		type = "armour",
		character_unit = managers.menu_scene._character_unit,
		cosmetics_data = new_cosmetics_data
	}

	if Global.shiny_debug.character_unit then
		Global.shiny_debug.character_unit:base()._cosmetics_data = new_cosmetics_data

		Global.shiny_debug.character_unit:base():_apply_cosmetics({})
	end
end

function MenuCustomizeWeaponInitiator:modify_node_main(node, data)
	if data.slot and data.category then
		self:_apply_cosmetics_to_weapon(data)
	elseif data.armour then
		self:_apply_cosmetics_to_armour(data)
	end

	if Global.shiny_debug.type == "weapon" then
		self:create_item(node, {
			name = "default_skin",
			enabled = true,
			text_id = "debug_wskn_base_skin",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "weapon_skin"
				}
			}
		})
		self:create_item(node, {
			name = "create_types_menu",
			enabled = true,
			text_id = "debug_wskn_types",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "types_menu"
				}
			}
		})
		self:create_item(node, {
			name = "create_parts_menu",
			enabled = true,
			text_id = "debug_wskn_parts",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "parts_menu"
				}
			}
		})
		self:create_divider(node, 1)
		self:create_item(node, {
			name = "edit_skin",
			enabled = true,
			text_id = "debug_wskn_edit_skin",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "edit_skin_menu"
				}
			}
		})
		self:create_item(node, {
			callback = "clear_debug_weapon_skin",
			name = "clear_skin",
			enabled = true,
			text_id = "debug_wskn_clear_skin"
		})
	elseif Global.shiny_debug.type == "armour" then
		self:create_item(node, {
			name = "default_skin",
			enabled = true,
			text_id = "debug_wskn_base_skin",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "weapon_skin"
				}
			}
		})
		self:create_item(node, {
			localize = false,
			name = "set_pose_menu",
			enabled = true,
			text_id = "Set Pose",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "pose_menu"
				}
			}
		})
		self:create_item(node, {
			localize = false,
			name = "set_armour_menu",
			enabled = true,
			text_id = "Set Armour",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "armour_menu"
				}
			}
		})
		self:create_item(node, {
			localize = false,
			name = "load_armour_menu",
			enabled = true,
			text_id = "Load Preset Armour",
			next_node = Global.shiny_debug.next_node,
			next_node_parameters = {
				{
					menu = "load_armour_menu"
				}
			}
		})
	end

	self:create_divider(node, 1)

	local name_input = self:create_input(node, {
		name = "name_input",
		enabled = true,
		text_id = "debug_wskn_name_input",
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name
	})

	name_input:set_input_text(Global.shiny_debug.cosmetics_data.id or "")

	local tbf_input = self:create_input(node, {
		name = "tbf_input",
		enabled = true,
		text_id = "debug_wskn_tbf_input",
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name
	})

	tbf_input:set_input_text(Global.shiny_debug.cosmetics_data.tbf or "")

	local rarities = tweak_data.economy.rarities
	local sort_list = {}

	for id in pairs(rarities) do
		table.insert(sort_list, id)
	end

	table.sort(sort_list, function (x, y)
		return rarities[x].index < rarities[y].index
	end)

	local multichoice_list = {}

	for _, id in ipairs(sort_list) do
		table.insert(multichoice_list, {
			localize = false,
			_meta = "option",
			text_id = id,
			value = id
		})
	end

	local rarity_input = self:create_multichoice(node, multichoice_list, {
		name = "rarity_input",
		enabled = true,
		text_id = "debug_wskn_rarity",
		text_offset = 100,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name
	})

	rarity_input:set_value(Global.shiny_debug.cosmetics_data.rarity or rarities[1])

	local bonuses = tweak_data.economy.bonuses
	local sort_list = {}

	for id in pairs(bonuses) do
		table.insert(sort_list, id)
	end

	table.sort(sort_list)

	local multichoice_list = {}

	table.insert(multichoice_list, {
		text_id = "None",
		localize = false,
		_meta = "option"
	})

	for _, id in ipairs(sort_list) do
		table.insert(multichoice_list, {
			localize = false,
			_meta = "option",
			text_id = id,
			value = id
		})
	end

	local bonus_input = self:create_multichoice(node, multichoice_list, {
		name = "bonus_input",
		enabled = true,
		text_id = "debug_wskn_bonus",
		text_offset = 100,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name
	})

	bonus_input:set_value(Global.shiny_debug.cosmetics_data.bonus or bonuses[1])

	local default_blueprint_toggle = self:create_toggle(node, {
		name = "default_blueprint",
		enabled = true,
		text_id = "debug_wskn_blueprint",
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name
	})

	default_blueprint_toggle:set_value(Global.shiny_debug.cosmetics_data.default_blueprint and "on" or "off")
	self:create_divider(node, "copy")

	if Global.shiny_debug.type == "weapon" then
		self:create_item(node, {
			callback = "copy_weapon_customize",
			name = "copy_skin",
			enabled = true,
			text_id = "debug_wskn_save_skin"
		})
	elseif Global.shiny_debug.type == "armour" then
		self:create_item(node, {
			callback = "copy_armour_customize",
			name = "copy_skin",
			enabled = true,
			text_id = "debug_wskn_save_skin"
		})
	end
end

function MenuCustomizeWeaponInitiator:modify_node_edit_skin_menu(node, data)
	local cosmetics = managers.blackmarket:get_cosmetics_by_weapon_id(Global.shiny_debug.cosmetics_data.weapon_id) or {}
	local sort_data = {}

	for id, data in pairs(cosmetics) do
		table.insert(sort_data, id)
	end

	table.sort(sort_data)

	local default_item = nil

	for _, id in ipairs(sort_data) do
		self:create_item(node, {
			callback = "edit_weapon_customize",
			enabled = true,
			name = id,
			text_id = tweak_data.blackmarket.weapon_skins[id].name_id
		})

		default_item = default_item or id
	end

	node:set_default_item_name(default_item)
	node:select_item(default_item)
end

function MenuCustomizeWeaponInitiator:modify_node_parts_menu(node, data)
	if not Global.shiny_debug.weapon_unit then
		return
	end

	local default_item = nil

	for part_id, materials in pairs(Global.shiny_debug.weapon_unit:base()._materials or {}) do
		self:create_item(node, {
			localize = false,
			enabled = true,
			next_node = "debug_shiny",
			name = part_id,
			text_id = (tweak_data.weapon.factory.parts[part_id] and managers.localization:text("bm_menu_" .. tweak_data.weapon.factory.parts[part_id].type) .. " - ") .. part_id,
			next_node_parameters = {
				{
					menu = "materials_menu",
					part_id = part_id
				}
			}
		})

		default_item = default_item or part_id
	end

	node:set_default_item_name(default_item)
	node:select_item(default_item)
end

function MenuCustomizeWeaponInitiator:modify_node_types_menu(node, data)
	local types = managers.weapon_factory._parts_by_type or {}
	local default_item = nil
	local sort_types = {}

	for type, parts in pairs(types) do
		table.insert(sort_types, type)
	end

	table.sort(sort_types)

	for _, mod_type in ipairs(sort_types) do
		self:create_item(node, {
			localize = false,
			enabled = true,
			next_node = "debug_shiny",
			name = mod_type,
			text_id = managers.localization:text("bm_menu_" .. mod_type),
			next_node_parameters = {
				{
					menu = "weapon_skin",
					mod_type = mod_type
				}
			}
		})

		default_item = default_item or mod_type
	end

	node:set_default_item_name(default_item)
	node:select_item(default_item)
end

function MenuCustomizeWeaponInitiator:modify_node_materials_menu(node, data)
	local default_item = nil
	local items_map = {}

	for _, material in pairs(Global.shiny_debug.weapon_unit:base()._materials[data.part_id] or {}) do
		if not items_map[material:name():key()] then
			self:create_item(node, {
				localize = false,
				enabled = true,
				next_node = "debug_shiny",
				name = material:name():key(),
				text_id = utf8.to_upper(material:name():s()),
				next_node_parameters = {
					{
						menu = "weapon_skin",
						part_id = data.part_id,
						material_name = material:name()
					}
				}
			})

			default_item = default_item or material:name():key()
			items_map[material:name():key()] = true
		end
	end

	node:set_default_item_name(default_item)
	node:select_item(default_item)
end

function MenuCustomizeWeaponInitiator:modify_node_weapon_skin(node, data)
	local cdata = Global.shiny_debug.cosmetics_data

	if data.part_id then
		cdata.parts = cdata.parts or {}
		cdata.parts[data.part_id] = cdata.parts[data.part_id] or {}

		if data.material_name then
			cdata.parts[data.part_id][data.material_name:key()] = cdata.parts[data.part_id][data.material_name:key()] or {}
			cdata = cdata.parts[data.part_id][data.material_name:key()]
		else
			cdata = cdata.parts[data.part_id]
		end
	elseif data.mod_type then
		cdata.types = cdata.types or {}
		cdata.types[data.mod_type] = cdata.types[data.mod_type] or {}
		cdata = cdata.types[data.mod_type]
	end

	local base_gradients = tweak_data.blackmarket.shiny_debug_tool.weapon_skins.BASE_GRADIENT
	local sort_list = {}

	for id in pairs(base_gradients) do
		table.insert(sort_list, id)
	end

	table.sort(sort_list)

	local base_gradient = nil
	local multichoice_list = {
		{
			value = -1,
			text_id = "DEFAULT",
			localize = false,
			_meta = "option"
		}
	}

	for _, id in ipairs(sort_list) do
		base_gradient = base_gradients[id]

		table.insert(multichoice_list, {
			localize = false,
			_meta = "option",
			text_id = id,
			value = Idstring(base_gradient)
		})
	end

	local base_gradient_item = self:create_multichoice(node, multichoice_list, {
		text_id = "debug_wskn_base_gradient",
		name = "base_gradient",
		callback = "update_skin_preview",
		text_offset = 50,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	base_gradient_item:set_value(cdata.base_gradient)

	local pattern_gradients = tweak_data.blackmarket.shiny_debug_tool.weapon_skins.PATTERN_GRADIENT
	sort_list = {}

	for id in pairs(pattern_gradients) do
		table.insert(sort_list, id)
	end

	table.sort(sort_list)

	local pattern_gradient = nil
	local multichoice_list = {
		{
			value = -1,
			text_id = "DEFAULT",
			localize = false,
			_meta = "option"
		}
	}

	for _, id in ipairs(sort_list) do
		pattern_gradient = pattern_gradients[id]

		table.insert(multichoice_list, {
			localize = false,
			_meta = "option",
			text_id = id,
			value = Idstring(pattern_gradient)
		})
	end

	local pattern_gradient_item = self:create_multichoice(node, multichoice_list, {
		text_id = "debug_wskn_pattern_gradient",
		name = "pattern_gradient",
		callback = "update_skin_preview",
		text_offset = 50,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_gradient_item:set_value(cdata.pattern_gradient)

	local patterns = tweak_data.blackmarket.shiny_debug_tool.weapon_skins.PATTERN
	sort_list = {}

	for id in pairs(patterns) do
		table.insert(sort_list, id)
	end

	table.sort(sort_list)

	local pattern = nil
	local multichoice_list = {
		{
			value = -1,
			text_id = "DEFAULT",
			localize = false,
			_meta = "option"
		}
	}

	for _, id in ipairs(sort_list) do
		pattern = patterns[id]

		table.insert(multichoice_list, {
			localize = false,
			_meta = "option",
			text_id = id,
			value = Idstring(pattern)
		})
	end

	local pattern_item = self:create_multichoice(node, multichoice_list, {
		text_id = "debug_wskn_pattern",
		name = "pattern",
		callback = "update_skin_preview",
		text_offset = 50,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_item:set_value(cdata.pattern)
	self:create_divider(node, "sliders")

	local wear_and_tear_item = self:create_slider(node, {
		callback = "update_skin_preview",
		name = "wear_and_tear",
		max = 1,
		text_id = "debug_wskn_wear_and_tear",
		step = 0.2,
		min = 0,
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	wear_and_tear_item:set_value(cdata.wear_and_tear or 1)

	local pattern_pos_x_item = self:create_slider(node, {
		name = "pattern_pos1",
		key = "pattern_pos",
		max = 2,
		text_id = "debug_wskn_pattern_pos_x",
		step = 0.001,
		vector = 1,
		min = -2,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_pos_x_item:set_value(cdata.pattern_pos and mvector3.x(cdata.pattern_pos) or 0)

	local pattern_pos_y_item = self:create_slider(node, {
		name = "pattern_pos2",
		key = "pattern_pos",
		max = 2,
		text_id = "debug_wskn_pattern_pos_y",
		step = 0.001,
		vector = 2,
		min = -2,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_pos_y_item:set_value(cdata.pattern_pos and mvector3.y(cdata.pattern_pos) or 0)

	local pattern_tweak_x_item = self:create_slider(node, {
		name = "pattern_tweak1",
		key = "pattern_tweak",
		max = 20,
		text_id = "debug_wskn_pattern_tweak_x",
		step = 0.001,
		vector = 1,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_tweak_x_item:set_value(cdata.pattern_tweak and mvector3.x(cdata.pattern_tweak) or 1)
	self:create_divider(node, 1)

	local pattern_tweak_y_item = self:create_slider(node, {
		name = "pattern_tweak2",
		key = "pattern_tweak",
		text_id = "debug_wskn_pattern_tweak_y",
		step = 0.001,
		vector = 2,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		max = 2 * math.pi,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_tweak_y_item:set_value(cdata.pattern_tweak and mvector3.y(cdata.pattern_tweak) or 0)

	local pattern_tweak_z_item = self:create_slider(node, {
		name = "pattern_tweak3",
		key = "pattern_tweak",
		max = 1,
		text_id = "debug_wskn_pattern_tweak_z",
		step = 0.001,
		vector = 3,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	pattern_tweak_z_item:set_value(cdata.pattern_tweak and mvector3.z(cdata.pattern_tweak) or 1)
	self:create_divider(node, 2)

	local cubemap_pattern_control_x_item = self:create_slider(node, {
		name = "cubemap_pattern_control1",
		key = "cubemap_pattern_control",
		max = 1,
		text_id = "debug_wskn_cubemap_pattern_control_x",
		step = 0.001,
		vector = 1,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	cubemap_pattern_control_x_item:set_value(cdata.cubemap_pattern_control and mvector3.x(cdata.cubemap_pattern_control) or 0)

	local cubemap_pattern_control_y_item = self:create_slider(node, {
		name = "cubemap_pattern_control2",
		key = "cubemap_pattern_control",
		max = 1,
		text_id = "debug_wskn_cubemap_pattern_control_y",
		step = 0.001,
		vector = 2,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	cubemap_pattern_control_y_item:set_value(cdata.cubemap_pattern_control and mvector3.y(cdata.cubemap_pattern_control) or 0)
	self:create_divider(node, "sticker")
	self:create_divider(node, "sticker2")

	local stickers = tweak_data.blackmarket.shiny_debug_tool.weapon_skins.STICKER
	sort_list = {}

	for id in pairs(stickers) do
		table.insert(sort_list, id)
	end

	table.sort(sort_list)

	local sticker = nil
	local multichoice_list = {
		{
			value = -1,
			text_id = "DEFAULT",
			localize = false,
			_meta = "option"
		}
	}

	for _, id in ipairs(sort_list) do
		sticker = stickers[id]

		table.insert(multichoice_list, {
			localize = false,
			_meta = "option",
			text_id = id,
			value = Idstring(sticker)
		})
	end

	local sticker_item = self:create_multichoice(node, multichoice_list, {
		text_id = "debug_wskn_sticker",
		name = "sticker",
		callback = "update_skin_preview",
		text_offset = 50,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	sticker_item:set_value(cdata.sticker)

	local uv_offset_rot_x_item = self:create_slider(node, {
		name = "uv_offset_rot1",
		key = "uv_offset_rot",
		max = 2,
		text_id = "debug_wskn_uv_offset_rot_x",
		step = 0.001,
		vector = 1,
		min = -2,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	uv_offset_rot_x_item:set_value(cdata.uv_offset_rot and mvector3.x(cdata.uv_offset_rot) or 0)

	local uv_offset_rot_y_item = self:create_slider(node, {
		name = "uv_offset_rot2",
		key = "uv_offset_rot",
		max = 2,
		text_id = "debug_wskn_uv_offset_rot_y",
		step = 0.001,
		vector = 2,
		min = -2,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	uv_offset_rot_y_item:set_value(cdata.uv_offset_rot and mvector3.y(cdata.uv_offset_rot) or 0)

	local uv_scale_x_item = self:create_slider(node, {
		name = "uv_scale1",
		key = "uv_scale",
		max = 20,
		text_id = "debug_wskn_uv_scale_x",
		step = 0.001,
		vector = 1,
		min = 0.01,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	uv_scale_x_item:set_value(cdata.uv_scale and mvector3.x(cdata.uv_scale) or 1)

	local uv_scale_y_item = self:create_slider(node, {
		name = "uv_scale2",
		key = "uv_scale",
		max = 20,
		text_id = "debug_wskn_uv_scale_y",
		step = 0.001,
		vector = 2,
		min = 0.01,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	uv_scale_y_item:set_value(cdata.uv_scale and mvector3.y(cdata.uv_scale) or 1)
	self:create_divider(node, 3)

	local uv_offset_rot_z_item = self:create_slider(node, {
		name = "uv_offset_rot3",
		key = "uv_offset_rot",
		text_id = "debug_wskn_uv_offset_rot_z",
		step = 0.001,
		vector = 3,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		max = 2 * math.pi,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	uv_offset_rot_z_item:set_value(cdata.uv_offset_rot and mvector3.z(cdata.uv_offset_rot) or 0)

	local uv_scale_z_item = self:create_slider(node, {
		name = "uv_scale3",
		key = "uv_scale",
		max = 1,
		text_id = "debug_wskn_uv_scale_z",
		step = 0.001,
		vector = 3,
		min = 0,
		callback = "update_skin_preview",
		show_value = true,
		crafted_data = Global.shiny_debug,
		part_id = data.part_id,
		material_name = data.material_name,
		mod_type = data.mod_type
	})

	uv_scale_z_item:set_value(cdata.uv_scale and mvector3.z(cdata.uv_scale) or 1)

	if Global.shiny_debug.weapon_unit then
		Global.shiny_debug.weapon_unit:base():_apply_cosmetics(function ()
		end)
	end

	if Global.shiny_debug.second_weapon_unit then
		Global.shiny_debug.second_weapon_unit:base():_apply_cosmetics(function ()
		end)
	end

	if alive(Global.shiny_debug.character_unit) then
		Global.shiny_debug.character_unit:base():_apply_cosmetics({})
	end

	node:set_default_item_name("base_gradient")
	node:select_item("base_gradient")
end

function MenuCustomizeWeaponInitiator:modify_node_pose_menu(node, data)
	local sort_types = {}
	local default_item = nil

	for pose_name, pose_table in pairs(managers.menu_scene._global_poses) do
		for _, pose in ipairs(pose_table) do
			if not table.contains(sort_types, pose) then
				table.insert(sort_types, pose)
			end
		end
	end

	table.sort(sort_types)

	for _, pose in ipairs(sort_types) do
		self:create_item(node, {
			localize = false,
			enabled = true,
			callback = "update_armour_preview_pose",
			name = pose,
			text_id = pose
		})

		default_item = default_item or pose
	end

	if default_item then
		node:set_default_item_name(default_item)
		node:select_item(default_item)
	end
end

function MenuCallbackHandler:update_armour_preview_pose(item)
	managers.menu_scene:_set_character_unit_pose(item:name(), Global.shiny_debug.character_unit)
end

function MenuCustomizeWeaponInitiator:modify_node_armour_menu(node, data)
	local sort_types = {}
	local default_item = nil

	for armor_name, armor_table in pairs(tweak_data.blackmarket.armors) do
		if not table.contains(sort_types, armor_name) then
			table.insert(sort_types, armor_name)
		end
	end

	table.sort(sort_types)

	for _, armor_name in ipairs(sort_types) do
		self:create_item(node, {
			localize = false,
			enabled = true,
			callback = "update_armour_preview_level",
			name = armor_name,
			text_id = armor_name
		})

		default_item = default_item or armor_name
	end

	if default_item then
		node:set_default_item_name(default_item)
		node:select_item(default_item)
	end
end

function MenuCustomizeWeaponInitiator:modify_node_load_armour_menu(node, data)
	local default_item = nil

	for name, data in pairs(tweak_data.economy.armor_skins) do
		self:create_item(node, {
			localize = false,
			enabled = true,
			callback = "load_existing_armour",
			name = name,
			text_id = name
		})

		default_item = default_item or name
	end

	if default_item then
		node:set_default_item_name(default_item)
		node:select_item(default_item)
	end
end

function MenuCallbackHandler:update_armour_preview_level(item)
	managers.menu_scene:set_character_armor(item:name())
end

function MenuCallbackHandler:load_existing_armour(item)
	local data = tweak_data.economy.armor_skins[item:name()]

	if not data then
		Application:error("Can not load item: ", item:name())

		return
	end

	local cos_data = Global.shiny_debug.cosmetics_data
	cos_data.id = item:name()
	cos_data.tbf = data.texture_bundle_folder
	cos_data.rarity = data.rarity
	cos_data.bonus = data.bonus
	cos_data.base_gradient = data.base_gradient
	cos_data.pattern_gradient = data.pattern_gradient
	cos_data.pattern = data.pattern
	cos_data.sticker = data.sticker
	cos_data.pattern_tweak = data.pattern_tweak
	cos_data.pattern_pos = data.pattern_pos
	cos_data.uv_scale = data.uv_scale
	cos_data.uv_offset_rot = data.uv_offset_rot
	cos_data.cubemap_pattern_control = data.cubemap_pattern_control

	MenuCustomizeWeaponInitiator:_apply_cosmetics_to_armour()
	managers.menu:active_menu().logic:refresh_node("main")
end

function MenuCallbackHandler:clear_debug_weapon_skin()
	local new_cosmetics_data = {
		wear_and_tear = 1,
		weapon_id = managers.blackmarket:get_crafted_category_slot(Global.shiny_debug.category, Global.shiny_debug.slot).weapon_id,
		parts = {}
	}
	Global.shiny_debug.weapon_unit:base()._cosmetics_data = new_cosmetics_data
	Global.shiny_debug.cosmetics_data = Global.shiny_debug.weapon_unit:base()._cosmetics_data

	Global.shiny_debug.weapon_unit:base():_apply_cosmetics(function ()
	end)

	if Global.shiny_debug.second_weapon_unit then
		Global.shiny_debug.second_weapon_unit:base()._cosmetics_data = new_cosmetics_data

		Global.shiny_debug.second_weapon_unit:base():_apply_cosmetics(function ()
		end)
	end
end

function MenuCallbackHandler:edit_weapon_customize(item)
	local id = item:name()
	local new_cosmetics_data = deep_clone(tweak_data.blackmarket.weapon_skins[id])
	local crafted_item = managers.blackmarket:get_crafted_category_slot(Global.shiny_debug.category, Global.shiny_debug.slot)

	if new_cosmetics_data.default_blueprint then
		crafted_item.blueprint = deep_clone(new_cosmetics_data.default_blueprint)
	end

	local id = string.sub(id, string.len(new_cosmetics_data.weapon_id .. "_") + 1, -1)
	local tbf = string.sub(new_cosmetics_data.texture_bundle_folder, string.len("cash/safes/") + 1, -1)
	new_cosmetics_data.name_id = nil
	new_cosmetics_data.desc_id = nil
	new_cosmetics_data.texture_bundle_folder = nil
	new_cosmetics_data.wear_and_tear = nil
	new_cosmetics_data.reserve_quality = nil
	new_cosmetics_data.locked = nil
	new_cosmetics_data.unique_name_id = nil
	new_cosmetics_data.id = id
	new_cosmetics_data.tbf = tbf
	Global.shiny_debug.cosmetics_data = new_cosmetics_data

	managers.menu:back()
	managers.menu:back()
	managers.blackmarket:view_weapon(Global.shiny_debug.category, Global.shiny_debug.slot, function ()
		managers.menu:open_node("debug_shiny", {
			{
				category = Global.shiny_debug.category,
				slot = Global.shiny_debug.slot
			}
		})
	end)
end

function MenuCallbackHandler:cleanup_weapon_customize_data(copy_data, skip_base)
	local function remove_empty_func(data)
		local remove = {}

		for key, v in pairs(data) do
			if key == "pattern_tweak" and v == Vector3(1, 0, 1) then
				table.insert(remove, key)
			elseif key == "pattern_pos" and v == Vector3(0, 0, 0) then
				table.insert(remove, key)
			elseif key == "uv_scale" and v == Vector3(1, 1, 1) then
				table.insert(remove, key)
			elseif key == "uv_offset_rot" and v == Vector3(0, 0, 0) then
				table.insert(remove, key)
			elseif key == "cubemap_pattern_control" and v == Vector3(0, 0, 0) then
				table.insert(remove, key)
			elseif key == "wear_and_tear" and v == 1 then
				table.insert(remove, key)
			end
		end

		for _, key in ipairs(remove) do
			data[key] = nil
		end
	end

	if not skip_base then
		remove_empty_func(copy_data)
	end

	if copy_data.parts then
		local remove_parts = {}

		for part_id, materials in pairs(copy_data.parts) do
			local remove_materials = {}

			for k, data in pairs(materials) do
				data.wear_and_tear = nil

				remove_empty_func(data)

				if table.size(data) == 0 then
					table.insert(remove_materials, k)
				end
			end

			for _, key in ipairs(remove_materials) do
				materials[key] = nil
			end

			if table.size(materials) == 0 then
				table.insert(remove_parts, part_id)
			end
		end

		for _, part_id in ipairs(remove_parts) do
			copy_data.parts[part_id] = nil
		end

		if copy_data.parts and table.size(copy_data.parts) == 0 then
			copy_data.parts = nil
		end
	end

	if copy_data.types then
		local remove_types = {}

		for type_id, data in pairs(copy_data.types) do
			remove_empty_func(data)

			if table.size(data) == 0 then
				table.insert(remove_types, type_id)
			end
		end

		for _, type_id in ipairs(remove_types) do
			copy_data.types[type_id] = nil
		end

		if copy_data.types and table.size(copy_data.types) == 0 then
			copy_data.types = nil
		end
	end
end

function MenuCallbackHandler:copy_weapon_customize(item)
	local crafted_item = managers.blackmarket:get_crafted_category_slot(Global.shiny_debug.category, Global.shiny_debug.slot)
	local name = managers.menu:active_menu().logic:selected_node():item("name_input"):input_text()

	if not name or name == "" then
		name = "[REPLACE ME]"
	end

	local tbf = managers.menu:active_menu().logic:selected_node():item("tbf_input"):input_text()

	if not tbf or tbf == "" then
		tbf = "wip"
	end

	local bonus = managers.menu:active_menu().logic:selected_node():item("bonus_input"):value()

	if not bonus or bonus == "" then
		bonus = "[NEED BONUS]"
	end

	local rarity = managers.menu:active_menu().logic:selected_node():item("rarity_input"):value()

	if not rarity or rarity == "" then
		rarity = "[NEED RARITY]"
	end

	local item_id = crafted_item.weapon_id .. "_" .. name
	local copy_data = deep_clone(Global.shiny_debug.cosmetics_data)
	copy_data.bonus = bonus
	copy_data.rarity = rarity
	copy_data.name_id = "bm_wskn_" .. item_id
	copy_data.desc_id = "bm_wskn_" .. item_id .. "_desc"
	copy_data.texture_bundle_folder = "cash/safes/" .. tbf
	copy_data.wear_and_tear = nil
	copy_data.reserve_quality = true

	MenuCallbackHandler:cleanup_weapon_customize_data(copy_data)

	if copy_data.rarity == "legendary" then
		copy_data.locked = true
		copy_data.unique_name_id = copy_data.name_id
	end

	if managers.menu:active_menu().logic:selected_node():item("default_blueprint"):value() == "on" then
		copy_data.default_blueprint = deep_clone(crafted_item.blueprint)
	else
		copy_data.default_blueprint = nil
	end

	local text = "\tself.weapon_skins." .. item_id .. " = {}" .. serializeTable("self.weapon_skins." .. item_id, copy_data)

	Application:set_clipboard(text)
end

function MenuCallbackHandler:copy_armour_customize(item)
	local name = managers.menu:active_menu().logic:selected_node():item("name_input"):input_text()

	if not name or name == "" then
		name = "[REPLACE ME]"
	end

	local tbf = managers.menu:active_menu().logic:selected_node():item("tbf_input"):input_text()

	if not tbf or tbf == "" then
		tbf = "wip"
	end

	local rarity = managers.menu:active_menu().logic:selected_node():item("rarity_input"):value()

	if not rarity or rarity == "" then
		rarity = "[NEED RARITY]"
	end

	local item_id = name
	local copy_data = deep_clone(Global.shiny_debug.cosmetics_data)
	copy_data.rarity = rarity
	copy_data.name_id = "bm_askn_" .. item_id
	copy_data.desc_id = "bm_askn_" .. item_id .. "_desc"
	copy_data.texture_bundle_folder = "cash/safes/" .. tbf
	copy_data.wear_and_tear = nil
	copy_data.reserve_quality = true

	MenuCallbackHandler:cleanup_weapon_customize_data(copy_data)

	if copy_data.rarity == "legendary" then
		copy_data.locked = true
		copy_data.unique_name_id = copy_data.name_id
	end

	local text = "\tself.skins." .. item_id .. " = {}" .. serializeTable("self.skins." .. item_id, copy_data)

	Application:set_clipboard(text)
end

function MenuCallbackHandler:update_skin_preview(item)
	local data = {
		key = item:parameters().key or item:name(),
		part_id = item:parameters().part_id,
		material_name = item:parameters().material_name,
		mod_type = item:parameters().mod_type,
		value = item:value(),
		vector = item:parameters().vector
	}
	local func = "update_skin_preview_" .. tostring(Global.shiny_debug.type)

	if self[func] then
		self[func](self, item, data)
	else
		Application:error("No update skin function for ", Global.shiny_debug.type, "Create function ", func)
	end
end

function MenuCallbackHandler:update_skin_preview_weapon(item, dat)
	local key = dat.key
	local part_id = dat.part_id
	local material_name = dat.material_name
	local mod_type = dat.mod_type
	local value = dat.value
	local vector = dat.vector

	if not Global.shiny_debug.weapon_unit or not alive(Global.shiny_debug.weapon_unit) or not Global.shiny_debug.cosmetics_data then
		return
	end

	local data = Global.shiny_debug.cosmetics_data

	if part_id then
		data.parts = data.parts or {}
		data.parts[part_id] = data.parts[part_id] or {}

		if material_name then
			data.parts[part_id][material_name:key()] = data.parts[part_id][material_name:key()] or {}
			data = data.parts[part_id][material_name:key()]
		else
			data = data.parts[part_id]
		end
	elseif mod_type then
		data.types = data.types or {}
		data.types[mod_type] = data.types[mod_type] or {}
		data = data.types[mod_type]
	end

	if value == -1 then
		value = nil
	elseif vector then
		local v = data[key]
		v = v or Vector3(i1 and i1:value() or 0, i2 and i2:value() or 0, i3 and i3:value() or 0)

		if vector == 1 then
			mvector3.set_x(v, value)
		elseif vector == 2 then
			mvector3.set_y(v, value)
		elseif vector == 3 then
			mvector3.set_z(v, value)
		end

		value = v
	end

	data[key] = value

	MenuCallbackHandler:cleanup_weapon_customize_data(Global.shiny_debug.cosmetics_data, true)
	Global.shiny_debug.weapon_unit:base():_apply_cosmetics(function ()
	end)

	if Global.shiny_debug.second_weapon_unit then
		Global.shiny_debug.second_weapon_unit:base():_apply_cosmetics(function ()
		end)
	end
end

function MenuCallbackHandler:update_skin_preview_armour(item, data)
	if not Global.shiny_debug.character_unit or not alive(Global.shiny_debug.character_unit) or not Global.shiny_debug.cosmetics_data then
		return
	end

	local cosmetic_data = Global.shiny_debug.cosmetics_data
	local key = data.key
	local value = data.value
	local vector = data.vector

	if value == -1 then
		value = nil
	elseif vector then
		local v = cosmetic_data[key]
		v = v or Vector3(i1 and i1:value() or 0, i2 and i2:value() or 0, i3 and i3:value() or 0)

		if vector == 1 then
			mvector3.set_x(v, value)
		elseif vector == 2 then
			mvector3.set_y(v, value)
		elseif vector == 3 then
			mvector3.set_z(v, value)
		end

		value = v
	end

	cosmetic_data[key] = value

	MenuCallbackHandler:cleanup_weapon_customize_data(Global.shiny_debug.cosmetics_data, true)

	if Global.shiny_debug.character_unit then
		Global.shiny_debug.character_unit:base():_apply_cosmetics({})
	end
end

function serializeTable(table_prefix, val, name, skipnewlines, depth)
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
			"name_id",
			"desc_id",
			"weapon_id",
			"rarity",
			"bonus",
			"reserve_quality",
			"texture_bundle_folder",
			"unique_name_id",
			"locked",
			"base_gradient",
			"pattern_gradient",
			"pattern",
			"sticker",
			"pattern_tweak",
			"pattern_pos",
			"uv_scale",
			"uv_offset_rot",
			"cubemap_pattern_control",
			"default_blueprint",
			"parts",
			"types"
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
