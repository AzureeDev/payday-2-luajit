
function GenericDLCManager:has_flm()
	return self:is_dlc_unlocked("flm")
end

function GenericDLCManager:has_mmh()
	return self:is_dlc_unlocked("mmh")
end

function GenericDLCManager:has_sdm()
	return self:is_dlc_unlocked("sdm")
end

function GenericDLCManager:has_sft()
	return self:is_dlc_unlocked("sft")
end

function GenericDLCManager:has_tam()
	return self:is_dlc_unlocked("tam")
end

function GenericDLCManager:has_tjp()
	return self:is_dlc_unlocked("tjp")
end

function GenericDLCManager:has_toon()
	return self:is_dlc_unlocked("toon")
end

function WINDLCManager:init_generated()
	Global.dlc_manager.all_dlc_data.flm = {}
	Global.dlc_manager.all_dlc_data.flm.app_id = "218620"
	Global.dlc_manager.all_dlc_data.flm.no_install = true
	Global.dlc_manager.all_dlc_data.mmh = {}
	Global.dlc_manager.all_dlc_data.mmh.app_id = "218620"
	Global.dlc_manager.all_dlc_data.mmh.no_install = true
	Global.dlc_manager.all_dlc_data.sdm = {}
	Global.dlc_manager.all_dlc_data.sdm.app_id = "218620"
	Global.dlc_manager.all_dlc_data.sdm.no_install = true
	Global.dlc_manager.all_dlc_data.sft = {}
	Global.dlc_manager.all_dlc_data.sft.app_id = "218620"
	Global.dlc_manager.all_dlc_data.sft.no_install = true
	Global.dlc_manager.all_dlc_data.tam = {}
	Global.dlc_manager.all_dlc_data.tam.app_id = "218620"
	Global.dlc_manager.all_dlc_data.tam.no_install = true
	Global.dlc_manager.all_dlc_data.tjp = {}
	Global.dlc_manager.all_dlc_data.tjp.app_id = "218620"
	Global.dlc_manager.all_dlc_data.tjp.no_install = true
	Global.dlc_manager.all_dlc_data.toon = {}
	Global.dlc_manager.all_dlc_data.toon.app_id = "218620"
	Global.dlc_manager.all_dlc_data.toon.no_install = true
end

