package.path = package.path ..';../?.lua';

local game = require "game"
local player = require "player"


g = game:new(nil)
g.id  = 1000

local p1 = player:new(nil)
p1.name = "p1"
local p2 = player:new(nil)
p2.name = "p2"
local p3 = player:new(nil)
p3.name = "p3"
local p4 = player:new(nil)
p4.name = "p4"

p1:join(g)
p2:join(g)
p3:join(g)
p4:join(g)

-- print(p1.prepared)
p1:ready()
p2:ready()
p3:ready()
p4:ready()
-- print(p3.ready)

