---------------------------------------------------------------------------
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then
    outputDebugString('imcore-teleport: запустите [lib]imcore первым', 1)
    return
end

local ok, err = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then
    outputDebugString(string.format('imcore-teleport: не удалось загрузить imgui: %s', tostring(err)), 1)
    return
end

---------------------------------------------------------------------------
local state = {
    show = true,
    spot = 1,
}

addCommandHandler('tp', function()
    state.show = not state.show
    showCursor(state.show, false)
end)

addEventHandler('onClientRender', root, function()
    if not state.show then return end

    ImGui.NewFrame()

    ImGui.SetNextWindowSize(400, 440)
    if ImGui.Begin('Spawn Manager (imcore)') then
        ImGui.SetWindowFontScale(0.95)

        ImGui.Text('Choose a teleport spot:')

        ImGui.Spacing()

        ImGui.PushItemWidth(300)
        local names = {}
        for _, s in ipairs(TELEPORT_SPOTS) do
            names[#names + 1] = s.name
        end
        local sel, selIdx = ImGui.ListBox('Spots', state.spot, names)
        if sel then state.spot = selIdx end
        ImGui.PopItemWidth()

        ImGui.Spacing()
        local spot = TELEPORT_SPOTS[state.spot]
        if spot then
            ImGui.Text('X: %.1f  Y: %.1f  Z: %.1f', spot.x, spot.y, spot.z)
        end

        ImGui.Spacing()

        if ImGui.Button('Teleport', { 140, 40 }) then
            if state.spot then
                triggerServerEvent('imcoreTeleportGo', localPlayer, state.spot)
            end
        end
        ImGui.SameLine(8)
        if ImGui.Button('Close', { 140, 40 }) then
            state.show = false
            showCursor(false, false)
        end

        ImGui.Separator()
        ImGui.Text('Server command: /tp')
    end
    ImGui.End()

    ImGui.Render()
end, false, 'low-1000')

addEventHandler('onClientResourceStart', resourceRoot, function()
    showCursor(true, false)
end)