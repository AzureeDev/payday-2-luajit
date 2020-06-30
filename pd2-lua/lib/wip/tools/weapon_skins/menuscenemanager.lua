if MenuSceneManager then
	local old_set_up_templates = MenuSceneManager._set_up_templates

	function MenuSceneManager:_set_up_templates()
		old_set_up_templates(self)

		local ref = self._bg_unit:get_object(Idstring("a_camera_reference"))
		local c_ref = self._bg_unit:get_object(Idstring("a_reference"))
		local target_pos = Vector3(0, 0, ref:position().z)
		local offset = Vector3(ref:position().x, ref:position().y, 0)
		self._scene_templates.blackmarket_customize = {
			fov = 40,
			use_item_grab = true,
			disable_rotate = true,
			disable_item_updates = true,
			can_change_fov = true,
			can_move_item = true,
			change_fov_sensitivity = 2,
			camera_pos = Vector3(1500, -2000, 0)
		}
		self._scene_templates.blackmarket_customize.target_pos = self._scene_templates.blackmarket_customize.camera_pos + Vector3(0, 1, 0) * 100
		local camera_look = (self._scene_templates.blackmarket_customize.target_pos - self._scene_templates.blackmarket_customize.camera_pos):normalized()

		mvector3.rotate_with(camera_look, Rotation(4, 2.25, 0))

		self._scene_templates.blackmarket_customize.item_pos = self._scene_templates.blackmarket_customize.camera_pos + camera_look * 240
		self._scene_templates.blackmarket_customize.environment = "crafting"
		self._scene_templates.blackmarket_customize.use_workbench_room = true
		local l_pos = self._scene_templates.blackmarket_customize.camera_pos
		local rot = Rotation(self._scene_templates.blackmarket_customize.target_pos - l_pos, math.UP)
		local l1_pos = l_pos + rot:x() * 50 + rot:y() * 50
		local l2_pos = l_pos + rot:x() * -50 + rot:y() * 100
		self._scene_templates.blackmarket_customize.lights = {}
	end
end
