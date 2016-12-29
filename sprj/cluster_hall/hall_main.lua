
--[[
 * @brief: hall_main.lua

 * @author:	  kun si
 * @date:	2016-12-29
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"

skynet.start(function ()
	cluster.open("cluster_hall")	
	printI("cluster_hall start")

	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")

	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	local debug_port = skynet.getenv "debug_port"
	skynet.newservice("debug_console",debug_port)
	
	skynet.uniqueservice("database")
	skynet.newservice("hall")
	skynet.exit()

	
end)