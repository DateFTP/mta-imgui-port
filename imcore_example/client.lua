----------------------------------------------------------------------------
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then
    outputDebugString('imcore-example: запустите [lib]imcore первым', 1)
    return
end

local ok, err = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then
    outputDebugString(string.format('imcore-example: не удалось загрузить imgui: %s', tostring(err)), 1)
    return
end

---------------------------------------------------------------------------- state
local state = {
    show = true,
    page = 1,
    clicks = 0,
    check1 = true,
    check2 = false,
    radio = 2,
    sliderA = 0.45,
    sliderB = 42,
    name = 'Warrior',
    pass = '',
    combo = 2,
    list = 1,
    bg = { 18, 20, 32 },
    fontSize = 15,
    openMain = false,
    openTabs = true,
    demo = false,
}

local pages = { 'Главная', 'Игрок', 'Транспорт', 'Магазин', 'Настройки' }
local cars = { 'Sultan', 'Infernus', 'Elegy', 'Buffalo', 'Comet' }
local weapons = { 'M4', 'AK-47', 'Deagle', 'Shotgun' }

---------------------------------------------------------------------------- commands
addCommandHandler('imgui', function()
    state.show = not state.show
    showCursor(state.show, false)
end)

---------------------------------------------------------------------------- pages
local function pageMain()
    if ImGui.Button('Нажми меня!') then
        state.clicks = state.clicks + 1
    end
    ImGui.SameLine()
    ImGui.Text('Счётчик: %d', state.clicks)

    ImGui.Spacing()

    if ImGui.Button('Открыть демо-окно') then
        state.demo = true
    end

    ImGui.Spacing()

    local c1, v1 = ImGui.Checkbox('Чекбокс один', state.check1)
    local c2, v2 = ImGui.Checkbox('Чекбокс два', state.check2)
    if c1 then state.check1 = v1 end
    if c2 then state.check2 = v2 end

    ImGui.Spacing()

    ImGui.Text('Радио-кнопки:')
    local r1 = ImGui.RadioButton('Вариант A', state.radio, 1)
    local r2 = ImGui.RadioButton('Вариант B', state.radio, 2)
    if r1 then state.radio = 1 end
    if r2 then state.radio = 2 end

    ImGui.Separator()
    ImGui.Selectable('Строка 1', state.list == 1)
    ImGui.Selectable('Строка 2', state.list == 2)
    ImGui.Selectable('Строка 3', state.list == 3)
end

local function pagePlayer()
    local n, t = ImGui.InputText('Имя', state.name, 24)
    if n then state.name = t end

    local p, pt = ImGui.InputText('Пароль', state.pass, 16)
    if p then state.pass = pt end

    ImGui.Separator()

    local s1, sv = ImGui.SliderFloat('Здоровье', state.sliderA, 0, 1)
    if s1 then state.sliderA = sv end

    local s2, sv2 = ImGui.SliderInt('Уровень', state.sliderB, 1, 100)
    if s2 then state.sliderB = sv2 end

    ImGui.Separator()
    ImGui.ProgressBar((getTickCount() % 5000) / 5000)
end

local function pageVehicle()
    local c, ci = ImGui.Combo('Машина', state.combo, cars)
    if c then state.combo = ci end

    ImGui.PushItemWidth(220)
    local l, li = ImGui.ListBox('Арсенал', state.list, weapons)
    if l then state.list = li end
    ImGui.PopItemWidth()

    ImGui.Separator()
    ImGui.Text('Выбрано: %s', cars[state.combo] or '-')

    ImGui.Separator()
    ImGui.BeginTable('tbl_garage', 2, 30)
    ImGui.TableNextRow()
    ImGui.TableSetColumnIndex(1); ImGui.Text('Модель')
    ImGui.TableSetColumnIndex(2); ImGui.Text('Цена')
    for i, car in ipairs(cars) do
        ImGui.TableNextRow()
        ImGui.TableSetColumnIndex(1)
        local colW = ImGui.GetColumnWidth()
        local sel = ImGui.Selectable(car, state.list == i, 30, colW)
        if sel then state.list = i end
        ImGui.TableSetColumnIndex(2); ImGui.Text('$%d', 10000 + i * 1000)
    end
    ImGui.EndTable()
