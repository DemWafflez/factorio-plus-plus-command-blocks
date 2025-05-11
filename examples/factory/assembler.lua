---@param api API
---@param caller CB
local function main(api, caller)
    local ent = caller.ent
    local entities = api.wire.bfs_wire_wl(ent, "green", {["assembling-machine"] = true}) -- finds all entities in the wire system
    local input_invs, crafted_invs = api.inv.get_entities_inv_bulk(entities, "assembler_in", "assembler_out")
    
    api.hook.add_hook(caller, "restock_assemblers", function (recipe_name)
        local ingred = prototypes.recipe[recipe_name].ingredients
        
        api.task.split_task(caller, #input_invs, 10, 10, function(s, e) -- split task into 10 chunks, 10 tick per chunk. 100 ticks total
            for i = s, e do 
                api.bank.inv_drain(crafted_invs[i]) -- move crafted items into bank
                api.assembler.set_recipe_extra_to_bank(entities[i], recipe_name) -- change recipe

                api.bank.inv_drain(input_invs[i])
                api.assembler.fill_inv_ingredient(input_invs[i], ingred, 2)
            end
        end)
    end)
end

return main