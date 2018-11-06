core:module("CoreScriptGraph")
core:import("CoreClass")
core:import("CoreEvent")

ScriptGraph = ScriptGraph or CoreClass.class()
CONFIG_VERSION = "1"

function ScriptGraph:init(parent, id, style)
	assert(style == "FLOW" or not style, "[ScriptGraph] Currently the only supported graph view type is 'FLOW'.")
	self:_create_panel(parent, id, style)
end

function ScriptGraph:update(t, dt)
	self._graph_view:update_graph(dt)
end

function ScriptGraph:window()
	return self._graph_view
end

function ScriptGraph:destroy()
	self._graph_view:destroy()
end

function ScriptGraph:selected_nodes()
	local t = {}

	for n in self._graph_view:selected_nodes() do
		table.insert(t, n)
	end

	return t
end

function ScriptGraph:last_selected_node()
	return self._graph_view:last_selected_node()
end

function ScriptGraph:nodes()
	return self._graph_view:nodes()
end

function ScriptGraph:graph_metadata()
	return self._graph_metadata
end

function ScriptGraph:set_graph_metadata(data)
	self._graph_metadata = data
end

function ScriptGraph:add_node(node)
	assert(node:type() == "FlowNode", "[ScriptGraph] The only supported node type is 'flow_node'.")
	self._graph:add_node(node)
end

function ScriptGraph:connect(id, event_type, cb, data)
	self._graph_view:connect(id, event_type, cb, data)
end

function ScriptGraph:save(id_map)
	local new_id_map = id_map or {}
	local config = Node("graph")

	config:set_parameter("name", self._name or "")
	config:set_parameter("version", CONFIG_VERSION)

	if self._graph_metadata then
		local gm = Node("metadata")

		gm:add_child(self._graph_metadata)
		config:add_child(gm)
	end

	if id_map then
		for id, node in pairs(id_map) do
			local cfg_node = Node("node")

			cfg_node:set_parameter("name", node:name())
			cfg_node:set_parameter("type", node:type())
			cfg_node:set_parameter("id", id)
			cfg_node:set_parameter("x", node:x())
			cfg_node:set_parameter("y", node:y())
			self:_write_slots(cfg_node, node, id_map)
			self:_write_icon(cfg_node, node)
			self:_write_node_color(cfg_node, node)
			config:add_child(cfg_node)
		end
	else
		for node in self._graph_view:nodes() do
			local cfg_node = Node("node")

			cfg_node:set_parameter("name", node:name())
			cfg_node:set_parameter("type", node:type())

			local id = tostring(node)
			new_id_map[id] = node

			cfg_node:set_parameter("id", id)
			cfg_node:set_parameter("x", node:x())
			cfg_node:set_parameter("y", node:y())
			self:_write_slots(cfg_node, node)
			self:_write_icon(cfg_node, node)
			self:_write_node_color(cfg_node, node)
			config:add_child(cfg_node)
		end
	end

	return config, new_id_map
end

function ScriptGraph:load(config_root)
	assert(config_root, "[ScriptGraph] Could not open: " .. tostring(config_root))
	assert(config_root:parameter("version") == CONFIG_VERSION, "[ScriptGraph] Bad version!")

	self._name = assert(config_root:parameter("name"))
	self._nodes = {}
	self._id_map = {}

	for node in config_root:children() do
		if node:name() == "metadata" then
			self._graph_metadata = node:child(0)

			break
		end
	end

	for node in config_root:children() do
		if node:name() == "node" then
			local node_info = self:_load_node_info(node)
			local ewsnode = EWS:FlowNode(assert(node:parameter("name")), node_info.in_slot_names, node_info.out_slot_names, tonumber(assert(node:parameter("x"))), tonumber(assert(node:parameter("y"))))
			self._nodes[assert(node:parameter("id"))] = {
				node_type = assert(node:parameter("type")),
				info = node_info,
				cnode = ewsnode
			}

			ewsnode:set_metadata(node:parameter("id"))

			self._id_map[node:parameter("id")] = ewsnode
		end
	end

	self._graph:clear()

	for _, node in pairs(self._nodes) do
		self._graph:add_node(node.cnode)

		if node.info.icon then
			node.cnode:set_icon(CoreEWS.image_path(node.info.icon:s()))
		end

		if node.info.color then
			node.cnode:set_colour(unpack(node.info.color))
		end
	end

	for _, node in pairs(self._nodes) do
		if node.info.out_slots then
			for slot_name, slot in pairs(node.info.out_slots) do
				for _, con in pairs(slot.con) do
					local dest_node = self:_find_node_with_id(self._nodes, con.id)

					node.cnode:set_target(slot_name, dest_node, con.slot, con.desc)
				end

				if slot.col then
					node.cnode:set_output_colour(slot_name, unpack(slot.col))
				end
			end
		end

		if node.info.in_slots then
			for slot_name, slot in pairs(node.info.in_slots) do
				if slot.col then
					node.cnode:set_input_colour(slot_name, unpack(slot.col))
				end
			end
		end
	end

	self._graph_view:refresh()

	return self._id_map
end

