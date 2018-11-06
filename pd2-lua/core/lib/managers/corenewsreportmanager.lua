core:module("CoreNewsReportManager")
core:import("CoreClass")
core:import("CoreString")
core:import("CoreDebug")

NewsReportManager = NewsReportManager or CoreClass.class()
NewsReportManager.NEWS_FILE = "settings/news"
NewsReportManager.OLD_NEWS_FILE = "settings/old_news"
NewsReportManager.KEYWORDS = {
	WIKI_URL = "http://ganonbackup/wiki_artistwiki/index.php/Main_Page",
	GANON_URL = "http://ganonbackup",
	CT_WIKI_URL = "http://ganonbackup/wiki_artistwiki/index.php/Core_Team",
	GRIN = [[

  _|_|_|  _|_|_|    _|_|_|  _|      _|
_|        _|    _|    _|    _|_|    _|
_|  _|_|  _|_|_|      _|    _|  _|  _|
_|    _|  _|    _|    _|    _|    _|_|
  _|_|_|  _|    _|  _|_|_|  _|      _|
]],
	NL = "\n",
	GRIN_URL = "http://www.grin.se",
	SP = " ",
	TB = "\t",
	ENV = {
		os.getenv,
		true
	}
}

function NewsReportManager:init()
	self._news_dates = {}
	local news_file = self.NEWS_FILE .. ".xml"
	local old_news_file = self.OLD_NEWS_FILE .. ".xml"

	if SystemFS:exists(news_file) then
		if not SystemFS:exists(old_news_file) then
			local old_news = assert(SystemFS:open(old_news_file, "w"))

			old_news:write("<old_news/>")
			old_news:close()
		else
			local old_news_root = assert(DB:load_node("xml", self.OLD_NEWS_FILE))

			for cat in old_news_root:children() do
				self._news_dates[cat:name()] = cat:parameter("date")
			end
		end
	else
		CoreDebug.cat_print("spam", "[CoreNewsReportManager] Can't find: " .. news_file)
	end
end

function NewsReportManager:replace(str)
	local function replace_str(s)
		local value = NewsReportManager.KEYWORDS[s]

		return tostring(type(value) == "table" and value[1]() or value or s)
	end

	for k, v in pairs(NewsReportManager.KEYWORDS) do
		if type(v) == "table" and v[2] then
			str = string.gsub(str, "%$" .. k .. "%s([%w_]+)", v[1])
		end
	end

	str = string.gsub(str, "%$([%w_]+)", replace_str)

	return str
end

function NewsReportManager:format_news(news, format, ...)
	if format == "TEXT" then
		local output = nil

		for _, v in ipairs(news) do
			output = output and string.format("%s\nDate: %s%s", output, v.date, v.text) or string.format("Date: %s%s", v.date, v.text)
			output = self:replace(output)
		end

		return output
	else
		local start = 0

		if #news > 20 then
			start = math.abs(20 - #news)
		end

		local output = {}

		for i, v in ipairs(news) do
			if start < i then
				local str = string.format("Date: %s%s", v.date, v.text)

				table.insert(output, self:replace(str))
			end
		end

		return #output > 0 and output
	end
end

function NewsReportManager:write_new_date()
	local old_news = assert(SystemFS:open(self.OLD_NEWS_FILE .. ".xml", "w"))

	old_news:write("<old_news>\n")

	for k, v in pairs(self._news_dates) do
		old_news:printf("\t<%s date=\"%s\"/>\n", k, v)
	end

	old_news:write("</old_news>")
	old_news:close()
end

function NewsReportManager:check_min_date(min_date, date)
	local d0 = {}
	local d1 = {}

	for n in string.gmatch(min_date, "%d+") do
		table.insert(d0, tonumber(n))
	end

	for n in string.gmatch(date, "%d+") do
		table.insert(d1, tonumber(n))
	end

	assert(#d0 == #d1, "Bad date format!")

	for i, n in ipairs(d0) do
		if d1[i] < n then
			break
		elseif n < d1[i] then
			return true
		end
	end

	return false
end

function NewsReportManager:check_news(category, include_old_news, format, ...)
	local news = {}
	local news_updated = false
	local news_root = DB:has("xml", self.NEWS_FILE) and DB:load_node("xml", self.NEWS_FILE)

	if news_root then
		for cat in news_root:children() do
			local cat_name = cat:name()

			if cat_name == category then
				local i = 1

				for msg in cat:children() do
					local msg_date = msg:parameter("date")
					local old_date = self._news_dates[cat_name]

					if not old_date or include_old_news or self:check_min_date(old_date, msg_date) then
						self._news_dates[cat_name] = msg_date
						news[i] = {
							date = msg_date,
							text = msg:data()
						}
						date_updated = true
						i = i + 1
					end
				end
			end
		end
	end

	if date_updated then
		self:write_new_date()
	end

	return self:format_news(news, format, ...)
end

function NewsReportManager:get_news(category)
	return self:check_news(category)
end

function NewsReportManager:get_old_news(category)
	return self:check_news(category, true)
end
