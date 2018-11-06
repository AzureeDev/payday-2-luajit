core:import("CoreGameStateMachine")
require("lib/states/BootupState")
require("lib/states/MenuTitlescreenState")
require("lib/states/MenuMainState")
require("lib/states/EditorState")
require("lib/states/WorldCameraState")
require("lib/utils/game_state_machine/GameStateFilters")
require("lib/states/IngamePlayerBase")
require("lib/states/IngameStandard")
require("lib/states/IngameMaskOff")
require("lib/states/IngameBleedOut")
require("lib/states/IngameFatalState")
require("lib/states/IngameWaitingForPlayers")
require("lib/states/IngameWaitingForRespawn")
require("lib/states/IngameWaitingForSpawnAllowed")
require("lib/states/IngameArrested")
require("lib/states/IngameElectrified")
require("lib/states/IngameIncapacitated")
require("lib/states/IngameClean")
require("lib/states/IngameCivilian")
require("lib/states/MissionEndState")
require("lib/states/VictoryState")
require("lib/states/GameOverState")
require("lib/states/ServerLeftState")
require("lib/states/DisconnectedState")
require("lib/states/KickedState")
require("lib/states/IngameLobbyMenu")
require("lib/states/IngameAccessCamera")
require("lib/states/IngameDriving")
require("lib/states/IngameParachuting")
require("lib/states/IngameFreefall")
require("lib/gamemodes/Gamemode")
require("lib/gamemodes/GamemodeStandard")
require("lib/gamemodes/GamemodeCrimeSpree")

GameStateMachine = GameStateMachine or class(CoreGameStateMachine.GameStateMachine)

function GameStateMachine:init()
	if not Global.game_state_machine then
		Global.game_state_machine = {
			is_boot_intro_done = false,
			is_boot_from_sign_out = false
		}
	end

	self._is_boot_intro_done = Global.game_state_machine.is_boot_intro_done
	Global.game_state_machine.is_boot_intro_done = true
	self._is_boot_from_sign_out = Global.game_state_machine.is_boot_from_sign_out
	Global.game_state_machine.is_boot_from_sign_out = false
	local setup_boot = not self._is_boot_intro_done and not Application:editor()
	local setup_title = (setup_boot or self._is_boot_from_sign_out) and not Application:editor()
	local states = {}
	self._controller_enabled_count = 1
	local empty = GameState:new("empty", self)
	self._empty_state = empty

	CoreGameStateMachine.GameStateMachine.init(self, empty)

	local gamemode = Global.game_settings and Global.game_settings.gamemode or "standard"

	self:change_gamemode_by_name(gamemode, setup_boot, setup_title)
	managers.menu:add_active_changed_callback(callback(self, self, "menu_active_changed_callback"))
	managers.system_menu:add_active_changed_callback(callback(self, self, "dialog_active_changed_callback"))
end

function GameStateMachine:init_finilize()
	if managers.hud then
		managers.hud:add_chatinput_changed_callback(callback(self, self, "chatinput_changed_callback"))
	end
end

function GameStateMachine:set_boot_intro_done(is_boot_intro_done)
	Global.game_state_machine.is_boot_intro_done = is_boot_intro_done
	self._is_boot_intro_done = is_boot_intro_done
end

function GameStateMachine:is_boot_intro_done()
	return self._is_boot_intro_done
end

function GameStateMachine:set_boot_from_sign_out(is_boot_from_sign_out)
	Global.game_state_machine.is_boot_from_sign_out = is_boot_from_sign_out
end

function GameStateMachine:is_boot_from_sign_out()
	return self._is_boot_from_sign_out
end

function GameStateMachine:menu_active_changed_callback(active)
	self:_set_controller_enabled(not active)
end

function GameStateMachine:dialog_active_changed_callback(active)
	self:_set_controller_enabled(not active)
end

function GameStateMachine:chatinput_changed_callback(active)
	self:_set_controller_enabled(not active)
end

function GameStateMachine:is_controller_enabled()
	return self._controller_enabled_count > 0
end

function GameStateMachine:_set_controller_enabled(enabled)
	local was_enabled = self:is_controller_enabled()

	if enabled then
		self._controller_enabled_count = self._controller_enabled_count + 1
	else
		self._controller_enabled_count = self._controller_enabled_count - 1
	end

	if not was_enabled ~= not self:is_controller_enabled() then
		local state = self:current_state()

		if state then
			state:set_controller_enabled(enabled)
		end
	end
end

function GameStateMachine:gamemode()
	return self._gamemode
end

function GameStateMachine:change_gamemode_by_name(gamemode, setup_boot, setup_title)
	Global.game_settings.gamemode = gamemode
	local gamemode_class = Gamemode.MAP[gamemode] or GamemodeStandard
	self._gamemode = gamemode_class:new()

	self._gamemode:setup_gsm(self, self._empty_state, setup_boot, setup_title)
end

function GameStateMachine:can_change_state_by_name(state_name)
	local name = self:gamemode():get_state(state_name)
	local state = assert(self._states[name], "[GameStateMachine] Name '" .. tostring(name) .. "' does not correspond to a valid state.")

	return self:can_change_state(state)
end

function GameStateMachine:change_state_by_name(state_name, params)
	local name = self:gamemode():get_state(state_name)
	local state = assert(self._states[name], "[GameStateMachine] Name '" .. tostring(name) .. "' does not correspond to a valid state.")

	self:change_state(state, params)
end

function GameStateMachine:verify_game_state(filter, state)
	state = state or self:last_queued_state_name()

	return filter[state]
end
