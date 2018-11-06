CoreCutsceneData = CoreCutsceneData or class()
CutsceneData = CoreCutsceneData

function CoreCutsceneData:init(unit)
	self.__unit = assert(unit, "Unit not supplied to CoreCutsceneData.")
	self.__cutscene_name = self:_cutscene_name(unit:name())

	self:cutscene_player(true, true)
	managers.cutscene:register_unit_with_cutscene_data_extension(self.__unit)
end

function CoreCutsceneData:destroy()
	self:destroy_cutscene_player()
	managers.cutscene:unregister_unit_with_cutscene_data_extension(self.__unit)

	self.__unit = nil
	self.__cutscene_name = nil
end

function CoreCutsceneData:cutscene_player(__skip_stall_warning, __skip_priming)
	if self.__cutscene_player == nil then
		local cutscene = managers.cutscene:get_cutscene(self.__cutscene_name)

		if not __skip_stall_warning then
			cat_print("spam", "[CoreCutsceneData] The cutscene \"" .. cutscene:name() .. "\" has been cleaned up. Call CoreCutsceneData:reset_cutscene_player() before attempting to replay it.")
		end

		self.__cutscene_player = core_or_local("CutscenePlayer", cutscene)

		self.__cutscene_player:add_keys()

		if not __skip_priming then
			self.__cutscene_player:prime()
		end

		local actual_destroy_func = self.__cutscene_player.destroy

		function self.__cutscene_player.destroy(instance)
			assert(instance == self.__cutscene_player)

			self.__cutscene_player = nil

			actual_destroy_func(instance)
		end
	end

	return self.__cutscene_player
end

function CoreCutsceneData:destroy_cutscene_player()
	if self.__cutscene_player then
		self.__cutscene_player:destroy()
		assert(self.__cutscene_player == nil)
	end
end

function CoreCutsceneData:reset_cutscene_player()
	self:destroy_cutscene_player()
	self:cutscene_player(true)
end

function CoreCutsceneData:_cutscene_name(unit_type_name)
	return string.match(unit_type_name, "cutscene_(.+)")
end
