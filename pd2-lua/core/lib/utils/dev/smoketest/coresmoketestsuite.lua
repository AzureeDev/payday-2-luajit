core:module("CoreSmoketestSuite")
core:import("CoreClass")

Suite = Suite or CoreClass.class()

function Suite:start(session_state, reporter, suite_arguments)
	assert(false, "Not implemented")
end

function Suite:is_done()
	assert(false, "Not implemented")
end

function Suite:update(t, dt)
	assert(false, "Not implemented")
end
