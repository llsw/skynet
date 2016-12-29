
--[[
 * @brief: game.lua

 * @author:	  kun si
 * @date:	2016-12-29
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"

local CMD = {}
local REQUEST = {}
local host = sprotoloader.load(1):host "package"
local send_request = host:attach(sprotoloader.load(2))
local service_config = require "sprj.service_config"
local queue = require "skynet.queue"
local lock = queue()
queue = require "sprj.queue"
local maxRoomNum = service_config["game_room_config"].maxRoomNum
local room_pool = queue.new(maxRoomNum)

local function handlerMsg(fd, type, name, args, respone)
	local f = assert(REQUEST[name])
	args.fd = fd 
	if type == "REQUEST" then
		if respone then
			local ret = respone(f(args))
			return ret
		end
	end	
end

function CMD.clientMsg(fd, msg, sz)
	local ret = handlerMsg(fd, host:dispatch(msg, sz))
	
	return ret 
end



skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
	
	for i = 1, maxRoomNum do
		local room = skynet.newservice("room")
		queue.push(room_pool, room)
		skynet.name(".room" .. i , room)
	end

	skynet.register(".game")
end)