local skynet = require "skynet"
require "skynet.manager"
local redis = require "redis"
local crypt = require "crypt"

local CMD = {}
local pool = {}
local maxconn

function CMD.start()
	
	maxconn = tonumber(skynet.getenv("redis_maxinst")) or 1
	for i=1, maxconn do
		local rwho = skynet.getenv("who")
		local rhost = skynet.getenv("redis_host" .. i)
		local rport = skynet.getenv("redis_port" .. i)
		local rdb = skynet.getenv("redis_db" .. i)
		local rauth = skynet.getenv("redis_auth" .. i)
		rauth = crypt.base64decode(rauth)
		rauth = crypt.aesdecode(rauth,rwho,"")

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

function getconn(dbn)
	local db
	if not dbn or maxconn == 1 then
		db = pool[1]

		if not db then
			LOG_EORR("there isn't this db[%d] in pool", 1)
		end
		assert(db, "there isn't this db[1] in pool")
	else
		local nu = dbn % maxconn + 1
		db = pool[nu]
		if not db then
			LOG_EORR("there isn't this db[%d] in pool", nu)
		end
		assert(db, "there isn't this db[" .. nu .. "] in pool")
	end

	return db
end

function CMD.set(dbn, key, value)
	local db = getconn(dbn)
	local retsult = db:set(key,value)
	
	return retsult
end

function CMD.get(dbn, key)
	local db = getconn(dbn)
	local retsult = db:get(key)
	
	return retsult
end

function CMD.hmset(dbn, key, t)
	local data = {}
	for k, v in pairs(t) do
		table.insert(data, k)
		table.insert(data, v)
	end

	local db = getconn(dbn)
	local result = db:hmset(key, table.unpack(data))

	return result
end

function CMD.hmget(dbn, key, ...)
	if not key then return end

	local db = getconn(dbn)
	local result = db:hmget(key, ...)
	
	return result
end

function CMD.hset(dbn, key, filed, value)
	local db = getconn(dbn)
	local result = db:hset(key,filed,value)
	
	return result
end

function CMD.hget(dbn, key, filed)
	local db = getconn(dbn)
	local result = db:hget(key, filed)
	
	return result
end

function CMD.hgetall(dbn, key)
	local db = getconn(dbn)
	local result = db:hgetall(key)
	
	return result
end

function CMD.zadd(dbn, key, score, member)
	local db = getconn(dbn)
	local result = db:zadd(key, score, member)

	return result
end

function CMD.keys(dbn, key)
	local db = getconn(dbn)
	local result = db:keys(key)

	return result
	
end

function CMD.zrange(dbn, key, from, to)
	local db = getconn(dbn)
	local result = db:zrange(key, from, to)

	return result
end

function CMD.zrevrange(dbn, key, from, to ,scores)
	local result
	local db = getconn(dbn)
	if not scores then
		result = db:zrevrange(key,from,to)
	else
		result = db:zrevrange(key,from,to,scores)
	end
	
	return result
end

function CMD.zrank(dbn, key, member)
	local db = getconn(dbn)
	local result = db:zrank(key,member)

	return result
end

function CMD.zrevrank(dbn, key, member)
	local db = getconn(dbn)
	local result = db:zrevrank(key,member)

	return result
end

function CMD.zscore(dbn, key, score)
	local db = getconn(dbn)
	local result = db:zscore(key,score)

	return result
end

function CMD.zcount(dbn, key, from, to)
	local db = getconn(dbn)
	local result = db:zcount(key,from,to)

	return result
end

function CMD.zcard(dbn, key)
	local db = getconn(dbn)
	local result = db:zcard(key)

	return result
end

function CMD.incr(dbn, key)
	local db = getconn(dbn)
	local result = db:incr(key)
	
	return result
end

function CMD.del(dbn, key)
	local db = getconn(dbn)
	local result = db:del(key)
	
	return result
end
	

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register("redispool")
end)
