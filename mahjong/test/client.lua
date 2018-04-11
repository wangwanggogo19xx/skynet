package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;mahjong/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "client.socket"
local proto = require "proto"
local sproto = require "sproto"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_package(fd, pack)
	-- print("send_package")
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)

	if result then

		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local session = 0

local function send_request(name, args)
	session = session + 1
	local str = request(name, args, session)
	print(str,"=============")
	send_package(fd, str)
	-- print("Request:", session)
end

local last = ""

local function print_request(name, args)
	print("REQUEST", name,args)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end


local function input( )
	local p = 0
	for i=1,500 do
		p = socket.readstdin()
		if p then
			return p 
		end
		socket.usleep(100)
	end	
	return nil
end

local REQUEST = {}
function REQUEST.set_discard(seat,value,response)
	print("定缺")
	print(value)
	local p = input()
	-- print(p)
	if p then
		return response({cmd="set_discard",value=p})
	end
end

function REQUEST.get(seat,value,response )
	print("get card : ",value)
	-- local p = input()
	-- print(p)
	-- if p then
	-- 	return response({cmd="throw",value=p})	
	-- end
	-- body
end
function REQUEST.pong( seat,value,response )
	return response({cmd="pong",value=nil})
end

function REQUEST.gong( seat,value,response )
	return response({cmd="gong",value=nil})
end
function REQUEST.player_join(seat,value,response )
	-- return response({cmd="throw",value=11})	
	-- body
end
function REQUEST.show_holds(seat,value,response )
	print(value)
end
function REQUEST.throw(seat,value,response )
	print("player",seat,"throw",value)
end
local function request(name,args,response)
	print(args.cmd)
	local f = REQUEST[args.cmd]
	assert(f)
	local ok,result =  f(args.seat,args.value,response)
	-- if response then
	-- 	send_package(fd,result)
	-- end
	return ok,result
end


function REQUEST.player_pong( seat,p)
	print(seat,"pong",p)

end
function REQUEST.player_gong( seat,p)
	print(seat,"gong",p)

end
local function print_package(t, ...)
	if t == "REQUEST" then
		local ok,result =pcall(request,...)
		-- print(ok,result)
		-- send_package(fd,result)
		if ok then
			if result then
				send_package(fd,result)
			end
		end
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		
		if not v then
			break
		end

		print_package(host:dispatch(v))
	end
end

-- send_request("join_room",{room_id = "11"})
send_request("login", { username = "1", password = "1" })
send_request("join_room", { room_id ,seat })
-- send_request("toggle_ready")
send_request("toggle_ready")
while true do
	dispatch_package()
	-- local cmd = socket.readstdin()
	-- if cmd then
	-- 	if cmd == "quit" then
	-- 		send_request("quit")
	-- 	else
	-- 		send_request("get", { what = cmd })
	-- 	end
	-- else
	-- 	socket.usleep(100)
	-- end
end
