local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
local json = require "json"


local handler = {}
local agent = {}

local function close_agent(fd)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		skynet.send(a, "lua", "disconnect")
	end
end

function handler.on_open(ws)
    print(string.format("%d::open",ws.id))
    agent[ws.id] = skynet.newservice("agent")
    -- skynet.call(agent[ws.id],"lua","start",{ws=ws,watchdog=skynet.self()})
end

function handler.on_message(ws, message)
    -- print(string.format("%d receive:%s", ws.id, message))
    -- ws:send_text(message .. "from server")
    -- print("decode.......")
    -- x='{"id":"UserInfo_BILL","actions":[],"attributes":{}}'
    -- y=json:decode(message)
    -- print(y.username)
    -- -- 
    -- -- print(data)
    -- -- print(data.username)
    -- ws:close()
    local data = json:decode(message)
    local ret = skynet.call(agent[ws.id],"lua","dispatch",data)
    print(ret.succeed)
    if ret then
        local str = json:encode(ret)
        print(str)
        ws:send_text(str)
    end
    -- skynet.call(agent[ws.id],"lua",data)
end

function handler.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
    close_agent(ws.fd)
    -- ws:close()
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    if code then
        
        if header.upgrade == "websocket" then
            local ws = websocket.new(id, header, handler)
            ws:start()
        end
    end


end

skynet.start(function()
    local address = "0.0.0.0:8008"
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       pcall(handle_socket, id)
    end)
end)
