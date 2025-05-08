---@param api API
---@param caller CB
local function main(api, caller)
    local ent = caller.ent
    local cached_ents = api.wire.bfs_wire_wl(ent, "green", {["assembling-machine"] = true})

    local input_invs = {}
    local crafted_items = {}

    for i, e in ipairs(cached_ents) do
        local a_in, a_out = api.inv.get_inv_bulk(e, "assembler_in", "assembler_out")
        input_invs[i] = a_in
        crafted_items[i] = a_out[1]
    end
    
    api.hook.add_hook(caller, "assemble", function (recipe_name)
        local ingred = prototypes.recipe[recipe_name].ingredients
        
        api.task.split_task(caller, #input_invs, 20, 10, function(s, e)
            for i = s, e do
                local inv = input_invs[i]

                for _, item in pairs(cached_ents[i].set_recipe(recipe_name)) do
                    api.bank.item_to_bank(item)
                end

                for j, item in pairs(ingred) do
                    api.bank.bank_to_item(item.name, 1000, inv[j])
                end

                api.bank.item_to_bank(crafted_items[i])
            end
        end)
    end)
end

return main