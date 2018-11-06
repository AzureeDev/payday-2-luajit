Gamemode = Gamemode or class()
Gamemode.id = "gamemode"
Gamemode._NAME = "Base Gamemode"
Gamemode.MAP = {}
Gamemode.STATES = {
	ingame_access_camera = "ingame_access_camera",
	bootup = "bootup",
	ingame_driving = "ingame_driving",
	ingame_freefall = "ingame_freefall",
	empty = "empty",
	gameoverscreen = "gameoverscreen",
	ingame_electrified = "ingame_electrified",
	ingame_fatal = "ingame_fatal",
	victoryscreen = "victoryscreen",
	ingame_waiting_for_players = "ingame_waiting_for_players",
	world_camera = "world_camera",
	ingame_waiting_for_respawn = "ingame_waiting_for_respawn",
	server_left = "server_left",
	ingame_arrested = "ingame_arrested",
	ingame_bleed_out = "ingame_bleed_out",
	ingame_parachuting = "ingame_parachuting",
	ingame_incapacitated = "ingame_incapacitated",
	editor = "editor",
	ingame_clean = "ingame_clean",
	menu_titlescreen = "menu_titlescreen",
	disconnected = "disconnected",
	ingame_standard = "ingame_standard",
	menu_main = "menu_main",
	ingame_waiting_for_spawn_allowed = "ingame_waiting_for_spawn_allowed",
	ingame_mask_off = "ingame_mask_off",
	ingame_lobby_menu = "ingame_lobby_menu",
	kicked = "kicked",
	ingame_civilian = "ingame_civilian"
}

function Gamemode.register(id, class)
	Gamemode.MAP[id] = class
end

function Gamemode:get_state(state_name)
	if self.STATES[state_name] then
		return self.STATES[state_name]
	else
		error(string.format("Invalid state '%s' in gamemode %s", tostring(state_name), self._NAME))
	end
end

function Gamemode:setup_gsm(gsm, empty, setup_boot, setup_title)
	error("Gamemode:setup_gsm not implemented for " .. self._NAME)
end
