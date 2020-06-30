DLCCreator = DLCCreator or class()
DLCCreator.dlc_tweak_data = "\\lib\\tweak_data\\DLCTweakData.lua"
DLCCreator.gui_tweak_data = "\\lib\\tweak_data\\GuiTweakData.lua"
DLCCreator.lootdrop_tweak_data = "\\lib\\tweak_data\\LootDropTweakData.lua"
DLCCreator.money_tweak_data = "\\lib\\tweak_data\\MoneyTweakData.lua"
DLCCreator.dlc_manager = "\\lib\\managers\\DLCManager.lua"
DLCCreator.menu_manager = "\\lib\\managers\\MenuManager.lua"
DLCCreator.gui_textures_bundle_info = "\\guis\\gui_textures.bundle_info"
DLCCreator.gui_folder = "\\guis\\dlcs"
DLCCreator.package_folder = "\\packages\\dlcs"
DLCCreator.network_settings = "\\settings\\network.network_settings"
DLCCreator.start_menu = "\\gamedata\\menus\\start_menu.menu"
DLCCreator.string_debug_production = "\\strings\\debug_production.strings"
DLCCreator.line_identifier_start = "@$# "
DLCCreator.line_identifier_end = " #$@"

local function sformat(fmt, ...)
	local args = {
		...
	}
	local order = {}
	fmt = fmt:gsub("%%(%d+)%$", function (i)
		table.insert(order, args[tonumber(i)])

		return "%"
	end)

	return string.format(fmt, unpack(order))
end

function DLCCreator:init(dlc, app_id, params)
	local base_path = managers.database:base_path()
	local dlc_package = params and params.dlc_tweak_data and params.dlc_tweak_data.dlc_package ~= nil and tostring(params.dlc_tweak_data.dlc_package)
	local text = sformat([[
--


]], dlc, dlc_package or "true", string.upper(dlc))

	self:_insert_text(text, base_path .. DLCCreator.dlc_tweak_data, "BUNDLED_DLC_PACKAGES")

	local achievement_text = ""

	for i = 1, params and params.dlc_tweak_data and params.dlc_tweak_data.num_achievements or 0 do
		achievement_text = achievement_text .. sformat([[
	self.ach_%1$s_%2$i = {}
	self.ach_%1$s_%2$i.dlc = "has_achievement"
	self.ach_%1$s_%2$i.achievement_id = "%1$s_%2$i"
	self.ach_%1$s_%2$i.content = {}
	self.ach_%1$s_%2$i.content.loot_global_value = "%3$s"
	self.ach_%1$s_%2$i.content.loot_drops = { 
		-- INSERT LOOT DROPS
	}
]], params.dlc_tweak_data.achievement_id or dlc, i, dlc)
	end

	text = sformat([[
--









	
]], string.upper(dlc), dlc, achievement_text)

	self:_insert_text(text, base_path .. DLCCreator.dlc_tweak_data, "DLC_DATA")

	local dlc_package = params and params.dlc_tweak_data and params.dlc_tweak_data.dlc_package ~= nil and tostring(params.dlc_tweak_data.dlc_package)
	local text = sformat([[
--




]], string.upper(dlc), dlc)

	self:_insert_text(text, base_path .. DLCCreator.dlc_manager, "DLC_HAS_FUNCTION")

	local dlc_package = params and params.dlc_tweak_data and params.dlc_tweak_data.dlc_package ~= nil and tostring(params.dlc_tweak_data.dlc_package)
	local text = sformat([[
--





]], string.upper(dlc), dlc, app_id)

	self:_insert_text(text, base_path .. DLCCreator.dlc_manager, "DLC_APP_ID")
end

function DLCCreator:_insert_text(text, path, identifier)
	local file = SystemFS:open(path, "r")
	local s = file:read()

	file:close()

	local is, ie = self:_find_identifier(s, identifier)

	if is and ie then
		local new_s = s:sub(1, is - 1) .. text .. s:sub(is)
		file = SystemFS:open(path, "w")

		file:write(new_s)
		file:close()
	end
end

function DLCCreator:_find_identifier(s, identifier)
	local is, ie = s:find(DLCCreator.line_identifier_start .. identifier .. DLCCreator.line_identifier_end)

	if is and ie then
		is = is - 5
		ie = ie + 3

		return is, ie
	end

	return nil
end
