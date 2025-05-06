local nexus = require("core.logic.nexus")
local scripts = require("core.storage.scripts")
local api = require("core.api")

local M = {}

---@param caller CB
function M.run(caller)
    if caller.enabled then
        if nexus.is_same_circuit(caller.ent) then
            scripts.run_key(caller.key, api, caller)
        else
            api.out.print(caller, "Could not find connection to nexus!")
        end
    end
end

return M