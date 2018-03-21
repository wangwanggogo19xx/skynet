local M = {}
-- 1-9:万
-- 11-19：条
-- 21-29：筒
function M:new(o)

	o = o or {}
	setmetatable(o,self)	
	self.__index = self

	self.mahjong = {}
	self.count = 0
	self.init_holds_count = 13
	for i=0,2 do
		for j=1,9 do
			for k = 1,4 do
				table.insert(self.mahjong,i*10+j)
				self.count = self.count + 1
			end
		end
	end
	math.randomseed(os.time()) 
	return o
end

function M:next()
	local m = self.mahjong[math.random(1,#self.mahjong)]
	self.count = self.count - 1
	-- print(m)
	table.remove(self.mahjong,m)
	return m
end



function M.hu(holds)
	-- body
end

-- package.path = package.path ..';../?.lua';
-- local holds = require("holds")
-- local h1 = holds:new(nil)
-- local mm = M:new(nil)

-- for i=1,13 do
-- 	-- print()
-- 	h1:add(mm:next())
-- end
-- for k,v in pairs(h1.need) do
-- 	print(k,v)
-- end

-- for k,v in pairs(h1.holds) do
-- 	-- print(k)
-- 	for i = 1,9 do
-- 		for j = 1 , v[i]  do
-- 			io.write(i + (k-1)*10,",")
-- 			-- print(v[i] + (k-1)*10)
-- 		end
-- 	end
-- 	print()
-- end

return M