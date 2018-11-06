require("lib/states/GameState")

EditorState = EditorState or class(GameState)

function EditorState:init(game_state_machine)
	GameState.init(self, "editor", game_state_machine)
end

function EditorState:at_enter()
	cat_print("game_state_machine", "GAME STATE EditorState ENTER")
end

function EditorState:at_exit()
	cat_print("game_state_machine", "GAME STATE EditorState ENTER")
end
