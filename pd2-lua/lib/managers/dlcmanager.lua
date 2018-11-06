DLCManager = DLCManager or class()
DLCManager.PLATFORM_CLASS_MAP = {}

function DLCManager:new(...)
	local platform = SystemInfo:platform()

	return self.PLATFORM_CLASS_MAP[platform:key()] or GenericDLCManager:new(...)
end

GenericDLCManager = GenericDLCManager or class()

function GenericDLCManager:init()
	self._debug_on = Application:production_build()

	self:_set_dlc_save_table()
end

function GenericDLCManager:_set_dlc_save_table()
	if not Global.dlc_save then
		Global.dlc_save = {
			packages = {}
		}
	end
end

function GenericDLCManager:setup()
	self:_modify_locked_content()
	self:_create_achievement_locked_content_table()
end

function GenericDLCManager:_create_achievement_locked_content_table()
	self._achievement_locked_content = {}
	self._achievement_milestone_locked_content = {}
	self._dlc_locked_content = {}

	for name, dlc in pairs(tweak_data.dlc) do
		local content = dlc.content

		if content then
			local loot_drops = content.loot_drops

			if loot_drops then
				for _, loot_drop in ipairs(loot_drops) do
					if loot_drop.type_items then
						if dlc.achievement_id then
							self._achievement_locked_content[loot_drop.type_items] = self._achievement_locked_content[loot_drop.type_items] or {}
							self._achievement_locked_content[loot_drop.type_items][loot_drop.item_entry] = name
						elseif dlc.milestone_id then
							self._achievement_milestone_locked_content[loot_drop.type_items] = self._achievement_milestone_locked_content[loot_drop.type_items] or {}
							self._achievement_milestone_locked_content[loot_drop.type_items][loot_drop.item_entry] = name
						else
							self._dlc_locked_content[loot_drop.type_items] = self._dlc_locked_content[loot_drop.type_items] or {}
							self._dlc_locked_content[loot_drop.type_items][loot_drop.item_entry] = name
						end
					end
				end
			end
		end
	end
end

