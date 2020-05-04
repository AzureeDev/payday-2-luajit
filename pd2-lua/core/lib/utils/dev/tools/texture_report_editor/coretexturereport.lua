CoreTextureReport = CoreTextureReport or class()
CoreTextureReport.EDITOR_TITLE = "Texture Report (Current Level)"
CoreTextureReport.SEPARATOR = "\t"
CoreTextureReport.ORDER_META_NAME = "Texture Name"
CoreTextureReport.DEFAULT_ORDER_FIELD_NAME = "file_size"
CoreTextureReport.TEXTURE_CACHE_REPORT_FIELDS = {
	"texture_name_from_cache",
	"references",
	"width",
	"height",
	"size_in_memory",
	"mips"
}

function CoreTextureReport.ASCENDING_ORDER(index, item1, item2)
	local item1invalid = not item1 or not item1[index]
	local item2invalid = not item2 or not item2[index]

	if item1invalid and item2invalid then
		return 0
	elseif item1invalid then
		return -1
	elseif item2invalid then
		return 1
	end

	if type(item1[index]) == "number" and type(item2[index]) ~= "number" then
		return 1
	elseif type(item2[index]) == "number" and type(item1[index]) ~= "number" then
		return -1
	end

	if item1[index] < item2[index] then
		return -1
	elseif item2[index] < item1[index] then
		return 1
	end

	return 0
end

function CoreTextureReport.DESCENDING_ORDER(index, item1, item2)
	return -1 * CoreTextureReport.ASCENDING_ORDER(index, item1, item2)
end

CoreTextureReport.STATUSBARFIELDS = {
	{
		width = 100,
		on_updating = function (report_data)
			return "Updating..."
		end,
		on_ready = function (report_data)
			return "Ready!"
		end
	},
	{
		width = 200,
		on_updating = function (report_data)
			return "Number of Textures: Updating..."
		end,
		on_ready = function (report_data)
			local count = 0

			for _ in pairs(report_data) do
				count = count + 1
			end

			return "Number of Textures: " .. tostring(count)
		end
	},
	{
		width = 200,
		on_updating = function (report_data)
			return "Total Size: Updating..."
		end,
		on_ready = function (report_data)
			local sum = 0

			for i, texture_meta in pairs(report_data) do
				if type(texture_meta.file_size) == "number" then
					sum = sum + texture_meta.file_size
				end
			end

			return "Total Size: " .. tostring(sum)
		end
	}
}

function CoreTextureReport.GET_WIDTH_ARRAY()
	local status_bar_widths = {}

	for i, status_bar_meta in pairs(CoreTextureReport.STATUSBARFIELDS) do
		table.insert(status_bar_widths, status_bar_meta.width)
	end

	return status_bar_widths
end

function CoreTextureReport:init()
	local dialog = self:start_dialog()

	self:reload_data()
end

function CoreTextureReport:set_position(newpos)
end

function CoreTextureReport:update(time, delta_time)
end

function CoreTextureReport:close()
	self._main_frame:destroy()
end

function CoreTextureReport:_get_all_continents()
	local continents = {}

	for name, continent in pairs(managers.editor:continents()) do
		table.insert(continents, {
			name = name,
			continent = continent
		})
	end

	return continents
end

function CoreTextureReport:_get_all_units_by_layer()
	local layer_units = {}

	for continent_idx, data in pairs(CoreTextureReport:_get_all_continents()) do
		layer_units[data.name] = {}
		local continent_units = layer_units[data.name]

		for layer_name, layer in pairs(managers.editor:layers()) do
			if layer:uses_continents() then
				continent_units[layer_name] = {}

				for i, unit in pairs(layer:created_units()) do
					if unit:unit_data().continent == data.continent then
						table.insert(continent_units[layer_name], unit)
					end
				end
			end
		end
	end

	return layer_units
end

