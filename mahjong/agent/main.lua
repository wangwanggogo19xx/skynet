local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local p = require "player"
local json = require "json"

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

function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST.login(user)
	if user.username == "1" and user.password == "1" then
		player = p:new(skynet.self())
		return {succeed=1,error=""}
	else
		return {succeed=0,error="invalid username or password"}
	end
end
function REQUEST:join_room()
	local succeed,seat,err,room_id = player:join_room(self.room_mgr,self.seat)
	print(succeed,seat,err,room_id)
	return {succeed=succeed,seat=seat,info=err,room=room_id}
end

function REQUEST:toggle_ready()
	skynet.sleep(20)
	player:toggle_ready()
end
function REQUEST:set()
	-- print("get", self.what,self.value)
	-- skynet.call(service,"lua",self.what,self.value)
	-- local f = assert(player[self.what])
	-- f(player,self.value)
end

local function sendRequest(data)
	local str = JSON:encode(data)
	ws.send(str);
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
	ws = conf.ws
	print("agent started")
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end


function CMD.notify(...)
	local str = send_request("notification",...)
	send_package(str)
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
	if f then
		return f(data.value,data.session)
	end
end
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print(command.."=====agent")
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	print("agent starting")
	-- skynet.register("agent")
end)
