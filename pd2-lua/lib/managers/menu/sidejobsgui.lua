SideJobsGui = SideJobsGui or class(MenuGuiComponentGeneric)

function SideJobsGui:init(...)
	SideJobsGui.super.init(self, ...)
end

function SideJobsGui:_setup(is_start_page)
	local component_data = {
		topic_id = "menu_side_jobs_title"
	}

	SideJobsGui.super._setup(self, is_start_page, component_data)
	self:tabs_panel():set_visible(false)
end

function SideJobsGui:populate_tabs_data(tabs_data)
	table.insert(tabs_data, {
		name_id = "menu_cs_daily_challenge",
		width_multiplier = 1,
		page_class = "CustomSafehouseGuiPageDaily"
	})
end