function GenericDLCManager:_modify_locked_content()
	if SystemInfo:platform() == Idstring("WIN32") then
		return
	end

	local function _modify_loot_drop(loot_drop)
		local entry = tweak_data.blackmarket[loot_drop.type_items] and tweak_data.blackmarket[loot_drop.type_items][loot_drop.item_entry]

		if entry then
			if not entry.pc and (not entry.pcs or #entry.pcs == 0) then
				entry.pcs = {
					10,
					20,
					30,
					40
				}

				if loot_drop.type_items == "weapon_mods" then
					tweak_data.weapon.factory.parts[loot_drop.item_entry].pcs = {
						10,
						20,
						30,
						40
					}
				end
			end
		else
			print(" -- entry not exists")
		end
	end

	for name, dlc in pairs(tweak_data.dlc) do
		if not dlc.content_on_consoles then
			local content = dlc.content

			if content then
				local loot_drops = content.loot_drops

				if loot_drops then
					for _, loot_drop in ipairs(loot_drops) do
						if #loot_drop > 0 then
							for _, lp in ipairs(loot_drop) do
								_modify_loot_drop(lp)
							end
						else
							_modify_loot_drop(loot_drop)
						end
					end

					content.loot_drops = {}
				end
			end
		end
	end
end

function GenericDLCManager:achievement_locked_content()
	return self._achievement_locked_content
end

function GenericDLCManager:is_mask_achievement_locked(mask_id)
	return self._achievement_locked_content.masks and self._achievement_locked_content.masks[mask_id]
end

function GenericDLCManager:is_material_achievement_locked(material_id)
	return self._achievement_locked_content.materials and self._achievement_locked_content.materials[material_id]
end

function GenericDLCManager:is_texture_achievement_locked(texture_id)
	return self._achievement_locked_content.textures and self._achievement_locked_content.textures[texture_id]
end

function GenericDLCManager:is_weapon_mod_achievement_locked(weapon_mod_id)
	return self._achievement_locked_content.weapon_mods and self._achievement_locked_content.weapon_mods[weapon_mod_id]
end

function GenericDLCManager:is_mask_achievement_milestone_locked(mask_id)
	return self._achievement_milestone_locked_content.masks and self._achievement_milestone_locked_content.masks[mask_id]
end

function GenericDLCManager:on_tweak_data_reloaded()
	self:setup()
end

function GenericDLCManager:init_finalize()
	managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
end

function GenericDLCManager:chk_content_updated()
end

function GenericDLCManager:give_dlc_and_verify_blackmarket()
	self:give_dlc_package()

	if managers.blackmarket then
		managers.blackmarket:tradable_dlcs()
		managers.blackmarket:verify_dlc_items()
	else
		Application:error("[GenericDLCManager] _load_done(): BlackMarketManager not yet initialized!")
	end
end

function GenericDLCManager:_load_done(...)
	self:give_dlc_and_verify_blackmarket()
end

function GenericDLCManager:give_dlc_package()
	for package_id, data in pairs(tweak_data.dlc) do
		if self:is_dlc_unlocked(package_id) then
			if not Global.dlc_save.packages[package_id] then
				Global.dlc_save.packages[package_id] = true

				for _, loot_drop in ipairs(data.content.loot_drops or {}) do
					local loot_drop = #loot_drop > 0 and loot_drop[math.random(#loot_drop)] or loot_drop

					if loot_drop.type_items == "armor_skins" then
						managers.blackmarket:on_aquired_armor_skin(loot_drop.item_entry)
					else
						for i = 1, loot_drop.amount or 1, 1 do
							local entry = tweak_data.blackmarket[loot_drop.type_items][loot_drop.item_entry]
							local global_value = loot_drop.global_value or data.content.loot_global_value or package_id

							managers.blackmarket:add_to_inventory(global_value, loot_drop.type_items, loot_drop.item_entry)
						end
					end
				end
			end

			local identifier = UpgradesManager.AQUIRE_STRINGS[5] .. tostring(package_id)

			for _, upgrade in ipairs(data.content.upgrades or {}) do
				if not managers.upgrades:aquired(upgrade, identifier) then
					managers.upgrades:aquire_default(upgrade, identifier)
				end
			end
		else
			local identifier = UpgradesManager.AQUIRE_STRINGS[5] .. tostring(package_id)

			for _, upgrade in ipairs(data.content.upgrades or {}) do
				if managers.upgrades:aquired(upgrade, identifier) then
					managers.upgrades:unaquire(upgrade, identifier)
				end
			end
		end
	end
end

function GenericDLCManager:give_missing_package()
	local name_converter = {
		colors = "color",
		materials = "material",
		textures = "pattern"
	}
	local entry, global_value, passed, has_item, name = nil

	for package_id, data in pairs(tweak_data.dlc) do
		if Global.dlc_save.packages[package_id] and self:is_dlc_unlocked(package_id) then
			for _, loot_drop in ipairs(data.content and data.content.loot_drops or {}) do
				if #loot_drop == 0 then
					if loot_drop.type_items == "armor_skins" then
						entry = tweak_data.economy.armor_skins[loot_drop.item_entry]
						has_item = managers.blackmarket:armor_skin_unlocked(loot_drop.item_entry)

						if not entry.steam_economy and not has_item then
							managers.blackmarket:on_aquired_armor_skin(loot_drop.item_entry)
						end
					else
						entry = tweak_data.blackmarket[loot_drop.type_items][loot_drop.item_entry]
						global_value = loot_drop.global_value or data.content.loot_global_value or package_id
						passed = false

						if (loot_drop.type_items == "weapon_mods" or loot_drop.type_items == "weapon_skins") and entry.is_a_unlockable then
							has_item = managers.blackmarket:get_item_amount(global_value, loot_drop.type_items, loot_drop.item_entry, true) > 0
							passed = not has_item
						elseif loot_drop.type_items ~= "weapon_mods" and entry.value == 0 then
							has_item = managers.blackmarket:get_item_amount(global_value, loot_drop.type_items, loot_drop.item_entry, true) > 0

							if not has_item then
								if loot_drop.type_items == "masks" then
									for slot, crafted in pairs(Global.blackmarket_manager.crafted_items.masks) do
										if slot ~= 1 and crafted.mask_id == loot_drop.item_entry and crafted.global_value == global_value then
											has_item = true

											break
										end
									end
								elseif loot_drop.type_items == "materials" or loot_drop.type_items == "textures" or loot_drop.type_items == "colors" then
									for slot, crafted in pairs(Global.blackmarket_manager.crafted_items.masks) do
										if slot ~= 1 then
											name = name_converter[loot_drop.type_items]

											if crafted.blueprint[name].id == loot_drop.item_entry and crafted.blueprint[name].global_value == global_value then
												has_item = true

												break
											end
										end
									end
								end

								passed = not has_item
							end
						end

						if passed then
							print("[GenericDLCManager:give_missing_package] Found missing Item!", loot_drop.amount, global_value, loot_drop.type_items, loot_drop.item_entry)

							for i = 1, loot_drop.amount or 1, 1 do
								managers.blackmarket:add_to_inventory(global_value, loot_drop.type_items, loot_drop.item_entry)
							end
						end
					end
				end
			end
		end
	end
end

function GenericDLCManager:list_dlc_package(dlcs)
	local t = {}

	for package_id, data in pairs(tweak_data.dlc) do
		if not dlcs or dlcs[package_id] or table.contains(dlcs, package_id) then
			for _, loot_drop in ipairs(data.content.loot_drops or {}) do
				t.items = t.items or {}

				if #loot_drop > 0 then
					-- Nothing
				else
					local global_value = loot_drop.global_value or data.content.loot_global_value or package_id
					local category = loot_drop.type_items
					local entry = loot_drop.item_entry
					local amount = loot_drop.amount

					table.insert(t.items, {
						global_value,
						category,
						entry,
						amount
					})
				end
			end

			for _, upgrade in ipairs(data.content.upgrades or {}) do
				t.upgrades = t.upgrades or {}

				table.insert(t.upgrades, upgrade)
			end
		end
	end

	return t
end

function GenericDLCManager:save(data)
	data.dlc_save = Global.dlc_save
end

function GenericDLCManager:load(data)
	if data.dlc_save and data.dlc_save.packages then
		Global.dlc_save = data.dlc_save
	end
end

function GenericDLCManager:on_reset_profile()
	Global.dlc_save = nil

	self:_set_dlc_save_table()
	self:give_dlc_package()
end

function GenericDLCManager:on_achievement_award_loot()
	Application:debug("GenericDLCManager:on_achievement_award_loot()")
	self:give_dlc_package()
end

function GenericDLCManager:on_signin_complete()
end

function GenericDLCManager:is_dlcs_unlocked(list_of_dlcs)
	for _, dlc in ipairs(list_of_dlcs) do
		if not self:is_dlc_unlocked(dlc) then
			return false
		end
	end

	return true
end

function GenericDLCManager:is_dlc_unlocked(dlc)
	return tweak_data.dlc[dlc] and tweak_data.dlc[dlc].free or self:has_dlc(dlc)
end

function GenericDLCManager:has_dlc(dlc)
	local dlc_tweak = tweak_data.dlc[dlc]

	if dlc_tweak and dlc_tweak.dlc then
		local unlocked_check_function = self[dlc_tweak.dlc]

		if unlocked_check_function then
			return unlocked_check_function(self, dlc_tweak)
		else
			Application:error("Didn't have dlc has function for", dlc, "has_dlc()", dlc_tweak.dlc)
			Application:stack_dump()
		end
	end

	if dlc == "cce" then
		dlc = "career_criminal_edition"
	end

	local dlc_data = Global.dlc_manager.all_dlc_data[dlc]

	if not dlc_data then
		Application:error("Didn't have dlc data for ", dlc)
		Application:stack_dump()

		return false
	end

	return dlc_data.verified
end

function GenericDLCManager:has_full_game()
	return Global.dlc_manager.all_dlc_data.full_game.verified
end

function GenericDLCManager:is_trial()
	return not self:has_full_game()
end

function GenericDLCManager:is_installing()
	if not DB:is_bundled() or SystemInfo:platform() == Idstring("WIN32") then
		return false, 1
	end

	local install_progress = Application:installer():get_progress()
	local is_installing = install_progress < 1

	return is_installing, install_progress
end

function GenericDLCManager:dlcs_string()
	local s = ""
	s = s .. (self:is_dlc_unlocked("preorder") and "preorder " or "")

	return s
end

function GenericDLCManager:has_corrupt_data()
	return self._has_corrupt_data
end

function GenericDLCManager:has_all_dlcs()
	return self:is_dlcs_unlocked({
		"armored_transport",
		"gage_pack"
	})
end

function GenericDLCManager:has_goty_weapon_bundle_2014()
	return self:is_dlcs_unlocked({
		"gage_pack",
		"gage_pack_lmg",
		"gage_pack_jobs",
		"gage_pack_snp",
		"gage_pack_shotgun",
		"gage_pack_assault",
		"gage_pack_historical"
	})
end

function GenericDLCManager:has_goty_heist_bundle_2014()
	return self:is_dlcs_unlocked({
		"armored_transport",
		"big_bank",
		"hl_miami",
		"hope_diamond"
	})
end

function GenericDLCManager:has_pd2_clan()
	return self:is_dlc_unlocked("pd2_clan")
end

function GenericDLCManager:has_raidww2_clan()
	return self:is_dlc_unlocked("raidww2_clan")
end

function GenericDLCManager:has_twitch_pack()
	return self:is_dlc_unlocked("twitch_pack")
end

function GenericDLCManager:has_turtles()
	return self:is_dlc_unlocked("turtles")
end

function GenericDLCManager:has_dragon()
	return self:is_dlc_unlocked("dragon")
end

function GenericDLCManager:has_dbd_clan()
	return self:is_dlc_unlocked("dbd_clan")
end

function GenericDLCManager:has_dbd_deluxe()
	return Global.dlc_manager.all_dlc_data.dbd_deluxe and Global.dlc_manager.all_dlc_data.dbd_deluxe.verified
end

function GenericDLCManager:has_solus_clan()
	return self:is_dlc_unlocked("solus_clan")
end

function GenericDLCManager:has_tango()
	return self:is_dlc_unlocked("tango")
end

function GenericDLCManager:has_chico()
	return self:is_dlc_unlocked("chico")
end

function GenericDLCManager:has_friend()
	return self:is_dlc_unlocked("friend")
end

function GenericDLCManager:has_sparkle()
	return self:is_dlc_unlocked("sparkle")
end

function GenericDLCManager:has_swm()
	return self:is_dlc_unlocked("swm")
end

function GenericDLCManager:has_spa()
	return self:is_dlc_unlocked("spa")
end

function GenericDLCManager:has_sha()
	return self:is_dlc_unlocked("sha")
end

function GenericDLCManager:has_rvd()
	return self:is_dlc_unlocked("rvd")
end

function GenericDLCManager:has_grv()
	return self:is_dlc_unlocked("grv")
end

function GenericDLCManager:has_amp()
	return self:is_dlc_unlocked("amp")
end

function GenericDLCManager:has_mp2()
	return self:is_dlc_unlocked("mp2")
end

function GenericDLCManager:has_ant()
	return Global.dlc_manager.all_dlc_data.ant and Global.dlc_manager.all_dlc_data.ant.verified
end

function GenericDLCManager:has_pn2()
	return self:is_dlc_unlocked("pn2")
end

function GenericDLCManager:has_max()
	return self:is_dlc_unlocked("max")
end

function GenericDLCManager:has_dgm()
	return self:is_dlc_unlocked("dgm")
end

function GenericDLCManager:has_gcm()
	return self:is_dlc_unlocked("gcm")
end

function GenericDLCManager:has_ztm()
	return self:is_dlc_unlocked("ztm")
end

function GenericDLCManager:has_joy()
	return self:is_dlc_unlocked("joy")
end

function GenericDLCManager:has_fdm()
	return self:is_dlc_unlocked("fdm")
end

function GenericDLCManager:has_ecp()
	return self:is_dlc_unlocked("ecp")
end

function GenericDLCManager:has_myh()
	return self:is_dlc_unlocked("myh")
end

function GenericDLCManager:has_pbm()
	return self:is_dlc_unlocked("pbm")
end

function GenericDLCManager:has_fgl()
	return self:is_dlc_unlocked("fgl")
end

function GenericDLCManager:has_osa()
	return self:is_dlc_unlocked("osa")
end

function GenericDLCManager:has_gwm()
	return self:is_dlc_unlocked("gwm")
end

function GenericDLCManager:has_ami()
	return self:is_dlc_unlocked("ami")
end

function GenericDLCManager:has_pmp()
	return self:is_dlc_unlocked("pmp")
end

function GenericDLCManager:has_ghm()
	return self:is_dlc_unlocked("ghm")
end

function GenericDLCManager:has_goty_all_dlc_bundle_2014()
	return self:has_goty_weapon_bundle_2014() and self:has_goty_heist_bundle_2014() and self:is_dlcs_unlocked({
		"character_pack_clover"
	})
end

function GenericDLCManager:has_soundtrack_or_cce()
	return self:is_dlc_unlocked("soundtrack") or self:is_dlc_unlocked("cce")
end

function GenericDLCManager:has_freed_old_hoxton(data)
	if SystemInfo:platform() == Idstring("WIN32") then
		return self:is_dlc_unlocked("pd2_clan") and self:has_achievement(data)
	end

	return true
end

function GenericDLCManager:has_armored_transport_and_intel(data)
	return self:is_dlc_unlocked("armored_transport") and self:has_achievement(data)
end

function GenericDLCManager:has_hlm2()
	return Global.dlc_manager.all_dlc_data.hlm2 and Global.dlc_manager.all_dlc_data.hlm2.verified or self:is_dlc_unlocked("hlm2_aus")
end

function GenericDLCManager:has_hlm2_deluxe()
	return Global.dlc_manager.all_dlc_data.hlm2_deluxe and Global.dlc_manager.all_dlc_data.hlm2_deluxe.verified or self:is_dlc_unlocked("hlm2_aus")
end

function GenericDLCManager:has_parent_dlc(data)
	return data and data.parent_dlc and self:is_dlc_unlocked(data.parent_dlc)
end

function GenericDLCManager:has_achievement(data)
	local achievement = managers.achievment and data and data.achievement_id and managers.achievment:get_info(data.achievement_id)

	return achievement and achievement.awarded or false
end

function GenericDLCManager:has_achievement_milestone(data)
	local milestone = data and data.milestone_id and managers.achievment:get_milestone(data.milestone_id)

	return milestone.awarded
end

function GenericDLCManager:has_stat(data)
	local sa_handler = Steam:sa_handler()

	return sa_handler:get_stat(data.stat_id) >= (data.stat_value or 1)
end

function GenericDLCManager:has_dlc_or_soundtrack_or_cce(dlc)
	return managers.dlc:is_dlc_unlocked(dlc) or managers.dlc:has_soundtrack_or_cce()
end

PS3DLCManager = PS3DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("PS3"):key()] = PS3DLCManager
PS3DLCManager.SERVICE_ID = "EP4040-BLES01902_00"

