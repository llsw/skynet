local skynet = require "skynet"
require "skynet.manager"
local redis = require "redis"

local CMD = {}
local pool = {}


function CMD.start()
	
	maxconn = tonumber(skynet.getenv("redis_maxinst")) or 1
	for i=1, maxconn do
		local rhost = skynet.getenv("redis_host" .. i)
		local rport = skynet.getenv("redis_port" .. i)
		local rdb = skynet.getenv("redis_db" .. i)
		local rauth = skynet.getenv("redis_auth" .. i)
		local db = redis.connect({
				host = rhost,
				port = rport,
				db = rdb,
				auth = rauth,		
			})
		if db then
			db:flushdb()
			table.insert(pool, db)
			LOG_INFO("redis connect success  [host = %s port = %s db = %d]", rhost, rport, rdb)
		else
			LOG_EORR("redis connect erorr [host = %s port = %s db = %d]", rhost, rport, rdb)
		end
	end
	
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)
