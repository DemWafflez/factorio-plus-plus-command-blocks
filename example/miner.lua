---@param api API
---@param caller CB
local function main(api, caller)
    local drills = api.wire.bfs_wire_wl(caller.ent, "green", {["burner-mining-drill"] = true})
    local chests = api.wire.bfs_wire_wl(caller.ent, "red", {["wooden-chest"] = true})


    api.task.schedule(caller, 1, function()
        for _, ent in ipairs(drills) do
            local fuel = api.inv.get_inv(ent, "fuel")
            api.bank.bank_to_item("coal", 1, fuel[1])
        end

        for _, ent in ipairs(chests) do
            local chest = api.inv.get_inv(ent, "chest")
            
            if chest[1].valid_for_read then
                api.bank.inv_to_bank(chest[1].name, 100, chest) -- drain all ores
            end
        end

        return 240
    end)
end

return main