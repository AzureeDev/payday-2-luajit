core:module("CoreMenuCallbackHandler")

CallbackHandler = CallbackHandler or class()

function CallbackHandler:init()
	getmetatable(self).__index = function (t, key)
		local value = rawget(getmetatable(t), key)

		if value then
			return value
		end
	end
end
