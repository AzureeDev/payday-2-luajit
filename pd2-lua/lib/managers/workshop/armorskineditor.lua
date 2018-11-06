ArmorSkinEditor = ArmorSkinEditor or class()
ArmorSkinEditor.allowed_extensions = SkinEditor.allowed_extensions
ArmorSkinEditor.menu_node_name = "armor_skin_editor"
ArmorSkinEditor.texture_types = {
	"base_gradient",
	"pattern_gradient",
	"pattern",
	"sticker"
}

function ArmorSkinEditor:init()
	Global.armor_skin_editor = {
		skins = {}
	}
	self._global = Global.armor_skin_editor
	self._current_skin = 1
	self._active = false
end

function ArmorSkinEditor:active()
	return self._active
end

function ArmorSkinEditor:set_active(active)
	self._active = active
end

function ArmorSkinEditor:init_items()
	self._global.skins = {}
	self._current_skin = 1

	for _, item in ipairs(managers.workshop:items()) do
		if item:config().name and item:config().data and item:config().type == "armor_skin" then
			self:add_literal_paths(item)
			self:_append_skin(item)
			self:load_textures(item)
		end
	end
end

function ArmorSkinEditor:create_new_skin(data)
	local local_skin_id = #self._global.skins + 1
	local new_skin = managers.workshop:create_item()

	self:_append_skin(new_skin)
	self:save_skin(new_skin, "New Skin " .. local_skin_id, data)
	self:setup_texture_folders(new_skin)

	return local_skin_id
end

function ArmorSkinEditor:_append_skin(skin)
	self._global.skins = self._global.skins or {}

	table.insert(self._global.skins, skin)
end

function ArmorSkinEditor:delete_current()
	local skin = self:get_current_skin()

	if not skin then
		return
	end

	table.remove(self._global.skins, self._current_skin)
	managers.workshop:delete_item(skin)

	self._current_skin = math.max(self._current_skin - 1, 1)

	self:reload_current_skin()
	managers.menu:active_menu().logic:get_node(ArmorSkinEditor.menu_node_name)
end

function ArmorSkinEditor:select_skin(local_skin_id)
	local is_reload = self._current_skin == local_skin_id
	self._current_skin = local_skin_id
	local skin = self:get_current_skin()

	if not skin then
		self:apply_changes_to_character({})

		return
	end

	if not skin:config().data then
		skin:config().data = {}
	end

	local new_cosmetics_data = deep_clone(skin:config().data)
	new_cosmetics_data.id = skin:config().data.name_id or "skin_default"

	local function cb()
		managers.menu_scene._disable_item_updates = false

		managers.menu_scene:update(TimerManager:main():time(), TimerManager:main():delta_time())

		managers.menu_scene._disable_item_updates = true
		local unsaved = self._unsaved

		self:apply_changes(new_cosmetics_data)

		self._unsaved = is_reload and unsaved or false
	end

	managers.menu:active_menu().logic:get_node(ArmorSkinEditor.menu_node_name)
	self:apply_changes_to_character(new_cosmetics_data)
end

function ArmorSkinEditor:reload_current_skin()
	self:select_skin(self._current_skin)
end

function ArmorSkinEditor:save_skin(skin, name, data)
	skin:config().name = name or skin:config().name
	skin:config().data = data or skin:config().data
	skin:config().type = "armor_skin"
	local tags = self:get_current_item_tags()

	skin:clear_tags()

	for _, tag in ipairs(tags) do
		skin:add_tag(tag)
	end

	local original = self:remove_literal_paths(skin)

	skin:save()

	skin:config().data = original
	self._unsaved = false
end

function ArmorSkinEditor:save_current_skin(name, data)
	self:save_skin(self:get_current_skin(), name, data)
end

function ArmorSkinEditor:skins()
	return self._global.skins
end

function ArmorSkinEditor:skin_count()
	return #self._global.skins
end

function ArmorSkinEditor:get_skin(local_skin_id)
	self._global.skins = self._global.skins or {}

	return self._global.skins[local_skin_id]
end

function ArmorSkinEditor:get_current_skin()
	return self:get_skin(self._current_skin)
end

function ArmorSkinEditor:unsaved()
	return self._unsaved and not self._ignore_unsaved
end

function ArmorSkinEditor:set_ignore_unsaved(ignore)
	self._ignore_unsaved = ignore
end

