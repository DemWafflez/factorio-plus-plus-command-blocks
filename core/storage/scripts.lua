local hooks = require("core.hooks")

---@class Scripts
local M = {}

local dirty_flags = {}
local compiled_funcs = {}

function M.add_script(key, script) 
    assert(storage.scripts[key] == nil, "Script already exists!")
    storage.scripts[key] = script
    dirty_flags[key] = true
    
    hooks.generic_callback("on_dirty_script", key)
end

function M.update_script(key, script)
    assert(storage.scripts[key] ~= nil, "Script doent exist!")
    storage.scripts[key] = script
    dirty_flags[key] = true

    hooks.generic_callback("on_dirty_script", key)
end

function M.get_script(key)
    assert(storage.scripts[key] ~= nil, "Script doent exist!")
    return storage.scripts[key]
end

function M.delete_script(key)
    assert(storage.scripts[key] ~= nil, "Script doesnt exist!")
    storage.scripts[key] = nil
    dirty_flags[key] = nil
    compiled_funcs[key] = nil

    hooks.generic_callback("on_delete_script", key)
end

function M.exist_script(key)
    return storage.scripts[key]
end

function M.allowed_to_run_script(key)
    return dirty_flags[key]
end

function M.get_scripts()
    return storage.scripts
end

function M.safe_run_func(func, ...)
    local ok, result = pcall(func, ...)

    if not ok then
        game.print("[SCRIPT] : " .. result) -- result = error
    end

    return result
end

function M.compile_all()
    hooks.generic_callback("pre_compile_all")

    for key, dirty in pairs(dirty_flags) do
        if dirty then
            local script = storage.scripts[key]
            
            local func, error = load(script, key, "t", {})

            if func then
                compiled_funcs[key] = func
            else 
                game.print("[SCRIPT] : " .. error)
                compiled_funcs[key] = nil
            end

            dirty_flags[key] = nil

        end
    end

    hooks.generic_callback("on_compile_all")
end

---@param key string
function M.run_key(key, ...)
    assert(storage.scripts[key] ~= nil, "Script doesnt exist!")
    local func = compiled_funcs[key]

    if not func then
        game.print("func is not compiled or failed compile")
        return
    end

    M.safe_run_func(function(...)
        local main = func()

        if main then
            main(...)
        end

    end, ...)
end

hooks.add_hook("on_load", function()
    storage.scripts = storage.scripts or {}
    
    for key in pairs(storage.scripts) do
        dirty_flags[key] = true
        hooks.generic_callback("on_dirty_script", key)
    end
    
    M.compile_all()
    return false
end)

return M