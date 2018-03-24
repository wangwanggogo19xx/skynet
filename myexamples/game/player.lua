package.path = package.path ..';../?.lua';


local M = {}

function M:new()
	local o = {
		name = os.time(),
		game = nil,
		prepared = false,
		holds = nil,
		pos = 0,
		succeed = false,
		-- self.discard = nil,
		-- self.lose
	}	
	-- local o = o or {}
	setmetatable(o,self)	
	math.randomseed(os.time())
	self.__index = self
	return o
end

function M:lose(p )
	local p = p
	if p then
		p = self.holds:lose(p)
	else
		p = self.holds:random_lose()
	end
	print("房间广播：xx出牌:",p)

	return 
end

function M:get()
	local  p = self.game:next()
	print("通知客户端："..self.name.."摸到牌:",p)
	self.holds:add(p)
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


function M:set_discard(type)
	self.holds.discard = type

	self.has_discarded = (self.holds.discard ~= nil)
end

function M:pong(p )
	self.holds:pong(p)
end

function M:gong(p,player )
	self.holds:gong(p,player)
end


function M:__tostring()
	return self.name
end


return M