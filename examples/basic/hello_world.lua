---@param api API
---@param caller CB
local function main(api, caller)
    api.out.print(caller, "Hello world")
end

return main