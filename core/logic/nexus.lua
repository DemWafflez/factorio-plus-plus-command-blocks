local bank = require("core.storage.item_bank")
local hooks = require("core.hooks")
local wire = require("core.modules.wire_module")
local out = require("core.modules.out_module")
local wheel = require("core.time_wheel")

---@class C_Nexus
local M = {}

local safe_guard_destroy = false
local last_items = {}
local nexus_multiplier = 1.1

---@param entity LuaEntity
---@return boolean
function M.is_same_circuit(entity)
    local nexus = storage.c_nexus
    return nexus and wire.is_same_circuit(nexus, entity)
end

hooks.add_hook("on_build", function(e)
    ---@type LuaEntity
    local entity = e.entity

    if entity.name == "command-nexus" then
        if not storage.c_nexus then
            game.print("Command Nexus Has Been Placed")
            game.print("Good luck player...")

            storage.c_nexus = entity
        else
            game.print("Only One Nexus ALLOWED!")

            safe_guard_destroy = true
            entity.destroy()
        end
    end
end)

hooks.add_hook("on_destroy", function(e)
    local entity = e.entity

    if entity.name == "command-nexus" then
        if not safe_guard_destroy then
            game.print("NEXUS HAS BEEN DESTROYED!")
            game.print("VIRTUAL ITEM BANK LOST!")

            storage.c_nexus = nil
            bank.WIPE()
        end

        safe_guard_destroy = false
    end
end)

wheel.schedule(__tasks, 60, function()
    if storage.c_nexus then
        out.print({ent = storage.c_nexus}, bank.inspect())
    end
    return 60
end)

wheel.schedule(__tasks, 30, function()
    local items = bank.get_items()
    local stats = game.forces.player.get_item_production_statistics(game.players[1].surface)

    for name, count in pairs(items) do
        local old_count = last_items[name]

        if old_count then
            local delta = count - last_items[name]
            
            if delta > 0 then
                local floor = math.floor(delta * (nexus_multiplier - 1))

                bank.add(name, floor)
                stats.on_flow(name, floor)
                count = count + floor
            end
        end

        last_items[name] = count
    end

    return 30
end)

return M
