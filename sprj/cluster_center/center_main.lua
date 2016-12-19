local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"

local max_client = 60


skynet.start(function ()
	cluster.open("cluster_center")
	--cluster.register("cluster_center")
	skynet.register("center_main")
	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")

	skynet.error("Cluster_center start")
	LOG_INFO("Cluster_centerstart")
	
	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.uniqueservice("database")

	local debug_port = skynet.getenv "debug_port"
	skynet.newservice("debug_console",debug_port)

	local gate = skynet.newservice("gateway")
	skynet.call(gate, "lua", "open", {
			port = 8889,
			maxclient = max_client,
			nodelay = true,
		})
	skynet.error("Gateway listen on", 8889)


  	local pvp  = skynet.uniqueservice("pvp")
  	skynet.call(pvp, "lua", "start")

 	-- skynet.error([[*━━━━━━神兽出没━━━━━━]])
 	-- skynet.error([[* 　　 ┏┓　 ┏┓]])
 	-- skynet.error([[* 　　┏┛┻━━━┛┻┓]])
 	-- skynet.error([[* 　　┃　　　 ┃]])
 	-- skynet.error([[* 　　┃　 ━   ┃]])
 	-- skynet.error([[* 　　┃ ┳┛ ┗┳ ┃]])
 	-- skynet.error([[* 　　┃　　　 ┃]])
 	-- skynet.error([[* 　　┃　 ┻ 　┃]])
 	-- skynet.error([[* 　　┃　　　 ┃]])
 	-- skynet.error([[* 　　┗━┓　 ┏━┛]])
 	-- skynet.error([[* 　　　┃　 ┃神兽保佑]])
 	-- skynet.error([[* 　　　┃　 ┃代码无BUG！]])
 	-- skynet.error([[* 　　　┃　 ┗━━━┓]])
 	-- skynet.error([[* 　　　┃　　　 ┣┓]])
 	-- skynet.error([[* 　　　┃　　　 ┏┛]])
 	-- skynet.error([[* 　　　┗┓┓┏━┳┓┏┛]])
 	-- skynet.error([[* 　　　 ┃┫┫ ┃┫┫]])
 	-- skynet.error([[* 　　 　┗┻┛ ┗┻┛]])
 	-- skynet.error([[* ━━━━━━神兽出没━━━━━━]])

	
 	local res = mysql_query("select * from account")
 	skynet.error("type of res:", type(res))
 	for k, row in pairs(res) do
 		skynet.error("key:", k)
 		skynet.error("row.id:", row.id, "row.uid", row.uid)
 	end
	skynet.exit()

end
)

  	
