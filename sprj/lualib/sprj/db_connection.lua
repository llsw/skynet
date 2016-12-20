
--[[
 * @brief: db_connetction.lua

 * @author:	  kun si
 * @date:	2016-12-20
--]]

local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local lock = skynet_queue()
local mysql = require "mysql"
local queue = require "sprj.queue"

local function printI(str, ...)
	skynet.error(string.format(str, ...))
	LOG_INFO(str, ...)
end

local function printE(str, ...)
	skynet.error(string.format(str, ...))
	LOG_ERROR(str, ...)
end


--!
--! @brief      类模板
--!
--! @param      父类
--!
--! @return     类模板
--!
--! @author     云风
--! 
local _class={}
function class(super)
	local class_type = {}
	class_type.ctor = false
	class_type.super = super
	class_type.new = function(...) 
			local obj = {}
			do
				local create
				create = function(c,...)
					if c.super then
						create(c.super,...)
					end
					if c.ctor then
						c.ctor(obj,...)
					end
				end
 
				create(class_type,...)
			end
			setmetatable(obj,{ __index = _class[class_type] })
			return obj
		end
	local vtbl = {}
	_class[class_type] = vtbl
 
	setmetatable(class_type,{__newindex =
		function(t,k,v)
			vtbl[k] = v
		end
	})
 
	if super then
		setmetatable(vtbl,{__index=
			function(t,k)
				local ret =_class[super][k]
				vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end

local dbcPool = class()

--[[
	config of pool
--]]
dbcPool.conf = nil
dbcPool.pool = nil --usef 
dbcPool.totalNum = nil
dbcPool.usedNum = 0
dbcPool.threshold = nil
dbcPool.pingTime = nil
dbcPool.lock = false
dbcPool.addNum = nil

--!
--! @brief      Pushes a pool.
--!
--! @param      q     The quarter
--! @param      db    The database
--! @param      l     { parameter_description }
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si
--! @date       2016-12-20
--!
local function pushPool(q, db, l)

	if queue.isFull(q) then
		return 1 
	else
		while l do
			skynet.sleep(0.1 * 100)
		end
		l = true
		queue.push(q, db)
		l = false
		return 0
	end
end
--!
--! @brief      { function_description }
--!
--! @param      q     The quarter
--! @param      l     { parameter_description }
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si
--! @date       2016-12-20
--!
local function popPool(q, l)
	if queue.isEmpty(q) then
		return 1
	else
		while l do
			skynet.sleep(0.1 * 100)
		end
		l = true
		local db = queue.pop(q)
		l = false
		return db 
	end
end

--!
--! @brief      { function_description }
--!
--! @param      dbcP  The dbc p
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si
--! @date       2016-12-20
--!
function dbcPool:ping()
	
	while true do
		for k, v in pairs(self.pool) do
			printI(type(v))
			v:query("select 1")
			printI("Activity DB[%d]", k)
		end
		skynet.sleep(self.pingTime * 100)
	end
end
local function ping(dbcP)
	dbcP:ping()
end
--!
--! @brief      Adds a connect.
--!
--! @param      dbcP  The dbc p
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si
--! @date       2016-12-20
--!
local function addConnect(dbcP)
	local old_totalNum = dbcP.totalNum
	dbcP.totalNum = dbcP.totalNum + dbcP.addNum
	queue.setMaxLen(dbcPool.pool, dbcP.totalNum)
	local count = 0
	for i = 1, dbcP.addNum do
		if lock(pushPool, self.pool, db, self.lock) == 1 then
			printE("AddConnect[%d] to pool is fail!", i)
		else
			count = count + 1
		end
	end
	dbcP.totalNum = dbcP.totalNum + count
	printI("DBPool real totalNum is [%d]", dbcP.totalNum)
end

--!
--! @brief      { function_description }
--!
--! @param      dbConf  The database conf
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si
--! @date       2016-12-20
--!
function dbcPool:init(dbConf)
	self.totalNum = 15 or dbConf.totalNum
	self.conf = nil or dbConf.conf
	self.threshold = 0.7 or dbConf.threshold
	self.pingTime = 3600 or dbConf.pingTime
	self.pool = queue.new(self.totalNum)
	self.addNum = 5 or dbConf.addNum
	self.lock = false
	local count = 0
	for i = 1 , self.totalNum do
		local db = mysql.connect(dbConf)
		if not db then
			printE("Create DB[%d] fail", i)
		else
			if lock(pushPool, self.pool, db, self.lock) == 1 then
				printE("DBPool if full")
				break
			else
				count = count + 1

			end
		end
	end
	printI("DBPool useful is %d", count)
	--synet.fork(ping, self)
end

--!
--! @brief      Gets the db.
--!
--! @return     The db.
--!
--! @author     kun si
--! @date       2016-12-20
--!
function dbcPool:get()
	if queue.isEmpty(self.pool) then
		printE("GetDB fail. DBPool is empty!")
		return nil
	else
		local db = lock(popPool, self.pool, self.lock)

		if db == 1 then
			printE("GetDB fail")
			return nil
		else
			printI("GetDB success")
			self.usedNum = self.usedNum + 1

			if  self.usedNum >= (self.threshold * self.totalNum) then
				skynet.fork(addConnect, self)
			end
			self.usedNum = self.usedNum + 1
			return db
		end
	end
end

--!
--! @brief      { function_description }
--!
--! @param      db    The database
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si
--! @date       2016-12-20
--!
function dbcPool:free(db)
	if lock(pushPool, self.pool, db, self.lock) == 1 then
		printE("DBPool if full")
	else
		self.usedNum = self.usedNum - 1
	end
end

return dbcPool