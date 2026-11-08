local theme = require("theme")
local c, g, a = theme.colors, theme.geometry, theme.appearance
local function color(value)
    return "rgba(" .. value:sub(2) .. "ff)"
end

hl.config({
    general = {
        gaps_in = g.gap_inner,
        gaps_out = g.gap_outer,
        border_size = g.border_width,
        col = {
            active_border = color(c.accent),
            inactive_border = color(c.border),
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = g.radius,
        rounding_power = 4,
        shadow = {
            enabled = a.shadow,
            range = 8,
            render_power = 2,
            color = "rgba(" .. c.black:sub(2) .. "55)",
        },
        blur = {
            enabled = a.blur,
            size = 4,
            passes = 1,
            vibrancy = 0.08,
        },
        active_opacity = a.opacity,
        inactive_opacity = a.opacity,
    },
    animations = { enabled = theme.motion.enabled },
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

hl.curve("mono", {
    type = "bezier",
    points = {
        { theme.motion.curve[1], theme.motion.curve[2] },
        { theme.motion.curve[3], theme.motion.curve[4] },
    },
})

local function animate(leaf, milliseconds, style)
    hl.animation({
        leaf = leaf,
        enabled = theme.motion.enabled,
        speed = math.max(0.01, milliseconds / 100),
        bezier = "mono",
        style = style,
    })
end

animate("windows", theme.duration.normal_ms)
animate("windowsOut", theme.duration.fast_ms, "popin 90%")
animate("fade", theme.duration.fast_ms)
animate("workspaces", theme.duration.normal_ms)

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.window_rule({ match = { class = "^(org\\.gnome\\.Nautilus|nautilus)$" }, float = true })
hl.window_rule({
    match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" },
    float = true,
    center = true,
})
hl.window_rule({ match = { class = "^(nm-connection-editor|blueman-manager)$" }, float = true })
hl.window_rule({ match = { modal = true }, float = true, center = true })
