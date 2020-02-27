local access_type_walk_only = {
	walk = true
}
local access_type_all = {
	acrobatic = true,
	walk = true
}
local ignored_groups = {
	"Phalanx_minion",
	"Phalanx_vip"
}
MutatorEnemyReplacer = MutatorEnemyReplacer or class(BaseMutator)
MutatorEnemyReplacer._type = "MutatorEnemyReplacer"
MutatorEnemyReplacer.name_id = "mutator_specials_override"
MutatorEnemyReplacer.desc_id = "mutator_specials_override_desc"
MutatorEnemyReplacer.has_options = true
MutatorEnemyReplacer.reductions = {
	money = 0.35,
	exp = 0.35
}
MutatorEnemyReplacer.disables_achievements = true
MutatorEnemyReplacer.categories = {
	"enemies"
}
MutatorEnemyReplacer.incompatibility_tags = {
	"replaces_units"
}
MutatorEnemyReplacer.icon_coords = {
	6,
	1
}

function MutatorEnemyReplacer:register_values(mutator_manager)
	self:register_value("override_enemy", self:default_override_enemy(), "oe")
end

function MutatorEnemyReplacer:setup()
	self._groups = self._groups or {}
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:modify_unit_categories(tweak_data.group_ai, difficulty_index)
end

function MutatorEnemyReplacer:name(lobby_data)
	local name = MutatorEnemyReplacer.super.name(self)

	if self:_mutate_name("override_enemy") then
		return string.format("%s - %s", name, managers.localization:text("mutator_specials_override_" .. tostring(self:value("override_enemy"))))
	else
		return name
	end
end

function MutatorEnemyReplacer:get_override_enemy()
	return self:value("override_enemy")
end

function MutatorEnemyReplacer:default_override_enemy()
	return "tank"
end

function MutatorEnemyReplacer:setup_options_gui(node)
	local params = {
		callback = "_update_mutator_value",
		name = "enemy_selector_choice",
		text_id = "mutator_specials_override_select",
		filter = true,
		update_callback = callback(self, self, "_update_selected_enemy")
	}
	local data_node = {
		{
			value = "tank",
			text_id = "mutator_specials_override_tank",
			_meta = "option"
		},
		{
			value = "taser",
			text_id = "mutator_specials_override_taser",
			_meta = "option"
		},
		{
			value = "shield",
			text_id = "mutator_specials_override_shield",
			_meta = "option"
		},
		{
			value = "spooc",
			text_id = "mutator_specials_override_spooc",
			_meta = "option"
		},
		{
			value = "medic",
			text_id = "mutator_specials_override_medic",
			_meta = "option"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_override_enemy())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorEnemyReplacer:_update_selected_enemy(item)
	self:set_value("override_enemy", item:value())
end

function MutatorEnemyReplacer:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("enemy_selector_choice")

		if slider then
			slider:set_value(self:default_override_enemy())
		end
	end
end

function MutatorEnemyReplacer:modify_unit_categories(group_ai_tweak, difficulty_index)
	for key, value in pairs(group_ai_tweak.special_unit_spawn_limits) do
		if key == self:get_override_enemy() then
			group_ai_tweak.special_unit_spawn_limits[key] = math.huge
		end
	end

	local unit_group = self["_get_unit_group_" .. self:get_override_enemy()](self, difficulty_index)

	for group, units in pairs(group_ai_tweak.unit_categories) do
		if not table.contains(ignored_groups, group) then
			print("[Mutators] Replacing unit group:", group)

			group_ai_tweak.unit_categories[group] = unit_group
		else
			print("[Mutators] Ignoring unit group:", group)
		end
	end
end

function MutatorEnemyReplacer:_get_unit_group_tank(difficulty_index)
	if not self._groups.tank then
		if difficulty_index < 6 then
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
					},
					federales = {
						Idstring("units/pd2_dlc_mad/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870")
					}
				},
				access = access_type_all
			}
		elseif difficulty_index <= 7 then
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
					},
					federales = {
						Idstring("units/pd2_dlc_mad/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249")
					}
				},
				access = access_type_all
			}
		else
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870")
					}
				},
				access = access_type_all
			}
		end
	end

	return self._groups.tank
end

function MutatorEnemyReplacer:_get_unit_group_shield(difficulty_index)
	if not self._groups.shield then
		if difficulty_index <= 7 then
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield"),
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
					},
					federales = {
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2")
					}
				},
				access = access_type_all
			}
		else
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
					},
					federales = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield")
					}
				},
				access = access_type_all
			}
		end
	end

	return self._groups.shield
end

function MutatorEnemyReplacer:_get_unit_group_taser(difficulty_index)
	if not self._groups.taser then
		self._groups.taser = {
			special_type = "taser",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_tazer_policia_federale/ene_swat_tazer_policia_federale")
				}
			},
			access = access_type_all
		}
	end

	return self._groups.taser
