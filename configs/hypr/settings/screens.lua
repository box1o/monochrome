local screens = {}

function screens.internal(monitor)
    local name = monitor.name or ""
    return name:match("^eDP%-") or name:match("^LVDS%-") or name:match("^DSI%-")
end

function screens.select(monitors)
    local active = {}
    for _, monitor in ipairs(monitors) do
        if monitor.enabled and not monitor.is_mirror then
            active[#active + 1] = monitor
        end
    end
    table.sort(active, function(a, b) return a.name < b.name end)

    local laptop, external
    for _, monitor in ipairs(active) do
        if screens.internal(monitor) then
            laptop = laptop or monitor
        elseif not external or (monitor.name:match("^HDMI%-") and not external.name:match("^HDMI%-")) then
            external = monitor
        end
    end

    local primary = laptop or active[1]
    if external == primary then
        external = nil
        for _, monitor in ipairs(active) do
            if monitor ~= primary then
                external = monitor
                break
            end
        end
    end
    return primary, external
end

return screens
