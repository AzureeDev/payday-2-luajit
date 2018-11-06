MenuHiddenRenderer = MenuHiddenRenderer or class(MenuRenderer)

function MenuHiddenRenderer:init(...)
	MenuHiddenRenderer.super.init(self, ...)

	self._disable_blackborder = true
end

function MenuHiddenRenderer:open(...)
	MenuHiddenRenderer.super.open(self, ...)
	self._main_panel:root():hide()
end

function MenuHiddenRenderer:show()
	MenuHiddenRenderer.super.show(self)
	self._main_panel:root():hide()
end

function MenuHiddenRenderer:hide()
	MenuHiddenRenderer.super.hide(self)
	self._main_panel:root():hide()
end
