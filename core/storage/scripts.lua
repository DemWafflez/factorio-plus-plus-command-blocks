local hooks = require("core.hooks")
local events = require("core.events")
local api = require("core.api")

---@class Scripts
local M = {}

local dirty_flags = {}
local compiled_funcs = {}

local shared_script_table = {    
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

function M.add_script(key, script) 
    assert(storage.scripts[key] == nil, "Script already exists!")
    storage.scripts[key] = script
    dirty_flags[key] = true
end

function M.update_script(key, script)
    assert(storage.scripts[key] ~= nil, "Script doent exist!")
    storage.scripts[key] = script
    dirty_flags[key] = true
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

---@return string
function M.get_default_script()
    for key in pairs(storage.scripts) do
        return key
    end
    
    return ""
end

function M.compile_all()
    game.print("RECOMPILING ALL SCRIPTS...")

    shared_script_table.game = game
    shared_script_table.prototypes = prototypes

    for key, dirty in pairs(dirty_flags) do
        if dirty then
            local script = storage.scripts[key]
            local func, error = load(script, key, "t", shared_script_table)

            if func then
                compiled_funcs[key] = func
            else 
                game.print("[COMPILE ERROR] : " .. error)
                compiled_funcs[key] = nil
            end

            dirty_flags[key] = nil
        end
    end

    events.on_compile_all()
end

---@param key string
---@param api API
---@param caller CB
function M.run_key(key, api, caller)
    assert(storage.scripts[key] ~= nil, "Script doesnt exist!")
    
    local func = compiled_funcs[key]
    if not func then return end

    local ok, result = pcall(function()
        func()(api, caller)
    end)

    if not ok then
        local string = "[" .. key .. "]" .. result
        game.print(string)
        api.out.error(caller, string, {0, -2}, 360)
    end
end

hooks.add_hook(cb_events.on_load, function()
    storage.scripts = storage.scripts or {}
    
    for key in pairs(storage.scripts) do
        dirty_flags[key] = true
    end
    
    M.compile_all()
    return false
end)

return M