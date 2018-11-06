core:import("CoreEngineAccess")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorUtil")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorProperties")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorEffect")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorInitializers")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorSimulators")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorVisualizers")
require("core/lib/utils/dev/tools/particle_editor/CoreParticleEditorPanel")

function collect_members(cls, m)
	for funcname, funcobj in pairs(cls) do
		if funcname:find("create_") then
			local fn = funcname:gsub("create_", "")
			m[fn] = funcobj
		end
	end
end

function collect_member_names(members, member_names)
	for k, v in pairs(members) do
		local vi = v()

		table.insert(member_names, {
			ui_name = vi:ui_name(),
			key = k
		})
	end

	table.sort(member_names, function (a, b)
		return a.ui_name < b.ui_name
	end)
end

stack_members = {
	initializer = {},
	simulator = {},
	visualizer = {}
}
stack_member_names = {
	initializer = {},
	simulator = {},
	visualizer = {}
}

collect_members(CoreParticleEditorInitializers, stack_members.initializer)
collect_members(CoreParticleEditorSimulators, stack_members.simulator)
collect_members(CoreParticleEditorVisualizers, stack_members.visualizer)
collect_member_names(stack_members.initializer, stack_member_names.initializer)
collect_member_names(stack_members.simulator, stack_member_names.simulator)
collect_member_names(stack_members.visualizer, stack_member_names.visualizer)

CoreParticleEditor = CoreParticleEditor or class()

function CoreParticleEditor:init()
	if managers.editor then
		managers.editor:set_listener_enabled(true)
	end

	self._gizmo_movement = "NO_MOVE"
	self._gizmo_accum = 0
	self._gizmo_anchor = Vector3(0, 300, 100)
	self._effects = {}

	self:create_main_frame()
	self._main_frame:update()
	self:start_dialog()
	CoreEWS.check_news(self._main_frame, "particle_editor", true)
end

function CoreParticleEditor:start_dialog()
	local dialog = EWS:Dialog(self._main_frame, "Tsar Bomba Particle Editor : Choose...", "", Vector3(-1, -1, 0), Vector3(400, 400, 0), "DEFAULT_DIALOG_STYLE")

	local function on_new(dialog)
		dialog:end_modal("NEW")
	end

	local function on_empty_new(dialog)
		dialog:end_modal("EMPTY_NEW")
	end

	local function on_load(dialog)
		dialog:end_modal("LOAD")
	end

	local new_empty_button = EWS:Button(dialog, "New Empty Effect", "", "BU_EXACTFIT")

	new_empty_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_empty_new, dialog)

	local new_button = EWS:Button(dialog, "New Effect...", "", "BU_EXACTFIT")

	new_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_new, dialog)

	local load_button = EWS:Button(dialog, "Open Effect...", "", "BU_EXACTFIT")

	load_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_load, dialog)

	local top_sizer = EWS:BoxSizer("VERTICAL")

	top_sizer:add(new_empty_button, 0, 4, "ALL,ALIGN_CENTER_HORIZONTAL")
	top_sizer:add(new_button, 0, 4, "ALL,ALIGN_CENTER_HORIZONTAL")
	top_sizer:add(load_button, 0, 4, "ALL,ALIGN_CENTER_HORIZONTAL")
	dialog:set_sizer(top_sizer)
	dialog:fit()
	dialog:center("BOTH")

	local ret = dialog:show_modal()

	if ret == "ID_CANCEL" then
		managers.toolhub:close("Particle Editor")
	elseif ret == "NEW" then
		self:on_new()
	elseif ret == "EMPTY_NEW" then
		self:add_effect(CoreEffectDefinition:new())
	elseif ret == "LOAD" then
		self:on_open()
	else
		managers.toolhub:close("Particle Editor")
	end
end

