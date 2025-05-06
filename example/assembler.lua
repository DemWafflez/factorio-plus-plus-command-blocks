---@param api API
---@param caller CB
local function main(api, caller)
    local bank_to_inv = api.bank.bank_to_inv
    local inv_to_bank = api.bank.inv_to_bank

    local ent = caller.ent
    local cached_ents = api.wire.bfs_wire(ent, "green")
    local size = #cached_ents
    local start = 1

    local max_ent_per = 30
    local distrib = 25

    local curr_recipe
    
    api.hooks.add_hook(caller, "assemble", function (recipe_name)
        curr_recipe = recipe_name
        start = 1

        for _, e in pairs(cached_ents) do
            if e.type == "assembling-machine" then
                for _, item in pairs(e.set_recipe(curr_recipe)) do
                    api.bank_debug.add(item.name, item.count)
                end
            end
        end
    end)

    api.hooks.schedule(caller, 1, function (id)
        if not curr_recipe then
            return 60
        end

        local arr, old = api.util.cycle_loop(start, size, max_ent_per)
        start = old

        for _, i in ipairs(arr) do
            local e = cached_ents[i]

            if e.type == "assembling-machine" then
                local a_in, a_out = api.inv.get_inv_bulk(e, "assembler_in", "assembler_out")
                
                for _, ing in pairs(e.get_recipe().ingredients) do
                    bank_to_inv(ing.name, distrib, a_in)
                end

                local out = a_out.get_contents()[1]

                if out then
                    inv_to_bank(out.name, out.count, a_out)
                end
            end
        end

        return 1
    end)
end

return main