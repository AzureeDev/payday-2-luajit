local base = _G
local string = require("string")
local math = require("math")

print("Socket: " .. io.popen("cd"):read("*l"))
PackageManager:load_socket_lib()

local _M = socket

if not socket.connect then
	function socket.connect(address, port, laddress, lport)
		local sock, err = socket.tcp()

		if not sock then
			return nil, err
		end

		if laddress then
			local res, err = sock:bind(laddress, lport, -1)

			if not res then
				return nil, err
			end
		end

		local res, err = sock:connect(address, port)

		if not res then
			return nil, err
		end

		return sock
	end
end

function _M.connect4(address, port, laddress, lport)
	return socket.connect(address, port, laddress, lport, "inet")
end

function _M.connect6(address, port, laddress, lport)
	return socket.connect(address, port, laddress, lport, "inet6")
end

function _M.bind(host, port, backlog)
	if host == "*" then
		host = "0.0.0.0"
	end

	local addrinfo, err = socket.dns.getaddrinfo(host)

	if not addrinfo then
		return nil, err
	end

	local sock, res = nil
	err = "no info on address"

	for i, alt in base.ipairs(addrinfo) do
		if alt.family == "inet" then
			sock, err = socket.tcp()
		else
			sock, err = socket.tcp6()
		end

		if not sock then
			return nil, err
		end

		sock:setoption("reuseaddr", true)

		res, err = sock:bind(alt.addr, port)

		if not res then
			sock:close()
		else
			res, err = sock:listen(backlog)

			if not res then
				sock:close()
			else
				return sock
			end
		end
	end

	return nil, err
end

_M.try = _M.newtry()

function _M.choose(table)
	return function (name, opt1, opt2)
		if base.type(name) ~= "string" then
			opt2 = opt1
			opt1 = name
			name = "default"
		end

		local f = table[name or "nil"]

		if not f then
			base.error("unknown key (" .. base.tostring(name) .. ")", 3)
		else
			return f(opt1, opt2)
		end
	end
end

local sourcet = {}
local sinkt = {}
_M.sourcet = sourcet
_M.sinkt = sinkt
_M.BLOCKSIZE = 2048

sinkt["close-when-done"] = function (sock)
	return base.setmetatable({
		getfd = function ()
			return sock:getfd()
		end,
		dirty = function ()
			return sock:dirty()
		end
	}, {
		__call = function (self, chunk, err)
			if not chunk then
				sock:close()

				return 1
			else
				return sock:send(chunk)
			end
		end
	})
end

sinkt["keep-open"] = function (sock)
	return base.setmetatable({
		getfd = function ()
			return sock:getfd()
		end,
		dirty = function ()
			return sock:dirty()
		end
	}, {
		__call = function (self, chunk, err)
			if chunk then
				return sock:send(chunk)
			else
				return 1
			end
		end
	})
end

sinkt.default = sinkt["keep-open"]
_M.sink = _M.choose(sinkt)

sourcet["by-length"] = function (sock, length)
	return base.setmetatable({
		getfd = function ()
			return sock:getfd()
		end,
		dirty = function ()
			return sock:dirty()
		end
	}, {
		__call = function ()
			if length <= 0 then
				return nil
			end

			local size = math.min(socket.BLOCKSIZE, length)
			local chunk, err = sock:receive(size)

			if err then
				return nil, err
			end

			length = length - string.len(chunk)

			return chunk
		end
	})
end

sourcet["until-closed"] = function (sock)
	local done = nil

	return base.setmetatable({
		getfd = function ()
			return sock:getfd()
		end,
		dirty = function ()
			return sock:dirty()
		end
	}, {
		__call = function ()
			if done then
				return nil
			end

			local chunk, err, partial = sock:receive(socket.BLOCKSIZE)

			if not err then
				return chunk
			elseif err == "closed" then
				sock:close()

				done = 1

				return partial
			else
				return nil, err
			end
		end
	})
end

sourcet.default = sourcet["until-closed"]
_M.source = _M.choose(sourcet)

print("Socket Library Initialized Correctly")

return _M
