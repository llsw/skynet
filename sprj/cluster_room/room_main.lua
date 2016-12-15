local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"


local pool = {}
local CMD = {}
local queue = {}


function getRoom()

	if #queue > 0 then
		skynet.error("CMD.getRoom")	

		local r = pool[queue[1]].room_name
		if not r then
			skynet.error("not room")
		end

		table.remove(queue, 1)
		return r
	else
		
		return 0
	end
end

function exitRoom(roomnumber)

	table.insert(queue, roomnumber)
	
end

function CMD.getRoom()


	return getRoom()
end

function CMD.exitRoom(roomnumber)
	exitRoom(exitRoom)
end 

skynet.start(function ()
	skynet.dispatch("lua",function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	cluster.open("cluster_room")
	--cluster.register("cluster_room")
	skynet.register("room_main")

	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console",8001)

	local maxnumber = skynet.getenv  "roommaxnumber"
	local address = skynet.getenv "roomaddress"
	local port = skynet.getenv "roomport"
	local maxclient = tonumber(skynet.getenv "roommaxclient")
	local nodelay = skynet.getenv "roomnodelay"
	

	for i=1, maxnumber do
		local room = skynet.newservice("room")
		skynet.call(room, "lua", "open", 
		{
			address = address,
		 	port = port, 
		 	maxclient = maxclient,
		 	nodelay = nodelay,
		 	number = i,
		 })
		if not room then
			skynet.error("start [room %d] fail", i)
		else 
			table.insert(pool, 
				{
					room = room,
					address = address,
					port = port,
					number = i,
					room_name = "room_" .. i,
				}
			)
			table.insert(queue,i)
			port = port +1
			skynet.error("start [room %d] success", i)
		end
	end
	
	local server_address = skynet.self()
	local server_address_name = skynet.address(server_address)
	skynet.error(string.format("address[%d] name[%s]", server_address, server_address_name))

end)

