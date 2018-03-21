package.path = package.path ..';../?.lua';

local holds = require "holds"

local M = {}

function M:new(o)
	o = o or {}
	setmetatable(o,self)	
	self.__index = self
	self.name = os.time()
	self.game = nil
	self.prepared = false
	self.holds = holds:new(nil)
	return o
end

function M:lose(p )
	self.holds:lose(p)
	print("房间广播：xx出牌:",p)
	
end

function M:get()
	local  p = self.game:next()
	self.holds:add(p)
	print("通知客户端："..self.name.."摸到牌:",p)
	-- self.infor(self,"get",p)
end
function M:join(game)
	self.game = game
	game:join(self)
	-- body
end
function M:ready()
	print(self.name.."  ready")

	self.prepared = true
	self.game:prepared()
end
function M:init_holds()

	for i=1,self.holds.init_holds_count do
		self.holds:add(self.game:next())
	end
	print("通知客户端："..self.name.."初始化手牌成功")
	-- body
end
function M:__tostring()
	return self.name
end


return M