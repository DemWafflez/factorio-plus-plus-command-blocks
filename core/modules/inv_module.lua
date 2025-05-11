local inv_types = require("core.other.inv_types")
local auto_table = require("core.utils.auto_table")
local hooks = require("core.hooks")

local M = {}

local cached_inv = auto_table.create(1)
local cached_items = {}

---@param entity LuaEntity
---@param inv_name string
---@return LuaInventory
function M.get_inv(entity, inv_name)
    local cache = cached_inv[entity.unit_number]
    local inv = cache[inv_name]

    if not inv then
        local type = inv_types[inv_name]
        assert(type ~= nil, "Inventory name does not exist!")
        inv = entity.get_inventory(type)
        cache[inv_name] = inv
    end

    ---@type LuaInventory
    return inv
end

---@param inv LuaInventory
---@return LuaItemStack[]
function M.get_inv_items(inv)
    local items = cached_items[inv]

    if not items then
        items = {}

        for i = 1, #inv do
            items[i] = inv[i] 
        end

        cached_items[inv] = items
    end

    return items
end

---@param entity LuaEntity
---@param ... string
---@return ... LuaInventory
function M.get_inv_bulk(entity, ...)
    ---@type (string | LuaInventory)[]
    local args = {...}
    local cache = cached_inv[entity.unit_number]

    for i = 1, #args do
        local inv_name = args[i]
        local inv = cache[inv_name]

        if not inv then
            local type = inv_types[inv_name]
            assert(type ~= nil, "Inventory name does not exist!")
            inv = entity.get_inventory(type)
            cache[inv_name] = inv
        end

        args[i] = inv
    end

    return table.unpack(args)
end

---@param entities LuaEntity[]
---@param ... string
---@return ... LuaInventory[]
function M.get_entities_inv_bulk(entities, ...) -- all inlined for performance!
    local args = {...}
    local results = {}

    for i = 1, #args do
        results[i] = {}
    end

    for i = 1, #entities do
        local entity = entities[i]
        local cache = cached_inv[entity.unit_number]

        for j = 1, #args do
            local inv_name = args[j]
            local inv = cache[inv_name]

            if not inv then
                local type = inv_types[inv_name]
                assert(type ~= nil, "Inventory name does not exist!")
                inv = entity.get_inventory(type)
                cache[inv_name] = inv
            end

            local result = results[j] 
            result[#result+1] = inv
        end
    end

    return table.unpack(results)
end

hooks.add_hook(cb_events.on_destroy, function(e)
    local ent = e.entity
    local id = ent.unit_number

    if id then
        local invs = cached_inv[id]

        for _, inv in pairs(invs) do
            cached_items[inv] = nil
        end

        cached_inv[id] = nil
    end
end)

return M