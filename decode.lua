package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua"
local crypt = require "crypt"

password = crypt.aesencode("123456", "interface", "")
print(password)

password = crypt.base64encode(password)
print(password)

password=crypt.base64decode(password)
print("decode password 1st", password)
password = crypt.aesdecode(password,"interface","")

print("decode password 2nd", password)