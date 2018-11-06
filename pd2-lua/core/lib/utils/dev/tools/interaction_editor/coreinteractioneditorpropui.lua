core:module("CoreInteractionEditorPropUI")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreInteractionEditorGenericPanel")

InteractionEditorPropUI = InteractionEditorPropUI or CoreClass.class()

function InteractionEditorPropUI:init(parent, owner)
	self._prop_panel = EWS:Panel(parent, "", "")
	self._box = EWS:BoxSizer("VERTICAL")

	self._prop_panel:set_sizer(self._box)

	self._node_panels = {
		[CoreInteractionEditorGenericPanel.NAME] = CoreInteractionEditorGenericPanel.InteractionEditorGenericPanel:new(self._prop_panel, self._box, owner)
	}
end

function InteractionEditorPropUI:window()
	return self._prop_panel
end

function InteractionEditorPropUI:clean()
	if self._current_panel then
		self._current_panel:set_visible(false)

		self._current_panel = nil
	end
end

function InteractionEditorPropUI:rebuild(desc, node)
	self._current_panel = self._node_panels[desc:node_type(node)] or self._node_panels[CoreInteractionEditorGenericPanel.NAME]

	self._current_panel:set_visible(true, desc, node)
end
