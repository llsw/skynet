local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"

skynet.start(function ()
	cluster.open("cluster_database")
	skynet.register("database_main")
	
	skynet.error("Cluster_database start")
	LOG_INFO("Cluster_database start")

	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")

	

	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end


	local debug_port = skynet.getenv "debug_port"
	skynet.newservice("debug_console",debug_port)


	local redispool = skynet.uniqueservice("redispool")
  	skynet.call(redispool, "lua", "start")

  	local mysqlpool = skynet.uniqueservice("mysqlpool")
  	skynet.call(mysqlpool, "lua", "start")

  	

	
end)