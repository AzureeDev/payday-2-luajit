core:module("CoreSmoketestReporter")
core:import("CoreClass")

Reporter = Reporter or CoreClass.class()

function Reporter:init()
end

function Reporter:begin_substep(name)
	cat_print("spam", "[Smoketest] begin_substep " .. name)
end

function Reporter:end_substep(name)
	cat_print("spam", "[Smoketest] end_substep " .. name)
end

function Reporter:fail_substep(name)
	cat_print("spam", "[Smoketest] fail_substep " .. name)
end

function Reporter:tests_done()
	cat_print("spam", "[Smoketest] tests_done")
end
