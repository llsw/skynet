
--[[
 * @brief: gateway_main.lua

 * @author:	  kun si
 * @date:	2016-12-22
--]]


local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"
local service_config = require "sprj.service_config"
local gateway_config = service_config["gateway_config"]

skynet.start(function ()
	cluster.open("cluster_gateway")	
	printI("Cluster_gateway start")

	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")

	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	local debug_port = skynet.getenv "debug_port"
	skynet.newservice("debug_console",debug_port)

	local gateway = skynet.newservice("gateway")
	skynet.call(gateway, "lua", "open", gateway_config)
	skynet.name(".gateway", gateway)
	skynet.exit()

	
end)