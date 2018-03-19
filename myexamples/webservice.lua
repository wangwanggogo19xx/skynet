local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string

local mode = ...
if mode == "agent" then

skynet.start(function()
	local httpservice = skynet.newservice("httpservice")
	
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
		if code then
			if code ~= 200 then
				-- response(id, code)
				skynet.send(httpservice,"lua",id,"http","error",code)
			else
				local i = 1
				local tmp = {}
				for k in string.gmatch(url, "/(%w+)") do
					tmp[i] = k
					print(k)
					i = i + 1
				end
				data = {}
				if body then
					for k,v in string.gmatch(body, "(%w+)=(%w+)") do
					    data[k]=v
					end
				end
				skynet.send(httpservice,"lua",id,tmp,data)
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
	skynet.error("Listen web port ",8000)
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