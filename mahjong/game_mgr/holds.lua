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
		init_holds_count = 13,--初始手牌数量
		need = {}, --能够要其他玩家出的牌
		back_gang = { }, --暗杠
		discard = nil,
		pongs = {},
		gongs = {}
	}
	setmetatable(o,self)
	self.__index = self	
	return o
end


function M:add(p)
	local temp = self.holds[ p // 10+1]
	temp[p % 10] = temp[p % 10] + 1
	self:check_need(p)
end
function M:has_p(p)
	-- return  self.holds[p // 10+1][p%10] == nil
	return true --测试
	-- body
end

function M:check_need(p)
	local countP = self.holds[p // 10+1][p%10]
	if countP == 4 then
		table.insert(self.back_gang,p)
	elseif countP == 3 then
		self.need[p]="gong"
	elseif countP == 2 then
		self.need[p]="pong"
	elseif countP == 1 then
		self.need[p] = nil 	
	end
end

function M:sub_one( p )
	local temp = self.holds[ p // 10+1]
	temp[p % 10] = temp[p % 10] - 1	
	self:check_need(p)	
	return p
end
function M:throw(p)
	self:sub_one(p)
	table.insert(self.lose_heap,p)
	return p
end


function M:random_one()
	-- 如果还未缺，先把要缺的牌打出
	if table_sum(self.holds[self.discard]) > 0 then
		for i = 1,#self.holds[self.discard] do
			if self.holds[self.discard][i] ~= 0 then
				return  ( self.discard -1) * 10 +i
				
			end
		end
	end
	for i=1,#self.holds do
		if  i ~= self.discard then
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
	if self.need[p] == "pong" or self.need[p] == "gong" then
		self:sub_one(p)
		self:sub_one(p)
		table.insert(self.pongs,p)
	end
end

function M:gong(p ,playerseat) --杠
	if  self.need[p] == "gong" then
		self:sub_one(p)
		self:sub_one(p)
		self:sub_one(p)
		self.gongs[p] = playerseat
	end
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
	if t and t>=1 and t<=3 then
		self.discard = t
	else
		-- 随机为排数最少的一种花色
		local tep1 = table_sum(self.holds[1])
		local tep2 = table_sum(self.holds[2])
		local tep3 = table_sum(self.holds[3])
		if tep1 <= tep2 then
			if tep1 <= tep3 then
				self.discard = 1
			else
				self.discard = 3
			end
		else
			if tep2 <= tep3 then
				self.discard = 2
			else
				self.discard = 3
			end		
		end
	end


	print("定缺种类为：",self.discard)
end

return M