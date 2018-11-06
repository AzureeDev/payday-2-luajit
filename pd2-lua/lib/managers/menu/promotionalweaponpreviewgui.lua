PromotionalWeaponPreviewGui = PromotionalWeaponPreviewGui or class(MenuGuiComponent)
local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function PromotionalWeaponPreviewGui:init(ws, fullscreen_ws, node)
	self._ws = managers.gui_data:create_saferect_workspace()
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._node = node
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()

	self:setup()
end

function PromotionalWeaponPreviewGui:close()
	if alive(self._ws) then
		managers.gui_data:destroy_workspace(self._ws)

		self._ws = nil
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end

function PromotionalWeaponPreviewGui:setup()
	local menu_component_data = self._node:parameters().menu_component_data
	local item_td, unlocked = nil

	if menu_component_data.category == "primaries" or menu_component_data.category == "secondaries" then
		item_td = tweak_data.weapon[menu_component_data.item_id]
		unlocked = item_td.unlock_func and managers.blackmarket[item_td.unlock_func](managers.blackmarket) or false
	elseif menu_component_data.category == "melee" then
		item_td = tweak_data.blackmarket.melee_weapons[menu_component_data.item_id]
		unlocked = item_td.locks and item_td.locks.func and managers.blackmarket[item_td.locks.func](managers.blackmarket) or false
	elseif menu_component_data.category == "mask" then
		item_td = tweak_data.blackmarket.masks[menu_component_data.item_id]
	else
		error("Could not find weapon tweak data for weapon of category " .. tostring(menu_component_data.category))
	end

	local unlock_id = (unlocked and "menu_promo_unlocked_" or "menu_promo_unlock_") .. tostring(menu_component_data.item_id)
	local unlock_data = managers.promo_unlocks:get_data_for_weapon(menu_component_data.item_id)

	if not item_td then
		return
	end

	self._panel = self._ws:panel():panel({
		h = 96,
		w = self._ws:panel():w() * 0.4
	})

	self._panel:set_left(0)
	self._panel:set_bottom(self._ws:panel():h())
	self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})
	self._panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self._panel:w(),
		h = self._panel:h()
	})
	BoxGuiObject:new(self._panel:panel({
		layer = 100
	}), {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	local img_size = self._panel:h() - padding * 2
	local img_panel = nil

	if unlock_data and unlock_data.achievement_image then
		local img_size = self._panel:h() - padding * 2
		img_panel = self._panel:panel({
			x = padding,
			y = padding,
			w = img_size,
			h = img_size
		})

		BoxGuiObject:new(img_panel:panel({
			layer = 100
		}), {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		img_panel:bitmap({
			layer = 1,
			y = 0,
			x = 0,
			valign = "top",
			texture = unlocked and unlock_data.achievement_image.unlocked or unlock_data.achievement_image.locked,
			w = img_size,
			h = img_size
		})
	end

	local name = self._panel:text({
		align = "left",
		vertical = "top",
		text = managers.localization:text(item_td.name_id),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text,
		x = (img_panel and img_panel:right() or 0) + padding,
		y = padding
	})

	make_fine_text(name)

	local desc = self._panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		word_wrap = true,
		text = managers.localization:text(unlock_id),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.text,
		x = (img_panel and img_panel:right() or 0) + padding,
		y = name:bottom(),
		w = self._panel:w() - name:left() - padding,
		h = self._panel:h() - name:bottom()
	})
end
