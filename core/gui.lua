local scripts = require("core.storage.scripts")
local command_blocks = require("core.storage.command_blocks")
local hooks = require("core.hooks")
local M = {}

local opened_entity = {}

local cached_dropdowns = {}

---@param player LuaPlayer
---@param entity LuaEntity
local function create_window(player, entity)
    local gui = player.gui.screen

    if gui.cb_window then
        gui.cb_window.destroy()
    end

    local window = gui.add{type = "frame", name = "cb_window", caption = "Command Block Window", direction = "vertical"}

    window.auto_center = true
    window.style.width = 500
    window.style.height = 500

    local flow = window.add{type = "flow", name = "flow", direction = "horizontal"}
    
    flow.add{type = "textfield", name = "script_name"}
    flow.add{type = "button", name = "script_create", caption = "Create Script"}

    local array = scripts.get_scripts()
    local data = command_blocks.get_data(entity.unit_number)

    local keys = {}
    local i = 0

    local entity_key = data.key
    local curr_index

    for key in pairs(array) do
        i = i + 1
        keys[i] = key

        if key == entity_key then
            curr_index = i
        end
    end

    local dropdown = window.add{type = "drop-down", name = "script_dropdown", items = keys}

    dropdown.selected_index = curr_index or #dropdown.items

    local text_box = window.add{type = "text-box", name = "script_text"}

    if scripts.exist_script(data.key) then
        text_box.text = scripts.get_script(data.key)
    end

    text_box.style.width = 400
    text_box.style.height = 350
    text_box.style.font = "default-large"

    local flow_2 = window.add{type = "flow", name = "flow_2", direction = "horizontal"}

    flow_2.add{type = "button", name = "set_current", caption = "Selected: " .. data.key}
    flow_2.add{type = "button", name = "toggle_enabled", caption = data.enabled and "ON" or "OFF"}
    flow_2.add{type = "button", name = "delete_current", caption = "Delete Current Script"}

    opened_entity[player.index] = entity
    cached_dropdowns[player.index] = dropdown
    return window
end

local function cleanup_window(player)
    opened_entity[player.index] = nil
    cached_dropdowns[player.index] = nil

    player.opened = nil
    player.gui.screen.cb_window.destroy()
end

local on_click = {
    script_create = function(player, elem)
        local script_name = elem.parent.script_name
        local text = script_name.text
        
        if text ~= "" and not scripts.exist_script(text) then
            script_name.text = ""

            local dropdown = cached_dropdowns[player.index]
            local new_index = #dropdown.items + 1

            dropdown.add_item(text, new_index)
            dropdown.selected_index = new_index

            scripts.add_script(text, "")
        end
    end,

    set_current = function(player, elem)
        local dropdown = cached_dropdowns[player.index]
        local index = dropdown.selected_index

        if index > 0 then
            local ent = opened_entity[player.index]
            local data = command_blocks.get_data(ent.unit_number)

            data.key = dropdown.get_item(index)
            elem.caption = "Selected: " .. data.key
        end
    end,

    delete_current = function(player, elem)
        local dropdown = cached_dropdowns[player.index]
        local index = dropdown.selected_index
        
        if index > 0 then
            scripts.delete_script(dropdown.get_item(index))
            dropdown.remove_item(index)
        end
    end,

    toggle_enabled = function(player, elem)
        local ent = opened_entity[player.index]
        local data = command_blocks.get_data(ent.unit_number)

        data.enabled = not data.enabled
        elem.caption = data.enabled and "ON" or "OFF"
    end
}

---@param e EventData.on_gui_opened
function M.on_open(e)
    local p = game.get_player(e.player_index)
    local entity = e.entity

    if p and entity and entity.name == "command-block" then
        p.opened = create_window(p, entity)
    end
end

---@param e EventData.on_gui_closed
function M.on_close(e)
    local p = game.get_player(e.player_index)
    local elem = e.element

    if p and elem and elem.name == "cb_window" then
        scripts.compile_all()
        cleanup_window(p)
    end
end

---@param e EventData.on_gui_click
function M.on_click(e)
    local player = game.get_player(e.player_index)
    local elem = e.element
    local func = on_click[elem.name]

    if func then
        func(player, elem)
    end
end

---@param e EventData.on_gui_text_changed
function M.on_text_changed(e)
    local player = game.get_player(e.player_index)
    local elem = e.element

    if player and elem.name == "script_text" then
        local dropdown = cached_dropdowns[player.index]
        local key = dropdown.get_item(dropdown.selected_index)

        scripts.update_script(key, elem.text)
    end
end

---@param e EventData.on_gui_selection_state_changed
function M.on_selected(e)
    local elem = e.element
    
    if elem.name == "script_dropdown" then
        local item = elem.get_item(elem.selected_index)
        local script_text = elem.parent.script_text
        script_text.text = scripts.get_script(item)
    end
end

hooks.add_hook("on_load", function()
    for _, player in pairs(game.players) do
        player.opened = nil
    end

    return false
end)


return M