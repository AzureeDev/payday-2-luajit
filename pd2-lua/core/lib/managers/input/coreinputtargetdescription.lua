core:module("CoreInputTargetDescription")

TargetDescription = TargetDescription or class()

function TargetDescription:init(name, type_name)
	self._name = name

	assert(type_name == "bool" or type_name == "vector")

	self._type_name = type_name
end

function TargetDescription:target_name()
	return self._name
end

function TargetDescription:target_type_name()
	return self._type_name
end