ArmorSkinEditor.get_texture_list = SkinEditor.get_texture_list
ArmorSkinEditor.get_texture_list_by_type = SkinEditor.get_texture_list_by_type
ArmorSkinEditor.load_textures = SkinEditor.load_textures
ArmorSkinEditor._load_textures_by_types = SkinEditor._load_textures_by_types
ArmorSkinEditor.get_texture_path_by_type = SkinEditor.get_texture_path_by_type
ArmorSkinEditor.get_texture_string = SkinEditor.get_texture_string
ArmorSkinEditor.get_texture_idstring = SkinEditor.get_texture_idstring
ArmorSkinEditor.check_texture_db = SkinEditor.check_texture_db
ArmorSkinEditor.check_texture_disk = SkinEditor.check_texture_disk
ArmorSkinEditor.check_texture = SkinEditor.check_texture

function ArmorSkinEditor:apply_changes(cosmetics_data)
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

	self:apply_changes_to_character(cosmetics_data)
end

function ArmorSkinEditor:apply_changes_to_character(data)
	local character = managers.menu_scene._character_unit

	if character then
		character:base()._cosmetics_data = data

		character:base():_apply_cosmetics({})
	end
end

ArmorSkinEditor.remove_texture_by_name = SkinEditor.remove_texture_by_name
ArmorSkinEditor.get_all_applied_textures = SkinEditor.get_all_applied_textures
ArmorSkinEditor.remove_literal_paths = SkinEditor.remove_literal_paths
ArmorSkinEditor.add_literal_paths = SkinEditor.add_literal_paths
ArmorSkinEditor.setup_texture_folders = SkinEditor.setup_texture_folders
ArmorSkinEditor.has_texture_folders = SkinEditor.has_texture_folders

function ArmorSkinEditor:get_texture_types()
	return ArmorSkinEditor.texture_types
end

function ArmorSkinEditor:clear_current_skin()
	local skin = self:get_current_skin()

	if skin then
		skin:config().data = {}
	end

	self:reload_current_skin()
end

function ArmorSkinEditor:get_current_item_tags()
	local tags = {}

	table.insert(tags, "Armor")

	return tags
end

ArmorSkinEditor.hide_screenshot_bg = SkinEditor.hide_screenshot_bg
ArmorSkinEditor.leave_screenshot_mode = SkinEditor.leave_screenshot_mode
ArmorSkinEditor.get_screenshot_name = SkinEditor.get_screenshot_name
ArmorSkinEditor.get_screenshot_rect = SkinEditor.get_screenshot_rect
ArmorSkinEditor.has_screenshots = SkinEditor.has_screenshots
ArmorSkinEditor.get_screenshot_path = SkinEditor.get_screenshot_path
ArmorSkinEditor.get_screenshot_list = SkinEditor.get_screenshot_list

function ArmorSkinEditor:enter_screenshot_mode()
	local vp = managers.environment_controller._vp:vp()
	self._old_bloom_setting = vp:get_post_processor_effect_name("World", Idstring("bloom_combine_post_processor"))

	vp:set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
	World:effect_manager():set_rendering_enabled(false)

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

function ArmorSkinEditor:_spawn_screenshot_background()
	managers.menu_scene._bg_unit:set_visible(false)

	local unit = managers.menu_scene._character_unit
	local gui = World:newgui()
	local offset_x = Vector3(0, 600, 0):rotate_with(unit:rotation())
	local offset_y = Vector3(0, 0, 500):rotate_with(unit:rotation())
	local pos_offset = Vector3(0, 450, 100):rotate_with(unit:rotation())
	self._screenshot_ws = gui:create_world_workspace(1000, 1000, unit:position() - pos_offset, offset_x, offset_y)

	self._screenshot_ws:panel():rect({
		name = "bg",
		layer = 20000,
		color = Color(0, 1, 0)
	})
	self._screenshot_ws:set_billboard(Workspace.BILLBOARD_BOTH)
	self:hide_screenshot_bg()
end

function ArmorSkinEditor:set_screenshot_color(color)
	managers.menu_scene._bg_unit:set_visible(false)
	self._screenshot_ws:show()
	self._screenshot_ws:panel():child("bg"):set_color(color)
	managers.menu_scene:delete_workbench_room()
end

function ArmorSkinEditor:hide_screenshot_bg()
	managers.menu_scene._bg_unit:set_visible(true)
	managers.menu_scene:spawn_workbench_room()
	self._screenshot_ws:hide()
end

function ArmorSkinEditor:publish_skin(skin, title, desc, changelog, callb)
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
