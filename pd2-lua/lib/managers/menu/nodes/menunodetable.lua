core:import("CoreMenuNode")
core:import("CoreSerialize")
core:import("CoreMenuItem")
core:import("CoreMenuItemToggle")

MenuNodeTable = MenuNodeTable or class(CoreMenuNode.MenuNode)

function MenuNodeTable:init(data_node)
	MenuNodeTable.super.init(self, data_node)

	self._columns = {}

	self:_setup_columns()

	self._parameters.total_proportions = 0

	for _, data in ipairs(self._columns) do
		self._parameters.total_proportions = self._parameters.total_proportions + data.proportions
	end
end

function MenuNodeTable:_setup_columns()
end

function MenuNodeTable:_add_column(params)
	table.insert(self._columns, params)
end

function MenuNodeTable:columns()
	return self._columns
end
