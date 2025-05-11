local inv_module = require("core.modules.inv_module")
local bank = require("core.storage.item_bank")
local M = {}

---@type SimpleItemStack
local cached_item = {name = "", count = 0}

---@alias ItemRequests {names : string[], counts : integer[], invs : LuaInventory[], start : integer, last : integer}

---@param name string
---@param count integer
---@param inv LuaInventory
local function inv_to_bank(name, count, inv)
    cached_item.name = name
    cached_item.count = count
    bank.add(name, inv.remove(cached_item))
end

---@param name string
---@param count integer
---@param inv LuaInventory
local function bank_to_inv(name, count, inv)
    local removed = bank.remove(name, count)
    if removed <= 0 then return 0 end

    cached_item.name = name
    cached_item.count = removed
    bank.add(name, removed - inv.insert(cached_item)) -- adds back overflow
end

---@param inv LuaInventory
function M.inv_drain(inv)
    local items = inv_module.get_inv_items(inv)

    for i = 1, #items do
        local item = items[i]

        if item.valid_for_read then
            bank.add(item.name, inv.remove(item))
        else
            return -- assumes dense inventory!
        end
    end
end

---@param name string
---@param count integer
---@param inv LuaInventory
function M.inv_move(name, count, inv)
    if count < 0 then
        inv_to_bank(name, -count, inv)
    elseif count > 0 then
        bank_to_inv(name, count, inv)
    end
end

function M.get_count(name)
    return bank.get_count(name)
end

function M.get_craftable_count(recipe_name)
    return bank.get_craftable_count(recipe_name)
end

---@return string
function M.inspect()
    return bank.inspect()
end

return M