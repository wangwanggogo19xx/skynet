local skynet = require "skynet"

local CMD = {}


function CMD.login(data)
	-- skynet.error(string.format("you are logining with %s and %s", data.username, data.password))
	return "ok"
	-- body
end

function CMD.register(data)
	-- skynet.error(string.format("you are registering with %s and %s", data.username, data.password))
	return "ok"
end

skynet.start(function()
	skynet.dispatch("lua",function(session,souce,cmd,...)
		print("userservice")
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)
	
	
	-- body
end)