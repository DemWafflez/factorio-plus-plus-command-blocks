---@class AutoTable
local M = {}

---@return AutoTable
function M.create(maxDepth) -- no more boiletplate
    maxDepth = maxDepth - 1
    
    return setmetatable({}, {
        __index = function(table, key)
            local nested = nil

            if maxDepth > 0 then
                nested = M.create(maxDepth)
            else
                nested = {}
            end

            table[key] = nested
            return nested
        end
    })
end

return M