function PS3DLCManager:init()
	PS3DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					filename = "full_game_key.edat",
					product_id = self.SERVICE_ID .. "-PAYDAY2NPEU00000"
				},
				preorder = {
					filename = "preorder_dlc_key.edat",
					product_id = self.SERVICE_ID .. "-PPAYDAY2XX000006"
				},
				sweettooth = {
					filename = "sweettooth_dlc_key.edat",
					product_id = self.SERVICE_ID .. "-PPAYDAY2SWTTOOTH"
				},
				armored_transport = {
					filename = "armored_transport_dlc_key.edat",
					product_id = self.SERVICE_ID .. "-PPAYDAY2ARMORDTR"
				},
				gage_pack = {
					filename = "gagepack_1_dlc_key.edat",
					product_id = self.SERVICE_ID .. "-PPAYDAY2GAGEPAK1"
				},
				gage_pack_lmg = {
					filename = "gagepack_2_dlc_key.edat",
					product_id = self.SERVICE_ID .. "-PPAYDAY2GAGEPAK2"
				}
			}
		}

		self:_verify_dlcs()
	end
end

function PS3DLCManager:_verify_dlcs()
	local all_dlc = {}

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if not dlc_data.verified then
			table.insert(all_dlc, dlc_data.filename)
		end
	end

	local verified_dlcs = PS3:check_dlc_availability(all_dlc)
	Global.dlc_manager.verified_dlcs = verified_dlcs

	for _, verified_filename in pairs(verified_dlcs) do
		for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
			if dlc_data.filename == verified_filename then
				print("DLC verified:", verified_filename)

				dlc_data.verified = true

				break
			end
		end
	end
