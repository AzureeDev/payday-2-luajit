TestAPI = TestAPI or class()
Global.test_api = Global.test_api or {}
Global.test_api.commands = Global.test_api.commands or {}
local print = make_tag_print("TestAPI")
TestAPIHelper = TestAPIHelper or class()

function TestAPIHelper.on_event(id)
	if Global.test_api["response_string_" .. id] then
		print(tostring(Global.test_api["response_string_" .. id]))

		Global.test_api["response_string_" .. id] = nil

		if Global.test_api["callback_" .. id] then
			Global.test_api["callback_" .. id]()

			Global.test_api["callback_" .. id] = nil
		end

		TestAPIHelper.call_next()
	end
end

function TestAPIHelper.register_event(id, string)
	Global.test_api["response_string_" .. id] = string
end

function TestAPIHelper.register_event_callback(id, clbk)
	Global.test_api["callback_" .. id] = clbk
end

local function parse_to_var(str)
	if type(str) ~= "string" then
		return str
	end

	local ret = tonumber(str)

	if not ret then
		local low_str = string.lower(str)

		if low_str == "true" then
			ret = true
		elseif low_str == "false" then
			ret = false
		end
	end

	if ret == nil then
		ret = str
	end

	return ret
end

function TestAPIHelper.register_API_function(name, category, args_str, func, desc, async)
	local args = {}

	if args_str then
		for _, arg in ipairs(string.split(args_str, ",%s*")) do
			local name, default = string.match(arg, "([A-Za-z_][A-Za-z0-9_]*)%s*=%s*([A-Za-z0-9_]*)")
			name = name or arg

			table.insert(args, {
				name = name,
				default = parse_to_var(default)
			})
		end
	end

	if not TestAPI[category] then
		TestAPI[category] = {}
	end

	TestAPI[category][name] = function (response_string, arg_tbl)
		TestAPIHelper.register_event(name, response_string)

		local ret = {}

		if #args > 0 then
			for _, arg_data in ipairs(args) do
				arg_tbl[arg_data.name] = arg_tbl[arg_data.name] or arg_data.default

				assert(arg_tbl[arg_data.name], string.format("Missing required argument: %s", arg_data.name))
			end

			local locals = {}
			local old_mt = getmetatable(_G)
			local _old__index = old_mt.__index
			local new_mt = deep_clone(old_mt)
			locals.__index = _old__index
			new_mt.__index = locals

			setmetatable(_G, new_mt)

			for arg_name, arg_val in pairs(arg_tbl) do
				locals[arg_name] = arg_val
			end

			ret = {
				func()
			}

			setmetatable(_G, old_mt)
		else
			ret = {
				func()
			}
		end

		if not async then
			TestAPIHelper.on_event(name)
		end

		return unpack(ret)
	end

	Global.test_api.commands = Global.test_api.commands or {}
	Global.test_api.commands[category] = Global.test_api.commands[category] or {}
	Global.test_api.commands[category][name] = {
		desc = desc,
		args = string.len(args_str) > 0 and args_str
	}
end

function TestAPIHelper.queue_call(category_and_or_func_name, response_string, args)
	local cat_func = string.split(category_and_or_func_name, "%.")
	local category = cat_func[1]
	local func_name = cat_func[2]
	Global.test_api.queued_calls = Global.test_api.queued_calls or {}

	assert(TestAPI[category], string.format("Missing category in TestAPI: %s", tostring(category)))
	assert(TestAPI[category][func_name], string.format("Missing function in TestAPI: %s", tostring(func_name)))
	table.insert(Global.test_api.queued_calls, {
		category = category,
		func_name = func_name,
		response_string = response_string,
		args = args
	})
end

function TestAPIHelper.call_next()
	if Global.test_api.queued_calls and #Global.test_api.queued_calls > 0 then
		local call = table.remove(Global.test_api.queued_calls, 1)

		assert(TestAPI[call.category], string.format("Missing category in TestAPI: %s", tostring(call.category)))
		assert(TestAPI[call.category][call.func_name], string.format("Missing function in TestAPI: %s", tostring(call.func_name)))
		TestAPI[call.category][call.func_name](call.response_string, call.args)
	end
end

function TestAPIHelper.update(t, dt)
	if Global.test_api.delayed_callbacks then
		for _, delayed in ipairs(Global.test_api.delayed_callbacks) do
			if delayed.t < t and delayed.callback then
				delayed.callback()
			end
		end
	end
end

