local skynet = require "skynet"
local maghjong = require "sc_mahjong"
local h = require "holds"
local M = {}

local allow_next = false

-- 当 current_session == wait_session 允许下一步，否则就等待，或者等待超时后执行下一步
local current_session  = 0
local wait_session  = 0


local function wakeup(co,sec)
	for i=1,sec * 10 do
		print(allow_next)
		if current_session == wait_session then
			skynet.wakeup(co)
			return	
		end	
		skynet.sleep(10)
	end	
end

local function wait( sec)
	wait_session = wait_session +1
	skynet.fork(wakeup, coroutine.running(),sec * 100)
	skynet.sleep(sec * 100)
end


function M:new(player_mgrs)
	local o = {
		mj = maghjong:new(),
		player_mgrs = player_mgrs,
		holds = {h:new(),h:new(),h:new(),h:new()},
		win = {false,false,false,false},
		id = 0
	}

	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o
	-- body
end


function M:start()
	self:init_holds()
	self:wait_set_discard()
	-- self:next_player()

end


function M:next_player(current_seat)

	if self.mj.count == 0 then
		return
	end
	allow_next = false

	local seat
	if current_seat then
		if current_seat == 4 then
			seat = 1
		else 
			seat  = current_seat + 1
		end
	else
		seat = math.random(math.random(1,#self.player_mgrs))
	end

	if not self.win[seat] then
		local p = self.mj:next()
		skynet.send(self.player_mgrs[seat],"lua","game",{cmd="get",seat=seat,value=p})
		skynet.fork(wait, coroutine.running())
		skynet.sleep(1500)	

		if allow_next then
			self:next_player(seat)
		end
		return	
	end

	self:next_player(seat)

end
function M:wait_response()
	-- body
end

function M:init_holds()
	for i= 1,4 do
		if self.player_mgrs[i] then
			for j=1,self.holds[i].init_holds_count do
				self.holds[i]:add(self.mj:next())
			end
			skynet.send(self.player_mgrs[i],"lua","game",{cmd="set_discard",value=self.holds[i]:__tostring()})
		end
	end
	-- body
end

function M:pong(seat,p)
	self.holds[seat]:pong(p)
end

function M:gong(seat,p)
	self.holds[seat]:gong(p)
end

function M:win(seat,p)
	self.holds[seat]:win(p)
end
function M:throw(seat,p)

	if self.holds[seat]:has_p(p) then
		print("throw",seat,p)
		self.holds[seat]:throw(p)
		-- 通知其他玩家，当前玩家出牌：p
		local ok 
		for i=1,4 do 
			print("inform seat and throw",seat,p)
			skynet.call(self.player_mgrs[i],"lua","notify",{seat=seat,cmd = "throw",value = p})

			if  self.holds[i].need[p] then
				--通知，并等待其他用户可进行的操作
				skynet.call(self.player_mgrs[i],"lua","game",{cmd = self.holds[i].need[p],value = p})
				ok = true
			end
		end
		
		-- 等待玩家操作
		-- if ok then


	end

	allow_next = true

	-- self:next_player(seat)
end

function M:wait_set_discard()
	wait(15)
	for j = 1,4 do
		if  not self.holds[j].discard then
			self.holds[j]:random_discard()
		end
	end	
end

function M:set_discard(seat,t)
	if not self.holds[seat].discard then
		if t and t >=1 and t<=3  then
			self.holds[seat].discard = t

			for i=1,#self.holds do
				if not self.holds[i].discard then
					return
				end
			end
			current_session = current_session + 1
		end	
	end
end


return M