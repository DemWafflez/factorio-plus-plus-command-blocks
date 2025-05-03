local caller_data = {}

local allowed = {}
local funcs = {}
local total = 0

local M = {}

function M.wrap_caller(caller_id, callback)
    local index = total + 1
    total = index

    local array = caller_data[caller_id] or {}
    caller_data[caller_id] = array
    table.insert(array, index)

    allowed[index] = true
    funcs[index] = callback

    return function(...)
        if allowed[index] then
            return funcs[index](...)
        end

        return false
    end
end

function M.disable_all_callers()
    for id, array in pairs(caller_data) do
        for _, index in pairs(array) do
            allowed[index] = nil
            funcs[index] = nil
        end

        caller_data[id] = {}
    end
end

function M.disable_caller(caller_id)
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