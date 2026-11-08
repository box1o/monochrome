local home = os.getenv("HOME")
local helpers = home .. "/.local/libexec/mono/capture"
local terminal = "kitty"
local browser = "zen-browser --blank-window"
local file_manager = "nautilus --new-window"

hl.bind("ALT + V", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
hl.bind("ALT + SHIFT + A", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(terminal))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd(browser))
hl.bind("ALT + SHIFT + F", hl.dsp.exec_cmd(file_manager))
hl.bind("ALT + N", hl.dsp.exec_cmd(terminal .. " -e nmtui"))

hl.bind("ALT + Q", hl.dsp.exec_cmd("mono-session lock"))
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

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true }
)
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl set 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl set 5%-"),
    { locked = true, repeating = true }
)

hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SUPER + P", hl.dsp.exec_cmd(helpers .. "/shot.sh"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(helpers .. "/shot.sh"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

hl.bind("SUPER + C", hl.dsp.exec_cmd("qs ipc call snippets toggle"))
