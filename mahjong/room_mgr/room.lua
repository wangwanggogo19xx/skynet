local skynet = require "skynet"
local room_id_mgr = require "room_id_mgr"
local M = {}

function M:new(room_id,no)
	local o = {
		-- player_mgrs = {false,false,false,false},
		players={false,false,false,false},
		id = room_id,
		room_no =no,
		gameservice = nil,
	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o	
end

function M:notify_all_player(data)
	for i=1,#self.players do
		if self.players[i] then
			skynet.send(self.players[i].player_mgr,"lua","notify",data)	
		end
	end
end

function M:notify_other_players(player_mgr,data)
	for i=1,#self.players do
		if self.players[i] and not rawequal(player_mgr,self.players[i].player_mgr) then
			skynet.send(self.players[i].player_mgr,"lua","notify",data)
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

function M:add_player(player_mgr,player_id,seat)
	local succeed = true
	local info = ""
	if not seat then
		for i=1,#self.players do
			if  not self.players[i] then
				seat = i
				break;
			end
		end
	end
	if not seat then
		local info = "not available seat"
		print(info)
		return {succeed = false,seat=seat,room_mgr = self.id,info=info,players=self.players }
	end	

	

	self.players[seat] = {player_mgr=player_mgr,seat = seat,player_id=player_id,status = 1}
	

	if self.players[1] and self.players[2] and self.players[3] and self.players[4] then
		skynet.call("area_mgr","lua","set_unavailable",self.room_no)
		print(self.room_no)
	end	

	-- 通知其余玩家，有玩家进入
	local data = {cmd="player_join",value={seat=seat,user_id = player_id,seat_status=seat_status}}
	self:notify_other_players(player_mgr,data)
	return {succeed = succeed,seat=seat,room_mgr = self.id,info=info,players=self.players }
end

function M:toggle_ready(seat)

	if self.players[seat].status == 1 then
		self.players[seat].status = 2
	else
		self.players[seat].status = 1
	end
	self:notify_all_player({cmd="toggle_ready",value={seat=seat,status =self.players[seat].status}})

	return self:start_new_game()
end
function M:start_new_game()
	for i=1,#self.players do
		if not self.players[i] or self.players[i].status ~= 2  then
			return 
		end
	end
	self.gameservice = skynet.newservice("game_mgr");
	local data = {cmd="new_game"}
	print("new game")
	self:notify_all_player(data)
	skynet.send(self.gameservice,"lua","start",self.players)
	return true,self.gameservice
end

function M:remove_player( seat )
	
	local data = {cmd="player_leave",value={seat=seat}}
	self:notify_other_players(self.players[seat].room_mgr,data)
	self.players[seat] = false


	skynet.call("area_mgr","lua","set_available",self.room_no)
	return true
end

function M:get_room_info()
	-- local ret = {}
	-- for i=1,#self.player_mgrs do
	-- 	if self.player_mgrs[i] then
	-- 		local temp =skynet.call(self.player_mgrs[i],"lua","get_info")
	-- 		print(temp.seat)	
	-- 		table.insert(ret,temp)
	-- 	end
	-- end	
	return temp
end


function M:__tostring()
	return self.id..""
end


return M
-- skynet.start()