SkinEditor = SkinEditor or class()
SkinEditor.allowed_extensions = {
	png = true,
	tga = true,
	dds = true
}

function SkinEditor:init()
	Global.skin_editor = {
		skins = {}
	}
	self._global = Global.skin_editor
	self._current_skin = 1
	self._active = false
end

function SkinEditor:active()
	return self._active
end

function SkinEditor:set_active(active)
	self._active = active
end

function SkinEditor:init_items()
	self._global.skins = {}
	self._current_skin = 1

	for _, item in ipairs(managers.workshop:items()) do
		if item:config().name and item:config().data and item:config().data.weapon_id then
			self:add_literal_paths(item)
			self:_append_skin(item:config().data.weapon_id, item)
			self:load_textures(item)
		end
	end
end

function SkinEditor:create_new_skin(data)
	if not data.weapon_id then
		data.weapon_id = self._current_weapon_id
	end

	local local_skin_id = #self._global.skins[data.weapon_id] + 1
	local new_skin = managers.workshop:create_item()

	self:_append_skin(data.weapon_id, new_skin)
	self:save_skin(new_skin, "New Skin " .. local_skin_id, data)
	self:setup_texture_folders(new_skin)

	return local_skin_id
end

function SkinEditor:_append_skin(weapon_id, skin)
	self._global.skins[weapon_id] = self._global.skins[weapon_id] or {}

	table.insert(self._global.skins[weapon_id], skin)
end

function SkinEditor:delete_current()
	local skin = self:get_current_skin()

	if not skin then
		return
	end

	table.remove(self._global.skins[self._current_weapon_id], self._current_skin)
	managers.workshop:delete_item(skin)

	self._current_skin = math.max(self._current_skin - 1, 1)

	self:reload_current_skin()
	managers.menu:active_menu().logic:get_node("skin_editor")
end

function SkinEditor:select_skin(local_skin_id)
	local is_reload = self._current_skin == local_skin_id
	self._current_skin = local_skin_id
	local skin = self:get_current_skin()

	if not skin then
		managers.menu:active_menu().logic:get_node("skin_editor")

		return
	end

	if not skin:config().data then
		skin:config().data = {}
	end

	local new_cosmetics_data = deep_clone(skin:config().data)
	local crafted_item = managers.blackmarket:get_crafted_category_slot(self:category_slot())

	if new_cosmetics_data.default_blueprint then
		crafted_item.blueprint = deep_clone(new_cosmetics_data.default_blueprint)
	end

	if not new_cosmetics_data.weapon_id then
		new_cosmetics_data.weapon_id = crafted_item.weapon_id
	end

	local id = skin:config().data.name_id or new_cosmetics_data.weapon_id .. "_default"
	id = string.sub(id, string.len(new_cosmetics_data.weapon_id .. "_") + 1, -1)
	new_cosmetics_data.id = id

	local function cb()
		local weapon = managers.blackmarket:get_crafted_category_slot(self:category_slot())

		self:set_weapon_unit(managers.menu_scene:spawn_item_weapon(weapon.factory_id, weapon.blueprint, weapon.cosmetics, weapon.texture_switches, BlackMarketGui.get_crafting_custom_data()))
		self:set_second_weapon_unit(managers.menu_scene._item_unit.second_unit)

		managers.menu_scene._disable_item_updates = false

		managers.menu_scene:update(TimerManager:main():time(), TimerManager:main():delta_time())

		managers.menu_scene._disable_item_updates = true
		local unsaved = self._unsaved

		self:apply_changes(new_cosmetics_data)

		self._unsaved = is_reload and unsaved or false
	end

	managers.blackmarket:preload_weapon_blueprint("preview", crafted_item.factory_id, crafted_item.blueprint, true)
	table.insert(managers.blackmarket._preloading_list, {
		done_cb = cb
	})
	managers.menu:active_menu().logic:get_node("skin_editor")
end

function SkinEditor:reload_current_skin()
	self:select_skin(self._current_skin)
