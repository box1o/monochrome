-- Lua is the compositor configuration; service-specific .conf files are separate.
local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local directory = os.getenv("MONO_HYPR_CONFIG_DIR") or (config .. "/hypr")
package.path = directory .. "/?.lua;" .. package.path

local theme = require("theme")
local appearance = theme.appearance
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_THEME", appearance.cursor)
hl.env("XCURSOR_SIZE", tostring(appearance.cursor_size))
hl.env("HYPRCURSOR_SIZE", tostring(appearance.cursor_size))

require("settings.displays")

require("settings.workspaces")
require("settings.options")
require("settings.bindings")

hl.on("hyprland.start", function()
    hl.exec_cmd(string.format("%q start", os.getenv("HOME") .. "/.local/bin/mono-session"))
end)