function ScriptGraph:_load_node_info(node)
	local info = {}

	for node_info in node:children() do
		if node_info:name() == "slot" then
			if assert(node_info:parameter("type")) == "in" then
				info.in_slots = info.in_slots or {}
				info.in_slot_names = info.in_slot_names or {}
				local color = nil
				local name = assert(node_info:parameter("name"))

				for inf in node_info:children() do
					if inf:name() == "color" then
						color = {
							tonumber(assert(inf:parameter("r"))),
							tonumber(assert(inf:parameter("g"))),
							tonumber(assert(inf:parameter("b")))
						}
					end
				end

				table.insert(info.in_slot_names, name)

				info.in_slots[name] = {
					col = color
				}
			else
				info.out_slots = info.out_slots or {}
				info.out_slot_names = info.out_slot_names or {}
				local connection = {}
				local color = nil
				local name = assert(node_info:parameter("name"))

				for inf in node_info:children() do
					if inf:name() == "connection" then
						table.insert(connection, {
							id = assert(inf:parameter("id")),
							slot = assert(inf:parameter("slot")),
							desc = assert(inf:parameter("desc"))
						})
					elseif inf:name() == "color" then
						color = {
							tonumber(assert(inf:parameter("r"))),
							tonumber(assert(inf:parameter("g"))),
							tonumber(assert(inf:parameter("b")))
						}
					end
				end

				table.insert(info.out_slot_names, name)

				info.out_slots[name] = {
					con = connection,
					col = color
				}
			end
		elseif node_info:name() == "icon" then
			info.icon = assert(Idstring(node_info:parameter("name")))
		elseif node_info:name() == "color" then
			info.color = {
				tonumber(assert(node_info:parameter("r"))),
				tonumber(assert(node_info:parameter("g"))),
				tonumber(assert(node_info:parameter("b")))
			}
		end
	end

	return info
end

function ScriptGraph:_create_panel(parent, id, style, window_style)
	self._graph = EWS:Graph()
	self._graph_view = EWS:GraphView(parent, id or "", self._graph, "FLOW")

	self._graph_view:set_clipping(false)
	self._graph_view:toggle_style(window_style or "SUNKEN_BORDER")
end

function ScriptGraph:_find_node_with_id(nodes, id)
	local node = assert(nodes[id], "[ScriptGraph] The graph is corrupt! Can't find node id: " .. tostring(id))

	return node.cnode
end

function ScriptGraph:_find_id_with_node(id_map, node)
	for id, n in pairs(id_map) do
		if n == node then
			return id
		end
	end

	error("[ScriptGraph] Could not find node: " .. tostring(node))
end

function ScriptGraph:_write_icon(cfg_node, node)
	if node:icon() ~= "" then
		local icon = Node("icon")
		local path_len = string.len(managers.database:base_path() .. "core\\lib\\utils\\dev\\ews\\images\\")

		icon:set_parameter("name", string.sub(node:icon(), path_len + 1))
		cfg_node:add_child(icon)
	end
end

function ScriptGraph:_write_connections(slot_node, slot, node, id_map)
	local con_info = node:connection_info(slot)

	for _, inf in pairs(con_info) do
		local dest = inf.node
		local dest_slots = inf.slots
		local id = id_map and self:_find_id_with_node(id_map, dest) or tostring(dest)

		for _, dest_slot in ipairs(dest_slots) do
			local con_node = Node("connection")

			con_node:set_parameter("id", id)
			con_node:set_parameter("slot", dest_slot)
			con_node:set_parameter("desc", "")
			slot_node:add_child(con_node)
		end
	end
end

function ScriptGraph:_write_output_color(slot_node, slot, node)
	local r, g, b = node:output_colour(slot)

	self:_write_output_color_to_node(slot_node, Node("color"), r, g, b)
end

function ScriptGraph:_write_input_color(slot_node, slot, node)
end

function ScriptGraph:_write_output_color_to_node(slot_node, color_node, r, g, b)
	color_node:set_parameter("r", tostring(assert(r)))
	color_node:set_parameter("g", tostring(assert(g)))
	color_node:set_parameter("b", tostring(assert(b)))
	slot_node:add_child(color_node)
end

function ScriptGraph:_write_node_color(cfg_node, node)
	local color_node = Node("color")

	color_node:set_parameter("r", tostring(assert(node:r())))
	color_node:set_parameter("g", tostring(assert(node:g())))
	color_node:set_parameter("b", tostring(assert(node:b())))
	cfg_node:add_child(color_node)
end

function ScriptGraph:_write_slots(cfg_node, node, id_map)
	if node:type() == "FlowNode" then
		for _, slot in ipairs(node:inputs()) do
			local slot_node = Node("slot")

			slot_node:set_parameter("name", slot)
			slot_node:set_parameter("type", "in")
			self:_write_connections(slot_node, slot, node, id_map)
			self:_write_input_color(slot_node, slot, node)
			cfg_node:add_child(slot_node)
		end

		for _, slot in ipairs(node:outputs()) do
			local slot_node = Node("slot")

			slot_node:set_parameter("name", slot)
			slot_node:set_parameter("type", "out")
			self:_write_connections(slot_node, slot, node, id_map)
			self:_write_output_color(slot_node, slot, node)
			cfg_node:add_child(slot_node)
		end
	end
end
