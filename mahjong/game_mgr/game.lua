local skynet = require "skynet"
local maghjong = require "sc_mahjong"
local h = require "holds"
local M = {}

function M:new(player_mgrs)
	local o = {
		mj = maghjong:new(),
		player_mgrs = player_mgrs,
		holds = {h:new(),h:new(),h:new(),h:new()},
		id = 0

	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o
	-- body
end

function M:init_holds()
	for i= 1,4 do
		if self.player_mgrs[i] then
			for j=1,self.holds[i].init_holds_count do
				self.holds[i]:add(self.mj:next())
			end
			skynet.send(self.player_mgrs[i],"lua","init_holds",self.holds[i]:__tostring())
		end
	end
	-- body
end


function M:set_discard()
	-- skynet.call(self.player_mgrs[i])	
end
function M:start()

end

return M