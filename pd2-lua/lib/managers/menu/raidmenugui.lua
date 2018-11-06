RaidMenuGui = RaidMenuGui or class(PromotionalMenuGui)
RaidMenuGui.RaidAppId = "414740"
RaidMenuGui.RaidBetaAppId = "704580"

function RaidMenuGui:init(ws, fullscreen_ws, node, promo_menu_id)
	RaidMenuGui.super.init(self, ws, fullscreen_ws, node)

	self._promo_menu = tweak_data.promos.menus[promo_menu_id]
	self._theme = tweak_data.promos.themes.raid

	self:setup(self._promo_menu, self._theme)
end

function RaidMenuGui:launch_raid()
	local dialog_data = {
		title = managers.localization:text("dialog_play_raid_beta"),
		text = managers.localization:text("dialog_play_raid_beta_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_launch_raid_dialog_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_launch_raid_dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function RaidMenuGui:_launch_raid_dialog_yes()
	managers.savefile:save_progress("local_hdd")
	setup:quit()
	os.execute("cmd /c start steam://run/" .. tostring(RaidMenuGui.RaidBetaAppId))
end

function RaidMenuGui:_launch_raid_dialog_no()
end

function RaidMenuGui:open_raid_weapons_menu()
	managers.menu:open_node("raid_beta_weapons", {})
	managers.menu:post_event("menu_enter")
end

function RaidMenuGui:open_raid_masks_menu()
	managers.menu:open_node("raid_beta_masks", {})
	managers.menu:post_event("menu_enter")
end

function RaidMenuGui:open_raid_trailer()
	Steam:overlay_activate("url", "https://www.youtube.com/embed/XARRgLUzSiA")
end

function RaidMenuGui:open_dev_diary_trailer()
	Steam:overlay_activate("url", "https://www.youtube.com/embed/cm98FnsSKvY")
end

function RaidMenuGui:open_gameplay_trailer()
	Steam:overlay_activate("url", "https://www.youtube.com/embed/Kl2qT-UJVJ4")
end

function RaidMenuGui:open_raid_gang()
	Steam:overlay_activate("url", "http://www.raidworldwar2.com/#characters")
end

function RaidMenuGui:open_raid_feedback()
	Steam:overlay_activate("url", "https://steamcommunity.com/games/" .. RaidMenuGui.RaidAppId .. "/")
end

function RaidMenuGui:open_raid_special_edition_menu()
	managers.menu:open_node("raid_beta_special", {})
	managers.menu:post_event("menu_enter")
end

function RaidMenuGui:open_raid_special_edition()
	Steam:overlay_activate("url", "https://store.steampowered.com/app/" .. RaidMenuGui.RaidAppId .. "/")
end

function RaidMenuGui:open_raid_twitch()
	Steam:overlay_activate("url", "https://www.twitch.tv/liongamelion")
end

function RaidMenuGui:open_raid_preorder_menu()
	managers.menu:open_node("raid_beta_preorder", {})
	managers.menu:post_event("menu_enter")
end

function RaidMenuGui:open_raid_preorder()
	Steam:overlay_activate("url", "https://store.steampowered.com/app/" .. RaidMenuGui.RaidAppId .. "/")
end

function RaidMenuGui:preview_breech()
	managers.blackmarket:view_weapon_platform("breech", callback(self, self, "_open_preview_node", {
		id = "breech",
		category = "secondaries"
	}))
end

function RaidMenuGui:preview_ching()
	managers.blackmarket:view_weapon_platform("ching", callback(self, self, "_open_preview_node", {
		id = "ching",
		category = "primaries"
	}))
end

function RaidMenuGui:preview_erma()
	managers.blackmarket:view_weapon_platform("erma", callback(self, self, "_open_preview_node", {
		id = "erma",
		category = "secondaries"
	}))
end

function RaidMenuGui:preview_push()
	managers.menu:open_node("raid_weapon_preview_node", {
		{
			category = "melee",
			item_id = "push"
		}
	})
	managers.blackmarket:preview_melee_weapon("push")
end

function RaidMenuGui:preview_grip()
	managers.menu:open_node("raid_weapon_preview_node", {
		{
			category = "melee",
			item_id = "grip"
		}
	})
	managers.blackmarket:preview_melee_weapon("grip")
end

function RaidMenuGui:_open_preview_node(data)
	managers.menu:open_node("raid_weapon_preview_node", {
		{
			item_id = data.id,
			category = data.category
		}
	})
end

function RaidMenuGui:preview_jfr_01()
	self:_preview_mask("jfr_01")
end

function RaidMenuGui:preview_jfr_02()
	self:_preview_mask("jfr_02")
end

function RaidMenuGui:preview_jfr_03()
	self:_preview_mask("jfr_03")
end

function RaidMenuGui:preview_jfr_04()
	self:_preview_mask("jfr_04")
end

function RaidMenuGui:_preview_mask(mask_id)
	managers.blackmarket:view_mask_with_mask_id(mask_id)
	managers.menu:open_node("raid_weapon_preview_node", {
		{
			category = "mask",
			item_id = mask_id
		}
	})
end
