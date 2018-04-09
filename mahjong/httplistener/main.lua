local skynet = require "skynet"
local socket = require "skynet.socket"
local string = string

local port = ...

skynet.start(function()
	skynet.uniqueservice("account_mgr") --账号服务

	local webagent = {}
	for i= 1, 20 do
		webagent[i] = skynet.newservice("httpagent")
	end
	local balance = 1
	local id = socket.listen("0.0.0.0", port)
	skynet.error("Listen web port ",port)
	socket.start(id , function(id, addr)
		skynet.error(string.format("%s connected, pass it to agent :%08x", addr, webagent[balance]))
		skynet.send(webagent[balance], "lua", id)
		balance = balance + 1
		if balance > #webagent then
			balance = 1
		end
	end)

end)