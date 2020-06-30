if false and MenuManager then
	core:import("CoreMenuData")
	core:import("CoreMenuLogic")
	core:import("CoreMenuInput")
	core:import("CoreMenuRenderer")

	local old_init = MenuManager.init

	function MenuManager:init(is_start_menu)
		old_init(self, is_start_menu)

		if self._registered_menus.menu_main then
			local c = ScriptSerializer:from_custom_xml([[
		<node name="fbifiles" scene_state="lobby" menu_components="player_stats" topic_id="menu_fbifiles" back_callback="fbifiles_back_callback" >
			<legend name="menu_legend_manual_switch_page"/>
			<legend name="menu_legend_select"/>
			<legend name="menu_legend_back"/>
		</node> ]])
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

			local main_node = self._registered_menus.menu_main.logic:get_node("main")
			local lobby_node = self._registered_menus.menu_main.logic:get_node("lobby")
			local c = ScriptSerializer:from_custom_xml(" <item name=\"fbifiles\" text_id=\"menu_fbifiles\" help_id=\"menu_fbifiles_help\" next_node=\"fbifiles\" /> ")

			for _, node in ipairs({
				main_node,
				lobby_node
			}) do
				local type = c._meta

				if type == "item" then
					local item = node:create_item(c)
					local item_name = "blackmarket"
					local index = 1

					for _, i in ipairs(node:items()) do
						if not item_name and i:visible() or i:parameters().name == item_name then
							break
						end

						index = index + 1
					end

					node:insert_item(item, index)
				elseif type == "default_item" then
					node._default_item_name = c.name
				elseif type == "legend" then
					table.insert(node._legends, {
						string_id = c.name,
						pc = c.pc,
						visible_callback = c.visible_callback
					})
				end
			end
		end
	end
end
