VideoManager = VideoManager or class()

function VideoManager:init()
	self._videos = {}
end

function VideoManager:add_video(video)
	local volume = managers.user:get_setting("sfx_volume")
	local percentage = (volume - tweak_data.menu.MIN_SFX_VOLUME) / (tweak_data.menu.MAX_SFX_VOLUME - tweak_data.menu.MIN_SFX_VOLUME)

	video:set_volume_gain(percentage)
	table.insert(self._videos, video)
end

function VideoManager:remove_video(video)
	table.delete(self._videos, video)
end

function VideoManager:volume_changed(volume)
	for _, video in ipairs(self._videos) do
		video:set_volume_gain(volume)
	end
end
