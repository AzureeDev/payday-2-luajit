core:module("CoreDependencyParser")
core:import("CoreDependencyNode")
core:import("CoreGameDn")
core:import("CoreLevelDn")
core:import("CoreUnitDn")
core:import("CoreObjectDn")
core:import("CoreModelDn")
core:import("CoreMaterialfileDn")
core:import("CoreMaterialconfigDn")
core:import("CoreTextureDn")
core:import("CoreCutsceneDn")
core:import("CoreEffectDn")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreKeywordArguments")
core:import("CoreWorkbook")
core:import("CoreWorksheet")
core:import("CoreSsRow")
core:import("CoreDebug")

local parse_kwargs = CoreKeywordArguments.parse_kwargs
GAME = CoreDependencyNode.GAME
LEVEL = CoreDependencyNode.LEVEL
UNIT = CoreDependencyNode.UNIT
OBJECT = CoreDependencyNode.OBJECT
MODEL = CoreDependencyNode.MODEL
MATERIALS_FILE = CoreDependencyNode.MATERIALS_FILE
MATERIAL_CONFIG = CoreDependencyNode.MATERIAL_CONFIG
TEXTURE = CoreDependencyNode.TEXTURE
CUTSCENE = CoreDependencyNode.CUTSCENE
EFFECT = CoreDependencyNode.EFFECT
DependencyParser = DependencyParser or CoreClass.class()

function DependencyParser:init(db)
	self._database = db or Database
	self._dn_cb = CoreEvent.callback(self, self, "_dn")
	self._key2node = {}

	self:_make_game_node()
	self:_make_level_nodes()
	self:_make_materialfile_node()
	self:_make_nodes_from_db(CoreUnitDn.UnitDependencyNode, "unit")
	self:_make_nodes_from_db(CoreObjectDn.ObjectDependencyNode, "object")
	self:_make_nodes_from_db(CoreModelDn.ModelDependencyNode, "model")
	self:_make_nodes_from_db(CoreMaterialconfigDn.Material_configDependencyNode, "material_config")
	self:_make_nodes_from_db(CoreTextureDn.TextureDependencyNode, "texture")
	self:_make_nodes_from_db(CoreCutsceneDn.CutsceneDependencyNode, "cutscene")
	self:_make_nodes_from_db(CoreEffectDn.EffectDependencyNode, "effect")
end

function DependencyParser:_key(type_, name)
	return string.format("%s:%s", type_, name)
end

function DependencyParser:_dn(...)
	local name, type_ = parse_kwargs({
		...
	}, "string:name", "number:type_")
	local key = self:_key(type_, name)

	return self._key2node[key]
end

function DependencyParser:_make_game_node()
	local key = self:_key(GAME, "Game")
	self._key2node[key] = CoreGameDn.GameDependencyNode:new("Game", self._dn_cb, self._database)
end

function DependencyParser:_make_level_nodes()
	for _, dir in ipairs(File:list(CoreLevelDn.LEVEL_BASE, true)) do
		local file = string.format(CoreLevelDn.LEVEL_FILE, dir)

		if File:exists(file) then
			local key = self:_key(LEVEL, dir)
			self._key2node[key] = CoreLevelDn.LevelDependencyNode:new(dir, self._dn_cb, self._database)
		end
	end
end

function DependencyParser:_make_materialfile_node()
	local key = self:_key(MATERIALS_FILE, "Materialsfile")
	self._key2node[key] = CoreMaterialfileDn.MaterialsfileDependencyNode:new("Materialsfile", self._dn_cb, self._database)
end

function DependencyParser:_make_nodes_from_db(dn_class, db_type)
	for _, name in ipairs(managers.database:list_entries_of_type(db_type)) do
		local dn = dn_class:new(name, self._dn_cb, self._database)
		local key = self:_key(dn:type_(), name)
		self._key2node[key] = dn
	end
end

function DependencyParser:nodes(pattern)
	local dn_list = {}

	for _, dn in pairs(self._key2node) do
		if dn:match(pattern) then
			table.insert(dn_list, dn)
		end
	end

	return dn_list
end

function DependencyParser:complement(dn_list, pattern)
	local all_dn = self:nodes()
	local list = set_difference(all_dn, dn_list)

	return filter(list, pattern)
end

