

---@param api API
---@param caller CB
local function main(api, caller)
    local ent = caller.ent
    local cached_ents = api.wire.bfs_wire_wl(ent, "green", {furnace = true}) -- traverse wire system

    local ore_items = {}
    local fuel_items = {}
    local result_items = {}

    for i, e in pairs(cached_ents) do -- cache predetermined items
        local o, f, r = api.inv.get_inv_bulk(e, "furnace_in", "fuel", "furnace_out")
        ore_items[i] = o[1]
        fuel_items[i] = f[1]
        result_items[i] = r[1]
    end

    api.hook.add_hook(caller, "refuel_ore", function(ore)
        api.task.split_task(caller, #ore_items, 10, 10, function(s, e)
            for i = s, e do
                -- refresh
                api.bank.item_to_bank(ore_items[i])
                api.bank.item_to_bank(fuel_items[i])
                api.bank.item_to_bank(result_items[i])

                -- puts ore and fuel into furnace
                api.bank.bank_to_item(ore, 2, ore_items[i])
                api.bank.bank_to_item("coal", 2, fuel_items[i])
            end
        end)
    end)
end

return main