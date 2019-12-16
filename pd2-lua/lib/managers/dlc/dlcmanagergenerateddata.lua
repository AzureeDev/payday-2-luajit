function GenericDLCManager:has_flm()
	return self:is_dlc_unlocked("flm")
end

function GenericDLCManager:has_ghx()
	return self:is_dlc_unlocked("ghx")
end

function GenericDLCManager:has_maw()
	return self:is_dlc_unlocked("maw")
end

function GenericDLCManager:has_mex()
	return self:is_dlc_unlocked("mex")
end

function GenericDLCManager:has_mmh()
	return self:is_dlc_unlocked("mmh")
end

function GenericDLCManager:has_mwm()
	return self:is_dlc_unlocked("mwm")
end

function GenericDLCManager:has_scm()
	return self:is_dlc_unlocked("scm")
end

function GenericDLCManager:has_sdm()
	return self:is_dlc_unlocked("sdm")
end

function GenericDLCManager:has_sft()
	return self:is_dlc_unlocked("sft")
end

function GenericDLCManager:has_skm()
	return self:is_dlc_unlocked("skm")
end

function GenericDLCManager:has_smo()
	return self:is_dlc_unlocked("smo")
end

function GenericDLCManager:has_sms()
	return self:is_dlc_unlocked("sms")
end

function GenericDLCManager:has_tam()
	return self:is_dlc_unlocked("tam")
end

function GenericDLCManager:has_tar()
	return self:is_dlc_unlocked("tar")
end

function GenericDLCManager:has_tjp()
	return self:is_dlc_unlocked("tjp")
end

function GenericDLCManager:has_toon()
	return self:is_dlc_unlocked("toon")
end

function GenericDLCManager:has_trd()
	return self:is_dlc_unlocked("trd")
end

function GenericDLCManager:has_xmn()
	return self:is_dlc_unlocked("xmn")
end

function WINDLCManager:init_generated()
	Global.dlc_manager.all_dlc_data.flm = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.ghx = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.maw = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.mex = {
		app_id = "1184411",
		no_install = true,
		webpage = "https://ovk.af/ingame2BorderCrossing"
	}
	Global.dlc_manager.all_dlc_data.mmh = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.mwm = {
		app_id = "1184412",
		no_install = true,
		webpage = "https://ovk.af/ingame2CartelOptics"
	}
	Global.dlc_manager.all_dlc_data.scm = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.sdm = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.sft = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.skm = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.smo = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.sms = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.tam = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.tar = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.tjp = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.toon = {
		app_id = "218620",
		no_install = true
	}
	Global.dlc_manager.all_dlc_data.trd = {
		app_id = "1184410",
		no_install = true,
		webpage = "https://ovk.af/ingame2TailorPack"
	}
	Global.dlc_manager.all_dlc_data.xmn = {
		app_id = "218620",
		no_install = true
	}
end
