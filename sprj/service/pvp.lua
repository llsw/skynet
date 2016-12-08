local skynet = require "skynet"
require "skynet.manager"
local coroutine = require "skynet.coroutine"

local CMD = {}
local queue = {}
local exist_queue = {}

local co 
local roomnum = 0;
local mannumber = 0;
local room = {}

function CMD.add(fd)
 	
 	if exist_queue[fd] ==  nil then
 		table.insert(queue, fd)
 		exist_queue[fd] = fd
 		--print(coroutine.status(co))
 		skynet.error("queuen", #queue)
 		if #queue >= 3 then
 			coroutine.resume(co)
 			--skynet.wakeup(co)
 		end
 		--print(coroutine.status(co))
 		-- if #queue > 10 then
 		-- 	skynet.send(service,"debug","GC") 
 		-- end

 		return 0
 	else 
 		return 1
 	end
end

function remove()
	if #queue >= 3 then
		for i=1, 3 do
			local fd = queue[1]
			skynet.error("remove fd", fd)
			--skynet.error("test")
			table.remove(queue, 1)
			exist_queue[fd] = nil
		end
		roomnum = roomnum + 1
	end
	skynet.error("room number", roomnum)
end

function beigin()
	while true do
		--skynet.wait(co)
		remove()
		coroutine.yield(co)
		
	end
end

function CMD.start()
	--co = skynet.fork(beigin)
	co = coroutine.create(beigin)
	--coroutine.resume(co)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
	local game_room = skynet.newservice("room")
	skynet.call(game_room, "lua", "start", conf)

end)