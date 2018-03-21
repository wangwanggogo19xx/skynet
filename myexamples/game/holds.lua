-- 玩家对应的牌
local M = {}
function M:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self	
	--手牌
	self.holds = {}
	self.holds[1]={0,0,0,0,0,0,0,0,0}
	self.holds[2]={0,0,0,0,0,0,0,0,0}
	self.holds[3]={0,0,0,0,0,0,0,0,0}
	self.lose = {} -- 弃牌堆
	self.init_holds_count = 13 --初始手牌数量
	self.need = {} --能够要其他玩家出的牌
	self.back_gang = { } --暗杠	

	return o
end
-- function M:init()
-- 	-- self.type = {"wan","tiao","tong"}
-- 	--手牌
-- 	self.holds = {}
-- 	self.holds[1]={0,0,0,0,0,0,0,0,0}
-- 	self.holds[2]={0,0,0,0,0,0,0,0,0}
-- 	self.holds[3]={0,0,0,0,0,0,0,0,0}
-- 	--
-- 	self.lose = {} -- 弃牌堆

-- 	self.need = {} --能够要其他玩家出的牌
-- 	self.back_gang = { } --暗杠
-- 	-- body
-- end

function M:add(p)
	local temp = self.holds[ p // 10+1]
	temp[p % 10] = temp[p % 10] + 1
	self:check_need(p)
	
end

function M:check_need(p)
	local countP = self.holds[p // 10+1][p%10]
	if countP == 4 then
		table.insert(self.back_gang,p)
	elseif countP == 3 then
		self.need[p]="gang"
	elseif countP == 2 then
		self.need[p]="peng"
	elseif countP == 1 then
		if self.need[p] ~= nil then
			table.remove(self.need,p)
		end
	end

end

function M:lose(p)
	local temp = self.holds[ p // 10+1]
	temp[p % 10] = temp[p % 10] - 1	
	self.check_need(p)
	table.insert(self.lose,p)
end

function M:random_lose()
	for i=1,#self.holds do
		for j=1,#self.holds[i] do
			if self.holds[i][j] > 0 then
				self:lose((i-1)*10 + j)
				return
			end
		end
	end
end
return M