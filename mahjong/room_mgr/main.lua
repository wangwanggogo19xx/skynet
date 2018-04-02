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


function CMD.join_room(player,room_id,seat)
	local id = tonumber(room_id)
	
	if id then
		print(rooms[id]:is_full())
		if not rooms[id]:is_full() then
			succeed ,info = rooms[id]:join(player,seat)
			print(succeed ,info)
			return true
		end
		return false
	else
		for i =1,#rooms do
			if not rooms[i]:is_full() then

				rooms[i]:join(player,seat)
				skynet.error("进入房间")
				return true
			end
		end
		return false	
	end

	return false		
end

skynet.start(function()
	
	skynet.dispatch("lua",function (_, session, cmd, ...)
		-- body
		local f = CMD[cmd]

		f(...)

	end)
	skynet.register("room_mgr")
	skynet.error("room_mgr start")
end)





