MutatorsListGui = MutatorsListGui or class(MenuGuiComponentGeneric)

function MutatorsListGui:populate_tabs_data(tabs_data)
	for _, category in ipairs(managers.mutators:categories()) do
		local class_name = "MutatorsCategoryPage_" .. tostring(category)

		if not rawget(_G, class_name) then
			rawset(_G, class_name, class(MutatorsCategoryPage))

			_G[class_name].category = tostring(category)
		end

		table.insert(self._tabs_data, {
			name_id = "menu_mutators_category_" .. tostring(category),
			page_class = class_name
		})
	end
end

function MutatorsListGui:_start_page_data()
	local data = {
		topic_id = "menu_mutators"
	}

	return data
end

function MutatorsListGui:input_focus()
	return managers.menu:active_menu().logic:selected_node():parameters().name == "mutators" and 1 or nil
end

function MutatorsListGui:set_active_page(new_index, play_sound)
	MutatorsListGui.super.set_active_page(self, new_index, play_sound)
	self._selected_page:refresh()
end

function MutatorsListGui:refresh()
	MutatorsListGui.super.refresh(self)
	self._selected_page:refresh()
end
