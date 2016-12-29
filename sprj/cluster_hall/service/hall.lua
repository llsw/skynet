
--[[
 * @brief: hall.lua

 * @author:	  kun si
 * @date:	2016-12-29
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"


local CMD = {}
local agents = {}
local users = {}



function CMD.clientMsg(fd, msg, sz)
	if not users[username]  then
		local agent = skynet.newservice("agent")
		agents[fd] = agent
		users[fd] = true
	end

	local ret = skynet.call(agents[fd], "lua", "clientMsg", fd, msg, sz)
	return ret 
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(".hall")
end)