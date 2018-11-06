CoreEnvEditor = CoreEnvEditor or class()

function CoreEnvEditor.lerp_formula(value, v)
	return math.lerp(value, Vector3(1, 1, 1), v or 0.5)
end
