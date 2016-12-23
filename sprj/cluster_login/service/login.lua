
--[[
 * @brief: login.lua

 * @author:	  kun si
 * @date:	2016-12-23
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
require "skynet.manager"
local socket = require "socket"

local CMD = {}
local REQUEST = {}
local host = sprotoloader.load(1):host "package"
local send_request = host:attach(sprotoloader.load(2))

function REQUEST:auth()
	skynet.sleep(20 * 100)
	return { info = "test" }
end

local function handlerMsg(type, name ,args, respone)
	local f = assert(REQUEST[name])
	if type == "REQUEST" then
		if respone then
			local ret = respone(f(args))
			return ret
		end
	end	
end
function CMD.clientMsg(fd, msg, sz)

	local ret = handlerMsg(host:dispatch(msg, sz))
	
	return ret 
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		printI("session[%d]  source[%d]", session, source)
		skynet.retpack(f(...))
	end)

	skynet.register(".login")
end)