function DependencyParser:reached(start_dn_list, pattern)
	local reached_dn = {}

	for _, start_dn in ipairs(start_dn_list) do
		reached_dn = union(reached_dn, start_dn:reached())
	end

	return filter(reached_dn, pattern)
end

function DependencyParser:not_reached(start_dn_list, pattern)
	local reached_dn = self:reached(start_dn_list)
	local not_reached_dn = self:complement(reached_dn)

	return filter(not_reached_dn, pattern)
end

function _set2list(set)
	local list = {}

	for n, _ in pairs(set) do
		table.insert(list, n)
	end

	return list
end

function _list2set(list)
	local set = {}

	for _, n in ipairs(list) do
		set[n] = n
	end

	return set
end

function union(A_list, B_list)
	local set = {}

	for _, dn in ipairs(A_list) do
		set[dn] = dn
	end

	for _, dn in ipairs(B_list) do
		set[dn] = dn
	end

	return _set2list(set)
end

function intersect(A_list, B_list)
	local b_set = _list2set(B_list)
	local c_set = {}

	for _, dn in ipairs(A_list) do
		if b_set[dn] ~= nil then
			c_set[dn] = dn
		end
	end

	return _set2list(c_set)
end

function set_difference(A_list, B_list)
	local set = _list2set(A_list)

	for _, n in ipairs(B_list) do
		set[n] = nil
	end

	return _set2list(set)
end

function names(A_list)
	local names = {}

	for _, dn in ipairs(A_list) do
		table.insert(names, dn:name())
	end

	table.sort(names)

	return names
end

function filter(dn_list, pattern)
	res_list = {}

	for _, dn in ipairs(dn_list) do
		if dn:match(pattern) then
			table.insert(res_list, dn)
		end
	end

	return res_list
end

