core:module("CoreWorkbook")
core:import("CoreClass")

local EMPTY_WORKBOOK_XML1 = [[
<?xml version="1.0"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
  </Style>
  <Style ss:ID="header1">
   <Font x:Family="Swiss" ss:Bold="1"/>
  </Style>
  <Style ss:ID="header2">
   <Font x:Family="Swiss" ss:Bold="1" ss:Italic="1"/>
  </Style>
 </Styles>]]
local EMPTY_WORKBOOK_XML2 = "</Workbook> "
Workbook = Workbook or CoreClass.class()

function Workbook:init()
	self._worksheets = {}
end

function Workbook:add_worksheet(worksheet)
	table.insert(self._worksheets, worksheet)
end

function Workbook:to_xml(f)
	f:write(EMPTY_WORKBOOK_XML1)

	local ws_xml = ""

	for _, ws in ipairs(self._worksheets) do
		f:write("\n")
		ws:to_xml(f)
	end

	f:write(EMPTY_WORKBOOK_XML2)
end
