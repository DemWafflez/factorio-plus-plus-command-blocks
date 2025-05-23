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

function M.get_craftable_count(recipe_name)
    local ingredients = prototypes.recipe[recipe_name].ingredients
    local count = nil

    for _, item in ipairs(ingredients) do
        local c = math.floor((cached_items[item.name] or 0) / item.amount)
        if c == 0 then return 0 end

        if not count or c < count then
            count = c
        end
    end

    return count or 0
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
    local i = 0
    for key, count in pairs(cached_items) do
        t[i * 4 + 1] = tostring(key)
        t[i * 4 + 2] = " : "
        t[i * 4 + 3] = tostring(count)
        t[i * 4 + 4] = "\n"
        i = i + 1
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