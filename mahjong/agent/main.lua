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

function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST.login(user)
	local ret
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
	print(client_fd,"fd is")
	local succeed,seat,err,room_id = player:join_room(info.room_id,info.seat)
	print(info.room_id,info.seat)
	sendRequest({succeed=succeed,seat=seat,info=err,room=room_id})
end

function REQUEST.toggle_ready()
	skynet.sleep(20)
	player:toggle_ready()
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
function CMD.set( conf )
	player[conf.attr] = conf.value
	print(player.game_mgr)
end
function CMD.dispatch(data)
	local f = REQUEST[data.cmd]
	-- print(data.cmd)
	if f then
		return f(data.value,data.session)
	end
end
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	-- print("agent starting")
	-- skynet.register("agent")
end)
