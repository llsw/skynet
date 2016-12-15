local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local host
local send_request
local CMD = {}
local REQUEST = {}
local ready_number = 0
local team = {}
local queue = {}

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)

end

function REQUEST:ready()
	--skynet.error("Ready session", session)
	-- if not team[session] then
	-- 	ready_number = ready_number + 1
	-- 	team[session] = true
	-- 	skynet.error(string.format("Client fd[%d] ready", session))
	-- 	return {info = "Ready success", error_code = 0}
	-- end
	return {info = "You have bean ready", error_code = 1}
end

function REQUEST:cancel_ready()
	-- if team[session] then
	-- 	skynet.error(string.format("Client fd[%d] ready", session))
	-- 	ready_number = ready_number - 1
	-- 	team[session] = false
	-- 	return {info = "Cancel ready success", error_code = 0}
	-- end
	return {info = "You have not bean ready", error_code = 1}
end

function CMD.start(room_number)
	skynet.register("room_agent_" .. room_number)
end

function CMD.send_request(fd, cmd, msg)
	skynet.error(string.format("send request to client[%d] cmd[%s]", fd, cmd))
	send_package(fd, send_request(cmd, msg))
end

function CMD.add_team(fd)
	table.insert(queue, fd)
	team[fd] =  false
	skynet.error(type(team[fd]))
end

function CMD.exit_team(fd)
	for k, v in ipairs(queue) do
		if v == fd then
			table.remove(queue, k)
			break
		end
	end
	team[fd] = nil
end

local function request(session, name, args, response)
	skynet.error(string.format("session[%d] REQUEST[%s] type_args[%s]", session, name, type(args)))
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		skynet.error("There is response")
		return response(r)
	end
end


host = sprotoloader.load(1):host "package"
send_request = host:attach(sprotoloader.load(2))


skynet.register_protocol {
	name = "room_msg",
	id = 13,
	unpack = function (msg, sz)

		return host:dispatch(msg, sz)
	end,
	dispatch = function (session, _, type, ...)
		
		if type == "REQUEST" then

			skynet.error("agent receive a requst msg", ...)
			skynet.error("agent start handler this msg")
			local ok, result  = pcall(request, session, ...)
			if ok then
				if result then
					send_package(session, result)
				end
			else
				skynet.error(result)
			end
			
			skynet.error("agent end of handler this msg")

		else
			skynet.error("agent receive not a requst msg\n")
			--assert(type == "RESPONSE")
			--error "This example doesn't support request client"
		end
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
end)