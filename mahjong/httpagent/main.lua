local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require "json"

local function response(id, code, msg, ...)
    local data = json:encode(msg)
    local header = {}
	header["Access-Control-Allow-Origin"] = "*"
    local ok, err = httpd.write_response(sockethelper.writefunc(id), code, data, header)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        skynet.error(string.format("fd = %d, %s", id, err))
    end
end

local function decode_body( body )
	local data = {}
	if body then
		for k,v in string.gmatch(body, "(%w+)=(%w+)") do
		    data[k]=v
		end
	end	
	return data
end
local function decode_url(url)
	local path, query = urllib.parse(url)
	local data = {}
	if query then
		local q = urllib.parse_query(query)
		for k, v in pairs(q) do
			data[k] = v
		end
	end	
	return string.sub(path,2,string.len(path)),data
end

local GET = {}
function GET.login(id,data)
	local ret = skynet.call("account_mgr","lua","login",data.username,data.password)
	response(id,200, ret)
end

function GET.get_room_info(id,data )
    print(data.room_mgr)
    local ret = skynet.call(data.room_mgr,"get_room_info")
    -- response()
end
function GET.get_history_record(id,data)
    for k,v in pairs(data) do
        print(k,v)
    end

    local ret = skynet.call("mysql","lua","get_game_record",data.user_id,5)
    response(id,200, ret)
end

local POST = {}

function POST.login(id,data)
    local ret = skynet.call("account_mgr","lua","login",data.username,data.password)
    response(id,200, ret)
    
end


local function handle(id)
    socket.start(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 128)
    print(code, url, body)

    if not code or code ~= 200 then
        return
    end

    if method == "GET" then
        local path,data = decode_url(url)
        print(path)
        local f = GET[path]
        if f then
        	return f(id,data)
            
        end
    else
        local path = string.sub(url,2,string.len(url))
        local data = decode_body(body)
        local f = POST[path]
        if f then
          return f(id,data)
       
        end
    end
    response(id,200,{succeed=0,err="something errors"})

end

skynet.start(function()
    skynet.dispatch("lua", function (_,_,id)
        handle(id)

        socket.close(id)
        -- if not pcall(handle, id) then
        --    response(id, 200, "{\"msg\"=\"exception\"}")
        -- end
    end)
end)
