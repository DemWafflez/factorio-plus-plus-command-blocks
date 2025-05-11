-- backbone ore for green science
local ores = {"iron-ore", "copper-ore"}
local total_ores = #ores

-- full assembly of green science
local recipes = {"iron-gear-wheel", "copper-cable", "electronic-circuit", "transport-belt", "inserter", "logistic-science-pack"}
-- gears (20 seconds) -> cables (20 seconds) -> circuits (10 ish seconds) -> ... -> green science (200 seconds)
local phase_length = {1200, 1200, 800, 800, 1200, 12000}
local total_recipes = #recipes

---@param api API
---@param caller CB
local function main(api, caller)
    local furnace_cycle = 0
    local assembler_cycle = 0

    api.task.schedule(caller, 1, function()
        local i = assembler_cycle % total_recipes + 1

        if api.bank.get_craftable_count(recipes[i]) <= 0 then -- cycle on empty recipe
            assembler_cycle = assembler_cycle + 1
            return 1
        end

        api.hook.trigger_hook("restock_assemblers", recipes[i]) -- restock assemblers
        return 120
    end)

    api.task.schedule(caller, 1, function()
        local i = furnace_cycle % total_ores + 1

        if api.bank.get_count(ores[i]) <= 0 then -- cycle ores on empty
            furnace_cycle = furnace_cycle + 1
            return 1
        end

        api.hook.trigger_hook("restock_furnaces", ores[i]) -- restock furnaces
        return 120
    end)

    api.task.schedule(caller, 1, function() -- cycle ores
        furnace_cycle = furnace_cycle + 1
        return 300 -- 5 seconds
    end)

    api.task.schedule(caller, 1, function() -- cycle recipes
        local i = assembler_cycle % total_recipes + 1

        assembler_cycle = assembler_cycle + 1
        return phase_length[i] -- specific intervals for each recipe
    end)
end

return main