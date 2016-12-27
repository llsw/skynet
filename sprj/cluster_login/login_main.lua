
--[[
 * @brief: login_main.lua

 * @author:	  kun si
 * @date:	2016-12-22
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"

skynet.start(function ()
	cluster.open("cluster_login")	
	printI("Cluster_login start")

	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")

	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	local debug_port = skynet.getenv "debug_port"
	skynet.newservice("debug_console",debug_port)
	
	skynet.uniqueservice("database")
	skynet.newservice("login")
	skynet.exit()

	
end)