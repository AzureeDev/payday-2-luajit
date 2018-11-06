core:module("CoreGTextureManager")

GTextureManager = GTextureManager or class()

function GTextureManager:init()
	self._texture_map = {}
	self._preloaded = {}

	GlobalTextureManager:set_texture("current_global_texture", nil)
	GlobalTextureManager:set_texture("current_global_world_overlay_texture", nil)
	GlobalTextureManager:set_texture("current_global_world_overlay_mask_texture", nil)
end

function GTextureManager:set_texture(variable_name, texture_name, texture_type)
	local old_data = self._texture_map[variable_name]

	if old_data and old_data.texture then
		GlobalTextureManager:set_texture(variable_name, nil)
		TextureCache:unretrieve(old_data.texture)

		old_data.texture = nil
	end

	if texture_name and texture_name ~= "" then
		local data = {
			texture_name = texture_name,
			texture_type = texture_type,
			texture = TextureCache:retrieve(texture_name, texture_type)
		}

		GlobalTextureManager:set_texture(variable_name, data.texture)

		self._texture_map[variable_name] = data
	end
end

function GTextureManager:preload(textures, texture_type)
	if type(textures) == "string" then
		if not self._preloaded[textures] then
			self._preloaded[textures] = TextureCache:retrieve(textures, texture_type)
		end
	else
		for _, v in ipairs(textures) do
			if not self._preloaded[v.name] then
				self._preloaded[v.name] = TextureCache:retrieve(v.name, v.type)
			end
		end
	end
end

function GTextureManager:destroy()
	for variable_name, data in pairs(self._texture_map) do
		if data.texture then
			GlobalTextureManager:set_texture(variable_name, nil)
			TextureCache:unretrieve(data.texture)
		end
	end

	for _, v in pairs(self._preloaded) do
		TextureCache:unretrieve(v)
	end

	self._texture_map = nil
	self._preloaded = nil
end
