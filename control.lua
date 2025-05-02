local time_wheel = require("core.utils.time_wheel")
local events = require("core.events")
local hooks  = require("core.hooks")
local api = require("core.environment.api")
local gui = require("core.gui")

local command_blocks = require("core.storage.command_blocks")
local scripts = require("core.storage.scripts")

__loaded = false
__devmode = true
__testmode = true

__tasks = time_wheel.create(2048)

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

script.on_event(d_e.on_tick, function()
    if not __loaded then
        events.on_load()
        __loaded = true
    end

    time_wheel.run_tick(__tasks)
end)

script.on_event(build_events, events.on_build)
script.on_event(destroy_events, events.on_destroy)

script.on_event(d_e.on_gui_opened, gui.on_open)
script.on_event(d_e.on_gui_closed, gui.on_close)

script.on_event(d_e.on_gui_click, gui.on_click)
script.on_event(d_e.on_gui_text_changed, gui.on_text_changed)
script.on_event(d_e.on_gui_selection_state_changed, gui.on_selected)

hooks.add_hook("on_load", function()
    command_blocks.on_load()
    scripts.on_load()
    api.___on_load()
    gui.on_load()
end)

hooks.add_hook("on_build", function(id, e)
    command_blocks.on_build(e)
end)

hooks.add_hook("on_destroy", function(id, e)
    command_blocks.on_destroy(e)
end)














if __testmode then
    hooks.add_hook("on_load", function()
        local total = 0
        local rng = game.create_random_generator(124)
        local count = 10000
    
        local dt = 1
    
        for i = 1, count do
            time_wheel.schedule(__tasks, dt, function(id)
                total = total + 1

                if id == count then
                    assert(total == count, "NOT SYNCED")
                    total = 0
                end
                return dt
            end)
        end
    end)

    hooks.add_hook("on_load", function()
        local source = [[
            ---@param api API
            local function main(api)
                api.print("hallo")
            end

            return main
        ]]

        scripts.delete_script("main")
        scripts.add_script("main", source)
        scripts.recompile_all_script()

        local func = scripts.get_compiled_script("main")
        func(api)
    end)
end