local M = {}

local registry = {}
local func_to_index = {}
local total = 0

---@param func function
function M.register(func)
    local val = func_to_index[func]

    if val then
        return val
    end

    total = total + 1

    registry[total] = func    
    func_to_index[func] = total
    
    return total
end

function M.unregister(func)
    local val = func_to_index[func]

    if not val then
        return
    end

    local old = registry[total]
    registry[val] = old
    func_to_index[old] = val

    func_to_index[func] = nil
    registry[total] = nil

    total = total - 1
end

function M.get_func_to_index()
    return func_to_index
end

---@return function[]
function M.get()
    return registry
end

return M