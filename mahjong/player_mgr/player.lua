local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local M = {}

local host = sprotoloader.load(1):host "package"
local send_request

function M:new(fd)
	local o = {
		room_mgr = nil,
		room = nil,
		client_fd = fd,
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

function M:player_join( player )
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	-- print(player,"join")
	self:send_package(send_request "heartbeat" )
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