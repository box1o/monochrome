local M = {}

function M.micropython()
    local ok, plugin = pcall(require, "micropython_nvim")
    return ok and type(plugin.exists) == "function" and plugin.exists() and plugin.statusline() or ""
end

function M.harpoon()
    local list = require("harpoon"):list()
    local total = list:length()
    if total == 0 then
        return ""
    end
    local current = vim.fn.expand("%:p")
    for index, item in pairs(list.items) do
        if item.value and vim.fn.fnamemodify(item.value, ":p") == current then
            return string.format("󱡅 %d/%d", index, total)
        end
    end
    return "󱡅 —/" .. total
end

function M.branch(branch)
    if #branch > 20 then
        return branch:sub(1, 17) .. "..."
    end
    return branch:gsub("^([^/])[^/]*/", "%1/")
end

function M.file_size()
    local size = vim.fn.getfsize(vim.fn.expand("%:p"))
    if size <= 0 then
        return ""
    end
    local units = { "B", "KB", "MB", "GB" }
    local unit = 1
    while size >= 1024 and unit < #units do
        size = size / 1024
        unit = unit + 1
    end
    return string.format("%.1f%s", size, units[unit])
end

return M
