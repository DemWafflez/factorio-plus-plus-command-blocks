

---@param api API
---@param caller CB
local function main(api, caller)
    local ent = caller.ent
    local entities = api.wire.bfs_wire_wl(ent, "green", {furnace = true}) -- traverse wire system
    local ore_invs, fuel_invs, result_invs = api.inv.get_entities_inv_bulk(entities, "furnace_in", "fuel", "furnace_out")

    api.hook.add_hook(caller, "restock_furnaces", function(ore)
        api.task.split_task(caller, #ore_invs, 10, 10, function(s, e)
            for i = s, e do
                api.bank.inv_drain(result_invs[i])

                -- sets current ore and fuel to exactly 2
                api.bank.inv_drain(ore_invs[i])
                api.bank.inv_drain(fuel_invs[i])
                api.bank.inv_move(ore, 2, ore_invs[i])
                api.bank.inv_move("coal", 2, fuel_invs[i])
            end
        end)
    end)
end

return main