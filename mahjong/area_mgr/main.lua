local skynet = require "skynet"

local rooms = {}

local CMD = {}

function CMD.random_room()
	return rooms[1]
end

skynet.start(function()
	rooms[1] = skynet.newservice("room_mgr")
	skynet.dispatch("lua",function (_, session, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)			
	skynet.error("create room")
end)