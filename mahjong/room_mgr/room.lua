local skynet = require "skynet"
local room_id_mgr = require "room_id_mgr"
local M = {}

function M:new(room_id)
	local o = {
		players = {false,false,false,false},
		id = room_id
	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o	
end

function M:join(player ,seat)
	local succeed = false
	local info = ""
	if seat then
		if not self.players[seat] then
			self.players[seat] = player
			info = player.."'s seat is "..seat
			succeed =  true
		else
			succeed = false
			info ="then seat "..seat.."is occupied"
		end	
	else
		for i=1,#self.players do
			if self.players[i] then
				self.players[i]  = player
				succeed = true	
				info = player.."'s seat is "..seat			
			end
		end	
		info = "no available seat "
	end	

	-- 通知其余玩家，有玩家进入
	if succeed then
		player.room  = self
		for i=1,#self.players do
			if self.players[i] and self.player[i] ~= player then
				self.players[i]:player_join(player)	
			end
		end	
	end
	return succeed,info
end

function M:leave( player )
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
			if self.players[i] and self.players[i] ~= player then
				self.players[i]:player_leave(player)
			end
		end	
	end

	return false
end