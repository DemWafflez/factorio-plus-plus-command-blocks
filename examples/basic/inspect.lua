---@param api API
---@param caller CB
local function main(api, caller)
    api.task.schedule(caller, 1, function() -- 1 tick delay before ran
        api.out.print(caller, "Bank Contents:\n" .. api.bank.inspect()) -- prints contents of the bank
        return 60 -- 1 second intervals
    end)
end

return main