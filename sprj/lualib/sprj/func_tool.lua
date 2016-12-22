
--[[
 * @brief: func_tool.lua

 * @author:	  kun si
 * @date:	2016-12-22
--]]

local tool = {}

function tool.wordToInt(str)
	return str:byte(1) * 256 + str:byte(2)
end
function tool.intToWord(num)
	local wordH = string.char(math.floor(num / 256))
	local wordL = string.char(num % 256)
	return wordH .. wordL	
end

return tool