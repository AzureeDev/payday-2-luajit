NetworkFriend = NetworkFriend or class()

function NetworkFriend:init(id, name, signin_status)
	self._id = id
	self._name = name
	self._signin_status = signin_status
end

function NetworkFriend:id()
	return self._id
end

function NetworkFriend:name()
	return self._name
end

function NetworkFriend:signin_status()
	return self._signin_status
end
