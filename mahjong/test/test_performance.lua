local skynet = require "skynet"


-- print("test_performance")
-- print("=========")




skynet.start(function()
	skynet.call("account_mgr","lua","login","2014110457","2014110457")
    for i=1,40 do
		client = skynet.newservice("agent")
		skynet.call(client,"lua","dispatch",{cmd="login",value="2014110457"})
		skynet.send(client,"lua","dispatch",{cmd="join_room"})
		skynet.send(client,"lua","dispatch",{cmd="toggle_ready"})
	end
end)
