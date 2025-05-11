---@class CB
---@description AKA Command Block
---@field ent LuaEntity
---@field key string
---@field enabled boolean

local scripts = require("core.storage.scripts")
local api = require("core.api")

local M = {}

---@return CB
function M.get_cb(id)
    local cb = storage.command_blocks[id]
    assert(cb ~= nil, "Command Block ID does not exist!")
    return cb
end

---@param entity LuaEntity
---@return CB
function M.create_cb(entity)
    game.print("Created CB")
    local cb = {
        ent = entity, 
        key = scripts.get_default_script(), 
        enabled = false
    }

    storage.command_blocks[entity.unit_number] = cb
    return cb
end

---@param cb CB
function M.try_run_cb(cb)
    if cb.enabled then
        scripts.run_key(cb.key, api, cb)
    end
end

return M