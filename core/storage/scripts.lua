---@class Scripts
local M = {}

---@type fun(api : API)[]
local compiled_scripts = {}
local dirty_scripts = {}

local chunk_name = "block_script"
local dummy_func = function(api) end

function M.on_load()
    storage.scripts = storage.scripts or {}
    
    for key in pairs(storage.scripts) do
        dirty_scripts[key] = true
    end

    M.recompile_all_script()
end

function M.add_script(key, script)
    assert(storage.scripts[key] == nil, "Script already exists!")
    storage.scripts[key] = script
    dirty_scripts[key] = true
end

function M.update_script(key, script)
    assert(storage.scripts[key] ~= nil, "Script doent exist!")
    storage.scripts[key] = script
    dirty_scripts[key] = true
end

function M.recompile_all_script()
    for key, script in pairs(storage.scripts) do

        if dirty_scripts[key] then
           
            local func, error = load(script, chunk_name, "t", {})

            if func then
                storage.scripts[key] = script
                compiled_scripts[key] = func()
            else
                game.print("[SCRIPT] : " .. error)
                compiled_scripts[key] = dummy_func
            end

            dirty_scripts[key] = false

        end

    end
end

function M.get_script(key)
    assert(storage.scripts[key] ~= nil, "Script doent exist!")
    return storage.scripts[key]
end

function M.get_compiled_script(key)
    assert(storage.scripts[key] ~= nil, "Script doesnt exist!")
    return compiled_scripts[key]
end

function M.delete_script(key)
    assert(storage.scripts[key] ~= nil, "Script doesnt exist!")
    storage.scripts[key] = nil
    compiled_scripts[key] = nil
end

function M.exist_script(key)
    return storage.scripts[key] ~= nil
end

function M.get_scripts()
    return storage.scripts
end

function M.safe_run_func(func, error_callback, ...)
    local ok, error = pcall(func, ...)

    if not ok then
        error_callback(error)
    end
end

return M