CrimeSpreeMenuComponent = CrimeSpreeMenuComponent or class(MenuGuiComponentGeneric)
local padding = 10
local button_size = {
	256,
	64
}
local crime_spree_button = {
	btn = "BTN_START",
	pc_btn = "menu_respec_tree_all"
}

function CrimeSpreeMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})
	self._buttons = {}

	self:_setup()
end

function CrimeSpreeMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeSpreeMenuComponent:_setup()
	local parent = self._ws:panel()

	if alive(self._panel) then
		parent:remove(self._panel)
	end

	self._panel = parent:panel({
		layer = self._init_layer
	})

	self._panel:set_size(unpack(button_size))
	self._panel:set_bottom(parent:bottom() - padding * 2)
	self._panel:set_center_x(parent:center_x())

	if self:can_show_crime_spree() then
		local btn = CrimeSpreeStartButton:new(self._panel)

		table.insert(self._buttons, btn)
		btn:set_button(crime_spree_button.btn)

		if managers.crime_spree:in_progress() then
			btn:set_text("")
			btn:set_level_text(managers.localization:text("menu_cs_level", {
				level = managers.experience:cash_string(managers.crime_spree:spree_level(), "")
			}))
			btn:set_callback(callback(self, self, "_continue_crime_spree"))
		else
			btn:set_text(managers.localization:to_upper_text("cn_crime_spree_start"))
			btn:set_callback(callback(self, self, "_open_crime_spree_contract"))
		end
	else
		self._panel:set_visible(false)
	end
end

function CrimeSpreeMenuComponent:can_show_crime_spree()
	if not managers.crime_spree:unlocked() then
		return false
	end

	if not Global.game_settings.single_player and managers.crimenet:no_servers() then
		return false
	end

	return true
end

function CrimeSpreeMenuComponent:mouse_moved(o, x, y)
	if not self:can_show_crime_spree() then
		return
	end

	local used, pointer = nil

	for idx, btn in ipairs(self._buttons) do
		btn:set_selected(btn:inside(x, y))

		if btn:is_selected() then
			pointer = "link"
			used = true
		end
	end

	return used, pointer
end

function CrimeSpreeMenuComponent:mouse_pressed(o, button, x, y)
	if not self:can_show_crime_spree() then
		return
	end

	for idx, btn in ipairs(self._buttons) do
		if btn:is_selected() and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeSpreeMenuComponent:confirm_pressed()
	if not self:can_show_crime_spree() then
		return
	end

	self:mouse_pressed()
end

function CrimeSpreeMenuComponent:special_btn_pressed(button)
	if not self:can_show_crime_spree() then
		return
	end

	if button == Idstring(crime_spree_button.pc_btn) then
		if managers.crime_spree:in_progress() then
			self:_continue_crime_spree()
		else
			self:_open_crime_spree_contract()
		end
	end
end

function CrimeSpreeMenuComponent:_open_crime_spree_contract()
	managers.menu_component:post_event("menu_enter")

	local node = Global.game_settings.single_player and "crimenet_crime_spree_contract_singleplayer" or "crimenet_crime_spree_contract_host"
	local data = {
		{
			job_id = "crime_spree",
			customize_contract = false,
			competitive = false,
			professional = false,
			difficulty = tweak_data.crime_spree.base_difficulty,
			difficulty_id = tweak_data.crime_spree.base_difficulty_index,
			contract_visuals = {}
		}
	}

	managers.menu:open_node(node, data)
end

function CrimeSpreeMenuComponent:_continue_crime_spree()
	self:_open_crime_spree_contract()
end

CrimeSpreeStartButton = CrimeSpreeStartButton or class(MenuGuiItem)
CrimeSpreeStartButton._type = "CrimeSpreeStartButton"

function CrimeSpreeStartButton:init(parent)
	self._panel = parent:panel({
		layer = 1000,
		w = parent:w(),
		h = parent:h()
	})
	self._text = self._panel:text({
		halign = "center",
		vertical = "center",
		layer = 1,
		align = "center",
		text = "",
		y = 0,
		x = 0,
		valign = "center",
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})
	self._level_text = self._panel:text({
		halign = "center",
		vertical = "center",
		layer = 1,
		align = "center",
		text = "",
		y = 0,
		x = 0,
		valign = "center",
		color = tweak_data.screen_colors.crime_spree_risk,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_medium_large_size
	})
	self._bg = self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})
	self._highlight = self._panel:rect({
		blend_mode = "add",
		layer = -1,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._blur = self._panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = self._panel:w(),
		h = self._panel:h()
	})

	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self:refresh()
end

function CrimeSpreeStartButton:refresh()
	self._bg:set_visible(not self:is_selected())
	self._highlight:set_visible(self:is_selected())
end

function CrimeSpreeStartButton:inside(x, y)
	return self._panel:inside(x, y)
end

function CrimeSpreeStartButton:callback()
	return self._callback
end

function CrimeSpreeStartButton:set_callback(clbk)
	self._callback = clbk
end

function CrimeSpreeStartButton:set_button(btn)
	self._btn = btn
end

function CrimeSpreeStartButton:set_text(text)
	local prefix = text ~= "" and (not managers.menu:is_pc_controller() and self._btn and managers.localization:get_default_macro(self._btn) or "") or ""

	self._text:set_text(prefix .. text)
end

function CrimeSpreeStartButton:set_level_text(text)
	self._level_text:set_text(text)
end

function CrimeSpreeStartButton:update(t, dt)
end
