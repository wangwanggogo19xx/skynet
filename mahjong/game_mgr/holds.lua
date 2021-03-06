local hu = require "sc_hulib"

local function table_sum(table)
	local sum = 0
	for i=1,#table do
		sum  = sum + table[i]
	end
	return sum
end

-- 玩家对应的牌
local M = {}
function M:new()
	local o = {
		holds={
			{0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0}
		},--手牌
		lose_heap = {},-- 弃牌堆
		init_holds_count = 13,
		holds_count = 0,--初始手牌数量
		need_p = {}, --能够要其他玩家出的牌
		back_gong = { }, --暗杠
		wan_gong = { },
		discard = nil,
		pongs = {},
		gongs = {},
		ting = {},

	}
	setmetatable(o,self)
	self.__index = self	
	return o
end

function M:count_p(p)
	return self.holds[p // 10+1][p%10]
	-- body
end

function M:add(p)
	local temp = self.holds[ p // 10+1]
	temp[p % 10] = temp[p % 10] + 1
	self.holds_count = self.holds_count + 1 
	if self:count_p(p) == 4 then
		table.insert(self.back_gong,p)
	end

end
-- function M:countP(p)
-- 	return 
-- 	-- body
-- end
function M:has_p(p)
	return  self.holds[p // 10+1][p%10] > 0
	-- return true --测试
	-- body
end


function M:have_gong()
	local temp = {}
	for i=1,#self.pongs do
		if self:count_p(self.pongs[i]) == 1 then
			table.insert(temp,self.pongs[i])
		end
	end
	return temp
end
-- function M:check_need(p)
-- 	local countP = self.holds[p // 10+1][p%10]

-- 	if countP == 4 then
-- 		print(p)
-- 		table.insert(self.back_gang,p)
-- 	elseif countP == 3 then
-- 		self.need_p[p]="gong"
-- 	elseif countP == 2 then
-- 		self.need_p[p]="pong"
-- 	elseif countP == 1 then
-- 		self.need_p[p] = nil 

-- 		-- self.wan_gong[p] = nil	
-- 		for k,v in pairs(self.pongs) do
-- 			print(k,v)
-- 		end
-- 		for i=1,#self.pongs do
-- 			print(self.pongs[i])
-- 			if self.pongs[i] == p then
-- 				-- self.wan_gong[p] = p
-- 				table.insert(self.wan_gong,p)
-- 				break;
-- 			end
-- 		end	
-- 	elseif countP == 0 then	

-- 	end
-- end
function M:is_qingyise()
	local temp = {}
	for i=1,#self.holds do
		temp[i]= table_sum(self.holds[i])
	end

	for i=1,#self.pongs do
		temp[self.pongs[i] // 10 + 1] = temp[self.pongs[i] //10 + 1] + 1
	end
	for i=1,#self.gongs do
		temp[self.gongs[i] //10 + 1] = temp[self.gongs[i] //10 + 1] + 1
	end	

	local color_count = 0
	for i=1,#temp do
		if temp[i] > 0 then
			color_count = color_count  + 1
		end
	end

	if	color_count == 1 then
		return true
	end
	return false
end

function M:get_hu_info( )
	local times = 1
	-- for k,v in pairs(self.hu_info) do
	-- 	print(k,v)
	-- end	
	-- print("self.hu_info.pongponghu",self.hu_info.pongponghu)
	-- print("self.hu_info.pinghu",self.hu_info.pinghu)

	local gong_count = #self:have_gong()
	for k,v in pairs(self.gongs) do
		gong_count = gong_count + 1
	end
	times = times * 2^gong_count
	self.hu_info.gong_count = gong_count


	if self.hu_info.qidui then
		times = times * 8
	end


	if self.hu_info.pongponghu then
		times = times * 4
	end

	if self:is_qingyise() then
		self.hu_info.qingyise = true
		times = times * 4
	end	
	self.hu_info.times = times

	return self.hu_info
end

-- 手牌是否胡牌
function M:hu( )
	

	local huable
	huable,self.hu_info = hu.huable(self.holds)
	
	return huable
end

function M:remove( p )
	self.holds_count = self.holds_count - 1 

	local temp = self.holds[ p // 10+1]
	temp[p % 10] = temp[p % 10] - 1	
	for i=1,#self.back_gong do
		if self.back_gong[i] == p then
			table.remove(self.back_gong,i)
			break
		end
	end
	return p
end

function M:throw(p)
	self:remove(p)
	table.insert(self.lose_heap,p)
	-- 出牌后,如果已经缺了,检测是否听牌（下叫）
	if table_sum(self.holds[self.discard+1]) == 0 then
		self.ting = hu.get_ting(self.holds)
	end

	return p
end

function M:need(p)
	if p // 10 == self.discard then
		return nil
	end

	local temp = {}

	if self:count_p(p) == 3 then
		table.insert(temp,"gong")
	elseif self:count_p(p) == 2 then
		table.insert(temp,"pong")
	end

	if  self.ting[p] then
		print("hu")
		self.hu_info = self.ting[p]

		table.insert(temp,"hu")
	end

	if #temp > 0 then
		return temp
	else
		return nil
	end
	
end

function M:random_one()
	-- 如果还未缺，先把要缺的牌打出
	if table_sum(self.holds[self.discard+1]) > 0 then
		for i = 1,#self.holds[self.discard+1] do
			if self.holds[self.discard+1][i] ~= 0 then
				return  ( self.discard) * 10 +i
				
			end
		end
	end
	-- 弃掉左边第一张
	for i=1,#self.holds do
		if  i ~= (self.discard + 1) then
			for j=1,#self.holds[i] do
				if self.holds[i][j] > 0 then
					-- print((i-1)*10 + j)
					return (i-1)*10 + j
				end
			end
		end
	end
end


function M:pong(p) --碰
	if self:count_p(p) == 3 or self:count_p(p) == 2 then
		self:remove(p)
		self:remove(p)
		table.insert(self.pongs,p)
		return true
	end
	return false
end

function M:zhi_gong(p ,playerseat) --杠
	if self:count_p(p) == 4 then
		self:remove(p)
		self:remove(p)
		self:remove(p)	
		self:remove(p)	
		self.gongs[p] = playerseat
		return true,"player_back_gong"
	end

	if self:count_p(p) == 1 then
		self:remove(p)
		self.gongs[p] = playerseat
		return true,"player_wan_gong"
	end


	if  self:count_p(p) == 3 then
		self:remove(p)
		self:remove(p)
		self:remove(p)
		self.gongs[p] = playerseat
		return true,"player_zhi_gong"
	end
	return false
end

function M:__tostring( )
	local tmp = {}
	local ret = ""
	for i=1,#self.holds do
		for j=1,#self.holds[i] do
			-- print(self.holds[i][j])
			for k= 1, self.holds[i][j]  do
				-- table.insert(temp,(i-1)*10 + j)
				ret = ret..((i-1)*10 + j).." "
			end
		end
	end
	return ret
	-- return os.time()
end

function M:set_discard(t)
	if t and t>=0 and t<=2 then
		self.discard = t
	else
		-- 随机为排数最少的一种花色
		local tep1 = table_sum(self.holds[1])
		local tep2 = table_sum(self.holds[2])
		local tep3 = table_sum(self.holds[3])
		if tep1 <= tep2 then
			if tep1 <= tep3 then
				self.discard = 0
			else
				self.discard = 2
			end
		else
			if tep2 <= tep3 then
				self.discard = 1
			else
				self.discard = 2
			end		
		end
	end
	print("定缺种类为：",self.discard)
	return true,self.discard

end

function M:get_holds()
	local holds = {}
	for i=1,#self.holds do
		for j=1,#self.holds[i] do
			for k= 1, self.holds[i][j]  do
				table.insert(holds,(i-1)*10 + j)
				-- ret = ret..((i-1)*10 + j).." "
			end
		end
	end
	return holds
end

function M:get_info(show_holds)
	local ret = {}
	ret.holds_count = self.holds_count

	if show_holds then
		ret.holds = self:get_holds()
	end

	ret.discard = self.discard
	ret.pongs = self.pongs
	ret.gongs = self.gongs
	ret.lose_heap = self.lose_heap
	return ret
end
return M