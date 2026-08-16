function getResName2(rnames)
	return getResourceName(rnames)
end

function getResName(res)
    if not res then return nil end
    if type(res) == "string" then
        res = getResourceFromName(res)
    end
    if not res or type(res) ~= "userdata" then
        outputDebugString("[CORE][GET-ResName] Invalid resource", 2)
        return nil
    end
    return getResourceName(res)
end

function getTimeDifference(date)

	local ts = getRealTime().timestamp - date.timestamp
	date.timestamp = nil
	date.hour = date.hour + 1
	date.day = date.monthday

	local os_time = os.time(date)
	return ts, os_time
end

addEvent('timestamp.getFromServer', true)
addEventHandler('timestamp.getFromServer', resourceRoot, function(date)
	triggerClientEvent(client, 'timestamp.receiveFromServer', client, getTimeDifference(date))
end)