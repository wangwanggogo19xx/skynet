local M = {}
-- 1-9:万
-- 11-19：条
-- 21-29：筒
function M:init()
	self.mahjong = {}
	self.count = 1
	for i=0,2 do
		for j=1,9 do
			for k = 1,4 do
				table.insert(self.mahjong,i*10+j)
				self.count = self.count + 1
			end
		end
	end
	math.randomseed(os.time()) 

end

function M:next()
	local m = self.mahjong[math.random(1,#self.mahjong)]
	table.remove(self.mahjong,m)
	return m
end

-- function M:has_next()
-- 	return #self.mahjong > 0
-- end

function M.hu(holds)
	-- body
end
-- return M
package.path = package.path ..';../?.lua';
local holds = require("holds")
holds:init()
M:init()

for i=1,13 do
	-- print()
	holds:add(M:next())
end
for k,v in pairs(holds.need) do
	print(k,v)
end