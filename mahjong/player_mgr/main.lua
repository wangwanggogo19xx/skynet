local skynet = require "skynet"
-- local player_mgr = require "player"

-- local fd = ...

-- local player = player_mgr:new(fd)

skynet.start(function()

    skynet.dispatch("lua", function(_, session, cmd, ...)
    	-- local f = player[cmd]
     --  f(player,...)
    end)

    skynet.error("create new player")
end)
