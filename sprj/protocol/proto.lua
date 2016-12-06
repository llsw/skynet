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

]]

return proto
