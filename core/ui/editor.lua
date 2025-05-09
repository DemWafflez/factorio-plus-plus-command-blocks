local scripts = require("core.storage.scripts")
local cb = require("core.logic.cb")
local M = {}

local opened_entity = {}
local cached_dropdowns = {}
local index_to_key = {}
local key_to_index = {}

---@param window LuaGuiElement
---@param data CB
local function create_top_buttons(window, data)
    local flow = window.add{type = "flow", name = "flow", direction = "horizontal"}
    flow.add{type = "textfield", name = "script_name"}
    flow.add{type = "button", name = "script_create", caption = "Create Script"}
end

---@param window LuaGuiElement
---@param data CB
local function create_dropdown(window, data)
    local dropdown = window.add{type = "drop-down", name = "script_dropdown", items = index_to_key}
    dropdown.selected_index = key_to_index[data.key] or math.min(1, #index_to_key)
end


---@param window LuaGuiElement
---@param data CB
local function create_text_box(window, data)
    local key = data.key
    local text_box = window.add{type = "text-box", name = "script_text"}
    text_box.text = scripts.exist_script(key) and scripts.get_script(key) or ""
    text_box.style.width = 400
    text_box.style.height = 350
    text_box.style.font = "default-large"
end

---@param window LuaGuiElement
---@param data CB
local function create_bottom_buttons(window, data)
    local flow_2 = window.add{type = "flow", name = "flow_2", direction = "horizontal"}
    flow_2.add{type = "button", name = "toggle_enabled", caption = data.enabled and "ON" or "OFF"}
    flow_2.add{type = "button", name = "set_current", caption = "Select Curr Script"}
    flow_2.add{type = "button", name = "delete_current", caption = "Delete Current Script"}
    window.add{type = "button", name = "compile_all", caption = "Compile All"}
end

local function update_mappings()
    local i = 0

    for key in pairs(scripts.get_scripts()) do
        i = i + 1
        index_to_key[i] = key
        key_to_index[key] = i
    end
end

---@param player LuaPlayer
---@param entity LuaEntity
function M.create_window(player, entity)
    local gui = player.gui.screen
    local data = cb.get_cb(entity.unit_number)
    update_mappings()

    if gui.cb_window then
        gui.cb_window.destroy()
    end

    local window = gui.add{type = "frame", name = "cb_window", caption = "Command Block Window", direction = "vertical"}
    window.auto_center = true
    window.style.width = 500
    window.style.height = 520

    create_top_buttons(window, data)
    create_dropdown(window, data)
    create_text_box(window, data)
    create_bottom_buttons(window, data)

    cached_dropdowns[player.index] = window.script_dropdown
    opened_entity[player.index] = entity
    return window
end

function M.cleanup_window(player)
    opened_entity[player.index] = nil
    cached_dropdowns[player.index] = nil

    player.opened = nil
    player.gui.screen.cb_window.destroy()
end

---@return LuaGuiElement
function M.get_player_dropdown(player)
    return cached_dropdowns[player.index]
end

---@return LuaEntity
function M.get_opened_entity(player)
    return opened_entity[player.index]
end

return M