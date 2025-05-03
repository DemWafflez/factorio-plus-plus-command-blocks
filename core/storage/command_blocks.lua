local hooks = require("core.hooks")

require("core.hooks.cb_builder")
require("core.hooks.cb_runner")

---@class CBData
---@field ent LuaEntity
---@field key string
---@field enabled boolean

local M = {}

---@return CBData[]
function M.get_datas()
    return storage.command_blocks
end

---@return CBData
function M.get_data(id)
    local index = storage.cb_id_to_index[id]
    assert(index ~= nil, "ID DOES NOT EXIST")
    return storage.command_blocks[index]
end

hooks.add_hook("on_load", function()
    storage.command_blocks = storage.command_blocks or {}
    storage.cb_id_to_index = storage.cb_id_to_index or {}
end)

return M