local hooks = require("core.hooks")
local hooker = require("core.logic.cb_hooker")
local cb = require("core.logic.cb")
local tw = require("core.time_wheel")
local out = require("core.modules.out_module")

hooks.add_hook(cb_events.on_load, function()
    ---@type table<integer, CB>
    storage.command_blocks = storage.command_blocks or {}
    
    local cbs = storage.command_blocks
    local found = game.surfaces[1].find_entities_filtered{name = "command-block"}

    for i, ent in ipairs(found) do
        local id = ent.unit_number
        
        if id and not cbs[id] then
            cbs[id] = cb.create_cb(ent)
        end
    end
    
    return false
end)

hooks.add_hook(cb_events.on_build, function(e)
    local entity = e.entity

    if entity.name == "command-block" then
        cb.create_cb(entity)
    end
end)

hooks.add_hook(cb_events.on_destroy, function(e)
    local entity = e.entity

    if entity.name == "command-block" then
        local id = entity.unit_number
        storage.command_blocks[id] = nil
        hooker.disable_caller_callback(id)
    end
end)

hooks.add_hook(cb_events.on_compile_all, function()
    hooker.disable_all_caller_callbacks()
    

    if storage.command_blocks then
        for _, data in pairs(storage.command_blocks) do
            cb.try_run_cb(data)
        end
    end
end)

tw.schedule(__tasks, 1, function()
    local offset = {0,-1}
    local color = {1,1,1}
    local time = 60

    for _, data in pairs(storage.command_blocks) do
        out.print(data, data.key .. " : " .. tostring(data.enabled), offset, color, time)
    end

    return time
end)