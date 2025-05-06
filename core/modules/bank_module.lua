local bank = require("core.storage.item_bank")
local M = {}

---@type SimpleItemStack
local cached_item = {name = "", count = 0}

---@param name string
---@param count integer
---@param inv LuaInventory
---@return integer
function M.inv_to_bank(name, count, inv)
    cached_item.name = name
    cached_item.count = count

    local removed = inv.remove(cached_item)
    bank.add(name, removed)
    
    return removed
end

---@param name string
---@param count integer
---@param inv LuaInventory
---@return integer
function M.bank_to_inv(name, count, inv)
    local removed = bank.remove(name, count)
    
    if removed > 0 then
        cached_item.name = name
        cached_item.count = removed

        local added = inv.insert(cached_item)
        bank.add(name, removed - added)

        return added
    end

    return 0
end

return M