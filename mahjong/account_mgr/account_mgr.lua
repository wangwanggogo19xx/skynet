local skynet = require "skynet"

local M = {}

local id = 1
function M:init( )
	self.online_account = {}
	print(self.online_account )
end

function M:login(username,password)
	local user 
	if not self.online_account[username] then

		local ret = skynet.call("mysql", "lua", "get_user_by_accountname", username)
		print(ret.succeed)
		if not ret.succeed then
			ret = skynet.call("mysql", "lua", "register", username,password)
			print(#ret)
			if #ret == 1 then
				ret = skynet.call("mysql", "lua", "get_user_by_accountname", username)
			else
				print("用户名或密码错误")
				return {succeed=false,error_info = "用户名或密码错误"}
			end
		end
		user = ret.value

		self.online_account[username] = user
	else

		user = self.online_account[username]
	end	
	-- for k,v in pairs(user) do 
	-- 	print(k,v)
	-- end
	print(self.online_account[username].username)
	if user.password == password then
		-- user.password= ""
		print("登录成功")

		return {succeed=true,user = user}
	else

		print("用户名或密码错误")
		return {succeed=false,error_info = "用户名或密码错误"}
	end

	-- id = id + 1
end

function M:register(username,password)
	-- local info = debug.getinfo(1, "S") -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息  
	-- local path = info.source 
	-- path = string.sub(path, 2, -1) -- 去掉开头的"@"  
	-- path = string.match(path, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分  
	-- print("dir=", path) 

end

function M:get_userinfo(username)
	
	return self.online_account[username] 
end
function M:is_online(accountname)
	return self.online_account[username] ~= nil
end

return M