local skynet = require "skynet"
local room_id_mgr = require "room_id_mgr"
local M = {}

function M:new(room_id)
	local o = {
		players = {false,false,false,false},
		id = room_id,
		player_count = 0
	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o	
end

function M:empty()
	for i=1,#self.players do
		if not self.players[i] then
			return false
		end
	end
	return true
end

function M:add_player(player,seat)
	print(self.player_count)
	if self.player_count >= 4 then
		return 0,-1,"no available seat"
	end

	local succeed = 0
	local info = ""
	if seat then
		if not self.players[seat] then
			self.players[seat] = player
			info = player.."'s seat is "..seat
			succeed =  1
		else
			succeed = 0
			info ="then seat "..seat.."is occupied"
		end	
	else
		for i=1,#self.players do
			if not self.players[i] then
				self.players[i]  = player
				succeed = 1	
				seat = i
				break		
			end
		end	
	end	
	self.player_count = self.player_count + 1

	-- 通知其余玩家，有玩家进入
	if succeed == 1 then
		info = player.agent.."'s seat is "..seat	
		player.room  = self
		for i=1,#self.players do
			if self.players[i] and not rawequal(player,self.players[i]) then
				skynet.call(self.players[i].agent,"lua","notify",player.name)
			end
		end	
	end
	print(succeed,seat,info)
	return succeed,seat,info,room = self.id
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