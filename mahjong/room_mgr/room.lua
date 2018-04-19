local skynet = require "skynet"
local room_id_mgr = require "room_id_mgr"
local M = {}

function M:new(room_id)
	local o = {
		player_mgrs = {false,false,false,false},
		seat_status = {0,0,0,0}, -- 0:empty，1：occupied ，2：ready
		id = room_id,
		player_count = 0
	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o	
end

function M:notify_all_player(data)
	for i=1,#self.player_mgrs do
		if self.player_mgrs[i] then
			skynet.send(self.player_mgrs[i],"lua","notify",data)	
		end
	end
end

function M:empty()
	for i=1,#self.players do
		if not self.players[i] then
			return false
		end
	end
	return true
end

function M:add_player(player_mgr,seat)
	if self.player_count >= 4 then
		return 0,-1,"no available seat"
	end

	local succeed = 0
	local info = ""
	if seat then
		if self.seat_status[seat] == 0 then

			self.player_mgrs[seat] = player_mgr
			self.seat_status[seat] = 1

			info = player.."'s seat is "..seat
			succeed =  1
		else
			succeed = 0
			info ="then seat "..seat.."is occupied"
		end	
	else
		for i=1,#self.seat_status do
			if  self.seat_status[i] == 0 then
				self.player_mgrs[i] = player_mgr
				self.seat_status[i] = 1
				succeed = 1	
				seat = i
				break		
			end
		end	
	end	

	-- 通知其余玩家，有玩家进入
	if succeed == 1 then
		self.player_count = self.player_count + 1	

		info = player_mgr.."'s seat is "..seat	
		-- player.room  = self
		for i=1,#self.player_mgrs do
			if self.player_mgrs[i] and not rawequal(player_mgr,self.player_mgrs[i]) then

				---掉线发生异常
				skynet.send(self.player_mgrs[i],"lua","notify",{cmd = "player_join",value=player_mgr,seat=seat})
			end
		end	
	end
	print("==========room return")
	return succeed,seat,info,self.id
end

function M:seat_ready(seat)
	local gameservice = nil

	if self.seat_status[seat] == 1 then
		self.seat_status[seat] = 2
	else
		self.seat_status[seat] = 1
	end

	---检查是否所有玩家已经准备
	if self.player_count == 4 then
		for i =1,#self.seat_status do
			if self.seat_status[i] ~= 2 then
				return
			end
		end
		print("start new game")

		gameservice=skynet.newservice("game_mgr")
		for i=1,#self.player_mgrs do
			skynet.send(self.player_mgrs[i],"lua","set",{attr="game_mgr",value=gameservice})	
		end
		skynet.send(gameservice,"lua","start",self.player_mgrs)		
	end
	print(#self.player_mgrs,"===========")
	local ret = {cmd="player_join",value={seat=seat}}
	self:notify_all_player(ret)

	return ret
end

function M:remove_player( player )
	local succeed = false
	for i=1,#self.players do
		if self.players[i] == player then
			self.players[i]  = false
			succeed  = true
		end
	end	

	-- 通知其余玩家，有玩家退出
	if succeed then
		for i=1,#self.players do
			if self.players[i] and not rawequal(player,self.players[i]) then
				self.players[i]:player_leave(player)
			end
		end	
	end
	return false
end



function M:__tostring()
	return self.id..""
	-- body
end


return M
-- skynet.start()