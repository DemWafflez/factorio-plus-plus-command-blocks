---@class CB
---@field ent LuaEntity
---@field key string
---@field enabled boolean

local M = {}

---@return CB
function M.get_cb(id)
    local cb = storage.command_blocks[id]
    assert(cb ~= nil, "ID DOES NOT EXIST")
    return cb
end

return M