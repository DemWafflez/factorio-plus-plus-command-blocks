local hooks = require("core.hooks")
local trigg = hooks.trigger_hook

---@class Events
local M = {}

---@type table<string, string>
cb_events = {
    on_init = "on_init",
    on_build = "on_build",
    on_destroy = "on_destroy",
    on_load = "on_load",
    on_gui_open = "on_gui_open",
    on_gui_close = "on_gui_close",
    on_gui_click = "on_gui_click",
    on_gui_text_changed = "on_gui_text_changed",
    on_gui_selected = "on_gui_selected",
    on_setup_blueprint = "on_setup_blueprint",
    on_stack_changed = "on_stack_changed",
    on_selected_area = "on_selected_area",
    on_compile_all = "on_compile_all"
}

function M.on_init(e) trigg("on_init", e) end
function M.on_build(e) trigg("on_build", e) end
function M.on_destroy(e) trigg("on_destroy", e) end
function M.on_load(e) trigg("on_load", e) end
function M.on_gui_open(e) trigg("on_gui_open", e) end
function M.on_gui_close(e) trigg("on_gui_close", e) end
function M.on_gui_click(e) trigg("on_gui_click", e) end
function M.on_gui_text_changed(e) trigg("on_gui_text_changed", e) end
function M.on_gui_selected(e) trigg("on_gui_selected", e) end
function M.on_setup_blueprint(e) trigg("on_setup_blueprint", e) end
function M.on_stack_changed(e) trigg("on_stack_changed", e) end
function M.on_selected_area(e) trigg("on_selected_area", e) end
function M.on_compile_all() trigg("on_compile_all") end

return M