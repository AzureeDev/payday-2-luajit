core:module("CorePlayer")
core:import("CoreAvatar")

Player = Player or class()

function Player:init(player_slot, player_handler)
	self._player_slot = player_slot
	self._player_handler = player_handler

	assert(self._player_handler)

	self._player_handler._core_player = self
end

function Player:destroy()
	if self._level_handler then
		self:leave_level(self._level_handler)
	end

	if self._avatar then
		self:_destroy_avatar()
	end

	self._player_handler:destroy()

	self._player_handler = nil
end

function Player:avatar()
	return self._avatar
end

function Player:has_avatar()
	return self._avatar ~= nil
end

function Player:is_alive()
	return self._player_handler ~= nil
end

function Player:_destroy_avatar()
	self._player_handler:release_avatar()
	self._avatar:destroy()

	self._avatar = nil
end

function Player:avatar_handler()
	return self._avatar_handler
end

function Player:enter_level(level_handler)
	self._player_handler:enter_level(level_handler)

	local avatar_handler = self._player_handler:spawn_avatar()
	self._avatar = CoreAvatar.Avatar:new(avatar_handler)
	avatar_handler._core_avatar = self._avatar

	self._player_handler:set_avatar(avatar_handler)

	self._level_handler = level_handler
end

function Player:leave_level(level_handler)
	if self._avatar then
		self:_destroy_avatar()
	end

	self._player_handler:leave_level(level_handler)

	self._level_handler = nil
end

function Player:player_slot()
	return self._player_slot
end

function Player:set_leaderboard_position(position)
	self._leaderboard_position = position
end

function Player:set_team(team)
	self._team = team
end