function CoreParticleEditor:new_dialog()
	local dialog = EWS:Dialog(self._main_frame, "Create New Effect", "", Vector3(-1, -1, 0), Vector3(300, 400, 0), "DEFAULT_DIALOG_STYLE")

	local function on_new(dialog)
		dialog:end_modal("NEW")
	end

	local function on_create(dialog)
		dialog:end_modal("CREATE")
	end

	local function on_select_type(combo_desc)
		local combo = combo_desc.combo
		local desc_ctrl = combo_desc.desc
		local desc = ""

		desc_ctrl:set_value(desc)
	end

	local type_combo = EWS:ComboBox(dialog, "", "", "CB_DROPDOWN,CB_READONLY")
	local description_text = EWS:StaticText(dialog, "", "", "ST_NO_AUTORESIZE")

	type_combo:connect("EVT_COMMAND_TEXT_UPDATED", on_select_type, {
		combo = type_combo,
		desc = description_text
	})

	for _, name in ipairs(managers.database:list_entries_of_type("template_effect")) do
		type_combo:append(name)
		type_combo:set_value(name)
	end

	on_select_type({
		combo = type_combo,
		desc = description_text
	})

	local create_button = EWS:Button(dialog, "Create", "", "BU_EXACTFIT")

	create_button:connect("EVT_COMMAND_BUTTON_CLICKED", on_create, dialog)

	local top_sizer = EWS:BoxSizer("VERTICAL")

	top_sizer:add(type_combo, 0, 4, "ALL,EXPAND")
	top_sizer:add(description_text, 1, 4, "ALL,ALIGN_CENTER_HORIZONTAL,EXPAND")
	top_sizer:add(create_button, 0, 4, "ALL,EXPAND")
	dialog:set_sizer(top_sizer)

	local ret = dialog:show_modal()

	if ret == "ID_CANCEL" then
		-- Nothing
	elseif ret == "CREATE" then
		local t = type_combo:get_value()
		local effect = CoreEffectDefinition:new("")

		effect:load(DB:load_node("template_effect", t))
		self:add_effect(effect)
	end
end

