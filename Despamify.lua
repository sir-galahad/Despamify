local hooks = {}
local lastlines = {} 
local MessageClass = {}

function MessageClass:new(obj)
	setmetatable(obj,self)
	self.__index = self
	return obj
end
	
local function AddMessage(self, message, ...)
	
	if(message == nil) then return "" end
	
	-- message includes what appears to be a timestamp 
	-- in the form of seconds since login, substitute it out to compare
	local tmp = string.gsub(message,'[^i][^t][^e][^m]:[0-9]+:',"xxx",1)
	tmp = string.gsub(tmp, '%s+$', '')
	-- this bit with the two matches is pretty gross
	local timestamp = time()
	
	msg = MessageClass:new{message=tmp, timestamp=tonumber(timestamp)}

	-- if turned off do no filtering
	if(despam_toggle == 1) then
		lastlines[self] = tmp 
		return hooks[self](self, message, ...)
	end
	
	
	if(lastlines[tmp] == nil or 
		msg.timestamp - lastlines[tmp].timestamp > despam_timeout) then
		
		if(lastlines[tmp] == nil) then
			oldTimestamp = "nil"
		else
			oldTimestamp = lastlines[tmp].timestamp
		end
	
		lastlines[tmp] = msg
		
		toRemove = {}
		for key, value in ipairs(lastlines) do
			if( msg.timestamp - value.timestamp > 2*despam_timeout) then
				table.insert(toRemove,key)
			end
		end

		for _,i in ipairs(toRemove) do
			lastlines[i] = nil
		end	
		
		debug = 1
		if(debug) then
			message = message .. "( " .. timestamp .. " vs ".. oldTimestamp .. " )"
		end
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

if( despam_timeout == nil ) then
	despam_timeout = 15
end
if( despam_toggle == nil) then
	despam_toggle = 2
end

-- register command to toggle whether despamify starts off or on
SLASH_DESPAM1 = "/despam"
SLASH_DESPAM2 = "/despamify"

local function despamify(msg)  

	if despam_toggle == 1 then
		print("Despamify now on")
		despam_toggle = 2
	else
		despam_toggle = 1
		print("Despamify now off")
	end
end

SlashCmdList["DESPAM"] = despamify

SLASH_DSTIMER1 = "/dstimer"

local function setDespamTimer(msg)
	if(msg ~= nil and msg ~= "") then
		despam_timeout = tonumber(msg)
	end
	print("spam timeout ", despam_timeout, "seconds")

end 
SlashCmdList["DSTIMER"] = setDespamTimer