Global.test_api.commands = Global.test_api.commands or {}
Global.test_api.commands.internal = Global.test_api.commands.internal or {}
Global.test_api.commands.internal.setup_call_queue = {
	args = "command_table as {{\"category.function\", \"ID\", {args}}, etc..}",
	desc = "Sets up an internal call queue for quick, in-game testing"
}

function TestAPI.setup_call_queue(call_queue)
	for _, call in ipairs(call_queue) do
		TestAPIHelper.queue_call(unpack(call))
	end

	TestAPIHelper.call_next()
end

local function get_max_padding_from_table_keys(tbl)
	local padding = 0

	for k in pairs(tbl) do
		padding = math.max(padding, string.len(k))
	end

	return padding + 1
end

local function get_max_padding_from_table(tbl, func)
	local padding = 0

	for _, v in pairs(tbl) do
		padding = math.max(padding, string.len(func(v)))
	end

	return padding + 1
end

local function center(text, w, delimeter)
	delimeter = delimeter or " "
	local mid = w / 2
	local offset = math.ceil(string.len(text) / 2)
	local ret = string.rep(delimeter, mid - offset - 1) .. " " .. text

	return ret .. " " .. string.rep(delimeter, w - string.len(ret) - 1)
end

function TestAPI.help()
	local padding = 0
	local arg_padding = 0

	for key, cmds in pairs(Global.test_api.commands) do
		padding = math.max(padding, get_max_padding_from_table_keys(cmds))
		arg_padding = math.max(arg_padding, get_max_padding_from_table(cmds, function (v)
			return v.desc
		end))
	end

	local first = true

	for key, cmds in sort_iterator(Global.test_api.commands) do
		if not first then
			print("")
		end

		first = nil

		print(center(key, padding, "-"))

		for name, data in sort_iterator(cmds) do
			print(name .. ":" .. string.rep(" ", padding - string.len(name)) .. data.desc .. string.rep(" ", arg_padding - string.len(data.desc)) .. (data.args and "Args: " .. data.args or ""))
		end

		print(string.rep("-", padding))
	end
end

TestAPIHelper.register_API_function("get_jobs", "jobs", "", function ()
	local jobs = {}

	for _, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_data = tweak_data.narrative:job_data(job_id)
		local stages = #job_data.chain

		table.insert(jobs, {
			job = job_id,
			stages = stages
		})
	end

	return {
		jobs = jobs
	}
end, "Returns a table with all available jobs.")

local function start(job_id, difficulty, stage)
	assert(not not tweak_data.narrative.jobs[job_id], string.format("invalid job: %s", job_id))

	if managers.job:current_job_id() == job_id and managers.job:current_stage() == stage and Global.game_settings.difficulty == difficulty then
		return false
	end

	Global.game_settings.single_player = true

	managers.network:host_game()
	Network:set_server()
	managers.job:activate_job(job_id)

	if stage > 1 then
		managers.job:set_current_stage(stage)
	end

	Global.game_settings.level_id = managers.job:current_level_id()
	Global.game_settings.mission = managers.job:current_mission()
	Global.game_settings.world_setting = managers.job:current_world_setting()
	Global.game_settings.difficulty = difficulty
	local level_name = tweak_data.levels[Global.game_settings.level_id].world_name
	local mission = Global.game_settings.mission ~= "none" and Global.game_settings.mission or nil

	managers.network:session():load_level(level_name, mission, Global.game_settings.world_setting, nil, Global.game_settings.level_id)

	return true
end

TestAPIHelper.register_API_function("start_job", "jobs", "job_id, difficulty = normal, stage = 1", function ()
	Global.exe_argument_auto_enter_level = true

	if not start(job_id, difficulty, stage) then
		TestAPIHelper.on_event("start_job")
	end
end, "Starts the given job and skips the loadout screen.", true)
TestAPIHelper.register_API_function("start_job_loadout", "jobs", "job_id, difficulty = normal, stage = 1", function ()
	Global.exe_argument_auto_enter_level = false

	if not start(job_id, difficulty, stage) then
		TestAPIHelper.on_event("start_job_loadout")
	end
end, "Starts the given job.", true)
TestAPIHelper.register_API_function("finish_job", "jobs", "", function ()
	if managers.platform:presence() == "Playing" then
		local num_winners = managers.network:session():amount_of_alive_players()

		managers.network:session():send_to_peers("mission_ended", true, num_winners)
		game_state_machine:change_state_by_name("victoryscreen", {
			num_winners = num_winners,
			personal_win = alive(managers.player:player_unit())
		})
	end
end, "Finishes the current job.")
TestAPIHelper.register_API_function("close_loadout_screen", "menu", "", function ()
	game_state_machine:current_state():start_game_intro()
end, "Closes the loadout screen.")
TestAPIHelper.register_API_function("delay", "internal", "time = 1", function ()
	Global.test_api.delayed_callbacks = Global.test_api.delayed_callbacks or {}
	local delayed = {
		t = TimerManager:main():time() + time,
		callback = function ()
			TestAPIHelper.on_event("delay")
		end
	}

	table.insert(Global.test_api.delayed_callbacks, delayed)
end, "Delays queued calls by the given time (seconds).", true)

