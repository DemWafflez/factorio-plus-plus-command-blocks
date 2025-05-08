local scripts = require("core.storage.scripts")
local hooks = require("core.hooks")
local editor = require("core.ui.editor")
local cb = require("core.logic.cb")

local on_click = {
    script_create = function(player, elem)
        local script_name = elem.parent.script_name
        local text = script_name.text
        
        if text ~= "" and not scripts.exist_script(text) then
            script_name.text = ""

            local dropdown = editor.get_player_dropdown(player)
            local new_index = #dropdown.items + 1

            dropdown.add_item(text, new_index)
            dropdown.selected_index = new_index

            scripts.add_script(text, "")
        end
    end,

    set_current = function(player, elem)
        local dropdown = editor.get_player_dropdown(player)
        local index = dropdown.selected_index

        if index > 0 then
            local key = tostring(dropdown.get_item(index))
            local ent = editor.get_opened_entity(player)

            cb.get_cb(ent.unit_number).key = key
            elem.caption = "Selected: " .. key
        end
    end,

    delete_current = function(player, elem)
        local dropdown = editor.get_player_dropdown(player)
        local index = dropdown.selected_index
        
        if index > 0 then
            scripts.delete_script(dropdown.get_item(index))
            dropdown.remove_item(index)
        end
    end,

    toggle_enabled = function(player, elem)
        local ent = editor.get_opened_entity(player)
        local data = cb.get_cb(ent.unit_number)

        data.enabled = not data.enabled
        elem.caption = data.enabled and "ON" or "OFF"

        if data.enabled then
            scripts.compile_all()
        end
    end
}

---@param e EventData.on_gui_opened
hooks.add_hook(cb_events.on_gui_open, function(e)
    local p = game.get_player(e.player_index)
    local entity = e.entity

    if p and entity and entity.name == "command-block" then
        p.opened = editor.create_window(p, entity)
    end
end)

---@param e EventData.on_gui_closed
hooks.add_hook(cb_events.on_gui_close, function(e)
    local p = game.get_player(e.player_index)
    local elem = e.element

    if p and elem and elem.name == "cb_window" then
        editor.cleanup_window(p)
    end
end)

---@param e EventData.on_gui_text_changed
hooks.add_hook(cb_events.on_gui_text_changed, function(e)
    local player = game.get_player(e.player_index)
    local elem = e.element

    if player and elem.name == "script_text" then
        local dropdown = editor.get_player_dropdown(player)
        local key = dropdown.get_item(dropdown.selected_index)

        scripts.update_script(key, elem.text)
    end
end)

---@param e EventData.on_gui_selection_state_changed
hooks.add_hook(cb_events.on_gui_selected, function(e)
    local elem = e.element
    
    if elem.name == "script_dropdown" then
        local item = elem.get_item(elem.selected_index)
        local script_text = elem.parent.script_text
        script_text.text = scripts.get_script(item)
    end
end)

---@param e EventData.on_gui_click
hooks.add_hook(cb_events.on_gui_click, function(e)
    local player = game.get_player(e.player_index)
    local elem = e.element
    local func = on_click[elem.name]

    if func then
        func(player, elem)
    end
end)

hooks.add_hook(cb_events.on_load, function()
    for _, player in pairs(game.players) do
        local cb = player.gui.screen.cb_window
        if cb then
            cb.destroy()
            player.opened = nil
        end
    end

    return false
end)