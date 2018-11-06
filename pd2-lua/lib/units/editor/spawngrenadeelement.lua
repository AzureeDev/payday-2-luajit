SpawnGrenadeUnitElement = SpawnGrenadeUnitElement or class(MissionElement)

function SpawnGrenadeUnitElement:init(unit)
	SpawnGrenadeUnitElement.super.init(self, unit)

	self._hed.grenade_type = "frag"
	self._hed.spawn_dir = Vector3(0, 0, 1)
	self._hed.strength = 1

	table.insert(self._save_values, "grenade_type")
	table.insert(self._save_values, "spawn_dir")
	table.insert(self._save_values, "strength")
end

function SpawnGrenadeUnitElement:test_element()
	if self._hed.grenade_type == "frag" then
		ProjectileBase.throw_projectile(self._hed.grenade_type, self._unit:position(), self._hed.spawn_dir * self._hed.strength)
	end
end

function SpawnGrenadeUnitElement:update_selected(time, rel_time)
	Application:draw_arrow(self._unit:position(), self._unit:position() + self._hed.spawn_dir * 35, 0.75, 0.75, 0.75, 0.075)
end

function SpawnGrenadeUnitElement:update_editing(time, rel_time)
	local kb = Input:keyboard()
	local speed = 60 * rel_time

	if kb:down(Idstring("left")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(speed, 0, 0))
	end

	if kb:down(Idstring("right")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(-speed, 0, 0))
	end

	if kb:down(Idstring("up")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(0, 0, speed))
	end

	if kb:down(Idstring("down")) then
		self._hed.spawn_dir = self._hed.spawn_dir:rotate_with(Rotation(0, 0, -speed))
	end

	local from = self._unit:position()
	local to = from + self._hed.spawn_dir * 100000
	local ray = managers.editor:unit_by_raycast({
		from = from,
		to = to,
		mask = managers.slot:get_mask("statics_layer")
	})

	if ray and ray.unit then
		Application:draw_sphere(ray.position, 25, 1, 0, 0)
	end
end

function SpawnGrenadeUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "grenade_type", table.map_keys(tweak_data.blackmarket.projectiles), "Select what type of grenade will be spawned.")
	self:_build_value_number(panel, panel_sizer, "strength", {
		floats = 1
	}, "Use this to add a strength to a physic push on the spawned grenade")
	self:_add_help_text("Spawns a grenade.")
end
