core:import("CoreEvent")

function HUDManager:_animate_test_circle()
	local t = 2

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
	end

	print("done")
end

function HUDManager:_animate_ammo_test(panel)
	local t = 3

	panel:set_alpha(1)

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		if t < 2 then
			panel:set_alpha(t / 2)
		end
	end

	panel:set_alpha(0)
end
