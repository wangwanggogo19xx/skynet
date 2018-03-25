local skynet = require "skynet"
local room =  require "room"

local rooms = {}

local M = {}

function M:start()
	for i = 1,100 do
		table.insert(rooms,room:new(i))
	end
end

function M:join_room(room_id,player,seat)
	rooms[room_id]:add(player,seat)
end

-- function M:add( player )
-- end

-- skynet.start(function()
-- 	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
-- end)

M:start()

return M