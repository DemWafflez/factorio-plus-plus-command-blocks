local reg = require("core.utils.func_registry")
local auto_table = require("core.utils.auto_table")

local funcs = reg.get()
local hooks = {}

local callbacks = auto_table.create(1)

---@param name string
---@param func fun(id: integer, ...)
function hooks.add_hook(name, func)
    table.insert(callbacks[name], reg.register(func))
end

---@param name string
function hooks.generic_callback(name, ...)
    local cbs = callbacks[name]

    local i = 1
    local n = #cbs

    while i <= n do
        local id = cbs[i]
        if not funcs[id](id, ...) then
            cbs[i] = cbs[n]
            cbs[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end
end


return hooks