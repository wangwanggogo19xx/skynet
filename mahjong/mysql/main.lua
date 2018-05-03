local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
require "skynet.manager"

local db
local CMD = {}


local function dump(res, tab)
	local result = {}
    tab = tab or 0
    if(tab == 0) then
        skynet.error("............dump...........")
    end
    if type(res) == "table" then
        skynet.error(string.rep("\t", tab).."{")
        for k,v in pairs(res) do

            if type(v) == "table" then
                result[k] = dump(v, tab + 1)
             else
             	result[k] =  v
                skynet.error(string.rep("\t", tab), k, "=", v, ",")
            end
        end
        skynet.error(string.rep("\t", tab).."}")
        return result

    else
        skynet.error(string.rep("\t", tab) , res)
    	return res

    end
end



function CMD.get_user_by_accountname(accountname)
	db:query("set charset utf8")
	local sql = string.format("select * from user where accountname = %s;", accountname)
	print(sql)
	local res = db:query(sql)
	if #res == 1 then
		local result = dump(res)[1]
		return {succeed=true,value=result}
	end

	return {succeed=false,info="不存在该用户"}
end 
function CMD.register(accountname,password)
	local info = debug.getinfo(1, "S") -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息  
	local path = info.source 
	path = string.sub(path, 2, -1) -- 去掉开头的"@"  
	path = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分  
	-- print("dir=", path) 



	-- local str="python --version"
	str = string.format("python3 %s/../labSystem/officeOfAcdemic/mahjong_login.py %s %s",path,accountname,password)
	-- print(str)
	local t = io.popen(str)
	local a = t:read("*all")
	local temp = {}
	for str in string.gmatch(a,"%C+") do
		table.insert(temp,str)
	end

	-- for k,v in pairs(temp) do
	-- 	print(k,v)
	-- end	
	return temp
end


function CMD.start()
	local function on_connect(db)
        skynet.error("on_connect")
	end

    db=mysql.connect({
        host="192.168.64.2",
        port=3306,
        database="mahjong",
        user="zhang",
        password="zhang",
        max_packet_size = 1024 * 1024,
        on_connect = on_connect
    })
    if not db then
    	db:query("set charset utf8")
        skynet.error("failed to connect")
    else
        skynet.error("success to connect to mysql server")    

    	-- CMD.get_user("2014110457","2014110457")
    end
end

function CMD.close( ... )
	db:disconnect() --关闭连接
end

skynet.start(function()

	skynet.dispatch("lua",function (_, session, cmd, ...)
		local f = CMD[cmd]

		skynet.ret(skynet.pack(f(...)))
	end)
	CMD.start()
	-- CMD.register("2015110433","123456")
	skynet.register("mysql")	
end)