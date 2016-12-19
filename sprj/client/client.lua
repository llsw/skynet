


package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;sprj/protocol/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"

local REQUEST = {}

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8889))
local connect_room_fd 

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local session = 0

local function send_request(name, args)
	session = session + 1
	local str = request(name, args, session)
	send_package(fd, str)
	--print("Request:", session)
end

local last = ""

local function print_request(name, args)
	print("request", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("\nsession", session, "respone:")
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
end

local function handler_package(t, ...)
	if t == "REQUEST" then

		local ok, result  = pcall(request, ...)

		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function dispatch_package()
	while true do
		local v 
		v, last = recv_package(last)
		if not v then
			break
		end
		handler_package(host:dispatch(v))	
	end
end

function REQUEST:connect_room()
	local address = self.address
	local port = self.port
	local room_name = self.room_name
	print("room_name:", room_name)
	print("room address:", address)
	print("room port:", port)
	connect_room_fd = assert(socket.connect(address, port))
	
	fd = connect_room_fd
end

function REQUEST:s2cinfo()
	local info = self.info
	print(info)
end


function login(username, password)
	
	send_request("login", { username = username, password = password })
end


-- local username = io.read()
-- print(username)

-- print("用户名:")
-- local username = socket.readstdin()
-- while(not username) do
-- 	username = socket.readstdin()
-- 	socket.usleep(100)
-- end

-- print("密码:")
-- local password = socket.readstdin()
-- while(not password) do
-- 	password = socket.readstdin()
-- 	socket.usleep(100)
-- end
-- login(username, password)

local tt = {
	{number = 1, color="黑桃"},
	{number = 1, color="红桃"}
}

send_request("transfer_table",{tt=tt, tti={5,6,7,8}})

send_request("pvp")
-- print(string.format("client msg fd[%d]", fd))

while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			send_request("quit")
		else
			send_request(cmd)
		end
	else
		socket.usleep(100)
	end
end

while true do
	socket.usleep(700)
end