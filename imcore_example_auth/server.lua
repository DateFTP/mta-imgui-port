---------------------------------------------------------------------------
local function sendMsg(player, color, text)
    outputChatBox(color .. text, player, 255, 255, 255, true)
end

---------------------------------------------------------------------------
addEvent('imcoreAuthRegister', true)
addEventHandler('imcoreAuthRegister', root, function(accountName, password)
    local player = client
    if not isElement(player) then return end

    if not isGuestAccount(getPlayerAccount(player)) then
        sendMsg(player, '#ff6666', 'Вы уже вошли в аккаунт.')
        return
    end

    if type(accountName) ~= 'string' or type(password) ~= 'string' then return end
    if #accountName < 3 or #password < 3 then
        sendMsg(player, '#ff6666', 'Логин и пароль: минимум 3 символа.')
        return
    end

    if getAccount(accountName) then
        sendMsg(player, '#ff6666', 'Такой аккаунт уже существует.')
        return
    end

    local account = addAccount(accountName, password)
    if not account then
        sendMsg(player, '#ff6666', 'Не удалось создать аккаунт (ошибка сервера).')
        return
    end

    if not logIn(player, account, password) then
        sendMsg(player, '#ff6666', 'Аккаунт создан, но войти не вышло.')
        return
    end

    sendMsg(player, '#66ff66', 'Аккаунт создан и вход выполнен: ' .. accountName)
end)

---------------------------------------------------------------------------
addEvent('imcoreAuthLogin', true)
addEventHandler('imcoreAuthLogin', root, function(accountName, password)
    local player = client
    if not isElement(player) then return end

    if not isGuestAccount(getPlayerAccount(player)) then
        sendMsg(player, '#ff6666', 'Вы уже вошли в аккаунт.')
        return
    end

    if type(accountName) ~= 'string' or type(password) ~= 'string' then return end

    local account = getAccount(accountName, password)
    if not account then
        sendMsg(player, '#ff6666', 'Неверный логин или пароль.')
        return
    end

    if not logIn(player, account, password) then
        sendMsg(player, '#ff6666', 'Не удалось войти.')
        return
    end

    sendMsg(player, '#66ff66', 'Добро пожаловать: ' .. accountName)
end)

---------------------------------------------------------------------------
addEventHandler('onPlayerLogin', root, function(_, account)
    outputChatBox('#66ff66' .. getPlayerName(source) .. ' вошёл в аккаунт ' .. tostring(getAccountName(account)), source, 255, 255, 255, true)
end)