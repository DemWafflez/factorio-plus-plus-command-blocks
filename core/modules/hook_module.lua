local hooks = require("core.hooks")
local cb_wrapper = require("core.logic.cb_hooker")

local M = {}

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