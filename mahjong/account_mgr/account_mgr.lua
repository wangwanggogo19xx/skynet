local skynet = require "skynet"

local M = {}

function M:init( )
	self.online_account = {}
end




function M.login(username,password)
	print(username,password)
	return {succeed=1,err="login succeed"}
end

return M