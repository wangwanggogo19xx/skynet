local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local p = require "player"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd
local service 
local player 
local session = 100

function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:login()

	if self.username == "1" and self.password == "1" then
		player = p:new(skynet.self())
		return {succeed=1,error=""}
	else
		return {succeed=0,error="invalid username or password"}
	end
end
function REQUEST:join_room()
	local succeed,seat,err,room_id = player:join_room(self.room_mgr,self.seat)
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

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	print("request==agent,params name",name,args,response)
	local f = assert(REQUEST[name])
	local r = f(args)
	print(r)
	if response then
		return response(r)
	end
end


local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

-- after gateserver.openclient(fd) be called
-- this would be touched
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			print(ok,result)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			print(...)
			-- assert(type == "RESPONSE")
			-- error "This example doesn't support request client"
		end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))

	client_fd = fd


	service = skynet.newservice("player_mgr",fd)
	skynet.send(service,"lua","service_addr",service)

	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end


function CMD.notify(...)
	local str = send_request("player_join",{player=...})
	send_package(str)
end


function CMD.init_holds(holds)
	local str = send_request("set_holds",{holds=holds},session)
	session = session +  1
	send_package(str)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print(command.."=====agent")
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	
	-- skynet.register("agent")
end)