end

function PS3DLCManager:_init_NPCommerce()
	PS3:set_service_id(self.SERVICE_ID)

	local result = NPCommerce:init()

	print("init result", result)

	if not result then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	local result = NPCommerce:open(callback(self, self, "cb_NPCommerce"))

	print("open result", result)

	if result < 0 then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	return true
end

function PS3DLCManager:buy_full_game()
	print("[PS3DLCManager:buy_full_game]")

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		product = "full_game",
		type = "buy_product"
	}
	self._activity = {
		type = "open"
	}
end

function PS3DLCManager:buy_product(product_name)
	print("[PS3DLCManager:buy_product]", product_name)

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		type = "buy_product",
		product = product_name
	}
	self._activity = {
		type = "open"
	}
end

function PS3DLCManager:cb_NPCommerce(result, info)
	print("[PS3DLCManager:cb_NPCommerce]", result, info)

	for i, k in pairs(info) do
		print(i, k)
	end

	self._NPCommerce_cb_results = self._NPCommerce_cb_results or {}

	print("self._activity", self._activity and inspect(self._activity))
	table.insert(self._NPCommerce_cb_results, {
		result,
		info
	})

	if not self._activity then
		return
	elseif self._activity.type == "open" then
		if info.category_error or info.category_done == false then
			self._activity = nil

			managers.system_menu:close("waiting_for_NPCommerce_open")
			self:_close_NPCommerce()
		else
			managers.system_menu:close("waiting_for_NPCommerce_open")

			local product_id = Global.dlc_manager.all_dlc_data[self._request.product].product_id

			print("starting storebrowse", product_id)

			local ret = NPCommerce:storebrowse("product", product_id, true)

			if not ret then
				self._activity = nil

				managers.menu:show_NPCommerce_checkout_fail()
				self:_close_NPCommerce()
			end

			self._activity = {
				type = "browse"
			}
		end
	elseif self._activity.type == "browse" then
		if info.browse_succes then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_success()
			self:_close_NPCommerce()
		elseif info.browse_back then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.category_error then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_fail()
			self:_close_NPCommerce()
		end
	elseif self._activity.type == "checkout" then
		if info.checkout_error then
			self._activity = nil

			managers.menu:show_NPCommerce_checkout_fail()
			self:_close_NPCommerce()
		elseif info.checkout_cancel then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.checkout_success then
			self._activity = nil

			self:_close_NPCommerce()
		end
	end

	print("/[PS3DLCManager:cb_NPCommerce]")
end

function PS3DLCManager:_close_NPCommerce()
	print("[PS3DLCManager:_close_NPCommerce]")
	NPCommerce:destroy()
end

function PS3DLCManager:cb_confirm_purchase_yes(sku_data)
	NPCommerce:checkout(sku_data.skuid)
end

