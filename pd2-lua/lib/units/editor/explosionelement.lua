ExplosionUnitElement = ExplosionUnitElement or class(FeedbackUnitElement)

function ExplosionUnitElement:init(unit)
	ExplosionUnitElement.super.init(self, unit)

	self._hed.damage = 40
	self._hed.player_damage = 10
	self._hed.explosion_effect = "effects/particles/explosions/explosion_grenade_launcher"
	self._hed.no_raycast_check_characters = nil
	self._hed.sound_event = "trip_mine_explode"

	table.insert(self._save_values, "damage")
	table.insert(self._save_values, "player_damage")
	table.insert(self._save_values, "explosion_effect")
	table.insert(self._save_values, "no_raycast_check_characters")
	table.insert(self._save_values, "sound_event")
end

function ExplosionUnitElement:update_selected(...)
	ExplosionUnitElement.super.update_selected(self, ...)
end

function ExplosionUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "damage", {
		floats = 0,
		min = 0
	}, "The damage done to beings and props from the explosion")
	self:_build_value_number(panel, panel_sizer, "player_damage", {
		floats = 0,
		min = 0
	}, "The player damage from the explosion")
	self:_build_value_combobox(panel, panel_sizer, "explosion_effect", table.list_add({
		"none"
	}, self:_effect_options()), "Select and explosion effect")
	self:_build_value_combobox(panel, panel_sizer, "sound_event", {
		"no_sound",
		"trip_mine_explode"
	})
	self:_build_value_checkbox(panel, panel_sizer, "no_raycast_check_characters", "No raycast check against characters")
	ExplosionUnitElement.super._build_panel(self, panel, panel_sizer)
end

function ExplosionUnitElement:add_to_mission_package()
	ExplosionUnitElement.super.add_to_mission_package(self)

	if self._hed.explosion_effect ~= "none" then
		managers.editor:add_to_world_package({
			category = "effects",
			name = self._hed.explosion_effect,
			continent = self._unit:unit_data().continent
		})
	end
end
