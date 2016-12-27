
--[[
 * @brief: login.lua

 * @author:	  kun si
 * @date:	2016-12-23
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
require "skynet.manager"
local socket = require "socket"
local crypt = require "crypt"
local cluster = require "cluster"

local CMD = {}
local REQUEST = {}
local host = sprotoloader.load(1):host "package"
local send_request = host:attach(sprotoloader.load(2))
local userList = {}
local internal_id = 0

function REQUEST:auth()
	local step = self.step
	local username = self.username
	local handshake = self.handshake
	local fd = self.fd
	if step == 1 then
		printI("Auth step[%d]", step)
		local challenge = crypt.randomkey()
		userList[fd] = {}
		userList[fd].challenge = challenge
		return {cmd = "auth", step = step, error = 0, result = crypt.base64encode(challenge)}

	elseif step == 2 then
		printI("Auth step[%d]", step)
		local clientkey = crypt.base64decode(handshake)
		userList[fd].clientkey = clientkey
		local serverkey = crypt.randomkey()
		userList[fd].serverkey = serverkey
		return {cmd = "auth", step = step, error = 0, result = crypt.base64encode(crypt.dhexchange(serverkey))}

	elseif step == 3 then
		printI("Auth step[%d]", step)
		local secret = crypt.dhsecret(userList[fd].clientkey, userList[fd].serverkey)
		userList[fd].secret = secret
		local hmac = crypt.hmac64(userList[fd].challenge, secret)
		if hmac ~= crypt.base64decode(handshake) then
			return {cmd = "auth", step = step, step = step, error =400 , result = "400 Bad Request"}
		else
			return {cmd = "auth", step = step, error = 0, result = "Handshake success"}
		end
		

	elseif step == 4 then

		local etoken = handshake
		userList[fd].etoken = etoken
		local token = crypt.desdecode(userList[fd].secret, crypt.base64decode(etoken))
		local user, password = token:match("([^:]+):(.+)")
		user = crypt.base64decode(user)
		password = crypt.base64decode(password)
		internal_id = internal_id + 1
		local subuid = internal_id
		userList[fd].subuid = subuid
		userList[fd].password = password
		userList[fd].username = user
		userList[fd].fd = fd
		userList[fd].cluster = "cluster_login"
		userList[fd].server = skynet.self()

		local sql = string.format("select * from user where username='%s' and password='%s'", user, password)
		printI("Launch sql[%s]", sql)
		local res = mysql_query(sql)
		if #res > 0 then
			local proxy = cluster.proxy("cluster_gateway", ".gateway")
			skynet.call(proxy, "lua", "logined", userList[fd])
			return {cmd = "auth", step = step, error = 0, result = crypt.base64encode(subuid)}
		else
			return {cmd = "auth", step = step, error = 1 , result = "Username or Password error"}
		end
		

	else

		return {cmd = "auth", step = -1, error =400 , result = "400 Bad Request"}

	end
end

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

function CMD.disconnect(fd)
	userList[fd] = nil
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		--printI("session[%d]  source[%d]", session, source)
		skynet.retpack(f(...))
	end)

	skynet.register(".login")
end)