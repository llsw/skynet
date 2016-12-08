local skynet = require "skynet"
local netpack = require "netpack"
local socketdriver = require "socketdriver"
require "skynet.manager"

local client_number = 0
local nodelay = false
local connection = {}
local socket
local queue	
local MSG = {}

function CMD.start( source, conf )
	assert(not socket)
	local address = conf.address or "0.0.0.0"
	local port = assert(conf.port)
	maxclient = conf.maxclient or 1024
	nodelay = conf.nodelay
	socket = socketdriver.listen(address, port)
	socketdriver.start(socket)
	skynet.error(string.format("Room listen on %s:%d", address, port))
	LOG_INFO("Room listen on %s:%d", address, port)

end

function openclient(fd)
	if connection[fd] then
		socketdriver.start(fd)
		client_number = client_number + 1

		LOG_INFO("Client come in")
		skynet.error("Client come in")

	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c ~= nil then
		connection[fd] = nil
		client_number = client_number - 1
	end
end

function MSG.open(fd, msg)
	if client_number >= maxclient then
		socketdriver.close(fd)
		return
	end
	if nodelay then
		socketdriver.nodelay(fd)
	end

	connection[fd] = true

	openclient(fd)

end
function MSG.close(fd)
	if fd ~= socket then
		
		close_fd(fd)

		LOG_INFO("Client disconnect")
		skynet.error("Client disconnect")
	else
		socket = nil
	end
end

function MSG.error(fd, msg)
	if fd == socket then
		socketdriver.close(fd)
		skynet.error(msg)
	else
		
		close_fd(fd)
	end
end

function MSG.warning(fd, size)
	if handler.warning then
		handler.warning(fd, size)
	end
end




local function dispatch_msg(fd, msg, sz)
	if connection[fd] then
		--handler.message(fd, msg, sz)
	else
		skynet.error(string.format("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz)))
	end
end


MSG.data = dispatch_msg

local function dispatch_queue()
	local fd, msg, sz = netpack.pop(queue)
	if fd then	
		skynet.fork(dispatch_queue)
		dispatch_msg(fd, msg, sz)

		for fd, msg, sz in netpack.pop, queue do
			dispatch_msg(fd, msg, sz)
		end
	end
end

MSG.more = dispatch_queue


skynet.register_protocol {
	name = "socket",
	id = skynet.PTYPE_SOCKET,	-- PTYPE_SOCKET = 6
	unpack = function ( msg, sz )
		return netpack.filter( queue, msg, sz)
	end,
	dispatch = function (_, _, q, type, ...)
		queue = q
		if type then
			MSG[type](...)
		end
	end
}

skynet.start(function ()
	skynet.dispatch("lua",function(session, source, cmd, ...)
		local  f = assert(CMD[cmd], cmd .. "not found")
		f(source, ...)
	end)
	skynet.register(SREVICE_NAME)
end)