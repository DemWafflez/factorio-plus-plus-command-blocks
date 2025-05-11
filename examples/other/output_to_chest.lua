local output_ores = {"iron-ore"}
local count = 50

---@param api API
---@param caller CB
local function main(api, caller)
    local cached_ents = api.wire.bfs_wire_wl(caller.ent, "green", {container = true})

    api.task.schedule(caller, 1, function()
        for _, ent in pairs(cached_ents) do
            local chest = api.inv.get_inv(ent, "chest")

            for _, ore in pairs(output_ores) do
                api.bank.inv_move(ore, count, chest)
            end
        end

        return 240
    end)
end

return main