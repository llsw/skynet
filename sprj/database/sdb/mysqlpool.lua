local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"

local CMD = {}
local pool = {}
local maxconn

function CMD.start()
	maxconn = tonumber(skynet.getenv("mysql_maxconn")) or 8
	
	for i=1, maxconn do
		local rhost = skynet.getenv("mysql_host")
		local rport = skynet.getenv("mysql_port")
		local ruser = skynet.getenv("mysql_user")
		local rpassword = skynet.getenv("mysql_password")
		local rdatabase = skynet.getenv("mysql_database")
		local rmax_packet_size = 1024 * 1024

		local db = mysql.connect({
				host = rhost,
				port = rport,
				database = rdatabase,
				user = ruser,
				password = rpassword,
				max_packet_size = rmax_packet_size,
			})

		if db then
			table.insert(pool, db)
			db:query("set charset utf8")
			LOG_INFO("mysql connect success [host = %s port = %d database = %s]", 
				rhost, rport, rdatabase)	
		else
			LOG_ERORR("mysql connect error [host = %s port = %d database = %s]", 
				rhost, rport, rdatabase)
		end

	end
end

local function getconn(dbn)
	local db
	if not dbn or maxconn == 1 then
		db = pool[1]
		if not db then
			LOG_EORR("there isn't this db[%d] in pool", 1)
		end
		assert(db, "there isn't this db[1] in pool")
	else
		local nu = dbn % maxconn + 1
		if not db then
			LOG_EORR("there isn't this db[%d] in pool", nu)
		end
		assert(db, "there isn't this db[" .. nu .. "] in pool")
	end
	return db
end

function CMD.execute(sql, dbn)
	local db = getconn(dbn)
	return db:query(sql)
end

function CMD.stop()
	for _, db in pairs(pool) do
		db:disconnect()
	end
	pool = {}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)