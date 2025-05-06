
---@param api API
---@param caller CB
local function main(api, caller)
    local bank_to_inv = api.bank.bank_to_inv
    local inv_to_bank = api.bank.inv_to_bank

    local ent = caller.ent
    local cached_ents = api.wire.bfs_wire(ent, "green")
    local start = 1
    local size = #cached_ents

    local max_ent_per = 150
    local distrib = 12

    local current_ore

    api.hooks.add_hook(caller, "smelt_ore", function(ore)
        current_ore = ore
        start = 1

        for _, e in pairs(cached_ents) do
            if e.type == "furnace" then
                local ore_inv = api.inv.get_inv(e, "furnace_in")
                local ore = ore_inv.get_contents()[1]

                if ore then
                    inv_to_bank(ore.name, ore.count, ore_inv)
                end
            end
        end
    end)

    api.hooks.schedule(caller, 1, function()
        if not current_ore then
            return 30
        end

        local arr, last = api.util.cycle_loop(start, size, max_ent_per)
        start = last

        for _, i in ipairs(arr) do
            local e = cached_ents[i]
            
            if e.type == "furnace" then
                local ore_inv, fuel_inv, result_inv = api.inv.get_inv_bulk(e, "furnace_in", "fuel", "furnace_out")
                local res = result_inv.get_contents()[1]

                if res then
                    inv_to_bank(res.name, res.count, result_inv)
                end

                bank_to_inv(current_ore, distrib, ore_inv)
                bank_to_inv("coal", distrib, fuel_inv) 
            end
        end

        return 1
    end)
end

return main
