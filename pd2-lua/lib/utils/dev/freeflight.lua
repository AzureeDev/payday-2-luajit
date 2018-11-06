core:module("FreeFlight")
core:import("CoreFreeFlight")
core:import("CoreClass")

FreeFlight = FreeFlight or class(CoreFreeFlight.FreeFlight)

function FreeFlight:enable(...)
	FreeFlight.super.enable(self, ...)

	if managers.hud then
		managers.hud:set_freeflight_disabled()
	end
end

function FreeFlight:disable(...)
	FreeFlight.super.disable(self, ...)

	if managers.hud then
		managers.hud:set_freeflight_enabled()
	end
end

function FreeFlight:_pause()
	Application:set_pause(true)
end

function FreeFlight:_unpause()
	Application:set_pause(false)
end

CoreClass.override_class(CoreFreeFlight.FreeFlight, FreeFlight)
