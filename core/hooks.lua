local auto_table = require("core.utils.auto_table")
local hooks = {}

local callbacks = auto_table.create(1)

local function trigger(name, ...)
    local cbs = callbacks[name]

    local i = 1
    local n = #cbs

    while i <= n do
        local func = cbs[i]

        if func(...) == false then
            cbs[i] = cbs[n]
            cbs[n] = nil
            n = n - 1
        else
            i = i + 1
        end

    end
end

---@param name string
---@param ... any
function hooks.trigger_hook(name, ...)
    local ok, error = pcall(trigger, name, ...)

    if not ok then
        game.print("[HOOK ERROR] " .. error)
    end
end

---@param name string
---@param func fun(...) : boolean | any
function hooks.add_hook(name, func)
    local array = callbacks[name]
    array[#array + 1] = func
end

return hooks