function generate_report(filepath, protected_list, dp)
	local workbook = CoreWorkbook.Workbook:new()
	local dp = dp or DependencyParser:new(ProjectDatabase)
	local game = dp:nodes(GAME)[1]
	local reached = game:reached()

	if protected_list ~= nil then
		reached = union(reached, dp:reached(protected_list))
	end

	local not_reached = dp:complement(reached)

	function make_first_worksheet()
		local ws = CoreWorksheet.Worksheet:new("README")

		ws:add_row(CoreSsRow.Header1Row:new("Candidates for Removal Report"))
		ws:add_row(CoreSsRow.Row:new(""))
		ws:add_row(CoreSsRow.Header2Row:new("About"))
		ws:add_row(CoreSsRow.Row:new("This is an automatically generated report suggesting different"))
		ws:add_row(CoreSsRow.Row:new("assets that (maybe) can be removed from the game because they"))
		ws:add_row(CoreSsRow.Row:new("are (probably) not used. Each worksheet contains a list of candidate"))
		ws:add_row(CoreSsRow.Row:new("assets of a given type. There is also a sheet with a list of assets"))
		ws:add_row(CoreSsRow.Row:new("that are consider protected."))
		ws:add_row(CoreSsRow.Row:new(""))
		ws:add_row(CoreSsRow.Header2Row:new("Warning!"))
		ws:add_row(CoreSsRow.Row:new("Unfortunately, the report is not exact: there are many assets listed"))
		ws:add_row(CoreSsRow.Row:new("in this report that is actually still part of the game. One reason for"))
		ws:add_row(CoreSsRow.Row:new("this is that assets can be invoked through Lua script code, another is"))
		ws:add_row(CoreSsRow.Row:new("that the dependency chains between assets are not always easily tracable."))
		ws:add_row(CoreSsRow.Row:new("This means the report is only a starting point for the hard, tiresome,"))
		ws:add_row(CoreSsRow.Row:new("manual, and error prone labour of removing assets..."))
		ws:add_row(CoreSsRow.Row:new(""))
		ws:add_row(CoreSsRow.Header2Row:new("Protected Assets"))
		ws:add_row(CoreSsRow.Row:new("Because of the issues listed above it is possible to add a list of"))
		ws:add_row(CoreSsRow.Row:new("protected assets. By listing a asset in the protected list it (including"))
		ws:add_row(CoreSsRow.Row:new("the assets it depends on) is removed from the list of candidates to"))
		ws:add_row(CoreSsRow.Row:new("be removed. The protected assets are listed in the last worksheet."))

		return ws
	end

	function make_worksheet(type_, name)
		local ws = CoreWorksheet.Worksheet:new(name)

		ws:add_row(CoreSsRow.Header1Row:new(string.format("%s, Candidates to be Removed:", name)))

		local node_names = names(filter(not_reached, type_))

		CoreDebug.cat_print("debug", name, #node_names)

		for _, n in ipairs(node_names) do
			ws:add_row(CoreSsRow.Row:new(n))
		end

		collectgarbage()

		return ws
	end

	function make_protected_worksheet()
		local ws = CoreWorksheet.Worksheet:new("Protected Assets")

		ws:add_row(CoreSsRow.Header1Row:new("Proteted Assets (by type):"))
		ws:add_row(CoreSsRow.Header2Row:new("Levels", "Units", "Objects", "Model", "Material Configs", "Textures", "Cutscenes", "Effects"))

		local levels = names(filter(protected_list, LEVEL))
		local units = names(filter(protected_list, UNIT))
		local objects = names(filter(protected_list, OBJECT))
		local models = names(filter(protected_list, MODEL))
		local mtrlcfgs = names(filter(protected_list, MATERIAL_CONFIG))
		local textures = names(filter(protected_list, TEXTURE))
		local cutscenes = names(filter(protected_list, CUTSCENE))
		local effects = names(filter(protected_list, EFFECT))
		local size = math.max(#levels, #units, #objects, #models, #mtrlcfgs, #textures, #cutscenes, #effects)

		for i = 1, size do
			ws:add_row(CoreSsRow.Row:new(levels[i] or "", units[i] or "", objects[i] or "", models[i] or "", mtrlcfgs[i] or "", textures[i] or "", cutscenes[i] or "", effects[i] or ""))
		end

		collectgarbage()

		return ws
	end

	workbook:add_worksheet(make_first_worksheet())
	workbook:add_worksheet(make_worksheet(LEVEL, "Levels"))
	workbook:add_worksheet(make_worksheet(UNIT, "Units"))
	workbook:add_worksheet(make_worksheet(OBJECT, "Objects"))
	workbook:add_worksheet(make_worksheet(MODEL, "Models"))
	workbook:add_worksheet(make_worksheet(MATERIAL_CONFIG, "Material Configs"))
	workbook:add_worksheet(make_worksheet(TEXTURE, "Textures"))
	workbook:add_worksheet(make_worksheet(CUTSCENE, "Cutscenes"))
	workbook:add_worksheet(make_worksheet(EFFECT, "Effects"))
	workbook:add_worksheet(make_protected_worksheet())
	collectgarbage()

	f = io.open(filepath, "w")

	if f == nil then
		local cause = "Unable to open file " .. filepath .. " (open in other program?)"

		Application:error(cause)

		return cause
	else
		workbook:to_xml(f)
		f:close()
	end
end

function generate_BC_report(filepath)
	local dp = dp or DependencyParser:new(ProjectDatabase)
	local units = dp:nodes(UNIT)
	local levels = dp:nodes(LEVEL)
	local textures = dp:nodes(TEXTURE)
	local effects = dp:nodes(EFFECT)
	local prot = {}
	prot = union(prot, filter(units, "terracotta.*"))
	prot = union(prot, filter(units, "mp_.*"))
	prot = union(prot, filter(units, "multiplayer.*"))
	prot = union(prot, filter(levels, "mp_.*"))
	prot = union(prot, filter(textures, "concept_.*"))
	prot = union(prot, filter(textures, "credits_.*"))
	prot = union(prot, filter(textures, "mp_.*"))
	prot = union(prot, filter(textures, "hud_.*"))
	prot = union(prot, filter(textures, "gui_.*"))
	prot = union(prot, filter(textures, "security_camera_.*"))
	prot = union(prot, effects)

	generate_report(filepath, prot, dp)
end

function generate_FAITH_report(filepath)
	local dp = dp or DependencyParser:new(ProjectDatabase)
	local levels = dp:nodes(LEVEL)
	local units = dp:nodes(UNIT)
	local objects = dp:nodes(OBJECT)
	local models = dp:nodes(MODEL)
	local mtrlcfgs = dp:nodes(MATERIAL_CONFIG)
	local textures = dp:nodes(TEXTURE)
	local cutscenes = dp:nodes(CUTSCENE)
	local effects = dp:nodes(EFFECT)
	local prot = {}

	generate_report(filepath, prot, dp)
end
