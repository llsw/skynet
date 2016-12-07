local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 60

skynet.start(function ()
	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")

	skynet.error("Login server start")
	LOG_INFO("Login server start")
	
	skynet.uniqueservice("protoloader")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console",8000)

	local sgate = skynet.newservice("sgate")
	skynet.call(sgate, "lua", "open", {
			port = 8889,
			maxclient = max_client,
			nodelay = true,
		})
	skynet.error("SGate listen on", 8889)
	skynet.error("sgate", sgate)

 	local redispool = skynet.uniqueservice("redispool")
  	skynet.call(redispool, "lua", "start")

  	local mysqlpool = skynet.uniqueservice("mysqlpool")
  	skynet.call(mysqlpool, "lua", "start")

  	skynet.error([[*━━━━━━神兽出没━━━━━━]])
 	skynet.error([[* 　　 ┏┓　 ┏┓]])
 	skynet.error([[* 　　┏┛┻━━━┛┻┓]])
 	skynet.error([[* 　　┃　　　 ┃]])
 	skynet.error([[* 　　┃　 ━   ┃]])
 	skynet.error([[* 　　┃ ┳┛ ┗┳ ┃]])
 	skynet.error([[* 　　┃　　　 ┃]])
 	skynet.error([[* 　　┃　 ┻ 　┃]])
 	skynet.error([[* 　　┃　　　 ┃]])
 	skynet.error([[* 　　┗━┓　 ┏━┛]])
 	skynet.error([[* 　　　┃　 ┃神兽保佑]])
 	skynet.error([[* 　　　┃　 ┃代码无BUG！]])
 	skynet.error([[* 　　　┃　 ┗━━━┓]])
 	skynet.error([[* 　　　┃　　　 ┣┓]])
 	skynet.error([[* 　　　┃　　　 ┏┛]])
 	skynet.error([[* 　　　┗┓┓┏━┳┓┏┛]])
 	skynet.error([[* 　　　 ┃┫┫ ┃┫┫]])
 	skynet.error([[* 　　 　┗┻┛ ┗┻┛]])
 	skynet.error([[* ━━━━━━神兽出没━━━━━━]])

	
 	-- local res = mysql_query("select * from account")
 	-- skynet.error("type of res:", type(res))
 	-- for k, row in pairs(res) do
 	-- 	skynet.error("key:", k)
 	-- 	skynet.error("row.id:", row.id, "row.uid", row.uid)
 	-- end
	skynet.exit()

end
)

  	
