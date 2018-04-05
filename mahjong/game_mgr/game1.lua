package.path = package.path ..';../?.lua';

local M = {}
local maghjong = require "sc_mahjong"
function M:new()
	local o = {
		players = {false,false,false,false},
		id = 0

	}
	setmetatable(o,self)		
	self.__index = self	
	math.randomseed(os.time()) 
	return o
	-- body
end
function M:next_player(pos)
	local pos = pos or math.random(math.random(1,#self.players))
	if self.mj.count > 0 then
		self.players[pos]:get()
		self.players[pos]:lose(nil)

	end

	-- body
end
function M:gameover( )
	print("gameover....,counting.....")
	-- body
end
function M:start()
	self.mj = maghjong:new(nil)
	-- 初始化手牌
	for i = 1,#self.players do
		self.players[i]:init_holds()
		print(self.players[i].holds)
	end
	

	for i = 1,#self.players do
		if not self.players[i].has_discarded then
			print(self.players[i],"did not confirmed discard")
			return
		end
	end
	
	self:next_player(nil);

	self:gameover()
end

function M:prepared()
	for i=1,#self.players do
		if not self.players[i].prepared then
			print(self.players[i],"not prepared")
			return
		end
	end
	print(self.players[1].holds == self.players[2].holds)
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
			self.players[i].pos = i
			break
		end
	end
end

local m1 = M:new()

local m2 = M:new()
print(m1~=m2)
return M