function PS3DLCManager:cb_confirm_purchase_no()
	self._activity = nil

	self:_close_NPCommerce()
end

X360DLCManager = X360DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("X360"):key()] = X360DLCManager

function X360DLCManager:init()
	X360DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					is_default = true,
					verified = true,
					index = 0
				},
				preorder = {
					is_default = false,
					index = 1
				}
			}
		}

		self:_verify_dlcs()
	end
end

function X360DLCManager:_verify_dlcs()
	local found_dlc = {}
	local status = XboxLive:check_dlc_availability(0, 100, found_dlc)

	if not status then
		Application:error("XboxLive:check_dlc_availability failed", inspect(found_dlc))

		return
	end

	print("[X360DLCManager:_verify_dlcs] found DLC:")

	for i, k in pairs(found_dlc) do
		print(i, k)
	end

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if found_dlc[dlc_data.index] == "corrupt" then
			print("[X360DLCManager:_verify_dlcs] Found corrupt DLC:", dlc_name)

			dlc_data.is_corrupt = true
		elseif dlc_data.is_default or found_dlc[dlc_data.index] == true then
			dlc_data.verified = true
		else
			dlc_data.verified = false
		end
	end

	if found_dlc.has_corrupt_data then
		print("[X360DLCManager:_verify_dlcs] Found at least one corrupt DLC.")

		self._has_corrupt_data = true
	end
end

function X360DLCManager:on_signin_complete()
	self:_verify_dlcs()
end

PS4DLCManager = PS4DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("PS4"):key()] = PS4DLCManager

function PS4DLCManager:init()
	PS4DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					verified_for_TheBigScore = true,
					verified = true
				},
				preorder = {
					verified_for_TheBigScore = false,
					product_id = "PAYDAYLOOTBAGDLC"
				},
				career_criminal_edition = {
					verified_for_TheBigScore = true,
					verified = true
				},
				alienware_alpha = {
					verified_for_TheBigScore = true,
					verified = true
				},
				alienware_alpha_promo = {
					verified_for_TheBigScore = true,
					verified = true
				},
				soundtrack = {
					verified_for_TheBigScore = true,
					verified = true
				},
				pdth_soundtrack = {
					verified_for_TheBigScore = true,
					verified = true
				},
				armored_transport = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack_lmg = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack_jobs = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack_snp = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack_shotgun = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack_assault = {
					verified_for_TheBigScore = true,
					verified = true
				},
				big_bank = {
					verified_for_TheBigScore = true,
					verified = true
				},
				hl_miami = {
					verified_for_TheBigScore = true,
					verified = true
				},
				hlm_game = {
					verified_for_TheBigScore = true,
					verified = true
				},
				character_pack_clover = {
					verified_for_TheBigScore = true,
					verified = true
				},
				character_pack_dragan = {
					verified_for_TheBigScore = true,
					verified = true
				},
				hope_diamond = {
					verified_for_TheBigScore = true,
					verified = true
				},
				the_bomb = {
					verified_for_TheBigScore = true,
					verified = true
				},
				xmas_soundtrack = {
					verified_for_TheBigScore = true,
					verified = true
				},
				twitch_pack = {
					verified_for_TheBigScore = true,
					verified = true
				},
				humble_pack2 = {
					verified_for_TheBigScore = true,
					verified = true
				},
				gage_pack_historical = {
					verified_for_TheBigScore = true,
					verified = true
				},
				akm4_pack = {
					verified = false,
					product_id = "PD2DLCBUTCHCAR01",
					verified_for_TheBigScore = true
				},
				bbq = {
					verified = false,
					product_id = "PD2DLCBUTCHBBQ02",
					verified_for_TheBigScore = true
				},
				west = {
					verified = false,
					product_id = "PD2DLCBUTCHWES03",
					verified_for_TheBigScore = true
				},
				arena = {
					verified = false,
					product_id = "PD2DLCALESSOHT04",
					verified_for_TheBigScore = true
				},
				kenaz = {
					verified = false,
					product_id = "PD2DLCGOLDENGC05",
					verified_for_TheBigScore = true
				},
				character_pack_sokol = {
					verified = false,
					product_id = "PD2DLCSOKOLCHR06",
					verified_for_TheBigScore = true
				},
				turtles = {
					verified = false,
					product_id = "PD2DLCGAGENINJ07",
					verified_for_TheBigScore = true
				},
				dragon = {
					verified = false,
					product_id = "PD2DLCYAKUZACH08",
					verified_for_TheBigScore = true
				},
				steel = {
					verified = false,
					product_id = "PD2DLCGAGECHIV09",
					verified_for_TheBigScore = true
				},
				berry = {
					verified = false,
					product_id = "PD2DLCPOINTBRK10",
					verified_for_TheBigScore = true
				},
				mad = {
					verified = true,
					product_id = "PD2DLCHARDCORE11",
					verified_for_TheBigScore = true
				},
				coco = {
					verified = true,
					product_id = "PD2DLCJIMMYCHA12",
					verified_for_TheBigScore = true
				},
				pal = {
					verified = false,
					product_id = "PD2DLCWOLFPACK13",
					verified_for_TheBigScore = false
				},
				peta = {
					verified = false,
					product_id = "PD2DLCGOATSIMU14",
					verified_for_TheBigScore = false
				},
				opera = {
					verified = false,
					product_id = "PD2DLCSYDNEYCH15",
					verified_for_TheBigScore = false
				},
				born = {
					verified = false,
					product_id = "PD2DLCBIKERHST16",
					verified_for_TheBigScore = false
				},
				wild = {
					verified = false,
					product_id = "PD2DLCBIKERCHA17",
					verified_for_TheBigScore = false
				},
				rota = {
					verified_for_TheBigScore = true,
					verified = true
				},
				pim = {
					verified = false,
					product_id = "PD2DLCJWICKWPN18",
					verified_for_TheBigScore = false
				},
				tango = {
					verified = false,
					product_id = "PD2DLCGAGESPEC19",
					verified_for_TheBigScore = false
				},
				friend = {
					verified = false,
					product_id = "PD2DLCSCARFHST20",
					verified_for_TheBigScore = false
				},
				chico = {
					verified = false,
					product_id = "PD2DLCSCARFCHA21",
					verified_for_TheBigScore = false
				},
				spa = {
					verified = false,
					product_id = "PD2DLCJWICKHST22",
					verified_for_TheBigScore = false
				},
				grv = {
					verified = false,
					product_id = "PD2DLCGAGERUSS23",
					verified_for_TheBigScore = false
				},
				pn2 = {
					verified_for_TheBigScore = true,
					verified = true
				}
			}
		}

		self:_verify_dlcs()
	end
