local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
	response {
		msg 0  : string
	}
}

get 2 {
	request {
		what 0 : string
	}
	response {
		result 0 : string
	}
}

set 3 {
	request {
		what 0 : string
		value 1 : string
	}
}

quit 4 {}

req 5{
	request {
		url 0 : string
		args 1 : string
	}
	response {
		succeed 0 : integer
		erro 1 : string
	}
}

login 6 {
	request {
		username 0 : string
		password 1 : string
	}
	response {
		succeed 0 : integer
		error 1 : string
	}
}
join_room 7 {
	request {
		room_mgr 0 : integer
		seat 1 : integer
	}
	response {
		succeed 0 : integer
		seat 1 : integer
		info 2 : string
		room 3 : integer
	}
}

toggle_ready 8 {
	
}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {
	request {
		what 0 : string
	}
}
set 2 {
	request {
		what 0 : string
		succeed 1:integer
		value 2 : string
	}
}

player_join 3 {
	request {
		player 0 : integer
	}
}
set_holds 4 {
	request {
		holds 0 : string
		dump 1 : string
		pong 2 : string
		gong 3 : string
	}
}


game 5 {
	request {
		cmd 1 :string
	}
	response {
		value 1 : integer
	}
}
]]

return proto
