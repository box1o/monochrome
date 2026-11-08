-- Workspace 0 on the keyboard is workspace 10.
-- HDMI gets 1..5; the laptop gets 6..10. Change this boundary to adjust the split.
local first_laptop_workspace = 6
local rules = {}
local topology

local function update()
    local laptop, hdmi, fallback
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.enabled and not monitor.is_mirror then
            fallback = fallback or monitor
            if
                monitor.name:match("^eDP%-")
                or monitor.name:match("^LVDS%-")
                or monitor.name:match("^DSI%-")
            then
                laptop = laptop or monitor
            elseif monitor.name:match("^HDMI%-") and (not hdmi or monitor.name < hdmi.name) then
                hdmi = monitor
            end
        end
    end

    laptop = laptop or hdmi or fallback
    if not laptop then
        return
    end

    local current = laptop.name .. ":" .. (hdmi and hdmi.name or "")
    if current == topology then
        return
    end

    for _, rule in pairs(rules) do
        rule:set_enabled(false)
    end

    for workspace = 1, 10 do
        local target = hdmi and workspace < first_laptop_workspace and hdmi or laptop
        local default_workspace = (not hdmi or target == hdmi) and 1 or first_laptop_workspace
        local is_default = workspace == default_workspace
        local key = target.name .. ":" .. workspace .. ":" .. tostring(is_default)
        if not rules[key] then
            rules[key] = hl.workspace_rule({
                workspace = tostring(workspace),
                monitor = target.name,
                default = is_default,
            })
        end
        rules[key]:set_enabled(true)
    end

    -- Move existing workspaces too: rules alone only govern future assignments.
    for _, workspace in ipairs(hl.get_workspaces()) do
        if not workspace.special and workspace.id and workspace.id >= 1 and workspace.id <= 10 then
            local target = hdmi and workspace.id < first_laptop_workspace and hdmi or laptop
            if not workspace.monitor or workspace.monitor.name ~= target.name then
                hl.dispatch(
                    hl.dsp.workspace.move({ workspace = workspace.id, monitor = target.name })
                )
            end
        end
    end
    topology = current
end

-- Native events run after the arrangement changes; no polling or shell processes.
hl.on("monitor.layout_changed", update)
hl.on("config.reloaded", update)
hl.on("hyprland.start", update)
