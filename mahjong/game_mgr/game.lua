local skynet = require "skynet"
local maghjong = require "sc_mahjong"
local h = require "holds"
local M = {}


local wait_count = 0
local wait_time = 20 -- 等待时间
wait_time = 0.5 

-- 当 current_session == wait_session 允许下一步，否则就等待，或者等待超时后执行下一步
local current_session  = 1
local current_card  -- 当前牌

local task_thread

-- local current_seat -- 当前出牌的玩家
-- local session = 0

local function wakeup(direct) -- 是否直接唤醒
	wait_count = wait_count - 1
	if direct or wait_count == 0 then
		wait_count = 0
		skynet.wakeup(task_thread)
		skynet.yield()
	end
end


local function wait(count,sec,func,...)
	task_thread = coroutine.running()

	wait_count = count
	skynet.sleep(sec * 100)
	print("wait_count:",wait_count)
	if wait_count > 0 then
		print("")
		print("overtime....")
		if func then
			return func(...)
		end
		wait_count = 0
	else
		print("")
		print("be wakeup")		
	end
end


function M:new(players,game_mgr,room_mgr)
	local o = {
		mj = maghjong:new(),
		players = players,
		holds = {h:new(),h:new(),h:new(),h:new()},
		have_hu = {},
		id = game_mgr,
		current_seat,
		result = {},
		hu_count=0,
		room_mgr = room_mgr,
	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o
end
function M:player_drop(seat)
	self.players[seat].active = false
	-- self.players[seat] = false
	-- body
end

function M:reconnect( seat )
	self.players[seat].active = true
	-- body
end

function M:notify_player(player,data)
	if player and player.active then
		skynet.send(player.agent,"lua","notify",data)
	end
end

function M:notify_other_players(player,data)
	for i=1,#self.players do
		if self.players[i] and self.players[i].active and not rawequal(player,self.players[i]) then
			skynet.send(self.players[i].agent,"lua","notify",data)
		end
	end		
end
function M:notify_all_players(data)
	for i=1,#self.players do
		if self.players[i] and self.players[i].active then
			skynet.send(self.players[i].agent,"lua","notify",data)
		end
	end		
end


function M:start()

	local data = {{value= self.id,attr="game_mgr"}}
	for i=1,#self.players do
		if self.players[i] then
			skynet.call(self.players[i].agent,"lua","set",data)
		end
	end		

	-- 初始手牌
	self:init_holds()
	-- 等待定缺,超时随机定缺
	wait(1,20,self.random_discard,self)

	-- 检测天胡,严重bug
	if self.holds[self.current_seat]:hu() then
		print("天胡")
		current_session = current_session + 1
		local data = {cmd="option",value={tian_hu=true,back_gang = self.self.holds[self.current_seat].back_gang},session = current_session}
		-- if #self.holds[self.current_seat].back_gang > 0 then

		-- end
		self:notify_player(self.players[self.current_seat],data)
	else
		-- self:notify_player(self.players[self.current_seat],{cmd="allow_throw",value={},session=current_session})
		-- current_session = current_session + 1				

		wait(1,wait_time,self.random_throw,self,self.current_seat)
		-- print("出牌")
		-- wait(1,self.random_throw,self,self.current_seat)
	end

	-- self:notify_player(self.players[self.current_seat],{cmd="wait_throw",value={}})


end

function M:next_seat()
	if self.current_seat == 4 then
		return 1
	else
		return self.current_seat + 1
	end
end
--发牌
function M:deal(s)
	if self.mj.count == 0 then
		self:gameover()
		return
	end
	
	seat = s or  math.random(math.random(1,#self.players))
	self.current_seat = seat
	if not self.have_hu[self.current_seat] then
		local p = self.mj:next()
		current_card = p
		self.holds[seat]:add(p)
		print(seat,"get card",p)

		-- if 
		local option = nil
		-- 是否自摸
		if self.holds[seat]:hu() then
			option = option or {}
			print("自摸=======================")
			option["hu"] = p
		end
		--  是否有暗杠
		if #self.holds[seat].back_gong > 0 and self.mj.count > 0 then
			print("暗杠============================")
			option = option or {}
			print(self.holds[seat].back_gong[1])
			option["back_gang"] = self.holds[seat].back_gong
		end
		if #self.holds[seat]:have_gong() > 0 and self.mj.count > 0  then
			option = option or {}
			print("弯杠============================")
			-- print(self.holds[seat].wan_gong[1])
			option["wan_gong"] = self.holds[seat]:have_gong()
		end

		local  data = {cmd="get_p",value={seat=seat,p = p,options = option},session=current_session}
		self:notify_player(self.players[seat],data)
		
		data.value.p = nil
		data.session = nil
		data.value.options = nil

		self:notify_other_players(self.players[seat],data)	

		wait(1,wait_time,self.random_throw,self,self.current_seat)
		return
	else
		self:deal(self:next_seat())	
	end
end


function M:init_holds()
	self.current_seat  = math.random(math.random(1,#self.players))
	self.holds[self.current_seat].init_holds_count = self.holds[self.current_seat].init_holds_count + 1
	local data = {cmd="init_holds",value={holds=nil,start_seat = self.current_seat},session=current_session}
	
	for i= 1,4 do
		if self.players[i] then
			for j=1,self.holds[i].init_holds_count do
				self.holds[i]:add(self.mj:next())
			end
			data.value.seat = self.players[i].seat;
			data.value.holds = self.holds[i]:get_holds();
			self:notify_player(self.players[i],data)
		end
	end

	-- self:deal()

end


function M:pong(seat,p,session)
	print(current_session,session)
	if session == current_session then
		print(seat,"pong",current_card)
		current_session =  current_session + 1

		wakeup(true)
		------------
		print(current_card,p)
		self.holds[seat]:pong(current_card)
		-- for i=1,4 do 
		-- 	skynet.send(self.players[i].player_mgr,"lua","notify",{seat=seat,cmd = "player_pong",value = current_card})
		-- end
		local data = {cmd="player_pong",value={seat=seat,p=p,chupai_seat=self.current_seat}}
		self:notify_other_players(self.players[seat],data);

		data.session = current_session
		self.current_seat = seat
		self:notify_player(self.players[seat],data)



		wait(1,wait_time,self.random_throw,self,self.current_seat)


	else 
		print("session has expired")		
	end
end

function M:zhi_gong(seat,p,session)
	-- print(current_session,session)
	if session == current_session then
		print(seat,"gong",p)
		current_session =  current_session + 1
		wakeup(true)
		local succeed,type=self.holds[seat]:zhi_gong(p,self.current_seat)
		print(self.holds)
		self:notify_all_players({cmd="player_zhi_gong",value={seat=seat,p=p,type=type}})
		self:deal(seat) -- 摸一张牌
	else 
		print("session has expired")
	end	
end

function M:hu(seat,p,session)
	if session == current_session then
		current_session = current_session + 1
		wakeup(true)
		self.hu_count = self.hu_count + 1

		print(seat,"hu",current_card)
		local hu_info = self.holds[seat]:get_hu_info()
		

		if self.current_seat == seat then --自摸
			-- 自摸的时候手牌减一
			self.holds[seat].holds_count = self.holds[seat].holds_count  - 1
			
			hu_info.zimo = true
			hu_info.times = hu_info.times * 2

			-- 最大8番
			if hu_info.times > 8 then
				hu_info.times = 8
			end		

			local no_hu_count = 0
			for i=1,#self.players do
				if i ~=seat then
					self.result[i] = self.result[i] or {}
					if not self.have_hu[i] then
						no_hu_count = no_hu_count + 1
						local row = {}
						row.seat = seat
						row.info = hu_info
						row.score = 0 - hu_info.times

						table.insert(self.result[i],row)						
					end
				end
			end

			self.result[seat] = self.result[seat] or {}
			local row = {}
			row.seat = seat

			row.info = hu_info
			row.score =  hu_info.times * no_hu_count
			table.insert(self.result[seat],row)			
		else  --点炮
			self.holds[seat]:add(p) --手牌中添加当前牌（判断是否胡在杠上）
			hu_info = self.holds[seat]:get_hu_info()
			-- 最大8番
			if hu_info.times > 8 then
				hu_info.times = 8
			end		

			hu_info.dianpao = true

			self.result[seat] = self.result[seat] or {}
			self.result[self.current_seat] = self.result[self.current_seat] or {}

			local row = {}
			row.seat = seat
			row.info = hu_info
			row.score = hu_info.times
			table.insert(self.result[seat],row)
			row = {}
			row.seat = seat
			row.info = hu_info
			row.score = 0 - hu_info.times
			table.insert(self.result[self.current_seat],row)

		end
		
		for k,v in pairs(hu_info) do
			print(k,v)
		end



		self.have_hu[seat] = {1}

		local data = {cmd="player_hu",value={seat =seat,p=current_card,hu_info=hu_info,result=self.result[seat]}}
		self:notify_all_players(data)
		self.current_seat = seat


		-- local t = 0
		-- for k,v in pairs(self.have_hu) do
		-- 	t = t+1
		-- end	
		if self.hu_count == 3 then
			self:gameover()
			return 
		else
			self:deal(self:next_seat())		
		end

		-- if #self.have_hu == 3 then
		-- 	self:gameover()
		-- 	return 
		-- else
		-- 	for k,v in pairs(self.have_hu) do
		-- 		print(k,v,"====")
		-- 	end
		-- 	print("#self.have_hu[seat]", #self.have_hu[seat])
		-- end

		-- self:deal(self:next_seat())
	end	
	
end

function M:throw(seat,p,session)
	if current_session == session and self.holds[seat]:has_p(p) then
		print(p)
		current_session = current_session + 1
		current_card = self.holds[seat]:throw(p)
		self.current_seat = seat

		wakeup(true)

		-- for i=1,4 do 
		-- 	print("inform seat and throw",seat,p)
		-- 	-- 通知其他玩家，当前玩家出牌：p
		-- 	self:notify_player(self.players[i],{cmd = "player_throw",value={seat=seat,p = p}})
		-- end
		self:notify_all_players({cmd = "player_throw",value={seat=seat,p = p}})

		local ok 

		local wait_player = {}
		for i=1,4 do 
			local need = self.holds[i]:need(p)
			if  i ~= seat and not self.have_hu[i] and need then
				-- for k,v in pairs(need) do
				-- 	print(k,v)
				-- end
				--通知，并等待其他用户可进行的操作
				if self.mj.count == 0 then
					-- 没牌了，不能杠
					for i=1,#need do
						if need[i] == "gong" then
							table.remove(need,i)
						end
					end
				end
				self:notify_player(self.players[i],{cmd="option",value={options = need,target_p =p},session=current_session})
				table.insert(wait_player,i)
				ok = true
			end
		end		
		
		if ok then
			wait(#wait_player,wait_time,self.all_pass,self,wait_player,current_session)
		else
			self:deal(self:next_seat())
		end
		-- 等待玩家操作
	end
end



function M:set_discard(seat,t,session)

	if session == current_session then
		if not self.holds[seat].discard then
			if self.holds[seat]:set_discard(t)  then
				local data = {cmd="set_discard",value={seat = seat,t = t}}
				self:notify_all_players(data)
				-- 
				
				for i=1,#self.holds do
					if not self.holds[i].discard then
						return
					end
				end
				-- current_session = current_session + 1
				-- self:notify_player(self.players[self.current_seat],{cmd="allow_throw"},session=current_session)
				-- current_session = current_session + 1
				print("all player have set discard")
				wakeup()
			end	
		end
	else
		print("session has expired")
	end
end

function M:get_statistic()
	local result = {}
	for i=1,#self.players do
		local sum = 0
		if self.result[i] then
			for j=1,#self.result[i] do
				sum = sum + self.result[i][j].score
			end
		end
		result[i] = {player_id = self.players[i].id,score = sum }
		-- result[self.players[i].player_id] = sum
		-- print(self.players[i].player_id,sum)		
	end


	-- for k,v in pairs(self.result) do
	-- 	local sum = 0
	-- 	for i=1,#self.result[k] do
	-- 		sum = sum + self.result[k][i].score
	-- 	end
	-- 	result[self.players[k].player_id] = sum
	-- 	print(self.players[k].player_id,sum)
	-- end
	
	return result
	-- body
end
function M:gameover( )
	
	if self.hu_count < 3 then
		print("查叫")
	end
	local statistic = self:get_statistic()


	skynet.call(self.room_mgr,"lua","gameover")
	for i=1,#self.players do
		if not self.have_hu[i] then
			self:notify_player(self.players[i],{cmd="gameover",value={result=self.result[i]}})
		else
			self:notify_player(self.players[i],{cmd="gameover",value={}})
		end
	end


	skynet.send("mysql","lua","save_result",statistic)

	skynet.exit()
	-- for k,v in pairs(self.have_hu) do
	-- 	print(k,v,"====")
	-- end	
	-- self:notify_all_players({cmd="gameover",value={}})

	-- skynet.exit()
	-- body
end

function M:pass(seat,session)
	print(self.id,seat,session)
	if session == current_session then
		self:notify_player(self.players[seat],{cmd="pass"})
		wakeup()

		if wait_count== 0 then
			if seat ~= self.current_seat then
				-- if wait_count == 0 then
				print("active")
				self:deal(self:next_seat())
				-- end			
			else
				-- 随机出牌
				-- wait(1,wait_time,self.random_throw,self,self.current_seat)
			end
		end

		
	else
		print("session has expired")
	end
end

function M:get_info(seat)
	local temp = {}
	for i=1,#self.holds do
		temp[i] = {}
		-- local show_holds = (seat == i)
		temp[i].holdsinfo = self.holds[i]:get_info(seat == i)
		temp[i].playerinfo = self.players[i]
		temp[i].seat = i
	end
	-- local ret = {players=self.players,holdsinfo = temp}
	return temp,self.mj.count
	-- body
end



function M.random_discard(game)
	for j = 1,4 do
		if  not game.holds[j].discard then
			-- print("player" ,j,"random_discard")
			local result,discard = game.holds[j]:set_discard(t)
			local data = {cmd="set_discard",value={seat = j,t = discard}}
			game:notify_all_players(data)			
		end
	end

	-- current_session = current_session + 1	
end

function M.random_throw(game,seat)
	-- current_session = current_session + 1	
	local p = game.holds[seat]:random_one()
	game.throw(game,seat,p,current_session)
end


function M.all_pass(game,seats,session )
	print("all_pass")
	for i=1,#seats do
		game:pass(seats[i],session)
	end
	-- game:deal(game:next_seat())

	-- return true
end

return M