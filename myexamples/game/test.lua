package.path = package.path ..';../?.lua';

local game = require "game"
local player = require "player"
local holds = require "holds"

local g = game:new(nil)
g.id  = 1000

-- local pp = player:new(nil)
-- local ppp = player:new(nil)
-- pp.aaaa = "123"
-- print(pp.aaaa)
-- print(ppp)
-- print(pp == ppp)

local p1 = player:new()
local h1 = holds:new()
p1.name = "p1"
p1.holds = h1

local p2 = player:new()
local h2 = holds:new()
p2.name = "p2"
p2.holds = h2

-- print(p1.holds)
-- print(p2.holds)
-- print(p1.holds==p2.holds)
-- print(h1 == h2 )

local p3 = player:new()
local h3 = holds:new()
p3.name = "p3"
p3.holds = h3

local p4 = player:new()
local h4 = holds:new()
p4.name = "p4"
p4.holds = h4


print(p1.holds==p2.holds)
print(h1 == h2 )

print(p1.name.."==="..p2.name.."==="..p3.name.."==="..p4.name)
p1:join(g)
p2:join(g)
p3:join(g)
p4:join(g)

p1:set_discard(1) 
p2:set_discard(2)
p3:set_discard(1)
p4:set_discard(3)

p1:ready()
p2:ready()
p3:ready()
p4:ready()





print("============")

print(p1.holds)
print(p2.holds )
print(p3.holds )
print(p4.holds )