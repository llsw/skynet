local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd
local mysqlservice = {}

local gate

function REQUEST:get()
	print("get", self.what)
	local r = "internal test"
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet" }
end

function REQUEST:quit()
	skynet.call(gate, "lua", "kick", fd)
end
function REQUEST:login()
	--skynet.error(self.username, self.password)
	local r = skynet.call(mysqlservice[client_fd], "lua", "login", 
		{ username=self.username, password=self.password})
	if r=="success" then
		return { result = "登录成功!", error=0 }
	else
		return { result = "登录失败!", error=1 }
	end
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then

			skynet.error("agent receive a requst msg")
			skynet.error("agent start handler this msg")
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
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


function CMD.start(conf)
	local fd = conf.client
	gate = conf.gate
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	client_fd = fd
	skynet.error("a sagent start")
	skynet.error("\n")
	skynet.call(gate, "lua", "forward", fd)
	skynet.error("mysql database service start")
	mysqlservice[fd] = skynet.newservice("smysql")
	
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)