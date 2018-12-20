MenuMovement = MenuMovement or class()

function MenuMovement:init(unit)
	self._align_points = {
		Idstring("a_weapon_right_front"),
		Idstring("a_weapon_left_front")
	}
	self._unit = unit
end

function MenuMovement:anim_clbk_hide_items()
	if not alive(self._unit) then
		return
	end

	local objects = {}

	for i, align in ipairs(self._align_points) do
		local o = self._unit:get_object(align)

		table.list_append(objects, o:children())
	end

	self._hidden_objects = self._hidden_objects or {}

	for _, unit in ipairs(self._unit:children()) do
		local object = unit:orientation_object()

		if table.contains(objects, object) and unit:visible() then
			unit:set_enabled(false)
			unit:set_visible(false)
			table.insert(self._hidden_objects, unit)
		end
	end
end

function MenuMovement:anim_clbk_show_items()
	for _, unit in ipairs(self._hidden_objects) do
		if alive(unit) then
			unit:set_enabled(true)
			unit:set_visible(true)
		end
	end
end
