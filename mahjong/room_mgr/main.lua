local skynet =require "skynet"
require "skynet.manager"

local room = require "room"

local rooms = {}
local CMD = {}
function CMD.start()
	for i= 1, 20 do
		rooms[i] = room:new(i)
		
	end		
	print(rooms[11])
	skynet.error("create room")

	-- body
end


function CMD.add_player(player,room_id,seat)
	local id = tonumber(room_id)
	return rooms[id]:add_player(player,seat)
end

skynet.start(function()
	
	skynet.dispatch("lua",function (_, session, cmd, ...)
		-- body
		local f = CMD[cmd]

		skynet.ret(skynet.pack(f(...)))

	end)
	skynet.register("room_mgr")
	skynet.error("room_mgr start")
end)