end

local function pageShop()
    ImGui.Text('Магазин — категории')
    if ImGui.SmallButton('Оружие') then ImGui.SetTooltip('Скоро') end
    ImGui.SameLine()
    if ImGui.SmallButton('Броня') then ImGui.SetTooltip('Скоро') end
    ImGui.SameLine()
    if ImGui.SmallButton('Аптечка') then ImGui.SetTooltip('Скоро') end

    ImGui.Spacing()
    if state.openMain then
        ImGui.Text('Раздел в разработке...')
    end
end

local function pageSettings()
    local r, rv = ImGui.SliderInt('Красный', state.bg[1], 0, 255)
    if r then state.bg[1] = rv end
    local g, gv = ImGui.SliderInt('Зелёный', state.bg[2], 0, 255)
    if g then state.bg[2] = gv end
    local b, bv = ImGui.SliderInt('Синий', state.bg[3], 0, 255)
    if b then state.bg[3] = bv end

    ImGui.Separator()

    if ImGui.CollapsingHeader('Вкладки', state.openTabs) then
        ImGui.BeginTabBar('tb')
        local t1 = ImGui.TabItem('Main', state.page == 1)
        local t2 = ImGui.TabItem('GUI', state.page == 2)
        ImGui.EndTabBar()
        ImGui.PushFont('Roboto-Medium', 9, false)
        ImGui.Text('Активная вкладка: %d', state.page)
        ImGui.PopFont()
    end

    ImGui.Separator()

    local fs, fsv = ImGui.SliderInt('Размер шрифта', state.fontSize, 9, 30)
    if fs then state.fontSize = fsv end

    if ImGui.Button('Центрировать окно') then
        ImGui.CenterWindow('imcore-example: меню')
    end

    ImGui.Text('Демонстрация порта Dear ImGui -> Lua.')
    ImGui.Text('Шрифты: gotham / Cousine-Regular и другие из misc/fonts.')
end

---------------------------------------------------------------------------- render
addEventHandler('onClientRender', root, function()
    if not state.show then return end

    ImGui.NewFrame()
    ImGui.PushStyleColor('ColWindowBg', state.bg)

    ImGui.SetNextWindowSize(420, 560)
    if ImGui.Begin('imcore-example: меню') then
        ImGui.SetWindowFontScale(state.fontSize / 15)

        ImGui.PushStyleColor('ColButton', { 30, 33, 50, 255 })
        ImGui.PushStyleColor('ColButtonHovered', { 44, 50, 80, 255 })
        ImGui.PushStyleColor('ColButtonActive', { 62, 72, 118, 255 })

        ImGui.PushItemWidth(220)
        for i, page in ipairs(pages) do
            if i > 1 then
                ImGui.Dummy(0, 5)
            end

            local active = state.page == i
            if active then
                ImGui.PushStyleColor('ColButton', { 90, 110, 200, 255 })
            end

            local clicked = ImGui.Button(page, { 220, 40 })
            if clicked then state.page = i end

            if active then
                ImGui.PopStyleColor('ColButton')
            end
        end
        ImGui.PopItemWidth()

        ImGui.PopStyleColor('ColButton')
        ImGui.PopStyleColor('ColButtonHovered')
        ImGui.PopStyleColor('ColButtonActive')

        if state.page == 1 then pageMain() end
        if state.page == 2 then pagePlayer() end
        if state.page == 3 then pageVehicle() end
        if state.page == 4 then pageShop() end
        if state.page == 5 then pageSettings() end

        ImGui.End()
    end

    if state.demo then
        state.demo = ImGui.ShowDemoWindow('Демо-окно')
    end

    ImGui.Render()
end, false, 'low-1000')

---------------------------------------------------------------------------- set default state
addEventHandler('onClientResourceStart', resourceRoot, function()
    showCursor(true, false)
end)