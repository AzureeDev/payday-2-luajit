VanSkinsTweakData = VanSkinsTweakData or class()

function VanSkinsTweakData:init(tweak_data)
	self.skins = {}
	self.default_skin_id = "default"
	self.skins.default = {
		dlc = nil,
		sequence_name = "mat_normal"
	}
	self.skins.overkill = {
		dlc = "overkill_pack",
		sequence_name = "mat_overkill"
	}
	self.skins.brown = {
		dlc = nil,
		sequence_name = "mat_chill_brown"
	}
	self.skins.green = {
		dlc = nil,
		sequence_name = "mat_chill_green"
	}
	self.skins.grey = {
		dlc = nil,
		sequence_name = "mat_chill_grey"
	}
	self.skins.red = {
		dlc = nil,
		sequence_name = "mat_chill_red"
	}
	self.skins.white = {
		dlc = nil,
		sequence_name = "mat_chill_white"
	}
	self.skins.yellow = {
		dlc = nil,
		sequence_name = "mat_chill_yellow"
	}
	self.skins.icecream = {
		dlc = nil,
		sequence_name = "mat_chill_icecream"
	}
	self.skins.spooky = {
		dlc = nil,
		sequence_name = "mat_chill_halloween"
	}
end
