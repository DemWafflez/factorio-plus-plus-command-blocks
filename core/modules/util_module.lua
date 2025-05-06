local M = {}
local temp_array = {}

---@param entity LuaEntity
function M.is_command(entity)
    local name = entity.name
    return name == "command-block" or name == "command-nexus"
end

---@param position integer
---@param end_i integer
---@param loop_times integer
---@return integer[], integer
function M.cycle_loop(position, end_i, loop_times)
    local index = position

    for i = 1, loop_times do
        temp_array[i] = index
        index = index + 1

        if index > end_i then
            index = 1
        end
    end

    temp_array[loop_times + 1] = nil -- ipairs iteration dont forget
    return temp_array, index
end

return M