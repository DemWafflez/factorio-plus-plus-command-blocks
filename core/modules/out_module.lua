local M = {}

local function split_lines(str)
    local lines = {}
    for line in string.gmatch(str, "([^\n]*)\n?") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    return lines
end


---@param caller CB
---@param string string
---@param offset {[1]: number, [2]: number}?
---@param color {[1]: number, [2]: number, [3]: number}?
---@param time integer?
function M.print(caller, string, offset, color, time)
    offset = offset or {0,0}
    color = color or {1,1,1}
    time = time or 60

    local ent = caller.ent
    local ent_pos = ent.position

    local px = ent_pos.x + offset[1]
    local py = ent_pos.y + offset[2]

    local lines = split_lines(string)

    for i, line in pairs(lines) do
        rendering.draw_text{
            text = line, 
            surface = ent.surface, 
            target = {px, py + 0.5 * (i - 1)}, 
            color = color, 
            time_to_live = time,
            alignment = "center"
        }
    end
end

---@param caller CB
---@param error string
---@param offset {[1]: number, [2]: number}?
---@param time integer?
function M.error(caller, error, offset, time)
    M.print(caller, error, offset, {1,0,0}, time)
end

return M