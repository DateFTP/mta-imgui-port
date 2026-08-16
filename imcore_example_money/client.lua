---------------------------------------------------------------------------
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then
    outputDebugString('imcore-money: запустите [lib]imcore первым', 1)
    return
end

local ok, err = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then
    outputDebugString(string.format('imcore-money: не удалось загрузить imgui: %s', tostring(err)), 1)
    return
end

---------------------------------------------------------------------------
local state = {
    show = false,
    amount = '',
}

addCommandHandler('money', function()
    if state.show then
        state.show = false
        showCursor(false, false)
    else
        showCursor(true, false)
        state.show = true
    end
end)

local function sanitizeAmount(txt)
    local out = ''
    for i = 1, #txt do
        local ch = string.sub(txt, i, i)
        if ch:match('%d') then out = out .. ch end
    end
    return out
end

addEventHandler('onClientRender', root, function()
    if not state.show then return end

    ImGui.NewFrame()

    ImGui.SetNextWindowSize(360, 380)
    if ImGui.Begin('Выдача денег (imcore)') then
        ImGui.Text('Текущий баланс: $%d', localPlayer:getMoney())

        ImGui.Spacing()

        ImGui.Text('Сумма:')
        local a, av = ImGui.InputText('Сумма', state.amount, 9)
        if a then
            state.amount = sanitizeAmount(av)
        end

        ImGui.Spacing()

        if ImGui.Button('Выдать $' .. (state.amount ~= '' and state.amount or '0'), { 180, 40 }) then
            local amount = tonumber(state.amount) or 0
            triggerServerEvent('imcoreMoneyGive', localPlayer, math.floor(amount))
        end

        ImGui.Spacing()

        if ImGui.Button('Закрыть', { 180, 40 }) then
            state.show = false
            showCursor(false, false)
        end

        ImGui.Separator()
        ImGui.Text('Команда сервера: /money')
    end
    ImGui.End()

    ImGui.Render()
end, false, 'low-1000')