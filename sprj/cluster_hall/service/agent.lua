
--[[
 * @brief: agent.lua

 * @author:	  kun si
 * @date:	2016-12-29
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
require "skynet.manager"
local cluster = require "cluster"

local CMD = {}
local REQUEST = {}
local host = sprotoloader.load(1):host "package"
local send_request = host:attach(sprotoloader.load(2))

function REQUEST:hall_in()
	local username = self.username
	local sql = string.format("select nickname, level from user where username='%s'", username)
	local res = mysql_query(sql)

	return {nickname = res[1].nickname, level=res[1].level}
end

local function handlerMsg(fd, type, name, args, respone)
	local f = assert(REQUEST[name])
	args.fd = fd 
	if type == "REQUEST" then
		if respone then
			local ret = respone(f(args))
			return ret
		end
	end	
end

function CMD.clientMsg(fd, msg, sz)
	local ret = handlerMsg(fd, host:dispatch(msg, sz))
	
	return ret 
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		--printI("session[%d]  source[%d]", session, source)
		skynet.retpack(f(...))
	end)
end)