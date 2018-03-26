local skynet = require "skynet"

local M = {}
function M:new(fd)
	local 0 = {
		room_mgr = nil,
		room = nil,
		client_fd = fd,
	}

	setmetatable(o,self)		
	self.__index = self	
	return o
end

function M:player_join( player )
	print(player,"join")
end

function M:player_leave( player )
	print(player,"leave")
end

return M