local hooks = require("core.hooks")
local time_wheel = require("core.time_wheel")
local auto_table = require("core.utils.auto_table")
local scripts = require("core.storage.scripts")

local caller_data = auto_table.create(1)

local cb_allowed = {}
local cb_funcs = {}
local total_cb = 0


---@class API
local M = {
    pairs = pairs,
    ipairs = ipairs,
    type = type,
    tostring = tostring,
    tonumber = tonumber,
    select = select,
    next = next,
    math = math, 
    table = table,
    string = string
}

local game_print

function M.print(string)
    game_print(string)
end

hooks.add_hook("on_load", function()
    game_print = game.print
    return false
end)

---@param caller CBData
local function handle_caller(caller, callback)
    total_cb = total_cb + 1

    local id = caller.ent.unit_number
    local index = total_cb

    table.insert(caller_data[id], index)
    cb_allowed[index] = true
    cb_funcs[index] = callback

    return function(...)
        if cb_allowed[index] then
            return cb_funcs[index](...)
        end

        cb_allowed[index] = nil
        cb_funcs[index] = nil
        return false
    end
end

---@param caller CBData
function M.schedule(caller, dt, callback)
    time_wheel.schedule(__api_tasks, dt, handle_caller(caller, callback))
end

---@param caller CBData
function M.add_hook(caller, name, callback)
    hooks.add_hook(name, handle_caller(caller, callback))
end

hooks.add_hook("on_compile_all", function()
    for _, array in pairs(caller_data) do
        for _, index in pairs(array) do
            cb_allowed[index] = nil
        end
    end
    
    caller_data = auto_table.create(1)

    for _, data in pairs(storage.command_blocks) do
        local key = data.key

        if data.enabled then
            scripts.run_key(key, M, data) 
        end
    end
end)

hooks.add_hook("on_destroy", function(e)
    local ent = e.entity
    local id = ent.unit_number
    local array = caller_data[id]

    if array then
        
        for _, index in pairs(array) do
            cb_allowed[index] = nil
        end
    
        caller_data[id] = nil

    end
end)

return M