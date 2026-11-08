local screens = require("settings.screens")
local configured = require("settings.monitors")
local explicit, applied = {}, {}
local defaults = {}

for _, monitor in ipairs(configured) do
    if monitor.output == "" then
        defaults = monitor
    else
        explicit[monitor.output] = true
    end
    hl.monitor(monitor)
end

local function update()
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.enabled and not monitor.is_mirror and screens.internal(monitor) then
            if not explicit[monitor.name] and not applied[monitor.name] then
                -- Mark first: changing a rule may trigger another layout event.
                applied[monitor.name] = true
                hl.monitor({
                    output = monitor.name,
                    mode = defaults.mode or "highres",
                    position = "auto-down",
                    scale = defaults.scale or 1,
                })
            end
        end
    end
end

hl.on("monitor.layout_changed", update)
hl.on("hyprland.start", update)
update()
