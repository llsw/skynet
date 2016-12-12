local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local host
local send_request
local CMD = {}


local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)

end

function CMD.start(room_number)
	skynet.register("room_agent_" .. room_number)
end

function CMD.send_request(fd, cmd, msg)
	skynet.error(string.format("send request to client[%d] cmd[%s]", fd, cmd))
	send_package(fd, send_request(cmd, msg))
end


host = sprotoloader.load(1):host "package"
send_request = host:attach(sprotoloader.load(2))

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
end)