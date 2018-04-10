local skynet = require "skynet"
local maghjong = require "sc_mahjong"
local h = require "holds"
local M = {}

local allow_next = false

-- 当 current_session == wait_session 允许下一步，否则就等待，或者等待超时后执行下一步
local current_session  = 0
local current_card  -- 当前牌
-- local current_seat -- 当前出牌的玩家
-- local session = 0

local function wakeup(sec,co)
	for i=1,sec * 10 do
		if allow_next then
			skynet.wakeup(co)
			print("wakeup===========")
			return	
		end	
		skynet.sleep(10)
	end	
end


local tt

local function wait( sec,func,...)
	print(current_session,"===============")
	allow_next = false
	skynet.fork(wakeup,sec , coroutine.running())
	skynet.sleep(sec * 100)
	print(current_session,"====================")
	
	if not allow_next then
		print("")
		print("overtime....")
		if func then
			func(...)
		end
		allow_next = true
	end
end


function M:new(player_mgrs)
	local o = {
		mj = maghjong:new(),
		player_mgrs = player_mgrs,
		holds = {h:new(),h:new(),h:new(),h:new()},
		win = {false,false,false,false},
		id = 0,
		current_seat,
	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o
end


function M:start()
	self:init_holds()
	-- self:deal()

end

function M:next_seat()
	if self.current_seat == 4 then
		return 1
	else
		return self.current_seat + 1
	end
end
--发牌
function M:deal(seat)
	if self.mj.count == 0 then
		print("game over .......")
		return
	end

	seat = seat or  math.random(math.random(1,#self.player_mgrs))
	self.current_seat = seat
	if not self.win[current_seat] then
		local p = self.mj:next()
		self.holds[seat]:add(p)
		print(seat,"get card",p)
		skynet.send(self.player_mgrs[seat],"lua","game",{cmd="get",seat=seat,value=p},current_session)
		wait(1,self.random_throw,self,seat)
		return	
	end
end


function M:init_holds()
	for i= 1,4 do
		if self.player_mgrs[i] then
			for j=1,self.holds[i].init_holds_count do
				self.holds[i]:add(self.mj:next())
			end
			skynet.send(self.player_mgrs[i],"lua","game",{cmd="set_discard",value=self.holds[i]:__tostring()},current_session)
		end
	end
	-- skynet.wait()
	tt = coroutine.running()
	skynet.sleep(10000)
	print("111")
	-- wait(15,self.random_discard,self)
	-- body
end


function M:pong(seat,p,session)
	if session == current_session then
		print(seat,"pong",current_card)
		current_session =  current_session + 1
		allow_next = true
		self.current_seat = seat
		------------
		
		self.holds[seat]:pong(current_card)
		for i=1,4 do 
			skynet.send(self.player_mgrs[i],"lua","notify",{seat=seat,cmd = "player_pong",value = current_card})
		end
		if not p then
			p = self.holds[seat]:random_one()
		end		
		self:throw(seat,p,current_session)
	else 
		print("session has expired")		
	end
end

function M:gong(seat,p,session)
	if session == current_session then
		print(seat,"pong",self.current_card)

		current_session =  current_session + 1
		allow_next = true
		self.holds[seat]:gong(current_card,self.current_seat)
		for i=1,4 do 
			skynet.call(self.player_mgrs[i],"lua","notify",{seat=seat,cmd = "player_gong",value = current_card})
		end		
		self:throw(seat,p,current_session)
	else 
		print("session has expired")
	end	
end

function M:win(seat,p,session)
	if session == current_session then
		self.holds[seat]:win(p)
	end	
	
end
function M:throw(seat,p,session)
	if current_session == session and self.holds[seat]:has_p(p) then
		current_session = current_session + 1
		current_card = self.holds[seat]:throw(p)
		self.current_seat = seat

		
		local ok 
		for i=1,4 do 
			print("inform seat and throw",seat,p)

			-- 通知其他玩家，当前玩家出牌：p
			skynet.send(self.player_mgrs[i],"lua","notify",{seat=seat,cmd = "throw",value = p})
			if  i ~= seat and self.holds[i].need[p] then
				--通知，并等待其他用户可进行的操作
				print(i,self.holds[i].need[p],p)
				skynet.send(self.player_mgrs[i],"lua","game",{cmd = self.holds[i].need[p],value = p},current_session)
				ok = true
			end
		end

		-- 查看手牌
		skynet.send(self.player_mgrs[seat],"lua","notify",{seat=seat,cmd="show_holds",value=self.holds[seat]:__tostring()})
		
		if ok then
			wait(15,self.pass,self)
		else
			self:deal(self:next_seat())
		end
		-- 等待玩家操作
	end
	-- allow_next = true
end



function M:set_discard(seat,t,session)
	print(tt,coroutine.running())
	print(seat,t,session)
	skynet.wakeup(tt)
	if session == current_session then
		if not self.holds[seat].discard then
			if t and t >=1 and t<=3  then
				self.holds[seat].discard = t
				for i=1,#self.holds do
					if not self.holds[i].discard then
						return
					end
				end
				print("all player have set discard")
				allow_next = true  -- 允许下一步操作
			end	
		end
	end
	print("session has expired")
end








function M.random_discard(game)
	for j = 1,4 do
		if  not game.holds[j].discard then
			print("player" ,j,"random_discard")
			game.holds[j]:random_discard()
		end
	end
	current_session = current_session + 1	
end

function M.random_throw(game,seat)
	current_session = current_session + 1	
	local p = game.holds[seat]:random_one()
	game.throw(game,seat,p,current_session)
end
function M.pass( game )
	print("pong gong hu...............")
	current_session = current_session + 1
	game:deal(game:next_seat())
end
return M