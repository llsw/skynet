package.cpath = "luaclib/?.so" 
package.path = "lualib/?.lua" 
local crypt = require "crypt"

local password
local who

print("please input who:")

who = io.read()

print("please input password:")

password = io.read()

password = crypt.aesencode(password, who,"")
password=crypt.base64encode(password)


print(string.format("password is encoded:%s", password))
