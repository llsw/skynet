local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
require "skynet.manager"

local CMD = {}

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(".login")
end)