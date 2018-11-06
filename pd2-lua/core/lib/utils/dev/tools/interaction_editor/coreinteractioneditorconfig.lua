core:module("CoreInteractionEditorConfig")
core:import("CoreEws")

EDITOR_TITLE = "Interaction Manager"
NEW_ICON = CoreEws.image_path("toolbar/new_16x16.png")
OPEN_ICON = CoreEws.image_path("toolbar/open_16x16.png")
SAVE_ICON = CoreEws.image_path("toolbar/save_16x16.png")
SAVE_ALL_ICON = CoreEws.image_path("toolbar/save_all_16x16.png")
CLOSE_ICON = CoreEws.image_path("toolbar/delete_16x16.png")
NODE_COLORS = {
	Color(243, 243, 243),
	Color(102, 255, 172),
	Color(255, 185, 102),
	Color(200, 100, 100),
	Color(255, 136, 102),
	Color(100, 200, 200),
	Color(36, 120, 166),
	Color(33, 166, 95)
}
DEFAULT_NODE_COLOR = NODE_COLORS[1]
NODE_TYPES = {
	"undefined",
	"event",
	"boolean",
	"color",
	"number",
	"references",
	"string",
	"vector"
}
