local skynet = require "skynet"
require "skynet.manager"
local account_mgr = require "account_mgr"

local CMD = {}

function CMD.login( username,password )
    return account_mgr:login(username,password)
end
-- function CMD.have_logined(username)
--     return account_mgr:exist(username)
-- end
function CMD.get_userinfo(accountname)
    return account_mgr:get_userinfo(accountname)
    -- body
end
function CMD.is_online(accountname)

    return account_mgr:is_online(accountname)
end
function CMD.logout( accountname )
    -- body
    return account_mgr:remove(accountname)
end

skynet.start(function()
    account_mgr:init()

    skynet.dispatch("lua", function(_, session, cmd, ...)
    	local f = CMD[cmd]
        if not f then
            print("no cmd",cmd)
            return
        end
        skynet.ret(skynet.pack(f(...)))
        -- if session > 0 then
        --     skynet.ret(skynet.pack(f(...)))
        -- else
        --     f(...)
        -- end
    end)
    -- account_mgr:login("2015110433","123456")
    skynet.register("account_mgr")
end)
