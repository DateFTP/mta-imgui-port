# MTA ImGui — Dear ImGui port for Multi Theft Auto (Lua)

An immediate-mode GUI framework written in **Lua 5.1** for
[Multi Theft Auto: San Andreas](https://multitheftauto.com), heavily inspired by
the API, windowing model and styling of
[Dear ImGui](https://github.com/ocornut/imgui) by Omar Cornut.

> This is an **early, fast-made prototype**. Some parts were written on the fly
> and are not deeply tested. Verified examples: `imcore_example_multi` and
> `imcore_example_money`. Expected bugs — fix locally, PRs are welcome.

---

## What is this?

A library resource **`imcore`** that gives you a Dear ImGui-style toolkit where
**every UI call is made every frame** ("immediate mode"): you describe windows
and widgets in your `onClientRender` handler and the library draws, hits-tests,
layouts and scrolls them for you.

```lua
ImGui.NewFrame()
if ImGui.Begin('Player') then
    if ImGui.Button('Heal') then
        setElementHealth(localPlayer, 100)
    end
    local hi, v = ImGui.SliderInt('HP', 80, 0, 100)
end
ImGui.End()
ImGui.Render()
```

No retained elements, no `guiCreateWindow` trees — state lives in your Lua
tables, exactly like Dear ImGui does in C++.

---

## How it works

1. **`ImGui.NewFrame()`** — resets frame state (windows, mouse, keyboard queues).
2. **`ImGui.Begin(name) ... ImGui.End()`** — declares one window and lays out
   its widgets. Windows are persistent by name: position, size, scroll and
   collapse state survive across frames. Multiple windows per frame are fine.
3. **`ImGui.Render()`** — each window is drawn into its own **render target**
   (dxCreateRenderTarget) and composited to the screen with a title bar,
   resize handle and scrollbar.
4. Keyboard input flows through `onClientCharacter` / `onClientKey`,
   mouse through `onClientClick` and cursor position — **frame-rate
   independent**, timestamps-based (multi-resource safe).

Widgets are laid out with an implicit cursor (`SameLine`, `Spacing`,
`Separator`, `Dummy`) and an ID stack that hashes labels — the same ergonomics
as upstream Dear ImGui.

---

## Features

- ✦ Immediate-mode windows: move, resize (min 220×150), collapse, scroll, focus
  on click, cascade default placement.
- ✦ Widgets: `Button`, `SmallButton`, `Checkbox`, `RadioButton`, `SliderFloat`,
  `SliderInt`, `DragFloat`, `InputText`, `Combo`, `ListBox`, `Selectable`,
  `ProgressBar`, `CollapsingHeader`/`TreeNode`, `TabBar`/`TabItem`, `Image`,
  `Text`, `Tooltip`, `SameLine`, `Spacing`, `Separator`, `Dummy`.
- ✦ `BeginTable` / `TableNextRow` / `TableSetColumnIndex` / co.
- ✦ Styles: `PushStyleColor` / `PopStyleColor` stack.
- ✦ Fonts: `GetFont`, `PushFont`/`PopFont`, per-window `SetWindowFontScale`,
  `SetNextWindowSize`, `SetNextWindowPos`, fallback chain +
  Dear ImGui `misc/fonts` (Roboto-Medium, DroidSans, Karla, Cousine, Proggy…).
- ✦ Multi-window & **multi-resource friendly** mouse/scroll handling.
- ✦ `ShowDemoWindow` — an on-the-fly demo inspector window.

---

## Getting started

Start the library, then any example:

```bash
start imcore
start imcore_example_multi
```

| Resource | Command | Purpose |
|---|---|---|
| `imcore_example` | `/imgui` | Full multi-page menu demo |
| `imcore_example_progressbar` | `/progress` | Animated progress bars |
| `imcore_example_money` | `/money` | Amount input + server-side money grant (ACL Admin) |
| `imcore_example_auth` | `/auth` | `addAccount` / `logIn` registration & login UI |
| `imcore_example_teleport` | `/tp` | Spawn/teleport manager (shared config, server-side TP) |
| `imcore_example_multi` | `/multi` | 5 windows at once (stress test) |

In your own resource:

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
    if ImGui.Begin('My Window') then
        if ImGui.Button('Close menu') then
            ImGui.CloseWindow('My Window')
        end
    end
    ImGui.End()
    ImGui.Render()
end)
```

---

## Repository layout

```
imcore/                       the library resource
  assets/opensources/
    imgui.source              main immediate-mode engine (widgets, windows)
    fonts.source              dx font wrappers (autonomous)
  assets/fonts/               fonts from Dear ImGui misc/fonts
  shared/include.lua          include list  (includes.lua is auto-generated)
  server/                     generator for includes.lua
imcore_example*               demo resources
```

---

## Origin & credits

- The core idea, API layout, windowing, styling and ID-stack pattern are from
  **Dear ImGui** — [ocornut/imgui](https://github.com/ocornut/imgui) (MIT).
  This project is a **Lua re-implementation**, not a code port.
- Bundled TTF fonts are the ones shipped in Dear ImGui `misc/fonts`.
- License: **MIT** (same spirit as upstream).

---

## Disclaimer

Written quickly, under a mercurial mood, without a test suite. If something
explodes — screenshot the console, open an issue, or poke the author directly.