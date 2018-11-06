core:module("CoreSmoketestManager")
core:import("CoreClass")
core:import("CoreEngineAccess")
core:import("CoreSmoketestReporter")
core:import("CoreSmoketestLoadLevelSuite")
core:import("CoreSmoketestEditorSuite")

Manager = Manager or CoreClass.class()

function Manager:init(session_state)
	self._session_state = session_state
	self._smoketestsuites = {}
	self._reporter = CoreSmoketestReporter.Reporter:new()

	self:register("editor", CoreSmoketestEditorSuite.EditorSuite:new())
	self:register("load_level", CoreSmoketestLoadLevelSuite.LoadLevelSuite:new())
end

function Manager:destroy()
end

function Manager:register(name, smoketestsuite)
	self._smoketestsuites[name] = smoketestsuite
end

function Manager:post_init()
	self:_parse_arguments(Application:argv())
end

function Manager:_parse_arguments(args)
	local suite_arguments = {}

	for i, arg in ipairs(args) do
		if arg:find("-smoketest:") then
			local smoketest_class = arg:sub(12, -1)

			assert(not self._suite, "Only one smoketest suite can be run at a time")
			assert(self._smoketestsuites[smoketest_class], "Smoketest '" .. smoketest_class .. "' does't exist")

			self._suite = self._smoketestsuites[smoketest_class]
		elseif arg:find("-smoketestarg:") then
			local subarg = arg:sub(15, -1)
			local separator_index = subarg:find("=")

			assert(separator_index, "smoketestargs must be on the form name=value! found this " .. subarg)

			local name = subarg:sub(1, separator_index - 1)
			local value = subarg:sub(separator_index + 1, -1)
			suite_arguments[name] = value
		end
	end

	if self._suite then
		self._suite:start(self._session_state, self._reporter, suite_arguments)
	end
end

function Manager:update(t, dt)
	if self._suite then
		self._suite:update(t, dt)

		if self._suite:is_done() then
			if SystemInfo:platform() == Idstring("WIN32") then
				self._reporter:begin_substep("shutdown")
				CoreEngineAccess._quit()
			else
				self._reporter:tests_done()
			end

			self._suite = nil
		end
	end
end
