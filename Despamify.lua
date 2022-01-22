local hooks = {}
local lastlines = {} 
local toggle = 2 -- 2 = on 1 = off
local MessageClass = {}
local timeout = 10 -- seconds to filter posts
function MessageClass:new(obj)
	setmetatable(obj,self)
	self.__index = self
	return obj
end
	
local function AddMessage(self, message, ...)
	
	if(message == nil) then return "" end
	
	-- message includes what appears to be a timestamp 
	-- in the form of seconds since login, substitute it out to compare
	local tmp = string.gsub(message,':[0-9]+:',"xxx")
	
	-- this bit with the two matches is pretty gross
	local timestamp = string.match(message, ':([0-9]+):')
	
	if ( timestamp == nil) then
		return hooks[self](self, message, ...)
	end

	msg = MessageClass:new{message=tmp, timestamp=tonumber(timestamp)}

	-- if turned off do no filtering
	if(toggle == 1) then
		lastlines[self] = tmp 
		return hooks[self](self, "("..channel..'+'..timestamp..")"..message, ...)
	end
	
	
	if(lastlines[tmp] == nil or 
			lastlines[tmp]["timestamp"] < msg["timestamp"] - timeout) then
		oldmsg = lastlines[tmp]

		local oldtimeout
		if(oldmsg ~= nil) then
			oldtimeout = lastlines[tmp]["timestamp"]
		else
			oldtimeout = "nil"
		end

		lastlines[tmp] = msg
		
		--print(lastlines[tmp].message)
		return hooks[self](self, tmp.."("..msg.timestamp.."vs"..oldtimeout..")", ...)
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