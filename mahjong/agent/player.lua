local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local M = {}
function M:new(agent)
	local o = {
		room_mgr = nil,
		agent = agent,
		name = os.time(),
		ready = false,
		seat = nil,
		game_mgr= nil,
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


-- function M:player_join(player)
-- 	local str = self:request("set", { what="player_join",value={a="12",b="34"}})
-- 	self:send_package(str)
-- end


function M:player_leave( player )
	print(player,"leave")
end

function M:join_room(room_mgr,seat)
	if not room_mgr then
		room_mgr = skynet.call("area_mgr","lua","random_room")
	end
	local succeed,seat,info,room_mgr =  skynet.call(room_mgr ,"lua","add_player",self.agent,seat)

	if succeed then
		self.room_mgr = room_mgr
		self.seat = seat
	end
	return succeed,seat,info,room_mgr

end

function M:toggle_ready()
	self.ready,self.game_mgr = skynet.call(self.room_mgr ,"lua","seat_ready",self.seat)
end

function M:service_addr( addr)
	self.service_addr = addr
end

return M