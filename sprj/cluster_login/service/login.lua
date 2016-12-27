
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

local CMD = {}
local REQUEST = {}
local host = sprotoloader.load(1):host "package"
local send_request = host:attach(sprotoloader.load(2))
local user = {}
local internal_id = 0

function REQUEST:auth()
	local step = self.step
	local username = self.username
	local handshake = self.handshake
	if step == 1 then
		printI("Auth step[%d]", step)
		local challenge = crypt.randomkey()
		user.username = {}
		user.username.challenge = challenge
		return {cmd = "auth", step = step, error = 0, result = crypt.base64encode(challenge)}

	elseif step == 2 then
		printI("Auth step[%d]", step)
		local clientkey = crypt.base64decode(handshake)
		user.username.clientkey = clientkey
		local serverkey = crypt.randomkey()
		user.username.serverkey = serverkey
		return {cmd = "auth", step = step, error = 0, result = crypt.base64encode(crypt.dhexchange(serverkey))}

	elseif step == 3 then
		printI("Auth step[%d]", step)
		local secret = crypt.dhsecret(user.username.clientkey, user.username.serverkey)
		user.username.secret = secret
		local hmac = crypt.hmac64(user.username.challenge, secret)
		if hmac ~= crypt.base64decode(handshake) then
			return {cmd = "auth", step = step, step = step, error =400 , result = "400 Bad Request"}
		else
			return {cmd = "auth", step = step, error = 0, result = "Handshake success"}
		end
		

	elseif step == 4 then

		local etoken = handshake
		user.username.etoken = etoken
		local token = crypt.desdecode(user.username.secret, crypt.base64decode(etoken))
		local user, password = token:match("([^:]+):(.+)")
		user = crypt.base64decode(user)
		password = crypt.base64decode(password)
		internal_id = internal_id + 1
		local subuid = internal_id
		user.username.subuid = subuid
		user.username.password = password

		return {cmd = "auth", step = step, error = 0, result = crypt.base64encode(subuid)}

	else

		return {cmd = "auth", step = -1, error =400 , result = "400 Bad Request"}

	end
end

local function handlerMsg(type, name ,args, respone)
	local f = assert(REQUEST[name])
	if type == "REQUEST" then
		if respone then
			local ret = respone(f(args))
			return ret
		end
	end	
end
function CMD.clientMsg(fd, msg, sz)

	local ret = handlerMsg(host:dispatch(msg, sz))
	
	return ret 
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		--printI("session[%d]  source[%d]", session, source)
		skynet.retpack(f(...))
	end)

	skynet.register(".login")
end)