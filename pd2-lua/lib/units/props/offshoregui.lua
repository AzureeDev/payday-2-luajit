OffshoreGui = OffshoreGui or class()
OffshoreGui.TITLE_COLOR = Color(0.5, 0.6, 0.5)
OffshoreGui.MONEY_COLOR = Color(0.5, 0.6, 0.5)

function OffshoreGui:init(unit)
	self._unit = unit
	self._visible = true
	self._gui_object = self._gui_object or "gui_object"
	self._new_gui = World:gui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("offshore_gui"), false)

	if managers.sync then
		managers.sync:add_managed_unit(self._unit:id(), self)
		self:perform_sync()
	end
end

function OffshoreGui:add_workspace(gui_object)
	local gui_width, gui_height = managers.gui_data:get_base_res()
	self._ws = self._new_gui:create_object_workspace(gui_width, gui_height, gui_object, Vector3(0, 0, 0))
end

function OffshoreGui:setup()
	if self._back_drop_gui then
		self._back_drop_gui:destroy()
	end

	self._ws:panel():clear()
	self._ws:panel():set_alpha(0.8)
	self._ws:panel():rect({
		layer = -1,
		color = Color.black
	})

	self._back_drop_gui = MenuBackdropGUI:new(self._ws)
	local panel = self._back_drop_gui:get_new_background_layer()
	local font_size = 120
	local default_offset = 48
	local text = managers.localization:to_upper_text("menu_offshore_account")
	self._title_text = panel:text({
		vertical = "bottom",
		align = "center",
		visible = true,
		layer = 0,
		text = text,
		y = -self._ws:panel():h() / 2 - default_offset,
		font = tweak_data.menu.pd2_medium_font,
		font_size = font_size,
		color = OffshoreGui.TITLE_COLOR
	})
	local font_size = 220
	local money_text = managers.experience:cash_string(managers.money:offshore())
	self._money_text = panel:text({
		vertical = "top",
		align = "center",
		visible = true,
		layer = 0,
		text = money_text,
		y = self._ws:panel():h() / 2 - default_offset,
		font = tweak_data.menu.pd2_massive_font,
		font_size = font_size,
		color = OffshoreGui.MONEY_COLOR
	})

	self._ws:panel():set_visible(self._visible)
end

function OffshoreGui:_start()
end

function OffshoreGui:start()
end

function OffshoreGui:sync_start()
	self:_start()
end

function OffshoreGui:set_visible(visible)
	self._visible = visible

	if self._ws and self._ws:panel() then
		self._ws:panel():set_visible(visible)
	end

	self:perform_sync()
end

function OffshoreGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

function OffshoreGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

function OffshoreGui:update_offshore(cash)
	self._money_text:set_text(managers.experience:cash_string(cash or managers.money:offshore()))
end

function OffshoreGui:perform_sync()
	if managers.sync and Network:is_server() then
		managers.sync:add_synced_offshore_gui(self._unit:id(), self._visible, managers.money:offshore())
	end
end
