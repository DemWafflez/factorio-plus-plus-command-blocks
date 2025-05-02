local M = {}

local registry = {}
local funcToIndex = {}
local total = 0

---@param func function
function M.register(func)
    local val = funcToIndex[func]

    if val then
        return val
    end

    total = total + 1

    registry[total] = func    
    funcToIndex[func] = total
    
    return total
end

---@return function[]
function M.get()
    return registry
end

return M