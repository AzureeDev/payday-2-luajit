StatisticsAdaptor = StatisticsAdaptor or {}
local max_possible_val = 2147483000

function StatisticsAdaptor:run(stats)
	local handler = Steam:sa_handler()
	local adapted = {}

	for key, stat in pairs(stats) do
		if stat.type == "int" then
			local val = math.max(0, handler:get_stat(key))

			if stat.method == "lowest" then
				if stat.value < val then
					adapted[key] = stat.value
				end
			elseif stat.method == "highest" then
				if val < stat.value then
					adapted[key] = stat.value
				end
			elseif stat.method == "set" then
				adapted[key] = math.clamp(stat.value, 0, max_possible_val)
			elseif stat.value > 0 then
				local mval = val / 1000 + stat.value / 1000

				if mval >= max_possible_val / 1000 then
					Application:error("[AccelByte:Telemetry] Warning, trying to set too high a value on stat [" .. key .. "]")

					adapted[key] = max_possible_val
				else
					adapted[key] = val + stat.value
				end
			end
		elseif stat.type == "float" then
			if stat.value > 0 then
				local val = handler:get_stat_float(key)
				adapted[key] = val + stat.value
			end
		elseif stat.type == "avgrate" then
			adapted[key] = stat.value / stat.hours
		end
	end

	return adapted
end
