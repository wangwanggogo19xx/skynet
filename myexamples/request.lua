local skynet = require "skynet"

local commad = {}

function commad.login(body)
	username = body.username
	password = body.password
	if username == "wangwang" and password == "wangwang" then
		return "succeed"
	else
		return "faild"
	end
	-- body
end