local hooks = require("core.hooks")
local time_wheel = require("core.time_wheel")
local cb_wrapper = require("core.logic.cb_hooker")

---@class HooksModule
local M = {}

---@param caller CB
---@param dt integer
---@param callback fun(id : integer) : boolean | integer
function M.schedule(caller, dt, callback)
    time_wheel.schedule(__tasks, dt, cb_wrapper.hook_callback(caller, callback))
end

---@param caller CB
---@param size integer
---@param total_ticks integer
---@param dt_per_tick integer
---@param callback fun(start : integer, last : integer)
function M.parallel_for(caller, size, total_ticks, dt_per_tick, callback)
    local dx = math.floor(size / total_ticks)
    local i = 0

    M.schedule(caller, dt_per_tick, function()
        if i >= total_ticks then
            return false
        end

        i = i + 1
        local start = (i - 1) * dx + 1
        local last = i < total_ticks and start + dx or size

        callback(start, last)
        return dt_per_tick
    end)
end

---@param caller CB
---@param name string
---@param callback fun(...) : boolean | any
function M.add_hook(caller, name, callback)
    hooks.add_hook(name, cb_wrapper.hook_callback(caller, callback))
end

function M.trigger_hook(name, ...)
    hooks.trigger_hook(name, ...)
end

return M