local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
local json = require "json"


local handler = {}
local agent = {}
local wss = {}
local M = {}

local function close_agent(fd)
    print(fd)
	local a = agent[fd]
	agent[fd] = nil
    print(a == nil)
	if a then
        print("disconnect..........")
		skynet.send(a, "lua", "disconnect")
	end
end

function handler.on_open(ws)
    print(string.format("%d::open",ws.id))
    agent[ws.id] = skynet.newservice("agent")
    wss[ws.id] = ws
    skynet.call(agent[ws.id],"lua","start",{fd = ws.id,watchdog = skynet.self()})
end

function handler.on_message(ws, message)
    print(message)
    local data = json:decode(message)
    -- print(data.cmd,"data.cmd")
    skynet.send(agent[ws.id],"lua","dispatch",data)

end

function handler.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
    close_agent(ws.id)
    -- ws:close()
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    print(header)
    if code then
        if header.upgrade == "websocket" then
            local ws = websocket.new(id, header, handler)
            ws:start()
        end
    end


end

function M.notify(id,data)
    local str = json:encode(data)
    websocket.send_text(wss[id],str)
end

skynet.start(function()
    local address = "0.0.0.0:8008"
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       pcall(handle_socket, id)
    end)
    
    skynet.dispatch("lua", function(_,_, command, ...)
        
        if command == "notify" then
            local f = M[command]
            f(...)
        end
        -- skynet.ret(skynet.pack(f(...)))
    end)    
end)
