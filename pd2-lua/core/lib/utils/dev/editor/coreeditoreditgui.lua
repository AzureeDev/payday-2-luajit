core:import("CoreEngineAccess")
core:import("CoreEditorUtils")

EditGui = EditGui or class()

function EditGui:init(parent, toolbar, btn, name)
	self._panel = EWS:Panel(parent, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:StaticBoxSizer(self._panel, "HORIZONTAL", name)

	self._panel:set_sizer(self._main_sizer)

	self._toolbar = toolbar
	self._btn = btn
	self._ctrls = {
		unit = nil
	}

	self:set_visible(false)
end

function EditGui:has(unit)
	if not alive(unit) then
		self:disable()

		return false
	end
end

function EditGui:disable()
	self._ctrls.unit = nil

	self._toolbar:set_tool_enabled(self._btn, false)
	self._toolbar:set_tool_state(self._btn, false)
	self:set_visible(false)
end

function EditGui:set_visible(vis)
	self._visible = vis

	self._panel:set_visible(vis)
	self._panel:layout()
end

function EditGui:visible()
	return self._visible
end

function EditGui:get_panel()
	return self._panel
end
