# ivd_animations

An in-game emote/animation browser for HMP servers. Players can search and play from a large animation library via a searchable UI, a quick chat-command keyword search, or an entry point wired into [ivd_radialmenu](../ivd_radialmenu). Includes instant cancellation via command or keybind.

## Features

- **`/anim`, `/emotes`, `/animations`** — opens a searchable, categorized animation browser (WebUI)
- **`/e <keyword>`** — plays the first matching animation directly from chat, no menu needed
- **`/cancelanim`, `/stopanim`**, or a configurable cancel key — stops the current animation immediately
- 307 animation dictionaries covering 706 individual clips, browsable by category or full-text search
- Optional dedicated menu-open keybind, in addition to chat commands and the radial menu integration
- Exports `ToggleMenu` / `IsMenuOpen` so other resources (e.g. `ivd_radialmenu`) can open/close the browser and check its state

## Installation

1. Copy the `ivd_animations` folder into your server's resources directory.
2. Start it the same way you start any other resource on your server.

## Configuration

All settings live in [`config/sh_config.lua`](config/sh_config.lua):

| Option | Default | Description |
|---|---|---|
| `Config.PlaySpeed` | `8.0` | Playback speed passed to the animation task |
| `Config.PlayDuration` | `-2` | Duration passed to the animation task (`-2` = loop until cancelled) |
| `Config.LoadTimeoutMs` | `3000` | Max time to wait for an animation dictionary to load before giving up |
| `Config.CancelKey` | `0x2D` | Key that cancels the current animation while one is playing |
| `Config.EnableMenuKey` | `false` | Whether a dedicated keybind can also open/close the browser |
| `Config.MenuKey` | `0x30` | Keybind used when `Config.EnableMenuKey` is `true` |

The animation library itself lives in [`data/animations_data.lua`](data/animations_data.lua) as a list of `{ dict, label, clips }` entries — add or remove dictionaries/clips there to customize the library.

## Integrating from other resources

```lua
-- open/close the browser
exports.ivd_animations:ToggleMenu()

-- check whether it's currently open
local open = exports.ivd_animations:IsMenuOpen()
```

Or trigger playback/cancellation directly via events:

```lua
Events.Call('ivd_anim:play', { dict, clip })
Events.Call('ivd_anim:cancel', {})
```

## File structure

```
ivd_animations/
├── client/
│   ├── sc_main.lua      -- playback, cancellation, /e and /cancelanim commands
│   ├── sc_menu.lua      -- browser WebUI lifecycle, /anim command, exports
│   └── ui/              -- animations.html / .css / .js / .js data bridge
├── config/
│   └── sh_config.lua    -- tunables (speed, duration, keybinds, timeouts)
├── data/
│   └── animations_data.lua -- animation dictionary/clip library
└── meta.xml
```