end

function PS4DLCManager:_verify_dlcs()
	local unlock_all_test = false
	local titleVersion = PS3:get_titleVersion()

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if titleVersion == 2 or unlock_all_test then
			dlc_data.verified = true
		else
			if dlc_data.is_default or dlc_data.verified == true then
				dlc_data.verified = true
			else
				dlc_data.verified = PS3:has_entitlement(dlc_data.product_id)
			end

			if titleVersion == 1 and dlc_data.verified_for_TheBigScore == true then
				dlc_data.verified = true
			end
		end
	end
end

function PS4DLCManager:_init_NPCommerce()
	local result = NPCommerce:init()

	print("init result", result)

	if not result then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	local result = NPCommerce:open(callback(self, self, "cb_NPCommerce"))

	print("open result", result)

	if result < 0 then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	return true
end

function PS4DLCManager:buy_full_game()
	print("[PS4DLCManager:buy_full_game]")

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		product = "full_game",
		type = "buy_product"
	}
	self._activity = {
		type = "open"
	}
end

function PS4DLCManager:buy_product(product_name)
	print("[PS4DLCManager:buy_product]", product_name)

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		type = "buy_product",
		product = product_name
	}
	self._activity = {
		type = "open"
	}
end

function PS4DLCManager:cb_NPCommerce(result, info)
	print("[PS4DLCManager:cb_NPCommerce]", result, info)

	for i, k in pairs(info) do
		print(i, k)
	end

	self._NPCommerce_cb_results = self._NPCommerce_cb_results or {}

	print("self._activity", self._activity and inspect(self._activity))
	table.insert(self._NPCommerce_cb_results, {
		result,
		info
	})

	if not self._activity then
		return
	elseif self._activity.type == "open" then
		if info.category_error or info.category_done == false then
			self._activity = nil

			managers.system_menu:close("waiting_for_NPCommerce_open")
			self:_close_NPCommerce()
		else
			managers.system_menu:close("waiting_for_NPCommerce_open")

			local product_id = Global.dlc_manager.all_dlc_data[self._request.product].product_id

			print("starting storebrowse", product_id)

			local ret = NPCommerce:storebrowse("product", product_id, true)

			if not ret then
				self._activity = nil

				managers.menu:show_NPCommerce_checkout_fail()
				self:_close_NPCommerce()
			end

			self._activity = {
				type = "browse"
			}
		end
	elseif self._activity.type == "browse" then
		if info.browse_succes then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_success()
			self:_close_NPCommerce()
		elseif info.browse_back then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.category_error then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_fail()
			self:_close_NPCommerce()
		end
	elseif self._activity.type == "checkout" then
		if info.checkout_error then
			self._activity = nil

			managers.menu:show_NPCommerce_checkout_fail()
			self:_close_NPCommerce()
		elseif info.checkout_cancel then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.checkout_success then
			self._activity = nil

			self:_close_NPCommerce()
		end
	end

	print("/[PS4DLCManager:cb_NPCommerce]")
end

function PS4DLCManager:_close_NPCommerce()
	print("[PS4DLCManager:_close_NPCommerce]")
	NPCommerce:destroy()
end

function PS4DLCManager:cb_confirm_purchase_yes(sku_data)
	NPCommerce:checkout(sku_data.skuid)
end

function PS4DLCManager:cb_confirm_purchase_no()
	self._activity = nil

	self:_close_NPCommerce()
end

XB1DLCManager = XB1DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("XB1"):key()] = XB1DLCManager

function XB1DLCManager:init()
	XB1DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					is_default = true,
					verified = true,
					index = 0
				},
				preorder = {
					is_default = false,
					product_id = "f4bfed8e-a74c-4bd5-baad-5b985d0ef15d",
					index = 1
				},
				career_criminal_edition = {
					index = 2,
					is_default = true
				},
				alienware_alpha = {
					index = 3,
					is_default = true
				},
				alienware_alpha_promo = {
					index = 4,
					is_default = true
				},
				soundtrack = {
					index = 5,
					is_default = true
				},
				pdth_soundtrack = {
					index = 6,
					is_default = true
				},
				armored_transport = {
					index = 7,
					is_default = true
				},
				gage_pack = {
					index = 8,
					is_default = true
				},
				gage_pack_lmg = {
					index = 9,
					is_default = true
				},
				gage_pack_jobs = {
					index = 10,
					is_default = true
				},
				gage_pack_snp = {
					index = 11,
					is_default = true
				},
				gage_pack_shotgun = {
					index = 12,
					is_default = true
				},
				gage_pack_assault = {
					index = 13,
					is_default = true
				},
				big_bank = {
					index = 14,
					is_default = true
				},
				hl_miami = {
					index = 15,
					is_default = true
				},
				hlm_game = {
					is_default = true,
					index = 16,
					external = true
				},
				character_pack_clover = {
					index = 17,
					is_default = true
				},
				character_pack_dragan = {
					index = 18,
					is_default = true
				},
				hope_diamond = {
					index = 19,
					is_default = true
				},
				the_bomb = {
					index = 20,
					is_default = true
				},
				xmas_soundtrack = {
					index = 21,
					is_default = true
				},
				twitch_pack = {
					index = 22,
					is_default = true
				},
				humble_pack2 = {
					index = 23,
					is_default = true
				},
				gage_pack_historical = {
					index = 24,
					is_default = true
				}
			}
		}

		self:_verify_dlcs()
	end
