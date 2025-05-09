local inv_types = require("core.other.inv_types")
local auto_table = require("core.utils.auto_table")
local hooks = require("core.hooks")

local M = {}

local cached_inv = auto_table.create(1)

---@param entity LuaEntity
---@param inv_name string
---@return LuaInventory
function M.get_inv(entity, inv_name)
    local array = cached_inv[entity.unit_number]
    local inv = array[inv_name]

    if not inv then
        local type = inv_types[inv_name]
        assert(type ~= nil, "Inventory name does not exist!")
        inv = entity.get_inventory(type)
        array[inv_name] = inv
    end

    ---@type LuaInventory
    return inv
end

---@param entity LuaEntity
---@param ... string
---@return ... LuaInventory
function M.get_inv_bulk(entity, ...)
    ---@type (string | LuaInventory)[]
    local args = {...}
    local array = cached_inv[entity.unit_number]

    for i = 1, #args do
        local inv_name = args[i]
        local inv = array[inv_name]

        if not inv then
            local type = inv_types[inv_name]
            assert(type ~= nil, "Inventory name does not exist!")
            inv = entity.get_inventory(type)
            array[inv_name] = inv
        end

        args[i] = inv
    end

    return table.unpack(args)
end

return M