local function equip_weapon_in_game(category, slot)
	assert(category == "primaries" or category == "secondaries", string.format("invalid category: %s", category))
	assert(slot and slot <= #Global.blackmarket_manager.crafted_items[category], string.format("invalid slot: %d", slot))

	local primary = category == "primaries"
	local first_time = true

	local function clbk()
		if first_time then
			managers.blackmarket:equip_weapon(category, slot)

			first_time = false
		end

		if not managers.network:session():local_peer():is_outfit_loaded() then
			return false
		end

		local weapon = Global.blackmarket_manager.crafted_items[category][slot]
		local texture_switches = managers.blackmarket:get_weapon_texture_switches(category, slot, weapon)

		managers.player:player_unit():inventory():add_unit_by_factory_name(weapon.factory_id, true, false, weapon.blueprint, weapon.cosmetics, texture_switches)

		return true
	end

	local factory_weapon = tweak_data.weapon.factory[Global.blackmarket_manager.crafted_items[category][slot].factory_id]
	local ids_unit_name = Idstring(factory_weapon.unit)

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
	end

	managers.player:player_unit():movement():current_state():_start_action_unequip_weapon(TimerManager:game():time(), {
		selection_wanted = primary and 2 or 1,
		unequip_callback = clbk
	})
end

TestAPIHelper.register_API_function("load_weapon", "ingame", "weapon_id", function ()
	local weapon_tweak = tweak_data.weapon[weapon_id]

	assert(weapon_tweak and weapon_tweak.use_data, string.format("Invalid weapon: %s", tostring(weapon_id)))

	if weapon_tweak.use_data.selection_index > 2 then
		TestAPIHelper.on_event("load_weapon")

		return
	end

	local category = weapon_tweak.use_data.selection_index == 1 and "secondaries" or "primaries"
	local slot = 1

	while Global.blackmarket_manager.crafted_items[category][slot] do
		slot = slot + 1
	end

	managers.blackmarket:craft_temporary(category, weapon_id, slot)
	equip_weapon_in_game(category, slot)
	TestAPIHelper.register_event_callback("load_weapon", function ()
		managers.blackmarket:clear_temporary()
	end)
end, "Loads the given weapon while in a job and equips it.", true)
TestAPIHelper.register_API_function("exit_to_menu", "ingame", "", function ()
	if not Global.game_settings.is_playing then
		TestAPIHelper.on_event("exit_to_menu")

		return
	end

	Global.skip_menu_dialogs = true

	managers.platform:set_playing(false)
	managers.job:clear_saved_ghost_bonus()
	managers.statistics:stop_session({
		quit = true
	})
	managers.savefile:save_progress()
	managers.job:deactivate_current_job()
	managers.gage_assignment:deactivate_assignments()

	if managers.custom_safehouse then
		managers.custom_safehouse:flush_completed_trophies()
	end

	if managers.crime_spree then
		managers.crime_spree:on_left_lobby()
	end

	if Network:multiplayer() then
		Network:set_multiplayer(false)
		managers.network:session():send_to_peers("set_peer_left")
		managers.network:queue_stop_network()
	end

	managers.network.matchmake:destroy_game()
	managers.network.voice_chat:destroy_voice()
	managers.groupai:state():set_AI_enabled(false)
	setup:load_start_menu()
end, "Ends the current game and returns to menu.", true)
TestAPIHelper.register_API_function("mask_up", "ingame", "", function ()
	if managers.player:current_state() ~= "mask_off" then
		TestAPIHelper.on_event("mask_up")

		return
	end

	managers.player:set_player_state("standard")
end, "Puts on the mask if the player is in the mask off state.", true)
TestAPIHelper.register_API_function("fire", "ingame", "", function ()
	local state = alive(managers.player:player_unit()) and managers.player:player_unit():movement():current_state()

	if state then
		state:force_input({
			btn_primary_attack_state = true,
			btn_primary_attack_press = true
		}, {
			btn_primary_attack_release = true
		})
	end
end, "Fires the equipped weapon once.")
