# MTA ImGui — порт Dear ImGui для Multi Theft Auto (Lua)

<img width="1532" height="739" alt="image" src="https://github.com/user-attachments/assets/36d23418-b5a9-49be-ba05-77abe19143ff" />

Немедленный (immediate-mode) GUI-фреймворк, написанный на **Lua 5.1** для
[Multi Theft Auto: San Andreas](https://multitheftauto.com), созданный по мотивам
API, модели окон и стилистики [Dear ImGui](https://github.com/ocornut/imgui)
от Омара Корнута.

> Это **ранний прототип, собранный на скорую руку**. Часть кода писалась быстро
> и не покрыта тестами. Проверенные примеры: `imcore_example_multi`
> и `imcore_example_money`. Возможны баги — чините локально, пул-реквесты
> приветствуются.

---

## Что это

Библиотечный ресурс **`imcore`**, который даёт инструментарий в стиле
Dear ImGui, где **каждый вызов UI происходит каждый кадр** («игтел-мод»):
вы описываете окна и виджеты в своём обработчике `onClientRender`,
а библиотека сама их рисует, ловит нажатия, раскладывает и скроллит.

```lua
ImGui.NewFrame()
if ImGui.Begin('Игрок') then
    if ImGui.Button('Лечить') then
        setElementHealth(localPlayer, 100)
    end
    local hi, v = ImGui.SliderInt('HP', 80, 0, 100)
end
ImGui.End()
ImGui.Render()
```

Никаких деревьев элементов и `guiCreateWindow` — состояние живёт в твоих
Lua-таблицах, ровно как в Dear ImGui на C++.

---

## Как устроен процесс

1. **`ImGui.NewFrame()`** — сбрасывает состояние кадра (окна, мышь, клавиатура).
2. **`ImGui.Begin(name) ... ImGui.End()`** — объявляет одно окно и раскладывает
   виджеты. Окна «помнят» себя по имени: позиция, размер, скролл и состояние
   сворачивания сохраняются между кадрами. Окон в кадре может быть сколько
   угодно.
3. **`ImGui.Render()`** — каждое окно рисуется в собственный **render target**
   (`dxCreateRenderTarget`) и собирается на экран с тайтл-баром, ручкой ресайза
   и скроллбаром.
4. Клавиатура приходит через `onClientCharacter` / `onClientKey`, мышь — через
   `onClientClick` и позицию курсора — **независимо от фпса**, по таймстампам
   (безопасно для нескольких ресурсов сразу).

Компоновка идёт неявным курсором (`SameLine`, `Spacing`, `Separator`, `Dummy`)
и стеком ID с хэшированием ярлыков — те же эргономика, что и в оригинале.

---

## Возможности

- ✦ Окна немедленного режима: перетаскивание, ресайз (мин. 220×150),
  сворачивание, скролл, фокус по клику, каскадное размещение по умолчанию.
- ✦ Виджеты: `Button`, `SmallButton`, `Checkbox`, `RadioButton`, `SliderFloat`,
  `SliderInt`, `DragFloat`, `InputText`, `Combo`, `ListBox`, `Selectable`,
  `ProgressBar`, `CollapsingHeader`/`TreeNode`, `TabBar`/`TabItem`, `Image`,
  `Text`, `Tooltip`, `SameLine`, `Spacing`, `Separator`, `Dummy`.
- ✦ Таблицы: `BeginTable` / `TableNextRow` / `TableSetColumnIndex` и др.
- ✦ Стили: стек `PushStyleColor` / `PopStyleColor`.
- ✦ Шрифты: `GetFont`, `PushFont`/`PopFont`, per-window `SetWindowFontScale`,
  `SetNextWindowSize`, `SetNextWindowPos`, цепочка фоллбэков + шрифты
  Dear ImGui `misc/fonts` (Roboto-Medium, DroidSans, Karla, Cousine, Proggy…).
- ✦ Мультиоконность и дружелюбие к **нескольким ресурсам** в обработке мыши.
- ✦ `ShowDemoWindow` — демо-окно «в одно касание».

---

## Быстрый старт

Сначала библиотеку, потом любой пример:

```bash
start imcore
start imcore_example_multi
```

| Ресурс | Команда | Назначение |
|---|---|---|
| `imcore_example` | `/imgui` | Демо многостраничного меню |
| `imcore_example_progressbar` | `/progress` | Анимированные прогресс-бары |
| `imcore_example_money` | `/money` | Ввод суммы + выдача денег сервером (ACL Admin) |
| `imcore_example_auth` | `/auth` | Регистрация/вход `addAccount` / `logIn` |
| `imcore_example_teleport` | `/tp` | Менеджер телепортов (общий конфиг, серверный TP) |
| `imcore_example_multi` | `/multi` | 5 окон сразу (стресс-тест) |

В своём ресурсе:

```lua
local imcore = getResourceFromName('imcore')
if not imcore or getResourceState(imcore) ~= 'running' then return end

local ok = pcall(function()
    loadstring(exports.imcore:include('imgui'))()
end)
if not ok then return end

addEventHandler('onClientRender', root, function()
    ImGui.NewFrame()
    ImGui.SetNextWindowSize(420, 560)
    if ImGui.Begin('Моё окно') then
        if ImGui.Button('Закрыть меню') then
            ImGui.CloseWindow('Моё окно')
        end
    end
    ImGui.End()
    ImGui.Render()
end)
```

---

## Структура репозитория

```
imcore/                       библиотечный ресурс
  assets/opensources/
    imgui.source              главный движок (виджеты, окна)
    fonts.source              обёртки шрифтов dx (автономные)
  assets/fonts/               шрифты из Dear ImGui misc/fonts
  shared/include.lua          список инклудов (includes.lua авто-генерируется)
  server/                     генератор includes.lua
imcore_example*               демо-ресурсы
```

---

## Происхождение и авторство

- Ключевая идея, форма API, модель окон, стили и паттерн ID-стека — из
  **Dear ImGui** — [ocornut/imgui](https://github.com/ocornut/imgui) (MIT).
  Этот проект — **переписанная на Lua реализация**, а не порт кода.
- Приложенные TTF-шрифты — те, что идут в Dear ImGui `misc/fonts`.
- Лицензия: **MIT** (в духе оригинала).

---

## Отказ от ответственности

Писано быстро, под сменой настроения, без тестового пакета. Если что-то
взорвётся — скриншот консоли, issue, или пинок автору лично.
