---------------------------------------------------------------------------
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then
    outputDebugString('imcore-multi: запустите [lib]imcore первым', 1)
    return
end

local ok, err = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then
    outputDebugString(string.format('imcore-multi: не удалось загрузить imgui: %s', tostring(err)), 1)
    return
end

---------------------------------------------------------------------------
local state = {
    show = true,
    stats = true,
    settings = true,
    logs = true,
    about = true,
    slider = 0.5,
    text = 'Привет, мульти-окна!',
}

addCommandHandler('multi', function()
    state.show = not state.show
    showCursor(state.show, false)
end)

local function windowCloseBtn(flagName)
    if ImGui.Button('Свернуть (collapse)', { 180, 32 }) then
        state[flagName] = false
    end
end

addEventHandler('onClientRender', root, function()
    if not state.show then return end

    ImGui.NewFrame()

    ImGui.SetNextWindowSize(420, 560)
    if ImGui.Begin('Dashboard (контроль)') then
        ImGui.Text('Открывай/закрывай окна:')

        ImGui.Spacing()
        if ImGui.Button('Stats: ' .. tostring(state.stats), { 200, 36 }) then state.stats = not state.stats end
        if ImGui.Button('Settings: ' .. tostring(state.settings), { 200, 36 }) then state.settings = not state.settings end
        if ImGui.Button('Logs: ' .. tostring(state.logs), { 200, 36 }) then state.logs = not state.logs end
        if ImGui.Button('About: ' .. tostring(state.about), { 200, 36 }) then state.about = not state.about end

        ImGui.Separator()
        ImGui.Text('Тяни окна за тайтл — они поверх всех.')
    end
    ImGui.End()

    if state.stats then
        if ImGui.Begin('Stats') then
            ImGui.Text('FPS: %.1f', 60 - (getTickCount() % 60))
            ImGui.ProgressBar(0.42)
            ImGui.Separator()
            windowCloseBtn('stats')
        end
        ImGui.End()
    end

    if state.settings then
        if ImGui.Begin('Settings') then
            local ch, v = ImGui.Checkbox('Звук', true)
            local sl, sv = ImGui.SliderFloat('Громкость', state.slider, 0, 1)
            if sl then state.slider = sv end
            local inp, ins = ImGui.InputText('Имя игрока', state.text, 24)
            if inp then state.text = ins end
            ImGui.Separator()
            windowCloseBtn('settings')
        end
        ImGui.End()
    end

    if state.logs then
        if ImGui.Begin('Logs') then
            ImGui.Text('[%s] client started', os.date('%H:%M:%S'))
            ImGui.Text('[%s] multi-window demo', os.date('%H:%M:%S'))
            ImGui.Separator()
            windowCloseBtn('logs')
        end
        ImGui.End()
    end

    if state.about then
        if ImGui.Begin('About') then
            ImGui.Text('Мульти-оконный пример imcore.')
            ImGui.Text('Колесо мыши скроллит только окно под курсором.')
            ImGui.Separator()
            windowCloseBtn('about')
        end
        ImGui.End()
    end

    ImGui.Render()
end, false, 'low-1000')

addEventHandler('onClientResourceStart', resourceRoot, function()
    showCursor(true, false)
end)