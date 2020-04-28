IngameContractGuiSkirmish = IngameContractGuiSkirmish or class()

function IngameContractGuiSkirmish:init(ws, node)
	local padding = SystemInfo:platform() == Idstring("WIN32") and 10 or 5
	self._panel = ws:panel():panel({
		w = math.round(ws:panel():w() * 0.6),
		h = math.round(ws:panel():h() * 1)
	})

	self._panel:set_y(CoreMenuRenderer.Renderer.border_height + tweak_data.menu.pd2_large_font_size - 5)
	self._panel:grow(0, -(self._panel:y() + tweak_data.menu.pd2_medium_font_size))

	self._node = node
	local job_data = managers.job:current_job_data()
	local job_chain = managers.job:current_job_chain_data()

	if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
		self._panel:set_visible(false)
	end

	local skirmish_type_text_id = managers.skirmish:is_weekly_skirmish() and "menu_weekly_skirmish" or "menu_skirmish"
	local skirmish_title = self._panel:text({
		vertical = "bottom",
		rotation = 360,
		layer = 1,
		text = managers.localization:to_upper_text("cn_menu_contract_header") .. " " .. managers.localization:to_upper_text(skirmish_type_text_id),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.text
	})

	skirmish_title:set_bottom(5)

	local text_panel = self._panel:panel({
		layer = 1,
		x = padding,
		y = padding,
		w = self._panel:w() - padding * 2,
		h = self._panel:h() - padding * 2
	})
	local heist_title = nil

	if managers.skirmish:is_weekly_skirmish() then
		heist_title = FineText:new(text_panel, {
			text = managers.localization:to_upper_text(job_data.name_id),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text
		})
	end

	local briefing_title = FineText:new(text_panel, {
		text = managers.localization:to_upper_text("menu_briefing"),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text,
		y = heist_title and heist_title:bottom()
	})
	local font_size = tweak_data.menu.pd2_small_font_size
	local text = nil

	if managers.skirmish:is_weekly_skirmish() then
		text = job_data and managers.localization:text(job_data.briefing_id) or ""
	else
		text = managers.localization:text("menu_skirmish_selected_briefing")
	end

	local briefing_description = text_panel:text({
		name = "briefing_description",
		vertical = "top",
		h = 128,
		wrap = true,
		align = "left",
		word_wrap = true,
		text = text,
		font = tweak_data.menu.pd2_small_font,
		font_size = font_size,
		color = tweak_data.screen_colors.text,
		y = briefing_title:bottom()
	})
	local _, _, _, h = briefing_description:text_rect()

	briefing_description:set_h(h)

	local current_ransom = managers.skirmish:current_ransom_amount()
	local ransom_string = managers.experience:cash_string(math.round(current_ransom))
	local ransom_text = FineText:new(text_panel, {
		text = managers.localization:to_upper_text("menu_skirmish_ransom", {
			money = ransom_string
		}),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.text
	})

	ransom_text:set_bottom(text_panel:h())

	if managers.skirmish:is_weekly_skirmish() then
		local modifiers_title = FineText:new(text_panel, {
			name = "modifiers_title",
			text = managers.localization:to_upper_text("cn_skirmish_modifiers"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text,
			y = briefing_description:bottom() + padding
		})
		self._modifier_list = SkirmishModifierList:new(text_panel, {
			modifiers = managers.skirmish:weekly_modifiers(),
			y = modifiers_title:bottom(),
			w = self._panel:width() - padding * 2,
			h = ransom_text:top() - modifiers_title:bottom() - padding
		})
	end

	self._text_panel = text_panel

	self:_rec_round_object(self._panel)

	self._sides = BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
end

function IngameContractGuiSkirmish:_rec_round_object(object)
	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end

	local x, y = object:position()

	object:set_position(math.round(x), math.round(y))
end

function IngameContractGuiSkirmish:set_layer(layer)
	self._panel:set_layer(layer)
end

function IngameContractGuiSkirmish:close()
	if self._panel and alive(self._panel) then
		self._panel:parent():remove(self._panel)

		self._panel = nil
	end
end

function IngameContractGuiSkirmish:mouse_wheel_up(x, y)
	if not self._modifier_list then
		return
	end

	self._modifier_list:scroll(x, y, 1)
end

function IngameContractGuiSkirmish:mouse_wheel_down(x, y)
	if not self._modifier_list then
		return
	end

	self._modifier_list:scroll(x, y, -1)
end
