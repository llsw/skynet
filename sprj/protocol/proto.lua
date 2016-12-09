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

quit 4 {
}

driver 5 {
    request {
        what 0 : string
    }
    response {
        result 0 : string
    }
}

login 6 {
	request {
		username 0 : string
		password 1 : string
	}
	response {
		result 0 : string
		error  1 : integer
	}
}

transfer_table 7 {
	request {

		.cart {
			number 0 : integer
			color 1 : string
		}

		tt 0 : *cart
		tti 1 : *integer
	}
}

pvp 8 {
	response {
		result 0 : string
		error 1 : integer
	}
}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}

test 2 {
	request {
		gaiyixia 0 : string
	}
}

connect_room 3 {
	request {
		address 0 : string
		port 1 : integer
		room_name 2 : string 
	}
}

]]

return proto
