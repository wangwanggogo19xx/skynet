local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local M = {}
function M:new(fd)
	local o = {
		room_mgr = nil,
		room = nil,
		client_fd = fd,
		name = os.time(),
		-- send_request = host:attach(sprotoloader.load(2)),		
	}

	setmetatable(o,self)		
	self.__index = self	
	return o
end

function M:send_package(pack)
	print(pack)
	local package = string.pack(">s2", pack)
	socket.write(self.client_fd, package)
end
function M:request(name,agrs,session)
	local host = sprotoloader.load(1):host "package"
	local request = host:attach(sprotoloader.load(2))
	return request(name,agrs,session)
end


function M:player_join(player)
	local str = self:request("set", { what="player_join",value={a="12",b="34"}})
	self:send_package(str)
end


function M:player_leave( player )
	print(player,"leave")
end

function M:join_room(...)

	skynet.call("room_mgr","lua","join_room",self,...)
	skynet.error("join room :",room_id)
end

function M:service_addr( addr)
	self.service_addr = addr
end

return M