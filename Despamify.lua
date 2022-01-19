local hooks = {}
local lastlines = {} 

local function AddMessage(self, message, ...)

	--message includes what appears to be a timestamp 
	--in the form of seconds since login, substitute it out to compare
	tmp = string.gsub(message,":[0-9]+:","xxx")

	if(lastlines[self] ~= tmp) then
		lastlines[self] = tmp
		return hooks[self](self, message, ...)
	end
	
	return ""
end
 
for index = 1, NUM_CHAT_WINDOWS do
	if(index ~= 2) then
		local frame = _G['ChatFrame'..index]
		hooks[frame] = frame.AddMessage
		lastlines[frame] = ""
		frame.AddMessage = AddMessage
	end
end