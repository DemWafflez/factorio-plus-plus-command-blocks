local hooks = require("core.hooks")
local tw = require("core.time_wheel")
local M = {}

local cached_items = {}

hooks.add_hook(cb_events.on_load, function()
    storage.item_bank = storage.item_bank or {}

    for name, count in pairs(storage.item_bank) do
        cached_items[name] = count
    end
end)

function M.get_count(name)
    return cached_items[name] or 0
end

function M.add(name, count)
    cached_items[name] = (cached_items[name] or 0) + count
    return count
end

function M.remove(name, count)
    local curr = cached_items[name] or 0
    
    if count > curr then
        count = curr
    end
    
    cached_items[name] = curr - count
    return count
end

function M.WIPE()
    cached_items = {}
    storage.item_bank = {}
end

function M.inspect()
    local t = {}
    for key, count in pairs(cached_items) do
        table.insert(t, tostring(key))
        table.insert(t, " : ")
        table.insert(t, tostring(count))
        table.insert(t, "\n")
    end

    return table.concat(t)
end

function M.get_items()
    return cached_items
end

tw.schedule(__tasks, 120, function()
    local bank = storage.item_bank

    for name, count in pairs(cached_items) do
        bank[name] = count
    end

    return 120
end)

return M