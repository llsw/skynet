local skynet = require "skynet"
require "skynet.manager"
local coroutine = require "skynet.coroutine"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
local queue = require "skynet.queue"
local lock = queue()
local lock_stat = false
local CMD = {}
local queue = {}
local exist_queue = {}
local co 
local roomnum = 0;
local mannumber = 0;
local room = {}

local host
local send_request


local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

local function add(fd)
	if lock_stat == false then
		lock_stat = true
		if exist_queue[fd] ==  nil then
	 		table.insert(queue, fd)
	 		exist_queue[fd] = fd
	 		--print(coroutine.status(co))
	 		print("queuen", #queue)
	 		if #queue >= 3 then
	 			--coroutine.resume(co)
	 			skynet.wakeup(co)
	 		end
	 		--print(coroutine.status(co))
	 		-- if #queue > 10 then
	 		-- 	skynet.send(service,"debug","GC") 
	 		-- end
	 		lock_stat = false
	 		return 0
	 	else 
	 		lock_stat = false
	 		return 1
	 	end
	 else
	 	lock_stat = false
	 	return 1
	 end

end

function CMD.add(fd)
 	
 	local result = lock(add, fd)
 	skynet.error("Add room result", result)
 	return result
end

function remove()
	local team = {}
	if #queue >= 3 then
		for i=1, 3 do
			local fd = queue[1]
			skynet.error("remove fd", fd)
			--skynet.error("test")
			table.remove(queue, 1)
			exist_queue[fd] = nil
			table.insert(team, fd)
		end
		local room_main = cluster.proxy("cluster_room", "room_main")
		--local proxy_address = cluster.query("cluster_room", "room_main")
		--skynet.error(string.format("node[%s] server[%s] address[%s]", 
		--	"cluster_room", "room_main", proxy_address))
		local room_name = skynet.call(room_main, "lua", "getRoom")
		skynet.error("roommain ok ", ok)
		
		if room_name ~= "0" then
			local room_service = cluster.proxy("cluster_room", room_name)
			local address = skynet.call(room_service, "lua", "getRoomAddress")
			local port = tonumber(skynet.call(room_service, "lua", "getRoomPort"))
			--local number = room_info.number
			local conf = { room_name = room_name, address = address, port = port }
			--local conf = room_name .. ";" .. address .. ";" .. port
			for i=1, #team do
				send_package(team[i], send_request("connect_room", conf))
			end
		else
			skynet.error("get room fail")
		end
		roomnum = roomnum + 1
	end
	skynet.error("room number", roomnum)

end

function beigin()
	while true do
		
		skynet.wait(co)
		remove()
		--coroutine.yield(co)
		
	end
end


function CMD.start()
	co = skynet.fork(beigin)
	
	--co = coroutine.create(beigin)
	--coroutine.resume(co)
end

host = sprotoloader.load(1):host "package"
send_request = host:attach(sprotoloader.load(2))

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register("pvp")
	--local game_room = skynet.newservice("room")
	--skynet.call(game_room, "lua", "start", conf)

end)