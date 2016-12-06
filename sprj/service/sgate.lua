local skynet = require "skynet"
local netpack = require "netpack"
local gateserver = require "snax.gateserver"

--local proto = require "proto"


local agent = {}
local connection = {}
local forwarding = {}
local host
local send_request

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,

}
local handler = {}

local function unforward(c)
	if c.agent then
		forwarding[c.agent] = nil
		c.agent = nil
		c.client = nil
	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c then
		unforward(c)
		connection[fd] = nil
	end
end

function handler.open(source, conf)
	skynet.error("handler.open")
end

function handler.message(fd, msg, sz)
	
	local c =  connection[fd]
	local agent = c.agent
	local client = c.client


	skynet.error("Sgate receive msg, come from client", fd)
	skynet.error("Agent", c.agent, "begin handler a msg")

	if agent then
		skynet.redirect(agent, client, "client", 0, msg, sz)
	else
		skynet.error("There is not a agent to handler a msg of client",fd)
	end	
	skynet.error("Sgate end handler a msg")
	skynet.error("\n")

end

function handler.connect(fd, addr)
	skynet.error("Begin a connect")
	skynet.error("Skynet.self()",skynet.self())
	local c = {
		fd = fd,
		ip = addr,
	}
	connection[fd] = c
	skynet.error("New client from : " .. addr)
	
	agent[fd] = skynet.newservice("sagent")
	skynet.error("fd", fd, "agent", agent[fd])
	skynet.error("\n")

	skynet.call(agent[fd], "lua", "start", { gate = skynet.self(), client = fd})
	
end

function handler.disconnect(fd)
	close_fd(fd)
	skynet.error("Client disconnect!")
	skynet.error("\n")
end

function handler.error(fd, msg)
	close_fd(fd)
	skynet.error("error")
end

function handler.warning(fd, size)
	skynet.error("Warning")
	skynet.error("Begin a connect")
end

local CMD = {}

function CMD.forward(source, fd, client, address)
	skynet.error("begin a forward")

	local c = assert(connection[fd])
	unforward(c)
	c.client = client or 0
	c.agent = address or source

	skynet.error("c.fd", fd)
	skynet.error("c.client", c.client, client, 0)
	skynet.error("c.agent", c.agent, address, source)

	forwarding[c.agent] = c
	gateserver.openclient(fd)

	skynet.error("end a forward")
	skynet.error("\n")
end



function CMD.kick(source, fd)
	gateserver.closeclient(fd)
end

function handler.command(cmd, source, ...)
	--skynet.error("cmd")
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)