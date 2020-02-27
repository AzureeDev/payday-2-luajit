core:module("CoreLocalizationManager")
core:import("CoreClass")
core:import("CoreEvent")

LocalizationManager = LocalizationManager or CoreClass.class()

function LocalizationManager:init()
	Localizer:set_post_processor(CoreEvent.callback(self, self, "_localizer_post_process"))

	self._default_macros = {}

	self:set_default_macro("NL", "\n")
	self:set_default_macro("EMPTY", "")

	local platform_id = SystemInfo:platform()

	if platform_id == Idstring("X360") then
		self._platform = "X360"
	elseif platform_id == Idstring("PS3") then
		self._platform = "PS3"
	elseif platform_id == Idstring("XB1") then
		self._platform = "X360"
	elseif platform_id == Idstring("PS4") then
		self._platform = "PS3"
	else
		self._platform = "WIN32"
	end
end

function LocalizationManager:add_default_macro(macro, value)
	self:set_default_macro(macro, value)
end

function LocalizationManager:set_default_macro(macro, value)
	if not self._default_macros then
		self._default_macros = {}
	end

	self._default_macros[macro] = tostring(value)
end

function LocalizationManager:get_default_macro(macro)
	return self._default_macros[macro]
end

function LocalizationManager:exists(string_id)
	return Localizer:exists(Idstring(string_id))
end

function LocalizationManager:text(string_id, macros)
	local return_string = "ERROR: " .. tostring(string_id)
	local str_id = nil

	if not string_id or string_id == "" or type(string_id) ~= "string" then
		return_string = ""
	elseif self:exists(string_id .. "_" .. self._platform) then
		str_id = string_id .. "_" .. self._platform
	elseif self:exists(string_id) then
		str_id = string_id
	end

	if str_id then
		self._macro_context = macros
		return_string = Localizer:lookup(Idstring(str_id))
		self._macro_context = nil
	end

	return return_string
end

function LocalizationManager:format_text(text_string)
	return self:_localizer_post_process(self:_text_localize(text_string, "@", ";"))
end

function LocalizationManager:_localizer_post_process(string)
	local localized_string = string
	local macros = {}

	if type(self._macro_context) ~= "table" then
		self._macro_context = {}
	end

	for k, v in pairs(self._default_macros) do
		macros[k] = v
	end

	for k, v in pairs(self._macro_context) do
		macros[k] = tostring(v)
	end

	if self._pre_process_func then
		self._pre_process_func(macros)
	end

	return self:_text_macroize(localized_string, macros)
end

function LocalizationManager:_text_localize(text)
	local function func(id)
		return self:exists(id) and self:text(id) or false
	end

	return self:_text_format(text, "@", ";", func)
end

function LocalizationManager:_text_macroize(text, macros)
	local function func(word)
		return macros[word] or false
	end

	return self:_text_format(text, "$", ";", func)
end

function LocalizationManager:_text_format(text, X, Y, func)
	local match_string = "%b" .. X .. Y

	return string.gsub(text, match_string, function (word)
		local id = string.sub(word, 2, -2)
		local value = func(id)

		if value then
			return value
		end

		return X .. self:_text_format(id, X, Y, func) .. Y
	end)
end
