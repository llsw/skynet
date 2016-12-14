package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;sprj/protocol/?.lua"

local crypt = require "crypt"

local password=crypt.base64decode("LOz2ElA5FzmskqtfnNxmKANgEiXoPMftWzAwdQmtH6A=")
print("decode password 1st", password)
password = crypt.aesdecode(password,"lk20-15Zp","")

print("decode password 2nd", password)