end

function SkinEditor:save_skin(skin, name, data)
	skin:config().name = name or skin:config().name
	skin:config().data = data or skin:config().data
	skin:config().type = "weapon_skin"
	local tags = self:get_current_weapon_tags()

	skin:clear_tags()

	for _, tag in ipairs(tags) do
		skin:add_tag(tag)
	end

	local original = self:remove_literal_paths(skin)

	skin:save()

	skin:config().data = original
	self._unsaved = false
end

function SkinEditor:publish_skin(skin, title, desc, changelog, callb)
	if skin:is_submitting() then
		return
	end

	local function cb(result)
		if result == "success" then
			local id = managers.blackmarket:skin_editor():get_current_skin():id()

			if id then
				Steam:overlay_activate("url", "steam://url/CommunityFilePage/" .. id)
			end
		else
			local dialog_data = {
				title = managers.localization:text("dialog_error_title")
			}
			local result_text = managers.localization:exists(result) and managers.localization:text(result) or result
			dialog_data.text = managers.localization:text("debug_wskn_submit_failed") .. "\n" .. result_text
			local ok_button = {
				text = managers.localization:text("dialog_ok")
			}
			dialog_data.button_list = {
				ok_button
			}

			managers.system_menu:show(dialog_data)
		end

		if SystemFS:exists(Application:nice_path(skin:staging_path(), false)) and Application:nice_path(skin:staging_path(), false) ~= Application:nice_path(skin:path(), false) then
			SystemFS:delete_file(Application:nice_path(skin:staging_path(), false))
		end

		if SystemFS:exists(Application:nice_path(skin:path(), true) .. "preview.png") then
			SystemFS:delete_file(Application:nice_path(skin:path(), true) .. "preview.png")
		end

		if callb then
			callb(result)
		end

		if self._publish_bar then
			self._publish_bar:remove()

			self._publish_bar = nil
		end
	end

	skin:set_title(title)
	skin:set_description(desc)
	self:save_skin(skin)

	local staging = managers.workshop:create_staging_directory()

	for _, type in ipairs(self:get_texture_types()) do
		if not SystemFS:exists(Application:nice_path(staging, true) .. type) then
			SystemFS:make_dir(Application:nice_path(staging, true) .. type)
		end
	end

	local textures = self:get_all_applied_textures(skin)
	local files = {}

	for _, texture in ipairs(textures) do
		local path = texture.type .. "/" .. texture.name

		table.insert(files, path)
	end

	table.insert(files, "info.xml")
	table.insert(files, "item.xml")
	table.insert(files, "preview.png")

	local copy_data = {}

	for _, file in ipairs(files) do
		local pair = {}

		table.insert(pair, Application:nice_path(skin:path(), true) .. file)
		table.insert(pair, Application:nice_path(staging, true) .. file)
		table.insert(copy_data, pair)
	end

	local function copy_cb(success, message)
		if success then
			if skin:submit(changelog, cb) then
				local bar_radius = 20
				local panel = managers.menu:active_menu().renderer.ws:panel()
				self._publish_bar = CircleBitmapGuiObject:new(panel, {
					use_bg = true,
					current = 0,
					blend_mode = "add",
					layer = 2,
					radius = bar_radius,
					sides = bar_radius,
					total = bar_radius,
					color = Color.white:with_alpha(1)
				})

				self._publish_bar:set_position(0, panel:h() - bar_radius * 2)

				local function update_publish(o)
					local current = 0
					local skin_editor = managers.blackmarket:skin_editor()

					while current < 1 do
						local bar = skin_editor._publish_bar

						if not bar then
							break
						end

						current = current + skin_editor:get_current_skin():get_update_progress()

						bar:set_current(current)
						coroutine.yield()
					end
				end

				panel:animate(update_publish)
			end
		else
			cb("copy_failed:" .. message)
		end
	end

	local function sub(result)
		if result == "success" then
			skin:set_staging_path(staging)
			SystemFS:copy_files_async(copy_data, copy_cb)
		else
			cb(result)
		end
	end

	if not skin:item_exists() then
		skin:prepare_for_submit(sub)
	else
		sub("success")
	end
