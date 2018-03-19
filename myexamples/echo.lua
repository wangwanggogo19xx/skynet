-- local skynet = require "skynet"
-- require "skynet.manager"


-- local command = {}

-- function command.HELLO(what)
--     return "i am echo server, get this:" .. what
-- end
-- function command.HELLO1(what)
--     return "you tell me "..what..",but i don't care!!!"
--     -- body
-- end
-- function dispatcher() 
--     skynet.dispatch("lua", function(session, address, cmd, ...)
--         cmd = cmd:upper()
--         if cmd == "HELLO" then
--             local f = command[cmd]
--             assert(f)
--             skynet.ret(skynet.pack(f(...)))
--         else
--             skynet.ret(skynet.pack(command.HELLO1(...)))
--         end
--     end)
--     skynet.register("echo")
-- end

-- skynet.start(dispatcher)

t = {}
s = "username=wangwang&password=123a"
print(string.gmatch(s, "(%w+)=(%w+)"))
for k,v in string.gmatch(s, "(%w+)=(%w+)") do
    t[k]=v
    -- print(k)
    print(k,v)
    -- print(string.gsub(k,"/",""))
end
-- for k, v in pairs(t) do
--     print(k, v)
-- end
print("ok")