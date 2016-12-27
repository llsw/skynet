
--[[
 * @brief: gateway.lua

 * @author:	  kun si
 * @date:	2016-12-22
--]]

local skynet = require "skynet"
local netpack = require "netpack"
local cluster = require "cluster"
local socketdriver = require "socketdriver"
local gateserver = require "snax.gateserver"
local cluster_code = require "sprj.cluster_code"
local sprotoloader = require "sprotoloader"
local tool = require "sprj.func_tool"

local handler = {}
local connection = {}

local host = sprotoloader.load(1):host "package"
local send_request = host:attach(sprotoloader.load(2))
local session = 0

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socketdriver.send(fd, package)
end

local function getClusterName(code)
	assert(cluster_code[code])
	return cluster_code[code]
end


local function forword(code, fd, msg, sz)
	local cluster_name = getClusterName(code)
	if code == 2 then
		
		printI("Forword cluster_name[%s] fd[%d]", cluster_name, fd)
		local proxy = cluster.proxy(cluster_name, cluster_code[cluster_name].SERVICE)
		local ret = skynet.call(proxy, "lua", "clientMsg", fd, msg, sz)
		send_package(fd, ret)
	else
		if not connection[fd].auth then
			
		else
	 		printI("Forword cluster_name[%s] fd[%d]", cluster_name, fd)
	 		local proxy = cluster.proxy(cluster_name, cluster_code[cluster_name].SERVICE)
	 		local ret = skynet.call(proxy, "lua", "clientMsg", fd, msg, sz)
	 		send_package(fd, ret)
	 	end
	end
	
end
function handler.open(source, conf)
	printI("Gateway open source[%d]", source)
end

function handler.message(fd, msg, sz)
		msg = netpack.tostring(msg, sz)
		local code = tool.wordToInt(string.sub(msg, 1, 2))
		local cut_msg = string.sub(msg, 3, sz)
		local cut_sz = sz - 2
		forword(code, fd, cut_msg, cut_sz)
		
end

function handler.connect(fd, addr)
	gateserver.openclient(fd)
	session = session + 1
	connection[fd] = {
		auth = false,
		session = session,
		loginCluster = nil,
		loginServer = nil,
		subuid = nil,
	}
	printI("Client fd[%d] connect gateway", fd)
end

function handler.disconnect(fd)
	gateserver.closeclient(fd)
	if connection[fd] then
		connection[fd] = nil
		printI("Client fd[%d] disconnect gateway", fd)
	end
end

function handler.error(fd, msg)
	printE("Gateway error fd[%d] msg[%s]", fd, msg)
end

function handler.warning(fd, size)
	printE("Gateway warning fd[%d] size[%s]", fd, size)	
end

local CMD = {}
function CMD.logined(client)
	connection[client.fd].auth = true
	connection[client.fd].loginCluster = client.cluster
	connection[client.fd].loginServer = client.server
	connection[client.fd].subuid = client.subuid
end
	

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(...)
end

gateserver.start(handler)
