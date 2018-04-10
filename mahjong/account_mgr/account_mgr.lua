local skynet = require "skynet"

local M = {}

local id = 1
function M:init( )
	self.online_account = {}
	print(self.online_account )
end

function M:login(username,password)
	if not self.online_account[id] then
		-- self.online_account[id] = skynet.newservice("agent")
	end
	-- skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })
	id = id + 1
	return {succeed=1,err="login succeed"}
end

return M