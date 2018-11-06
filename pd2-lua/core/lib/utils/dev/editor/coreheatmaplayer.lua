core:module("CoreHeatmapLayer")
core:import("CoreLayer")
core:import("CoreEws")

HeatmapLayer = HeatmapLayer or class(CoreLayer.Layer)

function HeatmapLayer:init(owner)
	HeatmapLayer.super.init(self, owner, "heatmap")

	self._heatmap_sets = {}
end

function HeatmapLayer:get_layer_name()
	return "Heatmap"
end

function HeatmapLayer:get_setting(setting)
end

function HeatmapLayer:load(world_holder, offset)
end

function HeatmapLayer:save(save_params)
end

function HeatmapLayer:update(t, dt)
	self:_draw(t, dt)
end

function HeatmapLayer:_draw(t, dt)
	local colors = {
		Vector3(0, 1, 0),
		Vector3(0, 0, 1),
		Vector3(1, 0, 1),
		Vector3(0, 1, 1),
		Vector3(1, 1, 1)
	}

	for j, set in ipairs(self._heatmap_sets) do
		self:_draw_path(set.player, colors[j % 5])

		for _, path in pairs(set.enemies) do
			self:_draw_path(path, Vector3(1, 0, 0))
		end

		for _, path in pairs(set.teamai) do
			self:_draw_path(path, Vector3(1, 1, 0))
		end

		for _, path in pairs(set.civilians) do
			self:_draw_path(path, Vector3(0, 0, 0))
		end

		for _, event in ipairs(set.events) do
			Application:draw_sphere(event[1], 25, event[2].x, event[2].y, event[2].z)
		end
	end
end

function HeatmapLayer:_draw_path(path, color)
	for i = 1, #path, 2 do
		local p1 = path[i]
		local p2 = path[i + 2]

		if p2 ~= nil then
			Application:draw_line(p1, p2, color.x, color.y, color.z)
		end
	end
end

function HeatmapLayer:build_panel(notebook)
	cat_print("editor", "HeatmapLayer:build_panel")

	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("HORIZONTAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")
	local add_btn = EWS:Button(self._ews_panel, "Add heatmap data", "", "BU_EXACTFIT,NO_BORDER")

	self._sizer:add(add_btn, 0, 5, "RIGHT")
	add_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_add_data"), {})

	local clr_btn = EWS:Button(self._ews_panel, "Clear heatmap data", "", "BU_EXACTFIT,NO_BORDER")

	self._sizer:add(clr_btn, 0, 5, "RIGHT")
	clr_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_clr_data"), {})
	self._main_sizer:add(self._sizer, 1, 0, "EXPAND")

	return self._ews_panel
end

function HeatmapLayer:_add_data()
	local opendlg_path, opendlg_dir = managers.database:open_file_dialog(Global.frame, "Logs (*.txt)|*.txt")

	if opendlg_path and opendlg_dir then
		local path = opendlg_path
		local dir = opendlg_dir

		print("Opening " .. path)

		local file = SystemFS:open(path, "r")
		local data = {}
		local name = file:gets()
		local server = file:gets() == "true"
		data.name = name
		data.is_server = server
		data.player = {}
		data.enemies = {}
		data.teamai = {}
		data.civilians = {}
		data.events = {}

		print("Found data from " .. name)

		while true do
			local line = file:gets()

			if line == "" then
				break
			end

			local comp = string.split(line, " ")
			local type = tonumber(comp[1])
			local time = tonumber(comp[2])
			local pos = Vector3(comp[3], comp[4], comp[5] + 5)

			if type == 1 then
				table.insert(data.player, pos)
			elseif type == 2 then
				local unit_type = tonumber(comp[6])
				local tble = nil

				if unit_type == 1 then
					tble = data.enemies
				elseif unit_type == 2 then
					tble = data.teamai
				elseif unit_type == 3 then
					tble = data.civilians
				end

				if tble ~= nil then
					if tble[comp[8]] == nil then
						tble[comp[8]] = {}
					end

					table.insert(tble[comp[8]], pos)
				end
			elseif type == 3 then
				local e_type = comp[6]
				local color = nil

				if e_type == "downed" then
					color = Vector3(1, 1, 0)
				elseif e_type == "reloaded" then
					color = Vector3(0.5, 0.5, 0.5)
				elseif e_type == "tiedown" then
					-- Nothing
				elseif e_type == "deploy_trip" then
					-- Nothing
				elseif e_type == "deploy_ammo" then
					color = Vector3(0, 0.5, 0)
				elseif e_type == "deploy_medic" then
					color = Vector3(1, 0.5, 0.5)
				elseif e_type == "in_custody" then
					-- Nothing
				elseif e_type == "trade" then
					-- Nothing
				elseif e_type == "cash" then
					color = Vector3(0, 1, 0)
				end

				if color ~= nil then
					table.insert(data.events, {
						pos,
						color
					})
				end
			end
		end

		print("Player positions: " .. #data.player)
		print("Enemies: " .. table.size(data.enemies))
		print("TeamAIs: " .. table.size(data.teamai))
		print("Civilians: " .. table.size(data.civilians))
		print("Events: " .. #data.events)

		if self._heatmap_sets == nil then
			self._heatmap_sets = {}
		end

		table.insert(self._heatmap_sets, data)
	end
end

function HeatmapLayer:_clr_data()
	self._heatmap_sets = {}
end

function HeatmapLayer:add_triggers()
	HeatmapLayer.super.add_triggers(self)
end

function HeatmapLayer:activate()
	HeatmapLayer.super.activate(self)
end

function HeatmapLayer:deactivate()
	HeatmapLayer.super.deactivate(self)
end

function HeatmapLayer:clear()
	HeatmapLayer.super.clear(self)
	self:_clr_data()
end