function CoreTextureReport:_get_all_textures()
	print("Getting textures")

	local function getFilename(str, sep)
		local path, file, extension = string.match(str, "(.-)([^/]-([^/%.]+))$")

		return file
	end

	local function add_file_to_report(unit, actual_entry, report)
		local filename = getFilename(actual_entry.file)

		if report[filename] then
			report[filename].count = report[filename].count + 1
			report[filename].unit_names = report[filename].unit_names .. ", " .. getFilename(unit:name():t())
		else
			local file_size = DB:open("texture", actual_entry.file):read():len()
			local report_row = {
				count = 1,
				unit_names = getFilename(unit:name():t()),
				tex_type = actual_entry._meta,
				file = actual_entry.file,
				file_size = file_size
			}

			for i, e in ipairs(CoreTextureReport.TEXTURE_CACHE_REPORT_FIELDS) do
				report_row[e] = report_row[e] or ""
			end

			report[filename] = report_row
		end
	end

	print("Defined local funcs")
	print("Preparing texture cache report")

	local report = {}
	local texture_cache_report = {}
	local texture_cache_report_raw = TextureCache:report()

	for line = 0, #texture_cache_report_raw / 6 - 1 do
		local current_texture = getFilename(texture_cache_report_raw[line * 6 + 1])

		if current_texture ~= "Total memory usage" and current_texture ~= "Texture Name" then
			texture_cache_report[current_texture] = {
				texture_name_from_cache = current_texture
			}

			for column = 2, 6 do
				local try_number = tonumber(texture_cache_report_raw[line * 6 + column]) or texture_cache_report_raw[line * 6 + column]
				texture_cache_report[current_texture][CoreTextureReport.TEXTURE_CACHE_REPORT_FIELDS[column]] = try_number
			end
		end
	end

	print("Prepared texture cache report")
	print("Preparing textures from units report")

	for continent, layers in pairs(CoreTextureReport:_get_all_units_by_layer()) do
		print("Going over continent: ", continent)

		for layer_name, layer_table in pairs(layers) do
			print("Going over layer: ", layer_name)

			for unit_i, unit in pairs(layer_table) do
				local unit_material_config = ScriptSerializer:from_custom_xml(DB:open("material_config", unit:material_config()):read())

				for key, material_entry in pairs(unit_material_config) do
					if type(material_entry) == "table" then
						for key_meta, material_file_entry in pairs(material_entry) do
							if type(key_meta) == "number" and material_file_entry.file then
								add_file_to_report(unit, material_file_entry, report)
							end
						end
					end
				end
			end
		end
	end

	print("Prepared textures from units report")
	print("Merging")

	for k, texture_meta in pairs(report) do
		for i, report_element in pairs(texture_cache_report) do
			if report[k] and i == k then
				for cache_property_index, cache_property in pairs(report_element) do
					print("Merge", k, i, inspect(cache_property))

					report[k][cache_property_index] = cache_property
				end
			end
		end

		print("Merged", inspect(report[k]))
	end

	print("Prepared Report")

	return report
end