end

function XB1DLCManager:_verify_dlcs()
	local dlc_content_updated = false
	local old_verified = nil
	local unlock_all_test = false

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		old_verified = dlc_data.verified or false

		if unlock_all_test then
			dlc_data.verified = true
		elseif dlc_data.is_default then
			dlc_data.verified = true
		else
			dlc_data.verified = XboxLive and XboxLive:check_dlc(dlc_data.product_id)
		end

		dlc_content_updated = dlc_content_updated or old_verified ~= dlc_data.verified
	end

	return dlc_content_updated
end

function XB1DLCManager:chk_content_updated()
	print("[XB1DLCManager:chk_content_updated]")

	if not managers.blackmarket:currently_customizing_mask() and self:_verify_dlcs() then
		print("[XB1DLCManager:chk_content_updated] content updated")

		if managers.experience and managers.upgrades then
			for level = 0, managers.experience:current_level(), 1 do
				managers.upgrades:aquire_from_level_tree(level, true)
				managers.upgrades:verify_level_tree(level, true)
			end
		end

		self:give_dlc_and_verify_blackmarket()

		if managers.crimenet then
			managers.crimenet:reset_seed()
		end
	end
end

function XB1DLCManager:on_signin_complete()
	self:chk_content_updated()
end

WINDLCManager = WINDLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("WIN32"):key()] = WINDLCManager

function WINDLCManager:init()
	WINDLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					app_id = "218620",
					verified = true
				},
				preorder = {
					app_id = "247450",
					no_install = true
				},
				career_criminal_edition = {
					app_id = "218630",
					no_install = true
				},
				alienware_alpha = {
					app_id = "328861",
					no_install = true
				},
				alienware_alpha_promo = {
					app_id = "318720",
					no_install = true
				},
				soundtrack = {
					app_id = "254260",
					no_install = true
				},
				pdth_soundtrack = {
					app_id = "207816",
					no_install = true
				},
				armored_transport = {
					app_id = "264610",
					no_install = true
				},
				gage_pack = {
					app_id = "267380",
					no_install = true
				},
				gage_pack_lmg = {
					app_id = "275590",
					no_install = true
				},
				gage_pack_jobs = {
					app_id = "259381",
					no_install = true
				},
				gage_pack_snp = {
					app_id = "259380",
					no_install = true
				},
				gage_pack_shotgun = {
					app_id = "311050",
					no_install = true
				},
				gage_pack_assault = {
					app_id = "320030",
					no_install = true
				},
				overkill_pack = {
					app_id = "348090",
					no_install = true
				},
				complete_overkill_pack = {
					app_id = "348091",
					no_install = true
				},
				akm4_pack = {
					app_id = "351890",
					no_install = true
				},
				big_bank = {
					app_id = "306690",
					no_install = true
				},
				hl_miami = {
					app_id = "323500",
					no_install = true
				},
				hlm_game = {
					no_install = true,
					app_id = "219150",
					external = true
				},
				hlm2 = {
					no_install = true,
					app_id = "274170",
					external = true
				},
				hlm2_deluxe = {
					no_install = true,
					app_id = "355390",
					external = true
				},
				hlm2_aus = {
					no_install = true,
					app_id = "338951",
					external = true
				},
				speedrunners = {
					no_install = true,
					app_id = "207140",
					external = true
				},
				character_pack_clover = {
					app_id = "337661",
					no_install = true
				},
				character_pack_dragan = {
					app_id = "344140",
					no_install = true
				},
				character_pack_sokol = {
					app_id = "374301",
					no_install = true
				},
				hope_diamond = {
					app_id = "337660",
					no_install = true
				},
				the_bomb = {
					app_id = "339480",
					no_install = true
				},
				bbq = {
					app_id = "358150",
					no_install = true
				},
				west = {
					app_id = "349830",
					no_install = true
				},
				arena = {
					app_id = "366660",
					no_install = true
				},
				kenaz = {
					app_id = "374300",
					no_install = true
				},
				turtles = {
					app_id = "384021",
					no_install = true
				},
				dragon = {
					app_id = "384020",
					no_install = true
				},
				berry = {
					app_id = "422400",
					no_install = true
				},
				xmas_soundtrack = {
					app_id = "267381",
					no_install = true
				},
				bsides_soundtrack = {
					app_id = "368870",
					no_install = true
				},
				twitch_pack = {
					app_id = "306110",
					no_install = true
				},
				humble_pack2 = {
					app_id = "331040",
					no_install = true
				},
				humble_pack3 = {
					app_id = "375380",
					no_install = true
				},
				humble_pack4 = {
					app_id = "375381",
					no_install = true
				},
				e3_s15a = {
					app_id = "375382",
					no_install = true
				},
				e3_s15b = {
					app_id = "375383",
					no_install = true
				},
				e3_s15c = {
					app_id = "375384",
					no_install = true
				},
				e3_s15d = {
					app_id = "375385",
					no_install = true
				},
				pdcon_2015 = {
					app_id = "338950",
					no_install = true
				},
				gage_pack_historical = {
					app_id = "331900",
					no_install = true
				},
				steel = {
					app_id = "401650",
					no_install = true
				},
				bobblehead = {
					app_id = "328860",
					no_install = true
				},
				peta = {
					app_id = "433730",
					no_install = true
				},
				pal = {
					no_install = true,
					app_id = "441600",
					external = true
				},
				opera = {
					app_id = "468410",
					no_install = true
				},
				jigg = {
					app_id = "486610",
					no_install = true
				},
				wild = {
					app_id = "450660",
					no_install = true
				},
				born = {
					app_id = "487210",
					no_install = true
				},
				dbd_deluxe = {
					no_install = true,
					app_id = "489980",
					external = true
				},
				pim = {
					app_id = "545100",
					no_install = true
				},
				rota = {
					app_id = "218620",
					no_install = true
				},
				gotti_bundle = {
					app_id = "218620",
					no_install = true
				},
				nyck_bundle = {
					app_id = "218620",
					no_install = true
				},
				sparkle = {
					app_id = "532810",
					no_install = true
				},
				urf_bundle = {
					app_id = "218620",
					no_install = true
				},
				tango = {
					app_id = "548420",
					no_install = true
				},
				friend = {
					app_id = "548421",
					no_install = true
				},
				chico = {
					app_id = "548422",
					no_install = true
				},
				rvd = {
					app_id = "218620",
					no_install = true
				},
				pd2_clan = {
					source_id = "103582791433980119"
				},
				dbd_clan = {
					source_id = "103582791441335905"
				},
				solus_clan = {
					source_id = "103582791438562929"
				},
				pdcon_2016 = {
					app_id = "552490",
					no_install = true
				},
				win_bundle = {
					app_id = "218620",
					no_install = true
				},
				swm = {
					app_id = "588130",
					no_install = true
				},
				yor_bundle = {
					app_id = "218620",
					no_install = true
				},
				sha = {
					app_id = "218620",
					no_install = true
				},
				spa = {
					app_id = "591710",
					no_install = true
				},
				grv = {
					app_id = "612900",
					no_install = true
				},
				amp = {
					app_id = "218620",
					no_install = true
				},
				mp2 = {
					app_id = "218620",
					no_install = true
				},
				mom = {
					app_id = "218620",
					no_install = true
				},
				ant = {
					no_install = true,
					app_id = "489570",
					external = true
				},
				pn2 = {
					app_id = "618940",
					no_install = true
				},
				max = {
					app_id = "218620",
					no_install = true
				},
				trk = {
					app_id = "218620",
					no_install = true
				},
				dgm = {
					app_id = "218620",
					no_install = true
				},
				ztm = {
					app_id = "735640",
					no_install = true
				},
				joy = {
					app_id = "218620",
					no_install = true
				},
				raidww2_clan = {
					source_id = "103582791460014708"
				},
				fdm = {
					app_id = "707620",
					no_install = true
				},
				ecp = {
					app_id = "758420",
					no_install = true
				},
				cmo = {
					app_id = "218620",
					no_install = true
				},
				cmt = {
					app_id = "218620",
					no_install = true
				},
				pbm = {
					app_id = "735630",
					no_install = true
				},
				dnm = {
					app_id = "218620",
					no_install = true
				},
				wwh = {
					app_id = "218620",
					no_install = true
				},
				myh = {
					app_id = "218620",
					no_install = true
				},
				fgl = {
					app_id = "218620",
					no_install = true
				},
				osa = {
					app_id = "218620",
					no_install = true
				},
				ami = {
					app_id = "218620",
					no_install = true
				},
				gwm = {
					app_id = "218620",
					no_install = true
				},
				dmg = {
					app_id = "218620",
					no_install = true
				},
				ggac = {
					app_id = "218620",
					no_install = true
				},
				pmp = {
					app_id = "218620",
					no_install = true
				},
				ghm = {
					app_id = "218620",
					no_install = true
				}
			}
		}

		self:init_generated()
		self:_verify_dlcs()
	end
