local cb = require("core.storage.command_blocks")
local scripts = require("core.storage.scripts")
local hooks = require("core.hooks")
local api = require("core.environment.api")
local M = {}

---@param bp LuaItemStack
---@param mapping_array any
local function generate_bp_tags(bp, mapping_array)
    local bp_entities = bp.get_blueprint_entities()

    if not bp_entities then
        return
    end

    for _, bp_ent in pairs(bp_entities) do
        local ent_num = bp_ent.entity_number
        local ent = mapping_array[ent_num]

        if ent and ent.name == "command-block" then
            local data = cb.get_data(ent.unit_number)
            local key = data.key
            
            if scripts.exist_script(key) then
                local copy = {
                    key = key,
                    enabled = data.enabled, 
                    source = scripts.get_script(key)
                }
    
                bp.set_blueprint_entity_tag(ent_num, "cb_data", copy)
            end
        end
    end
end

---@param e EventData.on_player_setup_blueprint
function M.setup_blueprint(e)
    local player = game.get_player(e.player_index)
    local mapping = e.mapping
    local mapping_array = mapping.get()

    if player and mapping.valid then
        local bp = player.cursor_stack or player.blueprint_to_setup

        if not bp or not bp.valid_for_read then
            return
        end

        generate_bp_tags(bp, mapping_array)
    end
end

---@param e EventData.on_built_entity
hooks.add_hook("on_build", function(e)
    local ent = e.entity
    local tags = e.tags

    if ent.name == "command-block" and tags then
        local data = tags.cb_data
        local key = data.key

        if not scripts.exist_script(key) then
            scripts.add_script(key, data.source)
        elseif data.source ~= scripts.get_script(key) then
            key = key .. "_bp_fallback"
            scripts.add_script(key, data.source)
        end

        local real_data = cb.get_data(ent.unit_number)
        real_data.key = key
        real_data.enabled = data.enabled

        scripts.run_key(key, api, real_data)
    end
end)

return M