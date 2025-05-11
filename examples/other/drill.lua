---@param api API
---@param caller CB
local function main(api, caller)
    local drills = api.wire.bfs_wire_wl(caller.ent, "green", {["mining-drill"] = true})
    local chests = api.wire.bfs_wire_wl(caller.ent, "red", {container = true})


    api.task.schedule(caller, 1, function()
        for _, ent in ipairs(drills) do
            local fuel = api.inv.get_inv(ent, "fuel")
            api.bank.inv_drain(fuel)
            api.bank.inv_move("coal", 2, fuel)
        end

        for _, ent in ipairs(chests) do
            local chest = api.inv.get_inv(ent, "chest")
            api.bank.inv_drain(chest)
        end

        return 480
    end)
end

return main