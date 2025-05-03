local api = require("core.environment.api")
local scripts = require("core.storage.scripts")
local hooks = require("core.hooks")
local reg = require("core.utils.func_registry")
local auto_table = require("core.utils.auto_table")
local func_to_index = reg.get_func_to_index()

local entity_hooks = auto_table.create(1)
local dirty = {}

local function unregister_all()
    for _, array in pairs(entity_hooks) do
        for _, id in pairs(array) do
            reg.unregister(id)
        end
    end

    entity_hooks = auto_table.create(1)
end

local function rerun_dirty()
    local datas = storage.command_blocks

    for _, data in pairs(datas) do
        local key = data.key

        if dirty[key] then
            scripts.run_key(key, api, data)
        end
    end
    
    dirty = {}
end

hooks.add_hook("on_compile_all", function()
    unregister_all()
    rerun_dirty()
end)

---@param caller CBData
---@param callback fun(...) : any
hooks.add_hook("on_api_add_hook", function(caller, callback)
    local index = func_to_index[callback]
    table.insert(entity_hooks[caller.ent.unit_number], index)
end)


hooks.add_hook("on_dirty_script", function(key)
    dirty[key] = true
end)
