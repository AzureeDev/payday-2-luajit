require("lib/units/enemies/cop/logics/CopLogicInactive")

CivilianLogicInactive = class(CopLogicInactive)

function CivilianLogicInactive.on_enemy_weapons_hot(data)
	data.unit:brain():set_attention_settings(nil)
end

function CivilianLogicInactive._register_attention(data, my_data)
	if data.unit:character_damage():dead() and managers.groupai:state():whisper_mode() then
		data.unit:brain():set_attention_settings({
			"civ_enemy_corpse_sneak"
		})
	else
		data.unit:brain():set_attention_settings(nil)
	end
end

function CivilianLogicInactive._set_interaction(data, my_data)
	if data.unit:character_damage():dead() and not managers.groupai:state():whisper_mode() then
		data.unit:interaction():set_tweak_data("corpse_dispose")
		data.unit:interaction():set_active(true, true, true)
	end
end
