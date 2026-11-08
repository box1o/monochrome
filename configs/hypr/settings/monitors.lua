-- One external monitor above the laptop. Hyprland uses its detected logical height.
-- With HDMI disconnected, the laptop is placed at the origin automatically.
return {
    { output = "", mode = "preferred", position = "0x0", scale = 1 },
    { output = "eDP-2", mode = "1920x1080@144.06", position = "auto-down", scale = 1 },
    { output = "eDP-1", mode = "1920x1080@144.06", position = "auto-down", scale = 1 },
}
