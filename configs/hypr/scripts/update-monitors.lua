-- Read only a data table, then emit an updated table for the Bash runtime to save.
local path, output, mode, position, scale, transform, vrr = table.unpack(arg)
local chunk = assert(loadfile(path, "t", {}))
local monitors = chunk()
assert(type(monitors) == "table", "monitor configuration must return a table")
scale = assert(tonumber(scale))
transform = assert(tonumber(transform or "0"))
vrr = assert(tonumber(vrr or "0"))
assert(scale > 0 and scale <= 8, "scale must be in 0..8")
assert(transform % 1 == 0 and transform >= 0 and transform <= 7, "invalid transform")
assert(vrr % 1 == 0 and vrr >= 0 and vrr <= 2, "invalid VRR")
local found = false
for _, monitor in ipairs(monitors) do
    assert(type(monitor) == "table" and type(monitor.output) == "string", "invalid monitor entry")
    if monitor.output == output then
        assert(not found, "duplicate output")
        monitor.mode, monitor.position, monitor.scale = mode, position, scale
        monitor.transform, monitor.vrr = transform, vrr
        found = true
    end
end
if not found then
    monitors[#monitors + 1] = {
        output = output,
        mode = mode,
        position = position,
        scale = scale,
        transform = transform,
        vrr = vrr,
    }
end
local keys = {
    "output",
    "mode",
    "position",
    "scale",
    "transform",
    "vrr",
    "disabled",
    "mirror",
    "bitdepth",
    "cm",
    "sdrbrightness",
    "sdrsaturation",
}
local allowed = {}
for _, key in ipairs(keys) do
    allowed[key] = true
end
local lines = { "-- Single monitor source; updated by mono-shell.\nreturn {" }
for _, monitor in ipairs(monitors) do
    for key in pairs(monitor) do
        assert(allowed[key], "unsupported monitor field: " .. key)
    end
    local fields = {}
    for _, key in ipairs(keys) do
        local value = monitor[key]
        if value ~= nil then
            local kind = type(value)
            assert(
                kind == "string" or kind == "number" or kind == "boolean",
                "invalid field: " .. key
            )
            fields[#fields + 1] = key
                .. " = "
                .. (kind == "string" and string.format("%q", value) or tostring(value))
        end
    end
    lines[#lines + 1] = "    { " .. table.concat(fields, ", ") .. " },"
end
lines[#lines + 1] = "}\n"
io.write(table.concat(lines, "\n"))
