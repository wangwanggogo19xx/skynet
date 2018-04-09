local skynet = require "skynet"

local M = {}

function M:init( )
	self.online_account = {}
end




function M.login(username,password)
	print(username,password)
	if not self.online_account[id] then
		self.online_account[id] = skynet.newservice("agent")
	end
	skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })

	return {succeed=1,err="login succeed"}
end

return M