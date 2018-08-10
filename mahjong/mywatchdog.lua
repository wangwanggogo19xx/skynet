local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
local json = require "json"


local handler = {}
local agent = {}
local account = {}
local wss = {}
local M = {}

local function close_agent(fd)
    print(fd)
	local a = agent[fd]
	agent[fd] = nil
    print(a == nil)
	if a then
        print("disconnect..........")
        print(skynet.self())
		skynet.send(a, "lua", "disconnect")
	end
end

function handler.on_open(ws)
    print(string.format("%d::open",ws.id))
    -- agent[ws.id] = skynet.newservice("agent")
    -- wss[ws.id] = ws
    -- skynet.call(agent[ws.id],"lua","start",{fd = ws.id,watchdog = skynet.self()})
     -- skynet.call(agent[ws.id],"lua","start",{fd = ws,watchdog = skynet.self()})
end

function handler.on_message(ws, message)
    print(message)

    local data = json:decode(message)
    print(data.cmd,"data.cmd")
    
    if data.cmd == "login" then
        -- 该用户没有登录
        print(account[data.value])
        print(not account[data.value])
        print(accountname,account[accountname])
        if not account[data.value] then
            local online = skynet.call("account_mgr","lua","is_online",data.value)
            print(online)
            if online then
                print("online")
                agent[ws.id] = skynet.newservice("agent")
                account[data.value] = {ws=ws,agent=agent[ws.id]}
                wss[ws.id] = ws
                skynet.send(agent[ws.id],"lua","start",{fd = ws.id,watchdog = skynet.self(),accountname =data.value})
            end
        else
            -- 挤下线
            
            --关闭上一个该用户的socket连接
            M.notify(account[data.value].ws.id,{cmd="be_occupied",value={}})
            agent[account[data.value].ws.id] = nil
            print(account[data.value].ws.id)
            account[data.value].ws:close()   



            agent[ws.id] = account[data.value].agent
            skynet.send(agent[ws.id],"lua","set_ws",ws.id)
            account[data.value] = {ws=ws,agent=agent[ws.id]} 
            wss[ws.id] = ws

            print(agent[ws.id],"======")

            skynet.send(agent[ws.id],"lua","reconnect")
            -- skynet.call()
            -- --关闭上一个该用户的socket连接
            -- M.notify(account[data.value].ws.id,{cmd="beiji",value={}})
            -- agent[account[data.value].ws.id] = nil
            -- print(account[data.value].ws.id)
            -- account[data.value].ws:close(nil,"close .......")
            -- socket.close()
            print(data.value.."has connected")
        end

    else
        skynet.send(agent[ws.id],"lua","dispatch",data)
    end
    -- skynet.send(agent[ws.id],"lua","dispatch",data)

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
function M.logout(accountname )
    account[accountname] = nil
    -- body
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
        
        local f = M[command]
        if f then
            f(...)
        end
        -- skynet.ret(skynet.pack(f(...)))
    end)    
end)
