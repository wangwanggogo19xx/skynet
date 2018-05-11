local skynet =require "skynet"
require "skynet.manager"

local r = require "room"
local room 
local room_no = ...

-- local rooms = {}
local CMD = {}
-- function CMD.start()
-- 	for i= 1, 20 do
-- 		rooms[i] = room:new(i)
		
-- 	end		
-- 	print(rooms[11])
-- 	skynet.error("create room")

-- 	-- body
-- end

-- function CMD:( ... )
-- 	-- body
-- end
function CMD.add_player(userinfo,seat)
	return room:add_player(userinfo,seat)

end
function CMD.toggle_ready(seat)
	-- skynet.yield()
	return room:toggle_ready(seat)
end
function CMD.remove_player( seat )
	return room:remove_player(seat)
end
function CMD.ongaming()
	-- skynet.yield()
	return room:ongaming()
end
function CMD.send_msg(seat,msg)
	room:player_send_msg(seat,msg)
	-- body
end

function CMD.gameover()
	return room:gameover()
end
skynet.start(function()
	room = r:new(skynet.self(),room_no)

	skynet.dispatch("lua",function (_, session, cmd, ...)
		-- body
		local f = CMD[cmd]

		skynet.ret(skynet.pack(f(...)))
	end)
	-- skynet.register("room_mgr")
end)





