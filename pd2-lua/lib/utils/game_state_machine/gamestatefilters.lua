GameStateFilters = {
	any_ingame = {
		ingame_incapacitated = true,
		ingame_bleed_out = true,
		ingame_clean = true,
		ingame_standard = true,
		ingame_waiting_for_respawn = true,
		ingame_waiting_for_spawn_allowed = true,
		ingame_electrified = true,
		ingame_fatal = true,
		ingame_mask_off = true,
		ingame_access_camera = true,
		ingame_driving = true,
		ingame_waiting_for_players = true,
		ingame_parachuting = true,
		ingame_arrested = true,
		ingame_civilian = true,
		ingame_freefall = true
	},
	any_ingame_playing = {
		ingame_incapacitated = true,
		ingame_bleed_out = true,
		ingame_clean = true,
		ingame_standard = true,
		ingame_waiting_for_respawn = true,
		ingame_waiting_for_spawn_allowed = true,
		ingame_electrified = true,
		ingame_fatal = true,
		ingame_mask_off = true,
		ingame_access_camera = true,
		ingame_driving = true,
		ingame_parachuting = true,
		ingame_freefall = true,
		ingame_arrested = true,
		ingame_civilian = true
	},
	downed = {
		ingame_incapacitated = true,
		ingame_bleed_out = true,
		ingame_fatal = true
	},
	need_revive = {
		ingame_incapacitated = true,
		ingame_arrested = true,
		ingame_bleed_out = true,
		ingame_fatal = true
	},
	arrested = {
		ingame_arrested = true
	},
	game_over = {
		gameoverscreen = true
	},
	any_end_game = {
		victoryscreen = true,
		gameoverscreen = true
	},
	waiting_for_players = {
		ingame_waiting_for_players = true
	},
	waiting_for_respawn = {
		ingame_waiting_for_respawn = true
	},
	waiting_for_spawn_allowed = {
		ingame_waiting_for_spawn_allowed = true
	},
	menu = {
		menu_main = true
	},
	player_slot = {
		ingame_lobby_menu = true,
		menu_main = true,
		ingame_waiting_for_players = true
	},
	lobby = {
		menu_main = true,
		ingame_lobby_menu = true
	}
}
