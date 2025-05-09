local time_wheel = require("core.time_wheel")
local events = require("core.events")
__tasks = time_wheel.create(4096)

require("core.hooks")
require("core.api")
require("core.logic.cb")
require("core.logic.cb_hooks")
require("core.ui.editor")
require("core.ui.editor_hooks")
require("core.logic.cb_bp")

local d_e = defines.events

local build_events = {
    d_e.on_built_entity,
    d_e.on_robot_built_entity,
    d_e.script_raised_built,
    d_e.on_entity_cloned
}

local destroy_events = {
    d_e.on_player_mined_entity,
    d_e.on_robot_mined_entity,
    d_e.on_entity_died,
    d_e.script_raised_destroy
}

__loaded = false
script.on_event(d_e.on_tick, function()
    if not __loaded then
        events.on_load()
        __loaded = true
    end

    time_wheel.run_tick(__tasks)
end)

script.on_event(build_events, events.on_build)
script.on_event(destroy_events, events.on_destroy)
script.on_event(d_e.on_gui_opened, events.on_gui_open)
script.on_event(d_e.on_gui_closed, events.on_gui_close)
script.on_event(d_e.on_gui_click, events.on_gui_click)
script.on_event(d_e.on_gui_text_changed, events.on_gui_text_changed)
script.on_event(d_e.on_gui_selection_state_changed, events.on_gui_selected)
script.on_event(d_e.on_player_setup_blueprint, events.on_setup_blueprint)
script.on_event(d_e.on_player_cursor_stack_changed, events.on_stack_changed)
script.on_event(d_e.on_player_selected_area, events.on_selected_area)