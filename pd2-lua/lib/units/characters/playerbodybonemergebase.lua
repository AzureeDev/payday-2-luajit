PlayerBodyBoneMergeBase = PlayerBodyBoneMergeBase or class(UnitBase)

function PlayerBodyBoneMergeBase:init(unit)
	UnitBase.init(self, unit, false)

	self._visibility_state = true
	self._allow_invisible = true
	self._is_in_original_material = true
end

function PlayerBodyBoneMergeBase:char_tweak()
	return {}
end

function PlayerBodyBoneMergeBase:is_in_original_material()
	return self._is_in_original_material
end

function PlayerBodyBoneMergeBase:set_material_state(original)
	if original and not self._is_in_original_material or not original and self._is_in_original_material then
		self:swap_material_config()
	end
end

function PlayerBodyBoneMergeBase:swap_material_config(material_applied_clbk)
	local new_material = Idstring(self.contour_material)

	if new_material then
		self._loading_material_key = new_material:key()
		self._is_in_original_material = not self._is_in_original_material

		self._unit:set_material_config(new_material, true, material_applied_clbk and callback(self, self, "on_material_applied", material_applied_clbk), 100)

		if not material_applied_clbk then
			self:on_material_applied()
		end
	else
		Application:error_stack_dump("[PlayerBodyBoneMergeBase:swap_material_config] fail", self._unit:material_config(), self._unit)
	end
end

function PlayerBodyBoneMergeBase:on_material_applied(material_applied_clbk)
	if not alive(self._unit) then
		return
	end

	self._loading_material_key = nil

	if self._unit:interaction() then
		self._unit:interaction():refresh_material()
	end

	if material_applied_clbk then
		material_applied_clbk()
	end
end

function PlayerBodyBoneMergeBase:set_allow_invisible(allow)
	self._allow_invisible = allow
end
