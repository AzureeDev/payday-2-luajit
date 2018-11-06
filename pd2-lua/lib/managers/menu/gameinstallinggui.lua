GameInstallingGui = GameInstallingGui or class()

function GameInstallingGui:init(ws)
	self._ws = ws
	self._show_installing_text = SystemInfo:platform() ~= Idstring("PS4")
	self._panel = self._ws:panel():panel()

	self._panel:text({
		text = "",
		name = "installing_text",
		alpha = 0.5,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		visible = self._show_installing_text
	})
end

function GameInstallingGui:update(install_progress)
	if self._show_installing_text then
		self._panel:child("installing_text"):set_text(managers.localization:text("menu_installing_progress", {
			progress = string.format("%.2f%%", install_progress * 100)
		}))
	end
end

function GameInstallingGui:close()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)

		self._panel = nil
	end
end
