
local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local p = require "player"
local json = require "json"
local websocket = require "websocket"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd
local service 
local player 
local session = 100
local ws

local function sendRequest(data)
	-- print("sendRequest")
	skynet.send(WATCHDOG,"lua","notify",client_fd,data)
	-- local str = json:encode(data)
 --    websocket.send_text(ws,str)
 --    print("============")
end

-- function REQUEST:get()
-- 	print("get", self.what)
-- 	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
-- 	return { result = r }
-- end

function REQUEST.login(accountname)
	local userinfo = skynet.call("account_mgr","lua","get_userinfo",accountname)
	
	if userinfo then
		userinfo.agent = skynet.self()

		player = p:new(userinfo)
		ret = {cmd="login",value={succeed=true,error=""}}
	else
		ret =  {cmd="login",{succeed=false,error="invalid username or password"}}
	end
	sendRequest(ret)
	return ret
end
function REQUEST.join_room(info)
	local ret = player:join_room(info.room_id,info.seat)
	sendRequest(ret)
end

function REQUEST.leave_room()
	
	sendRequest(player:leave_room())

end
function REQUEST.toggle_ready()
	skynet.sleep(20)
	player:toggle_ready()
end
function REQUEST.set_discard(data,session)
	-- print(session)
	player:set_discard(data.type ,session)
	-- print("set_discard")
	-- body
end

function REQUEST.throw(data,session)
	print("REQUEST.throw")
	player:throw(data.p,session)
end
function REQUEST.pong(data,session)
	player:pong(data.p,session)
end
function REQUEST.zhi_gong(data,session)
	player:zhi_gong(data.p,session)
end
function REQUEST.pass(data,session)
	-- body
	print(session)
	player:pass(session)
end
function REQUEST.hu(data,session)
	player:hu(data.p,session)
	-- body
end
function REQUEST.send_msg(msg)
	for k,v in pairs(msg) do
		print(k,v)
	end
	player:send_msg(msg)
	-- body
end
function REQUEST:set()
	-- print("get", self.what,self.value)
	-- skynet.call(service,"lua",self.what,self.value)
	-- local f = assert(player[self.what])
	-- f(player,self.value)
end


local function response(session,args)
	print("game_session",session)
	if args.cmd == "set_discard" then
		player:set_discard(args.value,session)
	elseif args.cmd == "throw" then
		player:throw(args.value,session)
	elseif args.cmd == "pong" then
		player:pong(args.value,session)
	elseif args.cmd == "gong" then
		player:gong(args.value,session)	
	end

end
local RESPONSE={}
function RESPONSE:lose(p)
	player:lose(p)
	-- body
end
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end


function CMD.start(conf)
	WATCHDOG = conf.watchdog
	client_fd = conf.fd
	REQUEST.login(conf.accountname)
end
function CMD.reconnect()
	print("reconnect")
	local ret
	local  ongaming = player:ongame()
	if  ongaming then

		print("on gaming")
		player.active = true
		local gameinfo = player:get_game_info()
		player:reconnect()
		ret = {cmd="reconnect",value=gameinfo}
	else
		print("not gaming")
		player:leave_room()
		ret = {cmd="login",value={succeed=true,error=""}}
		
	end
	

	sendRequest(ret)
	-- body
end
function CMD.disconnect()
	if not player:ongame() then
		local accountname = player:get_accountname()
		-- print(accountname,"===========",WATCHDOG)
		skynet.send(WATCHDOG,"lua","logout",accountname)
		skynet.send("account_mgr","lua","logout",accountname)
		player:leave_room()
		print("断开连接")
		-- todo: do something before exit
		skynet.exit()
	else

		player.active = false
		-- skynet.send()
		print("waiting reconnect")
	end
end


function CMD.notify(data)
	sendRequest(data)
end


function CMD.init_holds(holds,game_session)
	local str = send_request("set_holds",{holds=holds},game_session)
	-- session = session +  1
	send_package(str)
	print("be called")	
end

function CMD.game(obj,game_session)
	local str = send_request("game",obj,game_session)
	send_package(str)	
end

-- 设置属性
function CMD.set( conf )
	for k,v in pairs(conf) do
		player[v.attr] = v.value
	end
	-- player[conf.attr] = conf.value
	-- print(player.game_mgr)
end
function CMD.dispatch(data)
	local f = REQUEST[data.cmd]
	-- print(data.cmd)
	if f then
		return f(data.value,data.session)
	else
		print("no cmd",data.cmd)
	end
end
function CMD.get_info()
	-- print()
	return player:get_info()
end
function CMD.gameover()
	return player:gameover()
	-- body
end
function CMD.set_ws(fd)
	-- print("before change"..client_fd)
	-- print("after change"..fd)
	client_fd = fd
	-- body
end
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		if f then
			skynet.ret(skynet.pack(f(...)))
		end
	end)

	-- print("agent starting")
	-- skynet.register("agent")
end)
