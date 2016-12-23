
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


local function forword(cluster_name, fd, msg, sz)
	printI("Forword cluster_name[%s] fd[%d]", cluster_name, fd)
	local proxy = cluster.proxy(cluster_name, cluster_code[cluster_name].SERVICE)
	local ret = skynet.call(proxy, "lua", "clientMsg", fd, msg, sz)
	send_package(fd, ret)
	
end
function handler.open(source, conf)
	printI("Gateway open source[%d]", source)
end

function handler.message(fd, msg, sz)
		msg = netpack.tostring(msg, sz)
		local code = tool.wordToInt(string.sub(msg, 1, 2))
		local cut_msg = string.sub(msg, 3, sz)
		local cut_sz = sz - 2
		local clusterName = getClusterName(code)
		forword(clusterName, fd, cut_msg, cut_sz)
		
end

function handler.connect(fd, addr)
	gateserver.openclient(fd)
	session = session + 1
	connection[fd] = {
		auth = false,
		session = session,
		loginServerName = nil,
		uid = nil,
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
function CMD.logined(fd, loginServerName, uid)
	connection[fd]={
		auth = true,
		loginServerName = loginServerName,
		uid = uid,
	}
end
	

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)
