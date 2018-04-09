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

function CMD.pong(seat,p,session)
	game:pong(seat,p)
end

function CMD.gong(seat,p,session)
	game:gong(seat,p)
end

function CMD.win(seat,p,session)
	game:win(p)
end
function CMD.throw(seat,p,session)
	print("throw session",session)
	game:throw(seat,p,session)
end
function CMD.set_discard(seat,t,session)
	game:set_discard(seat,t,session)
end




skynet.start(function()
	skynet.dispatch("lua",function (_, session, cmd, ...)
		print(cmd)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)

	-- game:start()

end)