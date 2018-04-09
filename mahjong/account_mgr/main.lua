local skynet = require "skynet"
require "skynet.manager"
local account_mgr = require "account_mgr"

local CMD = {}

function CMD.login( username,password )
    return account_mgr.login(username,password)
end


skynet.start(function()
    account_mgr:init()

    skynet.dispatch("lua", function(_, session, cmd, ...)
    	local f = CMD[cmd]
        if not f then
            return
        end
        skynet.ret(skynet.pack(f(...)))
        -- if session > 0 then
        --     skynet.ret(skynet.pack(f(...)))
        -- else
        --     f(...)
        -- end
    end)
    skynet.register("account_mgr")
end)
