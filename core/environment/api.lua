local hooks = require("core.hooks")
local time_wheel = require("core.time_wheel")

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

---@param caller CBData
function M.schedule(caller, dt, callback)
    time_wheel.schedule(__api_tasks, dt, callback)
    hooks.generic_callback("on_api_add_hook", caller, callback)
end

---@param caller CBData
function M.add_hook(caller, name, callback)
    hooks.add_hook(name, callback)
    hooks.generic_callback("on_api_add_hook", caller, callback)
end

hooks.add_hook("on_load", function()
    game_print = game.print
end)

return M