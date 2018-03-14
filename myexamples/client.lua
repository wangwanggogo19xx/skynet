package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;myexample/e1/?.lua"

if _VERSION ~= "Lua 5.3" then
    error "Use lua 5.3"
end

local socket = require "clientsocket"

local fd = assert(socket.connect("127.0.0.1", 8888))

socket.send(fd, "Hello world")
while true do
    -- 接收服务器返回消息
    local str   = socket.recv(fd)
    if str~=nil and str~="" then
            print("server says: "..str)
            -- socket.close(fd)
            -- break;
    end

    -- 读取用户输入消息
    local readstr = socket.readstdin()
    if readstr then
        if readstr == "quit" then
            socket.close(fd)
            break;
        else
            -- 把用户输入消息发送给服务器
            socket.send(fd, readstr)
        end
    else
        socket.usleep(100)
    end
end