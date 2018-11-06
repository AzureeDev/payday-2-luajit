core:import("CoreMissionScriptElement")

ElementDialogue = ElementDialogue or class(CoreMissionScriptElement.MissionScriptElement)
ElementDialogue.MutedDialogs = {
	"pln_",
	"play_pln_",
	"btc_",
	"play_btc_",
	"vld_",
	"play_vld_",
	"plt_",
	"play_plt_",
	"dr1_",
	"play_dr1_",
	"dr2_",
	"play_dr2_",
	"pyr_",
	"play_pyr_",
	"dlr_",
	"play_dlr_",
	"rb5_",
	"play_rb5_",
	"ope_",
	"play_ope_",
	"pt1_",
	"play_pt1_",
	"pt2_",
	"play_pt2_",
	"crn_",
	"play_crn_",
	"hnc_",
	"play_hnc_",
	"cpn_",
	"play_cpn_",
	"zep_",
	"play_zep_",
	"drv_",
	"play_drv_",
	"loc_",
	"play_loc_",
	"brs_",
	"play_brs_",
	"cpg_",
	"play_cpg_",
	"mga_",
	"play_mga_",
	"bot_",
	"play_bot_",
	"snp_",
	"play_snp_",
	"com_",
	"play_com_"
}

function ElementDialogue:init(...)
	ElementDialogue.super.init(self, ...)
end

function ElementDialogue:client_on_executed(...)
	self:on_executed(...)
end

function ElementDialogue:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.play_on_player_instigator_only and instigator ~= managers.player:player_unit() then
		ElementDialogue.super.on_executed(self, instigator, nil, self._values.execute_on_executed_when_done)

		return
	end

	if self._values.dialogue ~= "none" then
		if self:_can_play() then
			if self._values.force_quit_current then
				managers.dialog:quit_dialog()
			end

			local done_cbk = self._values.execute_on_executed_when_done and callback(self, self, "_done_callback", instigator) or nil

			managers.dialog:queue_dialog(self._values.dialogue, {
				case = managers.criminals:character_name_by_unit(instigator),
				done_cbk = done_cbk,
				position = self._values.position,
				skip_idle_check = Application:editor(),
				on_unit = self._values.use_instigator and instigator
			})
		else
			print("[ElementDialogue] Skipping muted dialogue: ", self._values.dialogue)

			local done_cbk = self._values.execute_on_executed_when_done and callback(self, self, "_done_callback", instigator) or nil

			if done_cbk then
				done_cbk()
			end
		end
	elseif Application:editor() then
		managers.editor:output_warning("Dialogue not specified in element " .. self._editor_name .. ".", nil, true)
	end

	ElementDialogue.super.on_executed(self, instigator, nil, self._values.execute_on_executed_when_done)
end

function ElementDialogue:_done_callback(instigator, reason)
	ElementDialogue.super._trigger_execute_on_executed(self, instigator)
end

function ElementDialogue:_can_play()
	if managers.user:get_setting("mute_heist_vo") and not self._values.can_not_be_muted then
		local dialog_str = string.lower(self._values.dialogue)

		for _, mute_str in ipairs(ElementDialogue.MutedDialogs) do
			local len = utf8.len(mute_str)

			if string.sub(dialog_str, 1, len) == mute_str then
				return false
			end
		end

		return true
	else
		return true
	end
end
