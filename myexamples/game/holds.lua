-- 玩家对应的牌
local M = {}

function M:init()
	self.type = {"wan","tiao","tong"}
	--手牌
	self.holdes = {}
	self.holdes[self.type[1]]={0,0,0,0,0,0,0,0,0}
	self.holdes[self.type[2]]={0,0,0,0,0,0,0,0,0}
	self.holdes[self.type[3]]={0,0,0,0,0,0,0,0,0}
	--
	self.lose = {} -- 弃牌堆

	self.need = {} --能够要其他玩家出的牌
	self.back_gang = { } --暗杠
	-- body
end

function M:add(p)
	local temp = self.holdes[self.type[ p // 10+1]]
	temp[p % 10] = temp[p % 10] + 1
	self:check_need(p)
	
end

function M:check_need(p)
	local countP = self.holdes[self.type[ p // 10+1]][p%10]
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
	local temp = self.holdes[self.type[ p // 10+1]]
	temp[p % 10] = temp[p % 10] - 1	
	self.check_need(p)
	table.insert(self.lose,p)
end

return M