end

function SkinEditor:enter_screenshot_mode()
	local function cb()
		local weapon = managers.blackmarket:get_crafted_category_slot(self:category_slot())

		self:set_weapon_unit(managers.menu_scene:spawn_item_weapon(weapon.factory_id, weapon.blueprint, weapon.cosmetics, weapon.texture_switches, BlackMarketGui.get_screenshot_custom_data()))
		self:set_second_weapon_unit(managers.menu_scene._item_unit.second_unit)

		managers.menu_scene._disable_item_updates = false

		managers.menu_scene:update(TimerManager:main():time(), TimerManager:main():delta_time())

		managers.menu_scene._disable_item_updates = true
		local unsaved = self._unsaved

		self:apply_changes()

		self._unsaved = unsaved

		if not alive(self._screenshot_ws) then
			self:_spawn_screenshot_background()
		end
	end

	local vp = managers.environment_controller._vp:vp()
	self._old_bloom_setting = vp:get_post_processor_effect_name("World", Idstring("bloom_combine_post_processor"))

	vp:set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
	World:effect_manager():set_rendering_enabled(false)

	local weapon = managers.blackmarket:get_crafted_category_slot(self:category_slot())

	managers.blackmarket:preload_weapon_blueprint("preview", weapon.factory_id, weapon.blueprint, true)
	table.insert(managers.blackmarket._preloading_list, {
		done_cb = cb
	})
end

function SkinEditor:set_screenshot_color(color)
	managers.menu_scene._bg_unit:set_visible(false)
	self._screenshot_ws:show()
	self._screenshot_ws:panel():child("bg"):set_color(color)
end

function SkinEditor:hide_screenshot_bg()
	managers.menu_scene._bg_unit:set_visible(true)
	self._screenshot_ws:hide()
end

function SkinEditor:_spawn_screenshot_background()
	managers.menu_scene._bg_unit:set_visible(false)

	local gui = World:newgui()
	local offset_x = Vector3(0, 500, 0):rotate_with(self._weapon_unit:rotation())
	local offset_y = Vector3(0, 0, 500):rotate_with(self._weapon_unit:rotation())
	local pos_offset = Vector3(-50, 250, 250):rotate_with(self._weapon_unit:rotation())
	self._screenshot_ws = gui:create_world_workspace(500, 500, self._weapon_unit:position() - pos_offset, offset_x, offset_y)

	self._screenshot_ws:panel():rect({
		name = "bg",
		layer = 20000,
		color = Color(0, 1, 0)
	})
	self._screenshot_ws:set_billboard(Workspace.BILLBOARD_BOTH)
	self:hide_screenshot_bg()
end

function SkinEditor:leave_screenshot_mode()
	if alive(self._screenshot_ws) then
		World:newgui():destroy_workspace(self._screenshot_ws)
	end

	managers.menu_scene._bg_unit:set_visible(true)
	World:effect_manager():set_rendering_enabled(true)

	if self._old_bloom_setting then
		managers.environment_controller._vp:vp():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), self._old_bloom_setting)
	end
end

function SkinEditor:save_current_skin(name, data)
	self:save_skin(self:get_current_skin(), name, data)
end

function SkinEditor:skins(weapon_id)
	weapon_id = weapon_id or self._current_weapon_id

	return self._global.skins[weapon_id]
end

function SkinEditor:skin_count(weapon_id)
	return #self:skins(weapon_id)
end

function SkinEditor:get_skin(local_skin_id)
	if not self._global.skins[self._current_weapon_id] then
		self._global.skins[self._current_weapon_id] = {}
	end

	return self._global.skins[self._current_weapon_id][local_skin_id]
end

function SkinEditor:get_current_skin()
	return self:get_skin(self._current_skin)
end

function SkinEditor:set_category_slot(category, slot)
	self._category = category
	self._slot = slot
