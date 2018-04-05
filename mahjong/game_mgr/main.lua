local skynet = require "skynet"
local g = require "game"


local game 
local CMD = {}


function CMD.start( ...)
	local player_mgrs = ...
	game = g:new(player_mgrs)
	game:start()
	-- body
end
-- function CMD:lose( ... )
-- 	game:lose(...)
-- 	-- body
-- end

function CMD.pass()

end

function CMD.pong(seat,p)
	game:pong(seat,p)
end

function CMD.gong(seat,p)
	game:gong(seat,p)
end

function CMD.win(seat,p)
	game:win(p)
end
function CMD.throw(seat,p)
	game:throw(seat,p)
end
function CMD.set_discard(seat,t)
	game:set_discard(seat,t)
end




skynet.start(function()
	skynet.dispatch("lua",function (_, session, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)

	-- game:start()

end)