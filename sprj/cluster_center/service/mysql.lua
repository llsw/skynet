local skynet = require "skynet"
local mysql = require "mysql"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local CMD = {}
local db

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

function CMD.login(conf)
	skynet.error("username",conf.username)
	skynet.error("password",conf.password)

	local res = db:query("select * from user where username=\'" .. conf.username 
				.. "\' and password=\'" .. conf.password .. "\'")

	
	--print(type(res),#res)
	--local rt = dump(res)
	--print(type(rt));

	if #res > 0 then
		return "success"
	else
		return "fail"
	end
end


function dbconnet()
	local function set_charset(db)
		db:query("set charset utf8")
	end

	db = mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="skynet",
		user="interface",
		password="627795061",
		max_packet_size = 1024 * 1024,
		on_connect = set_charset
	})
end



skynet.start(function()
	dbconnet()
	if not db then
		skynet.error("failed to connect")
	else
		skynet.error("success to connect to mysql server\n")
	end
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)