end

function SkinEditor:category_slot()
	return self._category, self._slot
end

function SkinEditor:set_weapon_unit(unit)
	self._weapon_unit = unit
end

function SkinEditor:weapon_unit()
	return self._weapon_unit
end

function SkinEditor:set_second_weapon_unit(unit)
	self._second_weapon_unit = unit
end

function SkinEditor:second_weapon_unit()
	return self._second_weapon_unit
end

function SkinEditor:set_weapon_id(weapon_id)
	self._current_weapon_id = weapon_id
end

function SkinEditor:unsaved()
	return self._unsaved and not self._ignore_unsaved
end

function SkinEditor:set_ignore_unsaved(ignore)
	self._ignore_unsaved = ignore
end

function SkinEditor:get_texture_list(skin, path)
	path = path or skin:path()
	local texture_list = {}
	local file_list = SystemFS:list(path, false)

	local function valid_ext(filename)
		local dot_index = string.find(filename, ".[^.]*$")

		if dot_index == 1 then
			return false
		end

		return SkinEditor.allowed_extensions[string.sub(filename, dot_index + 1)]
	end

	for _, file_name in pairs(file_list) do
		if valid_ext(file_name) then
			table.insert(texture_list, file_name)
		end
	end

	return texture_list
end

function SkinEditor:get_texture_list_by_type(skin, tex_type)
	if not tex_type or not self:has_texture_folders(skin) then
		Application:error("[SkinEditor:get_texture_list_by_type] called without a type")

		return self:get_texture_list(skin)
	end

	return self:get_texture_list(skin, self:get_texture_path_by_type(skin, tex_type))
end

function SkinEditor:load_textures(skin, path_or_tex_type)
	if not path_or_tex_type and self:has_texture_folders(skin) then
		self:_load_textures_by_types(skin)

		return
	end

	local is_path = path_or_tex_type and string.find(path_or_tex_type, "[/\\]")
	local path = is_path and path_or_tex_type
	local tex_type = not is_path and path_or_tex_type
	local textures = tex_type and self:get_texture_list_by_type(skin, tex_type) or self:get_texture_list(skin, path)
	local new_textures = {}
	local type_texture_id = Idstring("texture")
	path = path or skin:path()

	for _, texture in ipairs(textures) do
		local texture_id = self:get_texture_idstring(skin, texture, tex_type)
		local rel_path = Application:nice_path(path, true)
		rel_path = string.sub(rel_path, string.len(Application:base_path()) + 1)
		rel_path = string.gsub(rel_path, "\\", "/")

		if tex_type then
			rel_path = rel_path .. tex_type .. "/"
		end

		DB:create_entry(type_texture_id, texture_id, rel_path .. texture)
		table.insert(new_textures, texture_id)
	end

	if not table.empty(new_textures) then
		Application:reload_textures(new_textures)
	end
end

function SkinEditor:_load_textures_by_types(skin)
	for _, tex_type in ipairs(self:get_texture_types()) do
		self:load_textures(skin, tex_type)
	end
end

function SkinEditor:get_texture_path_by_type(skin, tex_type)
	if not tex_type then
		Application:error("[SkinEditor:get_texture_path_by_type] called without a type")

		return skin:path()
	end

	return Application:nice_path(skin:path() .. "/" .. tex_type, false)
end

function SkinEditor:get_texture_string(skin, texture_name, texture_type)
	if self:has_texture_folders(skin) and texture_type then
		return string.lower(WorkshopManager.PATH .. string.match(skin:path(), "/(.*)/$") .. "/" .. texture_type .. "/" .. texture_name)
	else
		return string.lower(WorkshopManager.PATH .. string.match(skin:path(), "/(.*)/$") .. "/" .. texture_name)
	end
end

function SkinEditor:get_texture_idstring(skin, texture_name, texture_type)
	return Idstring(self:get_texture_string(skin, texture_name, texture_type))
end

