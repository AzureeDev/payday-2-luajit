core:import("CoreMissionScriptElement")

ElementAiGlobalEvent = ElementAiGlobalEvent or class(CoreMissionScriptElement.MissionScriptElement)
ElementAiGlobalEvent._wave_modes = {
	"none",
	"assault",
	"besiege",
	"blockade",
	"hunt",
	"quiet",
	"passive"
}
ElementAiGlobalEvent._AI_events = {
	"none",
	"police_called",
	"police_weapons_hot",
	"gangsters_called",
	"gangster_weapons_hot"
}
ElementAiGlobalEvent._blames = {
	"none",
	"empty",
	"cop",
	"gangster",
	"civilian",
	"metal_detector",
	"security_camera",
	"civilian_alarm",
	"cop_alarm",
	"gangster_alarm",
	"motion_sensor",
	"glass_alarm",
	"blackmailer",
	"gensec",
	"police_alerted",
	"csgo_gunfire"
}

function ElementAiGlobalEvent:init(...)
	ElementAiGlobalEvent.super.init(self, ...)

	if self._values.event then
		self._values.wave_mode = self._values.event
		self._values.event = nil
	end

	self:_finalize_values(self._values)
end

function ElementAiGlobalEvent:_finalize_values(values)
	values.wave_mode = table.index_of(self._wave_modes, values.wave_mode)
	values.AI_event = table.index_of(self._AI_events, values.AI_event)
	values.blame = table.index_of(self._blames, values.blame)
end

function ElementAiGlobalEvent:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local wave_mode = self._wave_modes[self._values.wave_mode]
	local blame = self._blames[self._values.blame]
	local AI_event = self._AI_events[self._values.AI_event]

	if wave_mode and wave_mode ~= "none" then
		managers.groupai:state():set_wave_mode(wave_mode)
	end

	if not blame or blame == "none" then
		Application:error("ElementAiGlobalEvent needs to be updated with blame parameter, and not none", blame)
	end

	if AI_event and AI_event ~= "none" then
		if AI_event == "police_called" then
			managers.groupai:state():on_police_called(managers.groupai:state().analyse_giveaway(blame, instigator, {
				"vo_cbt"
			}))
		elseif AI_event == "police_weapons_hot" then
			managers.groupai:state():on_police_weapons_hot(managers.groupai:state().analyse_giveaway(blame, instigator, {
				"vo_cbt"
			}))
		elseif AI_event == "gangsters_called" then
			managers.groupai:state():on_gangsters_called(managers.groupai:state().analyse_giveaway(blame, instigator, {
				"vo_cbt"
			}))
		elseif AI_event == "gangster_weapons_hot" then
			managers.groupai:state():on_gangster_weapons_hot(managers.groupai:state().analyse_giveaway(blame, instigator, {
				"vo_cbt"
			}))
		end
	end

	ElementAiGlobalEvent.super.on_executed(self, instigator)
end
