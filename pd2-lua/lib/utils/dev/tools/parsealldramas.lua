ParseAllDramas = ParseAllDramas or class()

function ParseAllDramas:init()
	self:load_all_soundbanks()
	self:parse_all_dramas()
	self:create_sound_devices()
	self:start_parsing()
end

function ParseAllDramas:load_all_soundbanks()
	for i, soundbank in pairs(SoundDevice:sound_banks()) do
		CoreEngineAccess._editor_load(("bnk"):id(), Idstring(soundbank))
	end
end

function ParseAllDramas:parse_all_dramas()
	self._dramas = {}
	local file_name = "gamedata/dramas/index"
	local data = PackageManager:script_data(Idstring("drama_index"), file_name:id())

	for _, c in ipairs(data) do
		if c.name then
			self:_load_drama(c.name)
		end
	end
end

function ParseAllDramas:_load_drama(name)
	local file_name = "gamedata/dramas/" .. name
	local data = PackageManager:script_data(Idstring("drama"), file_name:id())
	local id = nil

	for _, c in ipairs(data) do
		if c.id then
			for _, node in ipairs(c) do
				if node._meta == "sound" then
					table.insert(self._dramas, node.name)
				end
			end
		end
	end
end

function ParseAllDramas:create_sound_devices()
	self._sound_source = SoundDevice:create_source("ParseAllDramas")
	self._sound_listener = SoundDevice:create_listener("ParseAllDramas")

	self._sound_listener:activate(true)
end

function ParseAllDramas:start_parsing()
	if self._ws then
		managers.gui_data:destroy_workspace(self._ws)
	end

	self._ws = managers.gui_data:create_fullscreen_workspace()
	self._panel = self._ws:panel():panel()

	self._panel:set_size(self._ws:panel():w() / 2, self._ws:panel():h() / 2)
	self._panel:set_center(self._ws:panel():w() / 2, self._ws:panel():h() / 2)
	self._panel:rect({
		color = Color(0, 0, 0)
	})

	self._text = self._panel:text({
		text = "",
		name = "text",
		align = "center",
		layer = 1,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	self._text:set_text("0/" .. tostring(#self._dramas))

	self._parsed_sound_events = {}

	local function update_anim(panel)
		local text = panel:child("text")
		local print_text = ""
		local dt = 0
		local done = false
		local sound_events = {}
		local max_sound_events = 40
		local current_source_index = 1
		local current_drama_index = 1
		local TIME = 0.8
		local TIME_PER_SOURCE = TIME / max_sound_events
		local t = TIME_PER_SOURCE
		self._failed_events = {}
		self._non_string_events = {}

		while not done do
			dt = coroutine.yield()
			t = t - dt

			if t <= 0 then
				local drama = self._dramas[current_drama_index]

				if sound_events[current_source_index] then
					sound_events[current_source_index]:stop()

					sound_events[current_source_index] = nil
				end

				if drama then
					self._non_string_events[drama] = true
					sound_events[current_source_index] = self._sound_source:post_event(drama, callback(self, self, "marker_callback"), drama, "marker")
					current_source_index = current_source_index % max_sound_events + 1
					current_drama_index = current_drama_index + 1

					if not sound_events[current_source_index] then
						self._non_string_events[drama] = nil

						table.insert(self._failed_events, drama)
					end
				else
					current_source_index = math.min(current_source_index + 1, max_sound_events)

					if sound_events[current_source_index] then
						sound_events[current_source_index]:stop()

						sound_events[current_source_index] = nil
					end
				end

				if not drama and current_source_index == max_sound_events then
					done = true
				end

				print_text = tostring(math.min(current_drama_index, #self._dramas)) .. "/" .. tostring(#self._dramas)

				text:set_text(print_text)

				t = TIME_PER_SOURCE
			end
		end

		print_text = print_text .. "\n" .. "Drama sounds failed to play: " .. tostring(table.size(self._failed_events))
		print_text = print_text .. "\n" .. "Drama sounds without string_id: " .. tostring(table.size(self._non_string_events))
		print_text = print_text .. "\n" .. "Drama sounds with string_id: " .. tostring(table.size(self._parsed_sound_events))

		text:set_text(print_text)

		self._string_id_sound_events = {}

		Application:debug("____________________________________________________________________________")
		Application:debug(" ")
		Application:debug("  [ParseAllDramas] PRINTING ERROR STRINGS", "TOTAL STRING_IDS, INCLUDING LOCALIZED: " .. table.size(self._parsed_sound_events))
		Application:debug("____________________________________________________________________________")

		for sound_event, string_id in pairs(self._parsed_sound_events) do
			local localization_exists = string_id and managers.localization:exists(string_id)

			if not localization_exists then
				print(string_id or "")
			else
				self._string_id_sound_events[sound_event] = string_id
			end
		end

		local gen = "\n" .. "GENERATING LOCALIZED STRINGS..."

		text:set_text(print_text .. gen)

		self._localized_sound_events = {}

		for sound_event, string_id in pairs(self._string_id_sound_events) do
			self._localized_sound_events[sound_event or "_"] = managers.localization:text(string_id or "_")

			coroutine.yield()
		end

		Application:debug(" ")
		Application:debug(" ")
		Application:debug(" ")
		Application:debug(" ")
		Application:debug(" ")
		Application:debug(" ")
		Application:debug("____________________________________________________________________________")
		Application:debug(" ")
		Application:debug("  [ParseAllDramas] PRINTING FOUND STRINGS", "LOCALIZED STRINGS ONLY: " .. table.size(self._localized_sound_events))
		Application:debug("____________________________________________________________________________")

		for sound_event, string_id in pairs(self._localized_sound_events) do
			print("Sound Event: " .. sound_event .. " | " .. string_id)
		end

		Application:debug("____________________________________________________________________________")

		local gen = "\n" .. "LOCALIZED STRINGS GENERATED. CHECK CONSOLE"

		text:set_text(print_text .. gen)
	end

	self._panel:animate(update_anim)
end

function ParseAllDramas:marker_callback(instance, sound_source, event_type, cookie, label, identifier, position)
	self._non_string_events[cookie] = nil
	self._parsed_sound_events[cookie] = label
end
