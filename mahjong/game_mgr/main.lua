local skynet = require "skynet"
local g = require "game"


local game 
local CMD = {}


function CMD.start( ...)
	local player_mgrs = ...
	game = g:new(player_mgrs)
	game:init_holds()
	-- body
end
skynet.start(function()
	skynet.dispatch("lua",function (_, session, cmd, ...)
		print(...,"=====")
		local f = CMD[cmd]
		-- f(...)
		skynet.ret(skynet.pack(f(...)))
	end)

	-- game:start()

end)