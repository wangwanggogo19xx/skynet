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
	skynet.call(WATCHDOG,"lua","notify",client_fd,data)
end

-- function REQUEST:get()
-- 	print("get", self.what)
-- 	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
-- 	return { result = r }
-- end

function REQUEST.login(user)
	-- local ret = skynet.call("account_mgr","lua","have_logined",user.username)
	-- print(ret)
	-- if ret then
	-- 	player = p:new(skynet.self())
	-- 	-- ret = {succeed=true,error=""}
	-- 	sendRequest({succeed=true,error=""})
	-- else
	-- 	sendRequest({succeed=false,error="invalid username or password"})
	-- 	skynet.exit()
	-- end
	if user.username == "1" and user.password == "1" then
		player = p:new(skynet.self())
		ret = {succeed=1,error=""}
	else
		ret =  {succeed=0,error="invalid username or password"}
	end
	sendRequest(ret)
	return ret
end
function REQUEST.join_room(info)
	local ret = player:join_room(info.room_id,info.seat)
	sendRequest(ret)
end

function REQUEST.leave_room()
	player:leave_room()
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
end

function CMD.disconnect()
	REQUEST.leave_room()
	-- todo: do something before exit
	skynet.exit()
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
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	-- print("agent starting")
	-- skynet.register("agent")
end)
