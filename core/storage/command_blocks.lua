---@class CBData
---@field id integer
---@field key string
---@field enabled boolean

local M = {}

function M.on_load()
    storage.command_blocks = storage.command_blocks or {}
    storage.cb_id_to_index = storage.cb_id_to_index or {}
end

function M.on_build(event)
    local entity = event.entity or event.created_entity

    if entity.name == "command-block" then
        local cb = storage.command_blocks

        local index = #cb + 1
        local id = entity.unit_number

        cb[index] = {id = id, key = "", enabled = false}
        storage.cb_id_to_index[id] = index
    end
end

function M.on_destroy(event)
    local entity = event.entity or event.created_entity

    if entity.name == "command-block" then
        local cb = storage.command_blocks
        local n = #cb

        local id = entity.unit_number
        local index = storage.cb_id_to_index[id]

        local old = cb[n]
        
        if index ~= n then
            cb[index] = old
            storage.cb_id_to_index[old.id] = index
        end

        cb[n] = nil
        storage.cb_id_to_index[id] = nil
    end
end

---@return CBData
function M.get_data(id)
    local index = storage.cb_id_to_index[id]
    assert(index ~= nil, "ID DOES NOT EXIST")
    return storage.command_blocks[index]
end

return M