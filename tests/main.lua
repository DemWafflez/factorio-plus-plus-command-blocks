local value = 100

---@param api API
local function main(api)
    api.print("hallo " .. value)
    return 0
end

return main