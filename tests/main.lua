---@param api API
---@param data CBData
local function main(api, data)
    local value = 0
    
    api.schedule(data, 60, function()
        value = value + 1
        api.print("CALLED: " .. value)

        return 60
    end)
end

return main