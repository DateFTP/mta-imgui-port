---------------------------------------------------------------------------
addEvent('imcoreTeleportGo', true)

local function sendMsg(player, text)
    if isElement(player) then
        outputChatBox(text, player, 255, 255, 255, true)
    end
end

addEventHandler('imcoreTeleportGo', root, function(index)
    local player = client
    if not isElement(player) then return end

    index = tonumber(index)
    local spot = TELEPORT_SPOTS and TELEPORT_SPOTS[index]
    if not spot then
        sendMsg(player, '#ff6666Teleport spot not found.')
        return
    end

    local dimension = spot.dim or 0
    local interior = spot.int or 0

    if getElementType(player) == 'player' then
        if getPedOccupiedVehicle(player) then
            setElementPosition(getPedOccupiedVehicle(player), spot.x, spot.y, spot.z)
            setElementInterior(getPedOccupiedVehicle(player), interior)
            setElementDimension(getPedOccupiedVehicle(player), dimension)
        else
            setElementPosition(player, spot.x, spot.y, spot.z)
        end
        setElementInterior(player, interior)
        setElementDimension(player, dimension)
    end

    setCameraMatrix(player, spot.x, spot.y, spot.z + 2, spot.x, spot.y, spot.z)

    sendMsg(player, '#66ff66Teleported to: ' .. tostring(spot.name))
end)