function SkinEditor:check_texture_db(texture, silent)
	if not DB:has(Idstring("texture"), Idstring(texture)) then
		Application:error("Texture is not in DB: " .. texture)

		return false
	end

	return true
end

function SkinEditor:check_texture_disk(texture)
	if not SystemFS:exists(texture) then
		Application:error("Texture does not exist on disk: " .. texture)

		return false
	end

	return true
end

function SkinEditor:check_texture(texture)
	return self:check_texture_db(texture) and self:check_texture_disk(texture)
end

function SkinEditor:get_screenshot_name()
	local skin = self:get_current_skin()
	local path = self:get_screenshot_path(skin)

	if not SystemFS:exists(path) and not SystemFS:make_dir(path) then
		return
	end

	local id = #SystemFS:list(path)
	local name = nil

	repeat
		id = id + 1
		name = "screenshot" .. id .. ".png"
	until not SystemFS:exists(path .. "/" .. name)

	return path .. "/" .. name
end

function SkinEditor:apply_changes(cosmetics_data)
	local skin = self:get_current_skin()

	if cosmetics_data then
		self._unsaved = true
		skin:config().data = cosmetics_data
	end

	local textures = self:get_all_applied_textures(skin)

	for _, texture in ipairs(textures) do
		local texture_string = self:get_texture_string(skin, texture.name, texture.type)

		if not self:check_texture(texture_string) then
			self:remove_texture_by_name(skin, texture.name)
		end
	end

	self:weapon_unit():base()._cosmetics_data = self:get_current_skin():config().data

	self:weapon_unit():base():_apply_cosmetics(function ()
	end)

	if self:second_weapon_unit() then
		self:second_weapon_unit():base()._cosmetics_data = self:get_current_skin():config().data

		self:second_weapon_unit():base():_apply_cosmetics(function ()
		end)
	end
end

function SkinEditor:remove_texture_by_name(skin, texture_name)
	local original = deep_clone(skin:config().data)
	local to_process = {
		skin:config().data
	}

	while #to_process > 0 do
		local data = table.remove(to_process)

		for k, v in pairs(data) do
			if type(v) == "string" and (string.find(v, "/" .. texture_name .. "$") or string.find(v, "^" .. texture_name .. "$")) then
				data[k] = nil

				print("Removed texture: " .. texture_name .. " from: " .. k)
			elseif type(v) == "table" then
				table.insert(to_process, v)
			end
		end
	end
end

function SkinEditor:get_screenshot_rect()
	local gui_rect = managers.gui_data:full_16_9_size()
	local x = 0
	local y = gui_rect.y
	local screen_res = Application:screen_resolution()
	local w = screen_res.x
	local h = screen_res.y - gui_rect.y

	return x, y, w, h
end

function SkinEditor:has_screenshots(skin)
	local path = self:get_screenshot_path(skin)

	return SystemFS:exists(path) and #SystemFS:list(path) > 0
end

function SkinEditor:get_screenshot_path(skin)
	return Application:nice_path(skin:path(), true) .. "screenshots"
end

function SkinEditor:get_screenshot_list()
	local skin = self:get_current_skin()

	if not self:has_screenshots(skin) then
		return
	end

	local path = self:get_screenshot_path(skin)
	local screenshots = self:get_texture_list(skin, path)

	self:load_textures(skin, path)

	return screenshots
end

function SkinEditor:get_all_applied_textures(skin)
	local textures = {}
	local to_process = {
		skin:config().data
	}

	while #to_process > 0 do
		local data = table.remove(to_process)

		for k, v in pairs(data) do
			if type(k) == "string" and string.find(k, "_name$") and type(v) == "string" and string.find(v, "%..+$") then
				if not table.contains(textures, v) then
					table.insert(textures, {
						name = v,
						type = string.gsub(k, "_name$", "")
					})
				end
			elseif type(v) == "table" then
				table.insert(to_process, v)
			end
		end
	end

	return textures
end

