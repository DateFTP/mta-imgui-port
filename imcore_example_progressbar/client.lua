---------------------------------------------------------------------------
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then
    outputDebugString('imcore-progressbar: запустите [lib]imcore первым', 1)
    return
end

local ok, err = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then
    outputDebugString(string.format('imcore-progressbar: не удалось загрузить imgui: %s', tostring(err)), 1)
    return
end

---------------------------------------------------------------------------
local state = {
    show = true,
}

addCommandHandler('progress', function()
    state.show = not state.show
    showCursor(state.show, false)
end)

local function bar(frac, label, fillColor)
    ImGui.PushStyleColor('ColProgressFill', fillColor)
    ImGui.ProgressBar(frac, label)
    ImGui.PopStyleColor('ColProgressFill')
end

addEventHandler('onClientRender', root, function()
    if not state.show then return end

    local t = (getTickCount() % 5000) / 5000

    ImGui.NewFrame()

    ImGui.SetNextWindowSize(360, 480)
    if ImGui.Begin('Прогресс-бары (imcore)') then
        ImGui.SetWindowFontScale(0.9)

        ImGui.Text('Демо прогресс-баров (%d fps работает в RT)', 0)

        ImGui.Spacing()

        bar(t, 'Загрузка привода', { 50, 220, 90, 255 })
        ImGui.Spacing()
        bar((t * 3) % 1, 'Хитпоинт', { 200, 60, 60, 255 })
        ImGui.Spacing()
        bar(((t + 0.33) % 1), 'Броня', { 60, 130, 220, 255 })
        ImGui.Spacing()
        bar(((t + 0.66) % 1), 'Топливо', { 230, 180, 50, 255 })
        ImGui.Spacing()

        local fixed = math.min(math.abs(math.sin(getTickCount() / 800)) * 0.95 + 0.05, 1)
        ImGui.ProgressBar(math.floor(fixed * 100) / 100, 'Статичный счётчик')

        ImGui.Separator()
        ImGui.Text('Ядро стрелки: number внутри, scale через SetWindowFontScale.')

        ImGui.Spacing()
        if ImGui.Button('Переключить курсор') then
            showCursor(not isCursorShowing(), false)
        end
    end
    ImGui.End()

    ImGui.Render()
end, false, 'low-1000')

addEventHandler('onClientResourceStart', resourceRoot, function()
    showCursor(true, false)
end)