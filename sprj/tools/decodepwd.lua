package.cpath = "luaclib/?.so" 
package.path = "lualib/?.lua" 
local crypt = require "crypt"

local password
local who

print("please input who:")

who = io.read()

print("please input decode password:")

password = io.read()

password = crypt.base64decode(password)
password = crypt.aesdecode(password, who,"")



print(string.format("password is decoded:%s", password))
