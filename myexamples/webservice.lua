local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string

local mode = ...
if mode == "agent" then

local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

skynet.start(function()
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
		print("body==="..body.."code="..code.."method="..method)
		if code then
			if code ~= 200 then
				response(id, code)
			else
				print(code)
				local tmp = {}
				if header.host then
					table.insert(tmp, string.format("host: %s", header.host))
				end
				local path, query = urllib.parse(url)
				--print(path.."===query:"..query)
				table.insert(tmp, string.format("path: %s", path))
				if query then
					local q = urllib.parse_query(query)
					for k, v in pairs(q) do
						table.insert(tmp, string.format("query: %s= %s", k,v))
					end
				end
				table.insert(tmp, "-----header----")
				for k,v in pairs(header) do
					table.insert(tmp, string.format("%s = %s",k,v))
				end
				table.insert(tmp, "-----body----\n" .. body)
				res = skynet.call(skynet.newservice("userservice"),"lua","login")
				print(res)
				response(id, code, res)
			end
		else
			if url == sockethelper.socket_error then
				skynet.error("socket closed")
			else
				skynet.error(url)
			end
		end
		socket.close(id)
	end)
end)

else

skynet.start(function()
	local webagent = {}
	for i= 1, 20 do
		webagent[i] = skynet.newservice(SERVICE_NAME, "agent")
	end
	local balance = 1
	local id = socket.listen(WEB_LISTENER, WEB_LISTENER_PORT)
	skynet.error("Listen web port 8000")
	socket.start(id , function(id, addr)
		skynet.error(string.format("%s connected, pass it to agent :%08x", addr, webagent[balance]))
		skynet.send(webagent[balance], "lua", id)
		balance = balance + 1
		if balance > #webagent then
			balance = 1
		end
	end)

end)

end