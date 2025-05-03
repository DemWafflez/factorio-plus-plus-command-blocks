local scripts = require("core.storage.scripts")
local hooks = require("core.hooks")
local callbacks = require("core.environment.callback_wrapper")
local api = require("core.environment.api")

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
        callbacks.disable_caller(id)
    end
end)

hooks.add_hook("on_compile_all", function()
    callbacks.disable_all_callers()

    for _, data in pairs(storage.command_blocks) do
        local key = data.key

        if data.enabled then
            scripts.run_key(key, api, data) 
        end
    end
end)

return M