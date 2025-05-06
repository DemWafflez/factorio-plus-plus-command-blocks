local hooks = require("core.hooks")
local time_wheel = require("core.time_wheel")
local cb_wrapper = require("core.logic.cb_hooker")

---@class HooksModule
local M = {}

---@param caller CB
---@param dt integer
---@param callback fun(id : integer) : boolean | integer
function M.schedule(caller, dt, callback)
    time_wheel.schedule(__api_tasks, dt, cb_wrapper.hook_callback(caller, callback))
end

---@param caller CB
---@param name string
---@param callback fun(...) : boolean | any
function M.add_hook(caller, name, callback)
    hooks.add_hook(name, cb_wrapper.hook_callback(caller, callback))
end

function M.trigger_hook(name, ...)
    hooks.safe_generic_callback(name, ...)
end

return M