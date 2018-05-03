local skynet = require "skynet"
require "skynet.manager"

local rooms = {}

local CMD = {}

function CMD.random_room()
	for i=1,#rooms do
		if rooms[i].available then
			-- print("random_room======",i)
			return rooms[i].room_mgr
		end
	end
	return false
end

function CMD.set_available(room_no)
	room_no = tonumber(room_no)
	rooms[room_no].available = true
end
function CMD.set_unavailable(room_no)
	room_no = tonumber(room_no)
	rooms[room_no].available = false
end

skynet.start(function()

	-- 生成5个房间
	for i=1,5 do
		-- rooms[i]=skynet.newservice("room_mgr")
		rooms[i] = {room_mgr=skynet.newservice("room_mgr",i),available=true}
	end
	

	skynet.dispatch("lua",function (_, session, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)			
	skynet.register("area_mgr")
	-- skynet.error("create room")
end)