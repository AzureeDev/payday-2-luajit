
function DLCTweakData:init_generated()
	self.flm_bundle = {
		free = true,
		content = {}
	}
	self.flm_bundle.content.loot_global_value = "flm"
	self.flm_bundle.content.loot_drops = {{
		type_items = "masks",
		item_entry = "flm",
		amount = 1
	}}
	self.mmh_bundle = {
		free = true,
		content = {}
	}
	self.mmh_bundle.content.loot_global_value = "mmh"
	self.mmh_bundle.content.loot_drops = {{
		type_items = "masks",
		item_entry = "mmh",
		amount = 1
	}}
	self.sdm_bundle = {
		free = true,
		content = {}
	}
	self.sdm_bundle.content.loot_global_value = "sdm"
	self.sdm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sdm_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sdm_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sdm_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sdm_04",
			amount = 1
		}
	}
	self.sft_bundle = {
		free = true,
		content = {}
	}
	self.sft_bundle.content.loot_global_value = "sft"
	self.sft_bundle.content.loot_drops = {}
	self.tam_bundle = {
		free = true,
		content = {}
	}
	self.tam_bundle.content.loot_global_value = "tam"
	self.tam_bundle.content.loot_drops = {}
	self.tjp_bundle = {
		dlc = "has_tjp",
		content = {}
	}
	self.tjp_bundle.content.loot_global_value = "tjp"
	self.tjp_bundle.content.loot_drops = {}
	self.toon_bundle = {
		free = true,
		content = {}
	}
	self.toon_bundle.content.loot_global_value = "toon"
	self.toon_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "toon_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "toon_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "toon_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "toon_04",
			amount = 1
		}
	}
	self.skm_bundle = {
		free = true,
		content = {}
	}
	self.skm_bundle.content.loot_global_value = "skm"
	self.skm_bundle.content.loot_drops = {}
end

