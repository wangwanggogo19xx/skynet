local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require "json"

local function response(id, code, msg, ...)
    local data = json:encode(msg)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), code, data, ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        skynet.error(string.format("fd = %d, %s", id, err))
    end
end

local function decode_post_body( body )
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
local function handle(id)
    socket.start(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 128)
    print(code, url, body)

    if not code or code ~= 200 then
        return
    end
    -- print()

	-- local tmp = {}
	-- if header.host then
	-- 	table.insert(tmp, string.format("host: %s", header.host))
	-- end
	-- local path, query = urllib.parse(url)
	-- --print(path.."===query:"..query)
	-- table.insert(tmp, string.format("path: %s", path))
	-- if query then
	-- 	local q = urllib.parse_query(query)
	-- 	for k, v in pairs(q) do
	-- 		table.insert(tmp, string.format("query: %s= %s", k,v))
	-- 	end
	-- end
	-- table.insert(tmp, "-----header----")
	-- for k,v in pairs(header) do
	-- 	table.insert(tmp, string.format("%s = %s",k,v))
	-- end
	-- table.insert(tmp, "-----body----\n" .. body)
	-- response(id, code, table.concat(tmp,"\n"))   

	-- return

    if method == "GET" then
    	local path,data = decode_url(url)
    	print(path)
    	local f = GET[path]
    	if f then
    		f(id,data)
    	end
    else
    	print(json:decode(body))
    end


    -- local msg = decode_post_body(body)
    -- print(body)
    -- if url == "/login" then
    -- 	login(id,msg)
    -- end
    -- local msg = cjson.decode(body)
    -- if url == "/login_lobby" then
    --     login_lobby(id, msg)
    -- elseif url == "/create_room" then
    --     create_room(id, msg)
    -- elseif url == "/join_room" then
    --     join_room(id, msg)
    -- end
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
