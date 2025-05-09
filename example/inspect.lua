---@param api API
---@param caller CB
local function main(api, caller)
    api.task.schedule(caller, 1, function()
        api.out.print(caller, api.bank.inspect())
        return 60
    end)
end

return main