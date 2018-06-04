local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local M = {}
function M:new(userinfo)
	local o = {
		room_mgr = nil,
		name = os.time(),
		userinfo = userinfo,
		ready = false,
		seat = nil,
		game_mgr= nil,
		ongaming=false,
		active = true, --判断用户是否离线
		-- send_request = host:attach(sprotoloader.load(2)),		
	}

	setmetatable(o,self)		
	self.__index = self	
	return o
end

-- function M:send_package(pack)
-- 	print(pack)
-- 	local package = string.pack(">s2", pack)
-- 	socket.write(self.client_fd, package)
-- end
-- function M:request(name,agrs,session)
-- 	local host = sprotoloader.load(1):host "package"
-- 	local request = host:attach(sprotoloader.load(2))
-- 	return request(name,agrs,session)
-- end


-- function M:player_join(player)
-- 	local str = self:request("set", { what="player_join",value={a="12",b="34"}})
-- 	self:send_package(str)
-- end


function M:leave_room()
	if self.room_mgr  then
		succeed = skynet.call(self.room_mgr ,"lua","remove_player",self.seat)
		if succeed then
			self.seat = nil
			self.ready = nil
			self.game_mgr = nil
			self.room_mgr = nil
			return {cmd="succeed_leave"}
		end
	end
end

function M:join_room(room_mgr,seat)
	if not room_mgr then
		room_mgr = skynet.call("area_mgr","lua","random_room")
	end
	if room_mgr then
		local ret =  skynet.call(room_mgr ,"lua","add_player",self.userinfo,seat)
		print(ret.succeed,"======")
		if ret.succeed then
			self.room_mgr = room_mgr
			self.seat = ret.seat
		end
		return {cmd="succeed_join",value=ret}		
	else
		return {cmd="error_join",error_info = "无可用房间"}	
	end
	

end

function M:toggle_ready()
	if self.room_mgr then
		succeed,gameservice = skynet.call(self.room_mgr ,"lua","toggle_ready",self.seat)
		if succeed then
			self.game_mgr = gameservice
			self.ongaming = true
			print("gameservice",self.game_mgr)
		end
	end
	print("gameservice",self.game_mgr)
end
function M:get_game_info()
	if self.game_mgr then
		local ret,rest_count = skynet.call(self.game_mgr,"lua","get_info",self.seat)
		ret = {gameinfo = ret,my_seat = self.seat,rest_count=rest_count}
		return ret
	end
	return
	-- body
end
function M:ongame()
	return self.game_mgr ~= nil
	-- body
end
-- function M:lose( p )
-- 	print(self.game_mgr,p)
-- 	skynet.call(self.game_mgr,"lua","lose",self.seat,p)
-- end

function M:service_addr( addr)
	self.service_addr = addr
end


--- 玩家对牌的操作
function M:pass(session)
	skynet.send(self.game_mgr,"lua","pass",self.seat,session)
end
function M:pong(p,session)
	skynet.send(self.game_mgr,"lua","pong",self.seat,p,session)
end
function M:zhi_gong(p,session)
	skynet.send(self.game_mgr,"lua","zhi_gong",self.seat,p,session)
end
function M:hu(p,session)
	skynet.send(self.game_mgr,"lua","hu",self.seat,p,session)
	self.ongaming = false
end
function M:throw(p,session)
	print(session,p,"=========");
	skynet.send(self.game_mgr,"lua","throw",self.seat,p,session)
end

function M:send_msg(msg)
	skynet.send(self.room_mgr,"lua","send_msg",self.seat,msg)
	-- send_msg(msg)
	-- body
end

function M:set_discard(t ,session)
	print("gameservice",self.game_mgr)
	print("set_discard",self.game_mgr,t,session)
	skynet.send(self.game_mgr,"lua","set_discard",self.seat,t,session)
end
function M:gameover()
	-- self:toggle_ready()
	self.game_mgr = nil
	self.ongaming = false
	if not self.active then
		skynet.send(self.userinfo.agent,"lua","disconnect" )
		print("游戏结束，断开离线玩家")
	end

end
function M:get_info()
	print(name,seat)
	return {user_id = name,seat =seat}
end
function M:get_accountname()
	return self.userinfo.accountname
	-- body
end
function M:reconnect()
	self.active = true
	skynet.send(self.game_mgr,"lua","reconnect",self.seat)
	-- body
end


return M