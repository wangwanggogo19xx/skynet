local skynet = require "skynet"
local stm = require "skynet.stm"

local mode = ...
local M = {	}
function M:new( )
	local o ={
		name="123"
	}
	setmetatable(o,self)		
	self.__index = self	
	return o
	-- body
end
function M:hello()
	print("hello")
	-- body
end

if mode == "slave" then

skynet.start(function()
	skynet.dispatch("lua", function (_,_, obj)
		local obj = stm.newcopy(obj)
		print("read:", obj(skynet.unpack))
		-- print(obj(skynet.unpack))
		skynet.ret()
		skynet.error("sleep and read")
		for i=1,10 do
			skynet.sleep(10)
			-- print("read:", obj(skynet.unpack))
			local a,b = obj(skynet.unpack)
			if  b then 
				for k,v in pairs(b) do
					print(k,v)
				end				
				b:hello()
			end
			print(b)
			-- for k,v in pairs(b) do
			-- 	print(k,v)
			-- end
		end
		skynet.exit()
	end)
end)

else

skynet.start(function()
	local slave = skynet.newservice(SERVICE_NAME, "slave")
	local o = M:new()
	print(o.name)
	print(o:hello())
	local obj = stm.new(skynet.pack(o))
	local copy = stm.copy(obj)
	skynet.call(slave, "lua", copy)
	for i=1,5 do
		skynet.sleep(20)
		print("write", i)
		o.name = i
		o.aa = i * i 
		obj(skynet.pack(o))
	end	
	-- local obj = stm.new(skynet.pack(1,2,3,4,5))
	-- local copy = stm.copy(obj)
	-- skynet.call(slave, "lua", copy)
	-- for i=1,5 do
	-- 	skynet.sleep(20)
	-- 	print("write", i)
	-- 	obj(skynet.pack("hello world", i))
	-- end



 	skynet.exit()
end)
end
