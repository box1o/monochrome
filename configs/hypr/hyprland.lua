local home = os.getenv("HOME")
local shell = "qs ipc call mono"
local terminal = "kitty"
local browser = "zen-browser --blank-window"
local file_manager = "nautilus --new-window"

-- Keep the external display above the built-in panel. The generic rule covers
-- other outputs; connector-specific rules reproduce the preferred laptop setup.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-2", mode = "1920x1080@144.06", position = "0x1200", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@144.06", position = "0x1200", scale = 1 })

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 4,
        border_size = 1,
        col = {
            active_border = "rgba(c4746eff)",
            inactive_border = "rgba(2d2a2eff)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        rounding_power = 4,
        shadow = {
            enabled = true,
            range = 8,
            render_power = 2,
            color = "rgba(00000055)",
        },
        blur = {
            enabled = true,
            size = 4,
            passes = 1,
            vibrancy = 0.08,
        },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        disable_watchdog_warning = true,
    },
    input = {
        kb_layout = "us",
        kb_options = "caps:swapescape",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = true },
    },
})

hl.curve("mono", { type = "bezier", points = { { 0.2, 0.9 }, { 0.2, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 1.6, bezier = "mono" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.4, bezier = "mono", style = "popin 90%" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.4, bezier = "mono" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.6, bezier = "mono" })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.window_rule({ match = { class = "^(org\\.gnome\\.Nautilus|nautilus)$" }, float = true })
hl.window_rule({ match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor|blueman-manager)$" }, float = true })
hl.window_rule({ match = { modal = true }, float = true, center = true })

hl.on("hyprland.start", function()
    hl.exec_cmd("qs")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("udiskie --no-notify")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.bind("ALT + SHIFT + A", hl.dsp.exec_cmd(shell .. " launcher"))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd(browser))
hl.bind("ALT + SHIFT + F", hl.dsp.exec_cmd(file_manager))
hl.bind("ALT + V", hl.dsp.exec_cmd(shell .. " clipboard"))
hl.bind("ALT + N", hl.dsp.exec_cmd(terminal .. " -e nmtui"))

hl.bind("SUPER + Z", hl.dsp.exec_cmd(shell .. " toggle"))
hl.bind("SUPER + M", hl.dsp.exec_cmd(shell .. " powermenu"))
hl.bind("ALT + Q", hl.dsp.exec_cmd(home .. "/.config/quickshell/scripts/lock.sh"))
hl.bind("ALT + SHIFT + Q", hl.dsp.exec_cmd(shell .. " powermenu"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind("ALT + SHIFT + C", hl.dsp.window.close())
hl.bind("ALT + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + SHIFT + W", hl.dsp.window.fullscreen())
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind("ALT + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind("SUPER + N", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + N", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("ALT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SUPER + P", hl.dsp.exec_cmd(home .. "/.config/quickshell/scripts/shot.sh"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(home .. "/.config/quickshell/scripts/shot.sh"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