end

function WINDLCManager:_check_dlc_data(dlc_data)
	if SystemInfo:distribution() == Idstring("STEAM") then
		if dlc_data.app_id then
			if dlc_data.no_install then
				if Steam:is_product_owned(dlc_data.app_id) then
					return true
				end
			elseif Steam:is_product_installed(dlc_data.app_id) then
				return true
			end
		elseif dlc_data.source_id and Steam:is_user_in_source(Steam:userid(), dlc_data.source_id) then
			return true
		end
	end
end

function WINDLCManager:_verify_dlcs()
	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if not dlc_data.verified and self:_check_dlc_data(dlc_data) then
			dlc_data.verified = true
		end
	end
end

function WINDLCManager:check_pdth(clbk)
	if not self._check_pdth_request and clbk and Global.dlc_manager.has_pdth ~= nil then
		clbk(Global.dlc_manager.has_pdth, Global.dlc_manager.pdth_tester)

		return
	end

	self._check_pdth_callback = clbk

	if self._check_pdth_request or Global.dlc_manager.has_pdth ~= nil then
		return
	end

	local has_pdth = Steam:is_product_owned(24240)
	Global.dlc_manager.has_pdth = has_pdth

	if has_pdth then
		local function result_function(success, page)
			if success then
				local json_reply_match = "\"([^,:\"]+)\"%s*:%s*\"([^\"]+)\""
				local key, value = string.gmatch(page, json_reply_match)()

				if key and value then
					key = string.lower(key)
					value = string.lower(value)

					if key == "achieved" and value == "true" then
						Global.dlc_manager.pdth_tester = true
					elseif key == "error" then
						print("[WINDLCManager:check_pdth] Request error ", value)
					end
				end
			end

			if self._check_pdth_callback then
				self._check_pdth_callback(Global.dlc_manager.has_pdth, Global.dlc_manager.pdth_tester)

				self._check_pdth_callback = nil
			end

			self._check_pdth_request = nil
		end

		print("[WINDLCManager:check_pdth] Send request")

		self._check_pdth_request = true

		Steam:http_request("http://fbi.overkillsoftware.com/veterancheck/veterancheck.php?steamid=" .. Steam:userid(), result_function)
	end
end

function WINDLCManager:chk_vr_dlc()
	local steam_vr = Steam:is_app_installed("250820")
	local payday2_vr = Steam:is_product_installed("826090")

	if steam_vr and not payday2_vr then
		Steam:install_dlc("826090")

		return true
	elseif not steam_vr and payday2_vr then
		Steam:uninstall_dlc("826090")

		return false
	end

	return nil
end

function WINDLCManager:chk_content_updated()
	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if not dlc_data.verified and self:_check_dlc_data(dlc_data) then
			managers.menu:show_dlc_require_restart()

			break
		end
	end
end

require("lib/managers/dlc/DLCManagerGeneratedData")
