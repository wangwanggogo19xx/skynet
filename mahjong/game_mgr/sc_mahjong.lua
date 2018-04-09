local M = {}
-- 1-9:万
-- 11-19：条
-- 21-29：筒
function M:new()
	local mahjong = {}
	local count = 0

	for i=0,2 do
		for j=1,9 do
			for k = 1,4 do
				table.insert(mahjong,i*10+j)
				count = count + 1
			end
		end
	end	
	local o = {
		mahjong = mahjong,
		count = count,
		init_holds_count = 13
	}
	setmetatable(o,self)	
	self.__index = self

	math.randomseed(os.time()) 
	return o
end

function M:next()
	local pos = math.random(1,#self.mahjong)
	self.count = self.count - 1
	return table.remove(self.mahjong,pos)
end



function M.hu(holds)
	-- body
end

return M