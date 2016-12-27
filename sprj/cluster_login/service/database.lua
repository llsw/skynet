local skynet = require "skynet"
local cluster = require "cluster"
require "skynet.manager"

local CMD = {}


function CMD.redis_query(args, dbn)

	local redispool = cluster.proxy("cluster_database", "redispool")

	local cmd = assert(args[1])
	args[1] = dbn
	return skynet.call(redispool, "lua", cmd, table.unpack(args))
end

function CMD.mysql_query(sql, dbn)
	local mysqlpool = cluster.proxy("cluster_database", "mysqlpool")
	return skynet.call(mysqlpool, "lua", "execute", sql, dbn)
end

skynet.start(function ()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".database")
end)