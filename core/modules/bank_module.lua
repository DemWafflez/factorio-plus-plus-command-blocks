local bank = require("core.storage.item_bank")
local M = {}

---@type SimpleItemStack
local cached_item = {name = "", count = 0}
local proto_item = prototypes.item

local bank_items = bank.get_items()
local defer = {}

local function flush_defered_items()
    for name, count in pairs(defer) do
        bank_items[name] = (bank_items[name] or 0) + count
        defer[name] = 0
    end
end

---@param items LuaItemStack[]
---@param start integer
---@param last integer
function M.item_to_bank_bulk(items, start, last)
    for i = start, last do
        local item = items[i]

        if item.valid_for_read then
            local name = item.name
            defer[name] = (defer[name] or 0) + item.count
            item.count = 0
        end
    end

    flush_defered_items()
end

---@param name string
---@param count integer
---@param items LuaItemStack[]
---@param start integer
---@param last integer
function M.bank_to_item_bulk(name, count, items, start, last)
    local max = proto_item[name].stack_size
    for i = start, last  do
        local item = items[i]
        local new_count = 0

        if item.valid_for_read then
            if item.name ~= name then
                goto continue
            end
            new_count = item.count
        elseif not item.set_stack(name) then
            goto continue
        end

        new_count = new_count + bank.remove(name, count)
    
        if new_count > max then
            local over = new_count - max
            defer[name] = (defer[name] or 0) + over
            item.count = max
        else
            item.count = new_count
        end

        ::continue::
    end

    flush_defered_items()
end

---@param item LuaItemStack
function M.item_to_bank(item)
    if item.valid_for_read then
        local c = item.count
        bank.add(item.name, c)
        item.count = 0  
    end
end

---@param item LuaItemStack
function M.bank_to_item(name, count, item)
    local new_count = 0

    if item.valid_for_read then
        if item.name ~= name then
            return
        end
        new_count = item.count
    elseif not item.set_stack(name) then
        return
    end

    local max = proto_item[name].stack_size
    local removed = bank.remove(name, count)
    new_count = new_count + removed

    if new_count > max then
        local over = new_count - max
        bank.add(name, over)
        item.count = max
    else
        item.count = new_count
    end
end

---@param name string
---@param count integer
---@param inv LuaInventory
function M.inv_to_bank(name, count, inv)
    cached_item.name = name
    cached_item.count = count
    bank.add(name, inv.remove(cached_item))
end

---@param name string
---@param count integer
---@param inv LuaInventory
function M.bank_to_inv(name, count, inv)
    local removed = bank.remove(name, count)
    if removed <= 0 then return 0 end

    cached_item.name = name
    cached_item.count = removed
    bank.add(name, removed - inv.insert(cached_item))
end

return M