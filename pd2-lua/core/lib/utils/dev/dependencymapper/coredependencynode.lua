core:module("CoreDependencyNode")
core:import("CoreClass")

GAME = 0
LEVEL = 1
UNIT = 2
OBJECT = 3
MATERIAL_CONFIG = 4
TEXTURE = 6
CUTSCENE = 7
EFFECT = 8
MATERIALS_FILE = 9
MODEL = 10
DependencyNodeBase = DependencyNodeBase or CoreClass.class()

function DependencyNodeBase:init(type_, db_type, name, get_dn_cb, database)
	assert(type(type_) == "number")
	assert(type(name) == "string")
	assert(type(get_dn_cb) == "function")
	assert(type(database) == "userdata")

	self._type = type_
	self._db_type = db_type
	self._name = name
	self._get_dn = get_dn_cb
	self._database = database
	self._parsed = false
	self._depends_on = {}
end

function DependencyNodeBase:isdependencynode()
	return true
end

function DependencyNodeBase:type_()
	return self._type
end

function DependencyNodeBase:name()
	return self._name
end

function DependencyNodeBase:match(pattern)
	if pattern == nil then
		return true
	elseif type(pattern) == type(GAME) then
		return pattern == self:type_()
	elseif type(pattern) == "string" then
		return string.match(self:name(), string.format("^%s$", pattern)) ~= nil
	elseif pattern.isdependencynode then
		return pattern == self
	elseif type(pattern) == "table" then
		for _, f in ipairs(pattern) do
			if f == self then
				return true
			end
		end

		return false
	else
		error(string.format("Filter '%s' not supported", pattern))
	end
end

function DependencyNodeBase:get_dependencies()
	if not self._parsed then
		for _, xmlnode in ipairs(self:_parse()) do
			self:_walkxml(xmlnode)
		end

		self._parsed = true
	end

	local dn_list = {}

	for dn, _ in pairs(self._depends_on) do
		table.insert(dn_list, dn)
	end

	return dn_list
end

function DependencyNodeBase:reached(pattern)
	local found = {}

	self:_reached(pattern, {}, found)

	return found
end

function DependencyNodeBase:_reached(pattern, traversed, found)
	if traversed[self] then
		return
	else
		traversed[self] = true

		if self:match(pattern) then
			table.insert(found, self)
		end

		for _, dn in ipairs(self:get_dependencies()) do
			dn:_reached(pattern, traversed, found)
		end
	end
end

function DependencyNodeBase:_parse()
	local entry = self._database:lookup(self._db_type, self._name)

	assert(entry:valid())

	local xmlnode = self._database:load_node(entry)

	return {
		xmlnode
	}
end

function DependencyNodeBase:_walkxml(xmlnode)
	local deps = _Deps:new()

	self:_walkxml2dependencies(xmlnode, deps)

	for _, dn in deps:get_pairs() do
		self._depends_on[dn] = true
	end

	for child in xmlnode:children() do
		self:_walkxml(child)
	end
end

function DependencyNodeBase:_walkxml2dependencies(xmlnode, deps)
	error("Not Implemented")
end

_Deps = _Deps or CoreClass.class()

function _Deps:init()
	self._dnlist = {}
end

function _Deps:add(dn)
	table.insert(self._dnlist, dn)
end

function _Deps:get_pairs()
	return ipairs(self._dnlist)
end
