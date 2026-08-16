local textures = {
	
}

function getTexture(path)
	
	local texture = textures[path] or dxCreateTexture( string.format('assets/images/%s.png', path) )
	textures[path] = textures[path] or texture

	return textures[path]

end


serverTimeDifference = 0
function _getServerTimestamp()
	local rt = getRealTime(getRealTime().timestamp + serverTimeDifference)
	rt.server = serverTime
	return rt
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	triggerServerEvent('timestamp.getFromServer', resourceRoot, getRealTime())
end)

addEvent('timestamp.receiveFromServer', true)
addEventHandler('timestamp.receiveFromServer', root, function(difference, server_ts)
	serverTimeDifference = difference
	serverTime = server_ts
end)

-- local fontsQuality = 'antialiased'

fonts = {}

function getClientFont(path, size, weight)
	-- local fontIndex = path..size
	-- if fonts[fontIndex] and fonts[fontIndex][weight] then
	-- 	return fonts[fontIndex][weight]
	-- end

	-- local fontPath = string.format('assets/fonts/%s.ttf', path)

	-- fonts[fontIndex] = fonts[fontIndex] or {}
	-- fonts[fontIndex][weight] = dxCreateFont(fontPath, size, weight == 'bold', fontsQuality)

	-- return fonts[fontIndex][weight]

	local fontPath = string.format('assets/fonts/%s.ttf', path)

	return dxCreateFont(fontPath, size, weight == 'bold', fontsQuality)
end

function getFonts()
	return fonts
end

--[[addCommandHandler('getfontscount', function()
	local count = 0
	for _ in pairs(fonts) do
		count = count + 2
	end
	setClipboard(inspect(fonts))
	print(count, getTickCount(  ))
end)]]