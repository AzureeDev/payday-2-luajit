local free_dlcs = {
	"flm",
	"ghx",
	"maw",
	"mmh",
	"scm",
	"sdm",
	"sft",
	"skm",
	"smo",
	"sms",
	"tam",
	"tar",
	"tjp",
	"toon",
	"fdm",
	"ztm",
	"dmg",
	"pmp",
	"ant",
	"rvd",
	"dbd_clan",
	"dbd_deluxe",
	"sha",
	"boo",
	"eng",
	"solus_clan",
	"complete_overkill_pack",
	"mex",
	"mwm",
	"trd",
	"bex",
	"hnd"
}

function PS4DLCManager:init_console()
	for i, dlc in ipairs(free_dlcs) do
		Global.dlc_manager.all_dlc_data[dlc] = {
			verified_for_TheBigScore = true,
			verified = true
		}
	end
end

function XB1DLCManager:init_console()
	local last_index = 0

	for dlc, data in pairs(Global.dlc_manager.all_dlc_data) do
		last_index = math.max(last_index, data.index)
	end

	assert(last_index == 49)

	last_index = 50

	for i, dlc in ipairs(free_dlcs) do
		Global.dlc_manager.all_dlc_data[dlc] = {
			is_default = true,
			index = last_index + i
		}
	end
end
