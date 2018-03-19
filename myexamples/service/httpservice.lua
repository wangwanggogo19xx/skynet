local skynet = require "skynet"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"

local USERSERVICE = {}


function USERSERVICE.login(data)
	return 200,"ok"
end

function USERSERVICE.register( data)
	
	return 200,"ok"
	-- body
end



local ROOMSERVICE = {}

function ROOMSERVICE.create(  )

	return 200,"creating room"
end



local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end



local HTTP = {}
function HTTP.error( ... )
	-- body
	return "error"
end
local  SERVICE = {}

SERVICE["USERSERVICE"] = USERSERVICE
SERVICE["ROOMSERVICE"] = ROOMSERVICE
SERVICE["HTTP"] = HTTP

skynet.start(function()
	skynet.dispatch("lua",function(session,source,id,service,...)
		local f = nil
		if  SERVICE[string.upper(service[1])] ~= nil then
			f = assert(SERVICE[string.upper(service[1])][string.lower(service[2])])
		else
			f = HTTP.error
		end
		response(id,f(...))
		
	end)
end)