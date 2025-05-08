
---@param api API
---@param caller CB
local function main(api, caller)
    local ent = caller.ent
    local cached_ents = api.wire.bfs_wire_wl(ent, "green", {furnace = true})

    local ore_items = {}
    local fuel_items = {}
    local result_items = {}

    for i, e in pairs(cached_ents) do
        local o, f, r = api.inv.get_inv_bulk(e, "furnace_in", "fuel", "furnace_out")
        ore_items[i] = o[1]
        fuel_items[i] = f[1]
        result_items[i] = r[1]
    end

    api.hooks.add_hook(caller, "smelt_ore", function(ore)
        api.hooks.parallel_for(caller, #ore_items, 20, 10, function(s, e)
            api.bank.item_to_bank_bulk(ore_items, s,e )
            api.bank.item_to_bank_bulk(result_items, s, e)
            api.bank.bank_to_item_bulk(ore, 25, ore_items, s, e)
            api.bank.bank_to_item_bulk("coal", 25, fuel_items, s, e)
    
            api.hooks.schedule(caller, 120, function() -- edge case
                api.bank.item_to_bank_bulk(result_items, s, e)
                return false
            end)
        end)
    end)
end

return main
