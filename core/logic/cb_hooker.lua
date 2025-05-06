local nexus = require("core.logic.nexus")
local out = require("core.modules.out_module")

local caller_data = {}

local allowed = {}
local funcs = {}
local total = 0

local M = {}

---@param caller CB
---@param callback fun(...) : boolean | integer
function M.hook_callback(caller, callback)
    local ent = caller.ent

    local caller_id = ent.unit_number
    local array = caller_data[caller_id] or {}
    local index = total + 1

    allowed[index] = true
    funcs[index] = callback
    array[#array + 1] = index

    caller_data[caller_id] = array
    total = index

    return function(...)
        if allowed[index] then
            if nexus.is_same_circuit(ent) then
                return funcs[index](...)
            else
                out.print(caller, "Lost connection to nexus!")
            end
        end

        return false
    end
end

function M.disable_all_caller_callbacks()
    for caller_id, array in pairs(caller_data) do
        for _, index in pairs(array) do
            allowed[index] = nil
            funcs[index] = nil
        end

        caller_data[caller_id] = {}
    end
end

function M.disable_caller_callback(caller_id)
    local array = caller_data[caller_id]

    if array then
        for _, index in pairs(array) do
            allowed[index] = nil
            funcs[index] = nil
        end
    
        caller_data[caller_id] = {}
    end
end

return M