end

function MutatorEnemyReplacer:_get_unit_group_spooc(difficulty_index)
	if not self._groups.spooc then
		if difficulty_index <= 7 then
			self._groups.spooc = {
				special_type = "spooc",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale")
					}
				},
				access = access_type_all
			}
		else
			self._groups.spooc = {
				special_type = "spooc",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
					},
					murkywater = {
						Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale")
					}
				},
				access = access_type_all
			}
		end
	end

	return self._groups.spooc
end

function MutatorEnemyReplacer:_get_unit_group_medic(difficulty_index)
	if not self._groups.medic then
		self._groups.medic = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
					Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
				},
				russia = {
					Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
					Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale/ene_swat_medic_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale_r870/ene_swat_medic_policia_federale_r870")
				}
			},
			access = access_type_all
		}
	end

	return self._groups.medic
end

MutatorMediDozer = MutatorMediDozer or class(BaseMutator)
MutatorMediDozer._type = "MutatorMediDozer"
MutatorMediDozer.name_id = "mutator_medidozer"
MutatorMediDozer.desc_id = "mutator_medidozer_desc"
MutatorMediDozer.reductions = {
	money = 0,
	exp = 0
}
MutatorMediDozer.disables_achievements = true
MutatorMediDozer.categories = {
	"enemies"
}
MutatorMediDozer.incompatibility_tags = {
	"replaces_units"
}
MutatorMediDozer.icon_coords = {
	8,
	1
}

function MutatorMediDozer:setup()
	self._groups = self._groups or {}
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:modify_unit_categories(tweak_data.group_ai, difficulty_index)
end

function MutatorMediDozer:modify_unit_categories(group_ai_tweak, difficulty_index)
	group_ai_tweak.special_unit_spawn_limits = {
		shield = 0,
		taser = 0,
		spooc = 0,
		tank = math.huge,
		medic = math.huge
	}
	group_ai_tweak.unit_categories.medic_R870 = {
		special_type = "medic",
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),
				Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
			},
			russia = {
				Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),
				Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic"),
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic")
			},
			federales = {
				Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale/ene_swat_medic_policia_federale"),
				Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale/ene_swat_medic_policia_federale")
			}
		},
		access = access_type_all
	}
	group_ai_tweak.unit_categories.medic_R870 = {
		special_type = "medic",
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
				Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
			},
			russia = {
				Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
				Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"),
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
			},
			federales = {
				Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale_r870/ene_swat_medic_policia_federale_r870"),
				Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale_r870/ene_swat_medic_policia_federale_r870")
			}
		},
		access = access_type_all
	}

	for group, units_data in pairs(group_ai_tweak.unit_categories) do
		if not table.contains(ignored_groups, group) then
			if units_data.special_type then
				if units_data.special_type ~= "tank" and units_data.special_type ~= "medic" then
					group_ai_tweak.unit_categories[group] = group_ai_tweak.unit_categories.FBI_tank
				end
			elseif string.find(group, "r870") then
				group_ai_tweak.unit_categories[group] = group_ai_tweak.unit_categories.medic_R870
			else
				group_ai_tweak.unit_categories[group] = group_ai_tweak.unit_categories.medic_M4
			end
		end
	end
end

MutatorTitandozers = MutatorTitandozers or class(BaseMutator)
MutatorTitandozers._type = "MutatorTitandozers"
MutatorTitandozers.name_id = "mutator_titandozers"
MutatorTitandozers.desc_id = "mutator_titandozers_desc"
MutatorTitandozers.reductions = {
	money = 0,
	exp = 0
}
MutatorTitandozers.disables_achievements = true
MutatorTitandozers.categories = {
	"enemies"
}
MutatorTitandozers.incompatibility_tags = {}
MutatorTitandozers.icon_coords = {
	1,
	3
}
MutatorTitandozers.load_priority = -10

function MutatorTitandozers:setup()
	self._groups = self._groups or {}
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:modify_unit_categories(tweak_data.group_ai, difficulty_index)
end

function MutatorTitandozers:modify_unit_categories(group_ai_tweak, difficulty_index)
	group_ai_tweak.special_unit_spawn_limits.tank = math.huge
	local unit_group = self:_get_unit_group_titandozer(difficulty_index)

	for group, units_data in pairs(group_ai_tweak.unit_categories) do
		if not table.contains(ignored_groups, group) and units_data.special_type == "tank" then
			print("[Mutators] Replacing unit group:", group)

			group_ai_tweak.unit_categories[group] = unit_group
		end
	end
end

function MutatorTitandozers:_get_unit_group_titandozer(difficulty_index)
	if not self._groups.tank then
		self._groups.tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
				},
				russia = {
					Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
				},
				murkywater = {
					Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
				},
				federales = {
					Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
				}
			},
			access = access_type_all
		}
	end

	return self._groups.tank
end
