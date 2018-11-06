TextureCorrectionTweakData = TextureCorrectionTweakData or class()

function TextureCorrectionTweakData:init(hud_icons)
	self:take_middle_128(hud_icons, "guis/dlcs/big_bank/textures/pd2/blackmarket/icons/mods/wpn_fps_ass_fal_g_01")
	self:take_middle_128(hud_icons, "guis/dlcs/dlc_akm4/textures/pd2/blackmarket/icons/mods/wpn_fps_upg_m4_m_l5")
	self:take_middle_128(hud_icons, "guis/dlcs/big_bank/textures/pd2/blackmarket/icons/mods/wpn_fps_ass_fal_m_01")
	self:take_middle_128(hud_icons, "guis/dlcs/hl_miami/textures/pd2/blackmarket/icons/mods/wpn_fps_smg_scorpion_g_wood")
	self:take_middle_128(hud_icons, "guis/dlcs/hl_miami/textures/pd2/blackmarket/icons/mods/wpn_fps_smg_tec9_m_extended")
	self:take_middle_128(hud_icons, "guis/dlcs/hl_miami/textures/pd2/blackmarket/icons/mods/wpn_fps_smg_scorpion_g_ergo")
	self:take_middle_128(hud_icons, "guis/dlcs/hl_miami/textures/pd2/blackmarket/icons/mods/wpn_fps_smg_scorpion_m_extended")
	self:take_middle_128(hud_icons, "guis/dlcs/dlc_akm4/textures/pd2/blackmarket/icons/mods/wpn_fps_upg_ak_m_uspalm")
	self:take_middle_128(hud_icons, "guis/dlcs/dlc_akm4/textures/pd2/blackmarket/icons/mods/wpn_fps_upg_o_ak_scopemount")
	self:take_middle_128(hud_icons, "guis/dlcs/dlc_akm4/textures/pd2/blackmarket/icons/mods/wpn_fps_upg_ak_g_rk3")
	self:take_middle_128(hud_icons, "guis/dlcs/gage_pack_assault/textures/pd2/blackmarket/icons/mods/wpn_fps_ass_g3_g_retro")
	self:take_middle_128(hud_icons, "guis/dlcs/gage_pack_assault/textures/pd2/blackmarket/icons/mods/wpn_fps_ass_g3_g_sniper")
	self:take_middle_128(hud_icons, "guis/dlcs/gage_pack_assault/textures/pd2/blackmarket/icons/mods/wpn_fps_ass_galil_g_sniper")
	self:take_middle_128(hud_icons, "guis/dlcs/gage_pack_assault/textures/pd2/blackmarket/icons/mods/wpn_fps_ass_famas_g_retro")
end

function TextureCorrectionTweakData:take_middle_128(hud_icons, str)
	self:set(hud_icons, str, {
		64,
		0,
		128,
		128
	})
end

function TextureCorrectionTweakData:set(hud_icons, str, rect)
	hud_icons[str] = {
		texture = str,
		texture_rect = rect
	}
end
