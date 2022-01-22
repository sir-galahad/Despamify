local hooks = {}
local lastlines = {} 
local toggle = 2 -- 2 = on 1 = off

local MessageClass = {}

function MessageClass:new(obj)
	setmetatable(obj,self)
	self.__index = self
end
	
local function AddMessage(self, message, ...)
	
	if(message == nil) then return "" end
	
	-- message includes what appears to be a timestamp 
	-- in the form of seconds since login, substitute it out to compare

	tmp = string.gsub(message,':[0-9]+:',"xxx")
	timestamp = string.match(message, "(:[0-9]+:)")
	MessageClass:new{message=tmp, timestamp=timestamp}
	-- if turned off do no filtering
	if(toggle == 1) then
		lastlines[self] = tmp 
		return hooks[self](self, message, ...)
	end
	
	-- don't let the same line through twice
	if(lastlines[self] ~= tmp) then
		lastlines[self] = tmp
		return hooks[self](self, message, ...)
	end

	return ""
end

-- enumerate chat frames, and buffers for the last line in each
for index = 1, NUM_CHAT_WINDOWS do
	if(index ~= 2) then
		local frame = _G['ChatFrame'..index]
		hooks[frame] = frame.AddMessage
		lastlines[frame] = ""
		frame.AddMessage = AddMessage
	end
end

-- register command to toggle whether despamify starts off or on
SLASH_DESPAM1 = "/despam"
SLASH_DESPAM2 = "/despamify"
local function despamify(msg)  

	if toggle == 1 then
		print("Despamify now on")
		toggle = 2
	else
		toggle = 1
		print("Despamify now off")
	end
end

SlashCmdList["DESPAM"] = despamify