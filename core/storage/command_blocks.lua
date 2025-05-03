local hooks = require("core.hooks")

---@class CBData
---@field ent LuaEntity
---@field key string
---@field enabled boolean

local M = {}

---@return CBData
function M.get_data(id)
    local data = storage.command_blocks[id]
    assert(data ~= nil, "ID DOES NOT EXIST")
    return data
end

hooks.add_hook("on_load", function()
    storage.command_blocks = storage.command_blocks or {}
    return false
end)

hooks.add_hook("on_build", function(e)
    local entity = e.entity or e.created_entity

    if entity.name == "command-block" then
        local id = entity.unit_number
        storage.command_blocks[id] = {ent = entity, key = "", enabled = false}
    end
end)

hooks.add_hook("on_destroy", function(e)
    local entity = e.entity or e.created_entity

    if entity.name == "command-block" then
        local id = entity.unit_number
        storage.command_blocks[id] = nil
    end
end)

return M