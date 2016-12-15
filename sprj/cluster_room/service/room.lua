local skynet = require "skynet"
local netpack = require "netpack"
--local socketdriver = require "socketdriver"
local gateserver = require "snax.gateserver"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
require "skynet.manager"

local connection = {}
local CMD = {}
local handler = {}
local fd_queue = {}
local room_address
local room_port

local room_number

local agent
-- local host
-- local send_request

-- local function send_package(fd, pack)
-- 	local package = string.pack(">s2", pack)
-- 	socketdriver.send(fd, package)
-- end

skynet.register_protocol {
	name = "room_msg",
	id = 13,

}

function handler.open(source,conf)
	room_address = conf.address
	room_port = conf.port
	room_number = conf.number
	local service_name = "room_" .. room_number
	skynet.register(service_name)
	skynet.error("room service name is %s", service_name)
	-- host = sprotoloader.load(1):host "package"
	-- send_request = host:attach(sprotoloader.load(2))
	agent = skynet.newservice("agent")
	skynet.call(agent, "lua", "start", room_number)
	return "start"
end

function handler.message(fd, msg, sz)
	skynet.error(string.format("msg fd[%d]", fd))
	skynet.redirect(agent, 1, "room_msg", fd, msg, sz)
end

function handler.connect(fd, addr)

	gateserver.openclient(fd)
	connection[fd] = fd
	skynet.call(agent, "lua", "add_team", fd)
	skynet.error(string.format("Client[%d] come in", fd))
	local cmd = "s2cinfo"
	local msg = {info = string.format("Welcome to game room[%d]", room_number)}
	skynet.call(agent, "lua", "send_request", fd, cmd, msg)	
	--send_package(fd, send_request(cmd, msg))

end

function handler.disconnect(fd)
	connection[fd] = nil
	skynet.error(string.format("Client fd[%d] disconnect", fd))
	skynet.call(agent, "lua", "exit_team", fd)
end

function handler.error(fd, msg)
	
end

function handler.warning(fd, size)
	
end

function CMD.kick(source, fd)
	gateserver.closeclient(fd)
end

function CMD.getRoomAddress()
	return room_address
end
function CMD.getRoomPort()
	return room_port
end

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end


gateserver.start(handler)