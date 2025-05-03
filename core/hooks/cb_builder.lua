local hooks = require("core.hooks")

hooks.add_hook("on_build", function(e)
    local entity = e.entity or e.created_entity

    if entity.name == "command-block" then
        local cb = storage.command_blocks

        local index = #cb + 1
        local id = entity.unit_number

        cb[index] = {ent = entity, key = "", enabled = false}
        storage.cb_id_to_index[id] = index
    end
end)

hooks.add_hook("on_destroy", function(e)
    local entity = e.entity or e.created_entity

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
end)