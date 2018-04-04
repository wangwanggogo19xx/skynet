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
	print("send_package")
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

local function chupai(name,args,response)
	print(name,args,response)
	local p =0
	for i=1,50000 do
		p = socket.readstdin()
		
		if p then
			 p = tonumber(p)
			 if p then
			 	print("you lose ",p)
			 	break
			 end
		end
		socket.usleep(100)
	end
	return response({value=p})
	-- print(ok,result)
	-- print("my holds is:",args.holds)
	-- if args then
	-- 	for k,v in pairs(args) do
	-- 		print(k,v)
	-- 	end
	-- end	
	-- body
end
local function print_package(t, ...)
	if t == "REQUEST" then
		local ok,result =pcall(chupai,...)
		print(ok,result)
		send_package(fd,result)
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
