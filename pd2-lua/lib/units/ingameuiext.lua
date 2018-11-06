IngameUIExt = IngameUIExt or class()

function IngameUIExt:init(unit)
	self._unit = unit

	if self.objects then
		for name, object in pairs(self.objects) do
			managers.hud:register_ingame_workspace(name, self._unit:get_object(Idstring(object)))
		end
	end
end
