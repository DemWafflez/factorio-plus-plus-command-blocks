-- backbone ore for green science
local ores = {"iron-ore", "copper-ore"}
local total_ores = #ores

-- full assembly of green science!
local recipes = {"iron-gear-wheel", "copper-cable", "electronic-circuit", "transport-belt", "inserter", "logistic-science-pack"}
-- gears (20 seconds) -> cables (20 seconds) -> circuits (10 ish seconds) -> ... -> green science (200 seconds)
local phase_length = {1200, 1200, 800, 800, 1200, 12000}
local total_recipes = #recipes

---@param api API
---@param caller CB
local function main(api, caller)
    local cycles = 0
    local cycles_2 = 0

    api.task.schedule(caller, 60, function() -- cycles ores
        local i = cycles % total_ores + 1
        api.hook.trigger_hook("smelt_ore", ores[i]) -- trigger smelt ore listener

        cycles = cycles + 1
        return 1200 -- 20 seconds
    end)

    api.task.schedule(caller, 1, function() -- cycles recipes to build up to final product
        local i = cycles_2 % total_recipes + 1
        api.hook.trigger_hook("assemble", recipes[i]) -- trigger assemble listener

        cycles_2 = cycles_2 + 1
        return phase_length[i] -- specific intervals for each recipe
    end)
end

return main