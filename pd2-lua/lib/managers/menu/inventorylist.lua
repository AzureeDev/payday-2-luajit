InventoryList = InventoryList or class()
local NOT_WIN_32 = SystemInfo:platform() ~= Idstring("WIN32")
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.69 or 0.75
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 7 or 6) / 8
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size

function InventoryList:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._panel = ws:panel():panel()
end

function InventoryList:close()
	self._ws:panel():remove(self._panel)
end
