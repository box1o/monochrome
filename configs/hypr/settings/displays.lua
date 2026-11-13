local screens = require("settings.screens")
local configured = require("settings.monitors")
local explicit = {}
local defaults = {}
local updating = false

for _, monitor in ipairs(configured) do
    if monitor.output == "" then
        defaults = monitor
    else
        explicit[monitor.output] = true
    end
    hl.monitor(monitor)
end

local function place(monitor, x, y)
    if explicit[monitor.name] or (monitor.x == x and monitor.y == y) then
        return
    end
    hl.monitor({
        output = monitor.name,
        mode = defaults.mode or "highres",
        position = string.format("%dx%d", x, y),
        scale = defaults.scale or 1,
    })
end

local function update()
    if updating then
        return
    end
    local laptop, external = screens.select(hl.get_monitors())
    if not laptop or not screens.internal(laptop) then
        return
    end

    updating = true
    place(laptop, 0, 0)
    if external then
        -- mode is the logical size, including scale and rotation.
        place(external, 0, -math.floor(external.mode.height))
    end
    updating = false
end

hl.on("monitor.layout_changed", update)
hl.on("hyprland.start", update)
update()
