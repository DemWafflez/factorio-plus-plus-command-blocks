local hooks = require("core.hooks")
local M = {}


---@param event EventData.on_built_entity
function M.on_build(event)
    hooks.generic_callback("on_build", event)
end

---@param event EventData.on_player_mined_entity
function M.on_destroy(event)
    hooks.generic_callback("on_destroy", event)
end

function M.on_load()
    hooks.generic_callback("on_load")
end

return M