local hooks = require("core.hooks")
local time_wheel = require("core.time_wheel")
local callbacks = require("core.environment.callback_wrapper")

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
function M.schedule(caller, dt, callback)
    local id = caller.ent.unit_number
    time_wheel.schedule(__api_tasks, dt, callbacks.wrap_caller(id, callback))
end

---@param caller CBData
function M.add_hook(caller, name, callback)
    local id = caller.ent.unit_number
    hooks.add_hook(name, callbacks.wrap_caller(id, callback))
end

return M