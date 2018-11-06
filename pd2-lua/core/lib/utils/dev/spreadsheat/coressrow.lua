core:module("CoreSsRow")
core:import("CoreClass")

local EMPTY_ROW_XML = "   <Row> %s\n   </Row> "
local CELL_XML = "    <Cell><Data ss:Type=\"String\">%s</Data></Cell> "
Row = Row or CoreClass.class()

function Row:init(...)
	self._vals = {
		...
	}
end

function Row:add_val(val)
	table.insert(self._vals, val)
end

function Row:_to_cells_xml()
	local cells_xml = ""

	for _, v in ipairs(self._vals) do
		cells_xml = cells_xml .. "\n" .. string.format(CELL_XML, v)
	end

	return cells_xml
end

function Row:to_xml(f)
	f:write(string.format(EMPTY_ROW_XML, self:_to_cells_xml()))
end

local EMPTY_HEADER1_ROW_XML = "   <Row ss:StyleID=\"header1\"> %s\n   </Row> "
Header1Row = Header1Row or CoreClass.class(Row)

function Header1Row:to_xml(f)
	f:write(string.format(EMPTY_HEADER1_ROW_XML, self:_to_cells_xml()))
end

local EMPTY_HEADER2_ROW_XML = "   <Row ss:StyleID=\"header2\"> %s\n   </Row> "
Header2Row = Header2Row or CoreClass.class(Row)

function Header2Row:to_xml(f)
	f:write(string.format(EMPTY_HEADER2_ROW_XML, self:_to_cells_xml()))
end