function CoreParticleEditor:create_main_frame()
	self._main_frame = EWS:Frame("Tsar Bomba Particle Editor", Vector3(-1, -1, -1), Vector3(1000, 800, -1), "DEFAULT_FRAME_STYLE,FRAME_FLOAT_ON_PARENT", Global.frame)
	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("NEW", "New effect...", "")
	file_menu:append_item("OPEN", "Open effect...", "")
	file_menu:append_item("SAVE", "Save\tctrl-s", "")
	file_menu:append_item("SAVE_AS", "Save As...", "")
	file_menu:append_item("CLOSE_EFFECT", "Close", "")
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	local edit_menu = EWS:Menu("")

	edit_menu:append_item("UNDO", "Undo\tCtrl-Z")
	edit_menu:append_item("REDO", "Redo\tCtrl-Y")
	menu_bar:append(edit_menu, "Edit")

	local effect_menu = EWS:Menu("")

	effect_menu:append_item("PLAY", "Play\tF1", "")
	effect_menu:append_item("PLAY_LOW", "Play Lowest Quality Once\tF2", "")
	effect_menu:append_item("PLAY_HIGH", "Play Highest Quality Once\tF3", "")
	menu_bar:append(effect_menu, "Effect")

	local gizmo_menu = EWS:Menu("")
	self._gizmo_menu = gizmo_menu

	gizmo_menu:append_item("MOVE_TO_ORIGO", "Move Effect Gizmo To Origin")
	gizmo_menu:append_item("MOVE_TO_CAMERA", "Move Effect Gizmo In Front Of Camera")
	gizmo_menu:append_item("MOVE_TO_PLAYER", "Move Effect Gizmo To Player")
	gizmo_menu:append_separator()
	gizmo_menu:append_radio_item("PARENT_NO_MOVE", "Do Not Move Effect Gizmo")
	gizmo_menu:append_radio_item("PARENT_JUMP", "Move Effect Gizmo In Jump Pattern")
	gizmo_menu:append_radio_item("PARENT_SMOOTH", "Move Effect Gizmo In Smooth Pattern")
	gizmo_menu:append_radio_item("PARENT_CIRCLE", "Move Effect Gizmo In Circle Pattern")
	gizmo_menu:set_checked("PARENT_NO_MOVE", true)
	gizmo_menu:append_separator()
	gizmo_menu:append_item("ZERO_ROTATION", "Zero Effect Gizmo Rotation")
	gizmo_menu:append_item("SET_POSITIVE_Y", "Effect Gizmo Rotation Z To Positive Y")
	gizmo_menu:append_item("SET_NEGATIVE_Y", "Effect Gizmo Rotation Z To Negative Y")
	gizmo_menu:append_item("SET_POSITIVE_X", "Effect Gizmo Rotation Z To Positive X")
	gizmo_menu:append_item("SET_NEGATIVE_X", "Effect Gizmo Rotation Z To Negative X")
	menu_bar:append(gizmo_menu, "Effect Gizmo")

	self._view_menu = EWS:Menu("")

	self._view_menu:append_check_item("DEBUG_DRAWING", "Enable Debug Drawing (atom bounding volumes etc.)", "")
	self._view_menu:append_check_item("EFFECT_STATS", "Performance And Analysis Stats", "")
	self._view_menu:append_separator()
	self._view_menu:append_check_item("SHOW_STACK_OVERVIEW", "Show a graph of all operation stacks and channel reads/writes", "")
	menu_bar:append(self._view_menu, "View")

	local batch_menu = EWS:Menu("")

	batch_menu:append_item("BATCH_ALL_REMOVE_UPDATE_RENDER", "Batch all effects, remove update_render policy for effects not screen aligned")
	batch_menu:append_item("BATCH_ALL_LOAD_UNLOAD", "Load and unload all effects")
	menu_bar:append(batch_menu, "Batch")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("NEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_new"), "")
	self._main_frame:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open"), "")
	self._main_frame:connect("SAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save"), "")
	self._main_frame:connect("SAVE_AS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save_as"), "")
	self._main_frame:connect("CLOSE_EFFECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close_effect"), "")
	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")
	self._main_frame:connect("UNDO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_undo"), "")
	self._main_frame:connect("REDO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_redo"), "")
	self._main_frame:connect("PLAY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_play"), "")
	self._main_frame:connect("PLAY_LOW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_play_lowest"), "")
	self._main_frame:connect("PLAY_HIGH", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_play_highest"), "")
	self._main_frame:connect("MOVE_TO_ORIGO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_move_gizmo_to_origo"), "")
	self._main_frame:connect("MOVE_TO_CAMERA", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_move_gizmo_to_camera"), "")
	self._main_frame:connect("MOVE_TO_PLAYER", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_move_gizmo_to_player"), "")
	self._main_frame:connect("ZERO_ROTATION", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reset_gizmo_rotation"), "")
	self._main_frame:connect("SET_POSITIVE_Y", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_gizmo_rotation"), Rotation(Vector3(1, 0, 0), -90))
	self._main_frame:connect("SET_NEGATIVE_Y", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_gizmo_rotation"), Rotation(Vector3(1, 0, 0), 90))
	self._main_frame:connect("SET_POSITIVE_X", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_gizmo_rotation"), Rotation(Vector3(0, 1, 0), 90))
	self._main_frame:connect("SET_NEGATIVE_X", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_gizmo_rotation"), Rotation(Vector3(0, 1, 0), -90))
	self._main_frame:connect("PARENT_NO_MOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_automove_gizmo_no_move"), "")
	self._main_frame:connect("PARENT_JUMP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_automove_gizmo_jump"), "")
	self._main_frame:connect("PARENT_SMOOTH", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_automove_gizmo_smooth"), "")
	self._main_frame:connect("PARENT_CIRCLE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_automove_gizmo_circle"), "")
	self._main_frame:connect("DEBUG_DRAWING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_debug_draw"), "")
	self._main_frame:connect("EFFECT_STATS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_effect_stats"), "")
	self._main_frame:connect("SHOW_STACK_OVERVIEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_show_stack_overview"), "")
	self._main_frame:connect("BATCH_ALL_REMOVE_UPDATE_RENDER", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_batch_all_remove_update_render"), "")
	self._main_frame:connect("BATCH_ALL_LOAD_UNLOAD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_batch_all_load_unload"), "")

	local top_panel = self:create_top_bar(self._main_frame)
	self._effects_notebook = EWS:Notebook(self._main_frame, "EFFECTS_NOTEBOOK", "")

	self._effects_notebook:connect("EVT_COMMAND_NOTEBOOK_PAGE_CHANGED", callback(self, self, "on_effect_changed"), "")

	local top_sizer = EWS:BoxSizer("VERTICAL")

	top_sizer:add(top_panel, 0, 0, "EXPAND")
	top_sizer:add(self._effects_notebook, 1, 0, "EXPAND")
	self._main_frame:set_sizer(top_sizer)
	self._main_frame:center("BOTH")
	self._main_frame:set_visible(true)
end

function CoreParticleEditor:on_undo()
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:undo()
	end
end

function CoreParticleEditor:on_batch_all_remove_update_render()
	local ret = EWS:message_box(self._main_frame, "You are about to batch all effects of project database and remove update_render\nfor atoms that do not have a visualizer with screen_aligned set.\nAre you sure you want to continue?", "Are you sure you wish to continue?", "YES_NO", Vector3(-1, -1, 0))

	if ret ~= "YES" then
		return false
	end

	local any_saved = false

	for _, name in ipairs(managers.database:list_entries_of_type("effect")) do
		local n = DB:load_node("effect", name)
		local effect = CoreEffectDefinition:new()

		effect:load(n)

		local should_save = false

		for _, atom in ipairs(effect._atoms) do
			local cull_policy = atom:get_property("cull_policy")

			if cull_policy._value == "update_render" then
				local had_screen_aligned = false

				for _, visualizer in ipairs(atom._stacks.visualizer._stack) do
					if visualizer:name() == "billboard" and visualizer:get_property("billboard_type")._value == "screen_aligned" then
						had_screen_aligned = true
					end
				end

				if not had_screen_aligned then
					cull_policy._value = "freeze"
					should_save = true
				end
			end
		end

		if should_save then
			Application:error("FIXME: CoreParticleEditor:on_batch_all_remove_update_render(), (using Database:save_node())")
		end
	end

	if any_saved then
		cat_debug("debug", "Saved entries, saving database...")
	else
		cat_debug("debug", "Nothing modified, not saving database")
	end
end

function CoreParticleEditor:on_batch_all_load_unload()
	local ret = EWS:message_box(self._main_frame, "You are about to batch all effects of project database and load and unload them.\nAre you sure you want to continue?", "Are you sure you wish to continue?", "YES_NO", Vector3(-1, -1, 0))

	if ret ~= "YES" then
		return false
	end

	cat_debug("debug", "Loading all effects once...")

	for _, name in ipairs(managers.database:list_entries_of_type("effect")) do
		local n = DB:load_node("effect", name)
		local effect = CoreEffectDefinition:new()

		effect:load(n)

		local valid = effect:validate()

		if not valid.valid then
			cat_debug("debug", "Skipping engine load of", name, " since validation failed:", valid.message)
		else
			cat_debug("debug", "Loading", name)
			CoreEngineAccess._editor_reload_node(n, Idstring("effect"), Idstring("unique_test_effect_name"))
		end
	end

	cat_debug("debug", "Done!")
end

function CoreParticleEditor:on_redo()
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:redo()
	end
end

function CoreParticleEditor:on_effect_changed(arg, event)
	if event:get_id() ~= "EFFECTS_NOTEBOOK" then
		return
	end

	local old_page = event:get_old_selection()
	local new_page = event:get_selection()

	if old_page >= 0 and old_page < #self._effects then
		local old_effect = self._effects[old_page + 1]

		old_effect:on_lose_focus()
	end

	if new_page >= 0 and new_page < #self._effects then
		local new_effect = self._effects[new_page + 1]

		new_effect:update_view(false)

		if self._view_menu:is_checked("SHOW_STACK_OVERVIEW") then
			new_effect:show_stack_overview(true)
		end
	end

	event:skip()
end

function CoreParticleEditor:on_play()
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:update_effect_instance()
	end
end

function CoreParticleEditor:on_play_lowest()
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:update_effect_instance(0)
	end
end

function CoreParticleEditor:on_play_highest()
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:update_effect_instance(1)
	end
end

function CoreParticleEditor:on_debug_draw()
	local b = "true"

	if not self._view_menu:is_checked("DEBUG_DRAWING") then
		b = "false"
	end

	Application:console_command("set show_tngeffects " .. b)
end

function CoreParticleEditor:on_effect_stats()
	Application:console_command("stats tngeffects")
end

function CoreParticleEditor:on_show_stack_overview()
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:show_stack_overview(self._view_menu:is_checked("SHOW_STACK_OVERVIEW"))
	end
end

function CoreParticleEditor:on_automove_gizmo_no_move()
	self._gizmo_menu:set_checked("PARENT_JUMP", false)
	self._gizmo_menu:set_checked("PARENT_SMOOTH", false)
	self._gizmo_menu:set_checked("PARENT_CIRCLE", false)

	self._gizmo_movement = "NO_MOVE"
end

function CoreParticleEditor:on_automove_gizmo_jump()
	self._gizmo_menu:set_checked("PARENT_NO_MOVE", false)
	self._gizmo_menu:set_checked("PARENT_SMOOTH", false)
	self._gizmo_menu:set_checked("PARENT_CIRCLE", false)

	self._gizmo_movement = "JUMP"
	self._gizmo_anchor = self:effect_gizmo():position()
	self._gizmo_accum = 0
end

function CoreParticleEditor:on_automove_gizmo_smooth()
	self._gizmo_menu:set_checked("PARENT_NO_MOVE", false)
	self._gizmo_menu:set_checked("PARENT_JUMP", false)
	self._gizmo_menu:set_checked("PARENT_CIRCLE", false)

	self._gizmo_movement = "SMOOTH"
	self._gizmo_anchor = self:effect_gizmo():position()
	self._gizmo_accum = 0
end

function CoreParticleEditor:on_automove_gizmo_circle()
	self._gizmo_menu:set_checked("PARENT_NO_MOVE", false)
	self._gizmo_menu:set_checked("PARENT_SMOOTH", false)
	self._gizmo_menu:set_checked("PARENT_JUMP", false)

	self._gizmo_movement = "CIRCLE"
	self._gizmo_anchor = self:effect_gizmo():position()
	self._gizmo_accum = 0
end

function CoreParticleEditor:on_move_gizmo_to_origo()
	local gizmo = self:effect_gizmo()

	gizmo:set_position(Vector3(0, 0, 0))
	gizmo:set_rotation(Rotation())
end

function CoreParticleEditor:on_move_gizmo_to_camera()
	local gizmo = self:effect_gizmo()
	local camera_rot = Application:last_camera_rotation()
	local camera_pos = Application:last_camera_position()

	gizmo:set_position(camera_pos + camera_rot:y() * 400)
end

function CoreParticleEditor:on_move_gizmo_to_player()
	local gizmo = self:effect_gizmo()
	local pos = gizmo:position()
	local rot = gizmo:rotation()

	gizmo:set_position(pos)
end

function CoreParticleEditor:on_set_gizmo_rotation(rot)
	local gizmo = self:effect_gizmo()

	self:effect_gizmo():set_rotation(rot)
end

function CoreParticleEditor:on_reset_gizmo_rotation()
	self:effect_gizmo():set_rotation(Rotation())
end

function CoreParticleEditor:create_top_bar(parent)
	local panel = EWS:Panel(parent, "", "")
	local play_button = EWS:Button(panel, "Play", "", "BU_EXACTFIT")

	play_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_play"))

	local play_button_low = EWS:Button(panel, "Play Lowest Quality Once", "", "BU_EXACTFIT")

	play_button_low:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_play_lowest"))

	local play_button_high = EWS:Button(panel, "Play Highest Quality Once", "", "BU_EXACTFIT")

	play_button_high:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_play_highest"))

	local top_sizer = EWS:BoxSizer("VERTICAL")
	local row_sizer = EWS:BoxSizer("HORIZONTAL")

	row_sizer:add(play_button, 0, 0, "EXPAND")
	row_sizer:add(play_button_low, 0, 40, "EXPAND,LEFT")
	row_sizer:add(play_button_high, 0, 4, "EXPAND,LEFT")
	top_sizer:add(row_sizer, 0, 3, "EXPAND,TOP,BOTTOM")

	row_sizer = EWS:BoxSizer("HORIZONTAL")

	row_sizer:add_stretch_spacer(1)
	row_sizer:add(EWS:StaticText(panel, "Click on parameters and container names for usage hints.", "", ""), 0, 0, "ALIGN_RIGHT")
	top_sizer:add(row_sizer, 0, 0, "EXPAND")
	panel:set_sizer(top_sizer)

	return panel
end

function CoreParticleEditor:effect_gizmo()
	if not self._effect_gizmo or not alive(self._effect_gizmo) then
		self._effect_gizmo = World:spawn_unit(Idstring("core/units/effect_gizmo/effect_gizmo"), Vector3(0, 300, 100), Rotation())

		if managers.editor then
			managers.editor:add_special_unit(self._effect_gizmo, "Statics")
		end
	end

	return self._effect_gizmo
end

function CoreParticleEditor:update(t, dt)
	local cur_effect = self:current_effect()

	if cur_effect then
		cur_effect:update(t, dt)
	end

	if self._gizmo_movement == "SMOOTH" then
		local gizmo = self:effect_gizmo()
		self._gizmo_accum = self._gizmo_accum + dt * 360 / 4
		local a = self._gizmo_accum
		local r = 500

		gizmo:set_position(self._gizmo_anchor + Vector3(r, 0, 0) * math.cos(a) + Vector3(0, r, 0) * math.sin(a) + Vector3(0, 0, r / 5) * math.cos(5 * a))
		gizmo:set_rotation(Rotation(Vector3(0, 0, 1), a) * Rotation(Vector3(1, 0, 0), 45 * math.cos(5 * a)) + Rotation(Vector3(1, 0, 0), -90))
	elseif self._gizmo_movement == "JUMP" then
		local gizmo = self:effect_gizmo()
		self._gizmo_accum = self._gizmo_accum + dt
		local s = math.round(self._gizmo_accum)
		s = math.fmod(s, 15)

		gizmo:set_position(self._gizmo_anchor + Vector3(100 * s, 0, 0))
	elseif self._gizmo_movement == "CIRCLE" then
		local gizmo = self:effect_gizmo()
		self._gizmo_accum = self._gizmo_accum + dt * 360 / 16
		local a = self._gizmo_accum
		local r = 500

		gizmo:set_position(self._gizmo_anchor + Vector3(r, 0, 0) * math.cos(a) + Vector3(0, r, 0) * math.sin(a))
		gizmo:set_rotation(Rotation(Vector3(0, 0, 1), a) * Rotation(Vector3(1, 0, 0), -90))
	end
end

function CoreParticleEditor:set_position(pos)
end

function CoreParticleEditor:destroy()
	if alive(self._main_frame) then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function CoreParticleEditor:close()
	self._main_frame:destroy()
end

function CoreParticleEditor:on_close_effect()
	local curi = self:current_effect_index()

	if curi > 0 then
		if not self:current_effect():close() then
			return
		end

		self._effects_notebook:delete_page(curi - 1)
		table.remove(self._effects, curi)
	end

	self:remove_gizmo()
end

function CoreParticleEditor:on_close()
	for _, e in ipairs(self._effects) do
		if not e:close() then
			return
		end
	end

	self:remove_gizmo()
	managers.toolhub:close("Particle Editor")

	if managers.editor then
		managers.editor:set_listener_enabled(false)
	end
end

function CoreParticleEditor:remove_gizmo()
	if alive(self._effect_gizmo) then
		managers.editor:remove_special_unit(self._effect_gizmo)
		World:delete_unit(self._effect_gizmo)
	end
end

function CoreParticleEditor:add_effect(effect)
	self._main_frame:freeze()

	local effect_panel = CoreParticleEditorPanel:new(self, self._effects_notebook, effect)

	table.insert(self._effects, effect_panel)

	local n = effect:name()

	if n == "" then
		n = "New Effect"
	end

	n = base_path(n)

	self._effects_notebook:add_page(effect_panel:panel(), n, true)
	effect_panel:set_init_positions()
	self._main_frame:thaw()
end

function CoreParticleEditor:current_effect()
	local i = self:current_effect_index()

	if i < 0 then
		return nil
	end

	return self._effects[i]
end

function CoreParticleEditor:current_effect_index()
	local page = self._effects_notebook:get_current_page()

	for i, e in ipairs(self._effects) do
		if e:panel() == page then
			return i
		end
	end

	return -1
end

function CoreParticleEditor:effect_for_page(page)
	for _, e in ipairs(self._effects) do
		if e:panel() == page then
			return e
		end
	end

	return nil
end

function CoreParticleEditor:set_page_name(page, name)
	local i = 0

	while i < self._effects_notebook:get_page_count() do
		if self._effects_notebook:get_page(i) == page:panel() and self._effects_notebook:get_page_text(i) ~= name then
			self._effects_notebook:set_page_text(i, name)
		end

		i = i + 1
	end
end

function CoreParticleEditor:on_new()
	self:new_dialog()
end

function CoreParticleEditor:on_open()
	local f = managers.database:open_file_dialog(self._main_frame, "*.effect", self._last_used_dir)

	if not f then
		return
	end

	self._last_used_dir = dir_name(f)
	local n = managers.database:load_node(f)
	local effect = CoreEffectDefinition:new()

	effect:load(n)
	effect:set_name(f)
	self:add_effect(effect)
end

function CoreParticleEditor:on_save()
	local cur = self:current_effect()

	if cur then
		cur:on_save()
	end
end

function CoreParticleEditor:on_save_as()
	local cur = self:current_effect()

	if cur then
		cur:on_save_as()
	end
end
