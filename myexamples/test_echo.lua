local skynet = require "skynet"

skynet.start(function() 
    local echo = skynet.newservice("echo")
    print(skynet.call(echo, "lua", "HELLO", "world"))
    print(skynet.call(echo, "lua", "HELLO222", "nothing"))
end);