function CoreTextureReport:start_dialog()
	print("Starting dialog")

	local top_sizer = EWS:BoxSizer("VERTICAL")
	self._main_frame = EWS:Frame(CoreTextureReport.EDITOR_TITLE, Vector3(-1, -1, -1), Vector3(1733.3333333333333, 1300, -1), "DEFAULT_FRAME_STYLE,FRAME_FLOAT_ON_PARENT,MAXIMIZE", Global.frame)

	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")
	self._main_frame:set_sizer(top_sizer)

	self._top_bar = self:create_top_bar(self._main_frame)
	self._status_bar = EWS:StatusBar(self._main_frame, "", "")

	self._status_bar:set_fields(CoreTextureReport.GET_WIDTH_ARRAY())
	self._main_frame:set_status_bar(self._status_bar)
	self._status_bar:set_status_text(CoreTextureReport.STATUSBARFIELDS[1].on_updating(), 0)
	self._status_bar:set_visible(true)

	self._list = EWS:ListCtrl(self._main_frame, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._list:fit_inside(self._main_frame)
	self._list:connect("EVT_COMMAND_LIST_COL_CLICK", callback(self, self, "column_click_list"), nil)
	top_sizer:add(self._list, 1, 1, "EXPAND")
	self._main_frame:center("BOTH")
	self._main_frame:set_visible(true)
	self._main_frame:update()
	print("Created dialog")
end

function CoreTextureReport:create_top_bar(parent)
	local file_menu = EWS:Menu("")

	file_menu:append_item("RELOAD", "Reload Data", "")
	file_menu:append_item("COPY", "Copy Data to Clipboard", "")

	local menu_bar = EWS:MenuBar()

	menu_bar:append(file_menu, "Data Handling")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("RELOAD", "EVT_COMMAND_MENU_SELECTED", CoreEvent.callback(self, self, "reload_data"), "")
	self._main_frame:connect("COPY", "EVT_COMMAND_MENU_SELECTED", CoreEvent.callback(self, self, "copy_rows"), "")

	return menu_bar
end

function CoreTextureReport:on_close()
	managers.toolhub:close(CoreTextureReport.EDITOR_TITLE)
end

function CoreTextureReport:reload_data()
	local report = CoreTextureReport:_get_all_textures()

	self:draw_table(report)
end

function CoreTextureReport:find_column(key)
	for i, meta in pairs(self._column_states) do
		if meta.column_name == key then
			return i - 1
		end
	end
end

function CoreTextureReport:draw_table(report_data)
	print("Drawing table")
	self._list:clear_all()
	self._list:freeze()

	for i, status_bar_meta in pairs(CoreTextureReport.STATUSBARFIELDS) do
		local status_text = status_bar_meta.on_updating(report_data)

		print("Status: " .. status_text)
		self._status_bar:set_status_text(status_text, i - 1)
	end

	self._status_bar:update()

	self._column_states = {}

	for meta_key, element in pairs(report_data) do
		self._list:append_column(CoreTextureReport.ORDER_META_NAME)
		table.insert(self._column_states, {
			state = "random",
			column_name = CoreTextureReport.ORDER_META_NAME,
			value = CoreTextureReport.ORDER_META_NAME
		})

		for key, _ in pairs(element) do
			local state = tostring(key) == CoreTextureReport.DEFAULT_ORDER_FIELD_NAME and "ascending" or "random"

			table.insert(self._column_states, {
				column_name = tostring(key),
				state = state,
				value = tostring(key)
			})
			self._list:append_column(tostring(key))
		end

		break
	end

	print("Columns", inspect(self._column_states))

	for texture_key, texture in pairs(report_data) do
		local i = self._list:append_item(texture_key)

		for param_name, texture_meta in pairs(texture) do
			self._list:set_item(i, self:find_column(tostring(param_name)), texture_meta)
		end

		local new_t = deep_clone(texture)
		new_t[CoreTextureReport.ORDER_META_NAME] = texture_key
		new_t.name = tostring(texture_key)

		self._list:set_item_data_ref(i, new_t)
	end

	self._main_frame:layout()

	for i = 0, self._list:column_count() - 1 do
		self._list:autosize_column(i)
	end

	for i, status_bar_meta in pairs(CoreTextureReport.STATUSBARFIELDS) do
		local status_text = status_bar_meta.on_ready(report_data)

		print("Status: " .. status_text)
		self._status_bar:set_status_text(status_text, i - 1)
	end

	self._status_bar:update()
	self._list:sort(function (item1, item2)
		return CoreTextureReport.ASCENDING_ORDER(CoreTextureReport.DEFAULT_ORDER_FIELD_NAME, item1, item2)
	end)
	self._list:thaw()
	self._list:set_visible(true)
	print("Drawed table")
end

function CoreTextureReport:copy_rows(data, event)
	local rval = ""

	for i = 0, self._list:item_count() - 1 do
		local data = self._list:get_item_data(i)

		if data then
			for i, meta in pairs(data) do
				rval = rval .. tostring(meta) .. CoreTextureReport.SEPARATOR
			end

			rval = rval .. "\n"
		end
	end

	Application:set_clipboard(rval)

	return rval
end

function CoreTextureReport:column_click_list(data, event)
	local column = event:get_column() + 1
	local value = self._column_states[column].value
	local state = self._column_states[column].state

	print(column, value, state)

	for name, s in pairs(self._column_states) do
		s = "random"
	end

	if state == "ascending" then
		state = "descending"
	else
		state = "ascending"
	end

	self._column_states[column].state = state

	local function ascending(item1, item2)
		return CoreTextureReport.ASCENDING_ORDER(value, item1, item2)
	end

	local function descending(item1, item2)
		return CoreTextureReport.DESCENDING_ORDER(value, item1, item2)
	end

	self._list:sort(state == "ascending" and ascending or descending)
end
