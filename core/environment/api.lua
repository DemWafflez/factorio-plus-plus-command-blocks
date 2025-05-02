
---@class API
local M = {
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

local game_print

function M.print(string)
    game_print(string)
end

function M.___on_load()
    game_print = game.print
end

return M