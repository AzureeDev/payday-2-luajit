require("core/lib/utils/dev/editor/WorldHolder")
core:module("CoreGameStateLoadingGame")
core:import("CoreGameStateInGame")

LoadingGame = LoadingGame or class()

function LoadingGame:init()
	self._debug_time = self.game_state._session_manager:_debug_time()

	for _, unit in ipairs(World:find_units_quick("all")) do
		unit:set_slot(0)
	end

	local session_info = self.game_state._session_manager:session():session_info()
	local factory = self.game_state._session_manager._factory
	local level_name = session_info:level_name()
	local stage_name = session_info:stage_name() or "stage1"
	local level = Level:load(level_name)

	level:create("dynamics", "statics")
	managers.mission:parse(level_name, stage_name, nil, "mission")

	self._level_handler = factory:create_level_handler()

	self._level_handler:set_player_slots(self.game_state:player_slots())
	self.game_state:player_slots():enter_level_handler(self._level_handler)

	local local_user_manager = self.game_state._session_manager._local_user_manager

	local_user_manager:enter_level_handler(self._level_handler)
end

function LoadingGame:destroy()
end

function LoadingGame:transition()
	local current_time = self.game_state._session_manager:_debug_time()

	if current_time > self._debug_time + 2 then
		return CoreGameStateInGame.InGame, self._level_handler
	end
end
