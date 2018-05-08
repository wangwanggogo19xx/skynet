local skynet = require "skynet"
local g = require "game"


local game 
local CMD = {}

-- local room_mgr = ...

function CMD.start( ...)
	local players,room_mgr = ...
	for k,v in pairs(players) do
		for a,b in pairs(v) do
			print(a,b)
		end
	end
	print(skynet.self())
	game = g:new(players,skynet.self(),room_mgr)
	game:start()
	-- body
end
function CMD.player_leave(seat)
	game:player_leave(seat)
end
function CMD.pass(seat,session)
	game:pass(seat,session)
end

function CMD.pong(seat,p,session)
	game:pong(seat,p,session)
end

function CMD.zhi_gong(seat,p,session)
	game:zhi_gong(seat,p,session)
end

function CMD.hu(seat,p,session)
	game:hu(seat,p,session)
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