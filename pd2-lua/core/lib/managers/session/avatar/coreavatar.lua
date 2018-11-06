core:module("CoreAvatar")

Avatar = Avatar or class()

function Avatar:init(avatar_handler)
	self._avatar_handler = avatar_handler
end

function Avatar:destroy()
	if self._input_input_provider then
		self:release_input()
	end

	self._avatar_handler:destroy()
end

function Avatar:set_input(input_input_provider)
	self._avatar_handler:enable_input(input_input_provider)

	self._input_input_provider = input_input_provider
end

function Avatar:release_input()
	self._avatar_handler:disable_input()

	self._input_input_provider = nil
end

function Avatar:avatar_handler()
	return self._avatar_handler
end
