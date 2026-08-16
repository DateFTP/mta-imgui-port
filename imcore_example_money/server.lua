---------------------------------------------------------------------------
addEvent('imcoreMoneyGive', true)

function imcoreGiveMoney(amount)
    local player = client
    if not isElement(player) or type(amount) ~= 'number' then
        return
    end

    local accountName = getAccountName(getPlayerAccount(player)) or ''
    local isAdmin = accountName ~= '' and isObjectInACLGroup('user.' .. accountName, aclGetGroup('Admin'))

    if not isAdmin then
        outputChatBox('#ff6666Вы не в группе Admin — выдача денег отменена.', player, 255, 255, 255, true)
        return
    end

    amount = math.floor(amount)
    if amount < 1 or amount > 100000000 then
        outputChatBox('#ff6666Сумма должна быть от 1 до 100 000 000.', player, 255, 255, 255, true)
        return
    end

    setPlayerMoney(player, getPlayerMoney(player) + amount, false)
    outputChatBox(string.format('#66ff66Выдано +$%d. Баланс: $%d', amount, getPlayerMoney(player)), player, 255, 255, 255, true)
end
addEventHandler('imcoreMoneyGive', root, imcoreGiveMoney)