function SkinEditor:remove_literal_paths(skin)
	local original = deep_clone(skin:config().data)
	local to_process = {
		skin:config().data
	}

	while #to_process > 0 do
		local data = table.remove(to_process)

		for k, v in pairs(data) do
			if type(v) == "string" and string.find(v, "^" .. WorkshopManager.PATH) then
				data[k] = nil
			elseif type(v) == "table" then
				table.insert(to_process, v)
			end
		end
	end

	return original
end

function SkinEditor:add_literal_paths(skin)
	local add_type = self:has_texture_folders(skin)
	local to_process = {
		skin:config().data
	}

	while #to_process > 0 do
		local data = table.remove(to_process)

		if type(data) == "string" then
			data = {
				data
			}
		end

		local it_data = deep_clone(data)

		for k, v in pairs(it_data) do
			if type(k) == "string" and string.find(k, "_name$") and type(v) == "string" and string.find(v, "%..+$") then
				local new_key = string.gsub(k, "_name$", "")
				local path = self:get_texture_string(skin, v, add_type and new_key)
				data[new_key] = path
			elseif type(v) == "table" then
				table.insert(to_process, data[k])
			end
		end
	end
end

function SkinEditor:get_texture_types()
	return {
		"base_gradient",
		"pattern_gradient",
		"pattern",
		"sticker"
	}
end

function SkinEditor:setup_texture_folders(skin)
	local texture_types = self:get_texture_types()

	for _, texture_type in ipairs(texture_types) do
		local tex_path = self:get_texture_path_by_type(skin, texture_type)

		if not SystemFS:exists(tex_path) and not SystemFS:make_dir(tex_path) then
			Application:error("Failed to create dir:", tex_path)

			return
		end
	end
end

function SkinEditor:has_texture_folders(skin)
	local has_folders = true
	local texture_types = self:get_texture_types()

	for _, texture_type in ipairs(texture_types) do
		local tex_path = self:get_texture_path_by_type(skin, texture_type)

		if not SystemFS:exists(tex_path) or not SystemFS:is_dir(tex_path) then
			has_folders = false

			break
		end
	end

	return has_folders
end

function SkinEditor:clear_current_skin()
	local skin = self:get_current_skin()
	skin:config().data = {
		wear_and_tear = 1,
		weapon_id = self._current_weapon_id,
		parts = {}
	}

	self:reload_current_skin()
end

function SkinEditor:get_current_weapon_tags()
	local tags = {}

	table.insert(tags, "Weapon")

	if self._category == "primaries" then
		table.insert(tags, "Primary")
	else
		table.insert(tags, "Secondary")
	end

	local weapon_data = tweak_data.weapon[self._current_weapon_id]

	if not weapon_data then
		return tags
	end

	local sub_category = weapon_data.categories[1]

	if sub_category == "assault_rifle" then
		table.insert(tags, "Assault Rifle")
	elseif sub_category == "akimbo" then
		table.insert(tags, "AKIMBO")
	elseif sub_category == "shotgun" then
		if self._category == "primaries" then
			table.insert(tags, "Shotgun")
		else
			table.insert(tags, "Shotgun - Secondary")
		end
	elseif sub_category == "snp" then
		table.insert(tags, "Sniper Rifle")
	elseif sub_category == "lmg" then
		table.insert(tags, "Light Machine Gun")
	elseif sub_category == "smg" then
		table.insert(tags, "Submachine Gun")
	elseif sub_category == "pistol" then
		table.insert(tags, "Pistol")
	elseif self._category == "primaries" then
		table.insert(tags, "Special")
	else
		table.insert(tags, "Special - Secondary")
	end

	table.insert(tags, managers.localization:text(weapon_data.name_id))

	return tags
end

function SkinEditor:get_excluded_weapons()
	return {
		"akm_gold",
		"arblast",
		"cobray",
		"hajk",
		"pl14"
	}
end

function SkinEditor:get_excluded_type_categories()
	return {
		"ammo",
		"bayonet",
		"bipod",
		"bonus",
		"custom",
		"extra"
	}
end
