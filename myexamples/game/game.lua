package.path = package.path ..';../?.lua';

local M = {}
local maghjong = require "sc_mahjong"
function M:new(o)
	o = o or {}
	setmetatable(o,self)		
	self.__index = self	

	self.id = 0
	self.players = {}
	self.players[1] = false
	self.players[2] = false
	self.players[3] = false
	self.players[4] = false
	math.randomseed(os.time()) 
	return o
	-- body
end

function M:start()
	self.mj = maghjong:new(nil)
	-- 初始化手牌
	for i = 1,#self.players do
		self.players[i]:init_holds()
	end
	local pos = math.random(1,#self.players)
	while( self.mj.count > 0)
	do
		print(pos)
		self.players[pos]:get()
		-- self.
		pos  = pos + 1 
		if pos > #self.players then
			pos = 1
		end
	end
	
end

function M:prepared()
	for i=1,#self.players do
		if not self.players[i].prepared then
			print(self.players[i],"not prepared")
			return
		end
	end
	print("have prepared")
	self:start()
	-- body
end
function M:__tostring( )
	return self.id..""
	-- body
end
function M:next( )
	return self.mj:next()
	-- body
end
function M:join(player)
	for i =1,#self.players do
		if not self.players[i]  then
			self.players[i]  = player
			break
		end
	end
end
return M

