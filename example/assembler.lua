---@param api API
---@param caller CB
local function main(api, caller)
    local ent = caller.ent
    local cached_ents = api.wire.bfs_wire_wl(ent, "green", {["assembling-machine"] = true})

    local in_inv = {}
    local out_items = {}

    for i, e in ipairs(cached_ents) do
        local a_in, a_out = api.inv.get_inv_bulk(e, "assembler_in", "assembler_out")
        in_inv[i] = a_in
        out_items[i] = a_out[1]
    end
    
    api.hooks.add_hook(caller, "assemble", function (recipe_name)
        local ingred = prototypes.recipe[recipe_name].ingredients
        
        api.hooks.parallel_for(caller, #in_inv, 20, 10, function(s, e)
            api.bank.item_to_bank_bulk(out_items, s, e)

            for i = s, e do
                local inv = in_inv[i]

                for _, item in pairs(cached_ents[i].set_recipe(recipe_name)) do
                    api.bank_debug.add(item.name, item.count)
                end

                for j, item in pairs(ingred) do
                    api.bank.bank_to_item(item.name, 1000, inv[j])
                end
            end
        end)
    end)
end

return main