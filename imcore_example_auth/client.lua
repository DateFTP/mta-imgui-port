---------------------------------------------------------------------------
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then
    outputDebugString('imcore-auth: запустите [lib]imcore первым', 1)
    return
end

local ok, err = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then
    outputDebugString(string.format('imcore-auth: не удалось загрузить imgui: %s', tostring(err)), 1)
    return
end

---------------------------------------------------------------------------
local state = {
    show = false,
    login = '',
    pass = '',
    mode = 'login',
}

addCommandHandler('auth', function()
    state.show = not state.show
    showCursor(state.show, false)
end)

addEventHandler('onClientRender', root, function()
    if not state.show then return end

    ImGui.NewFrame()

    ImGui.SetNextWindowSize(380, 440)
    if ImGui.Begin('Авторизация (imcore)') then
        local acc = localPlayer:getAccount()

        if not isGuestAccount(acc) then
            ImGui.Text('Вы вошли: %s', tostring(getAccountName(acc)))
            ImGui.Spacing()
            if ImGui.Button('Выйти (логаут)', { 200, 40 }) then
                localPlayer:logOut()
            end
            ImGui.Spacing()
            if ImGui.Button('Закрыть', { 200, 40 }) then
                state.show = false
                showCursor(false, false)
            end
        else
            ImGui.Text('Режим: ' .. (state.mode == 'login' and 'Вход' or 'Регистрация'))

            ImGui.Spacing()
            ImGui.Text('Логин:')
            local la, lav = ImGui.InputText('Логин', state.login, 30)
            if la then state.login = lav end

            ImGui.Spacing()
            ImGui.Text('Пароль:')
            local pa, pav = ImGui.InputText('Пароль', state.pass, 30)
            if pa then state.pass = pav end

            ImGui.Spacing()

            if ImGui.Button(state.mode == 'login' and 'Войти' or 'Создать аккаунт', { 200, 40 }) then
                if #state.login < 3 or #state.pass < 3 then
                    outputChatBox('#ff6666Логин и пароль: минимум 3 символа.', 255, 255, 255, true)
                else
                    if state.mode == 'login' then
                        triggerServerEvent('imcoreAuthLogin', localPlayer, state.login, state.pass)
                    else
                        triggerServerEvent('imcoreAuthRegister', localPlayer, state.login, state.pass)
                    end
                end
            end

            ImGui.Spacing()

            if ImGui.Button('Сменить режим', { 200, 40 }) then
                state.mode = state.mode == 'login' and 'register' or 'login'
            end

            ImGui.Separator()
            ImGui.Text('Команды сервера: /auth')
        end
    end
    ImGui.End()

    ImGui.Render()
end, false, 'low-1000')