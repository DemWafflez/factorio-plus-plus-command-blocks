local ores = {"iron-ore", "copper-ore"}
local total_ores = #ores

local recipes = {"iron-gear-wheel", "copper-cable", "electronic-circuit", "transport-belt", "inserter", "logistic-science-pack"}
local phase_length = {1200, 1200, 900, 800, 800, 30000}
local total_recipes = #recipes

---@param api API
---@param caller CB
local function main(api, caller)
    local cycles = 0
    local cycles_2 = 0
    api.hooks.schedule(caller, 60, function()
        local i = cycles % total_ores + 1

        api.bank_debug.add(ores[i], 1000000)
        api.hooks.trigger_hook("smelt_ore", ores[i])

        cycles = cycles + 1
        return 600
    end)

    api.hooks.schedule(caller, 1, function()
        local i = cycles_2 % total_recipes + 1

        api.hooks.trigger_hook("assemble", recipes[i])

        cycles_2 = cycles_2 + 1
        return phase_length[i]
    end)
end

return main