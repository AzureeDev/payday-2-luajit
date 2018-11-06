core:module("CoreSubtitleSequencePlayer")
core:import("CoreClass")

SubtitleSequencePlayer = SubtitleSequencePlayer or CoreClass.class()

function SubtitleSequencePlayer:init(sequence, presenter)
	assert(sequence, "Invalid sequence.")
	assert(presenter, "Invalid presenter.")

	self.__presenter = presenter
	self.__sequence = self.__presenter:preprocess_sequence(sequence)
end

function SubtitleSequencePlayer:is_done()
	return self.__sequence:duration() <= (self.__time or 0)
end

function SubtitleSequencePlayer:update(time, delta_time)
	self.__time = (self.__time or 0) + delta_time

	self:evaluate_at_time(self.__time)
end

function SubtitleSequencePlayer:evaluate_at_time(time)
	if time ~= self._last_evaluated_time then
		local subtitle = table.inject(self.__sequence:subtitles(), nil, function (latest, subtitle)
			return subtitle:is_active_at_time(time) and subtitle or latest
		end)

		if subtitle ~= self.__previous_subtitle then
			self.__presenter:show_text(subtitle and subtitle:string() or "", subtitle and subtitle:duration())

			self.__previous_subtitle = subtitle
		end

		self._last_evaluated_time = time
	end
end
