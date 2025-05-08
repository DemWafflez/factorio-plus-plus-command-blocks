---@class API
local M = {}

M.hooks = require("core.modules.hooks_module")
M.out = require("core.modules.out_module")
M.inv = require("core.modules.inv_module")
M.wire = require("core.modules.wire_module")
M.bank = require("core.modules.bank_module")

M.bank_debug = require("storage.item_bank")

return M