local time_wheel = require("core.time_wheel")
local cb_wrapper = require("core.logic.cb_hooker")

local M = {}
local cached_tasks = __tasks

---@param caller CB
---@param dt integer
---@param callback fun(id : integer) : boolean | integer
function M.schedule(caller, dt, callback)
    time_wheel.schedule(cached_tasks, dt, cb_wrapper.hook_callback(caller, callback))
end

---@param caller CB
---@param size integer
---@param total_ticks integer
---@param dt_per_tick integer
---@param callback fun(start : integer, last : integer)
function M.split_task(caller, size, total_ticks, dt_per_tick, callback)
    time_wheel.split_task(cached_tasks, size, total_ticks, dt_per_tick, cb_wrapper.hook_callback(caller, callback))
end

return M