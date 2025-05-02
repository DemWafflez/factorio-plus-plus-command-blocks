-- debug
local util = require("util")

local function createBlockItem(name)
    return {
        type = "item",
        name = name,
        icon = "__base__/graphics/icons/constant-combinator.png",
        icon_size = 64,
        subgroup = "storage",
        order = "z[" .. name .. "]",
        place_result = name,
        stack_size = 100
    }
end
  
local function createBlockRecipe(name)
    return {
        type = "recipe",
        name = name,
        enabled = true,
        ingredients = {
            {type = "item", name = "iron-plate", amount = 1}
        },
        results = {{type="item", name = name, amount = 1}}
    }
end

local function createBlock(blockName, type, name)
    local block = util.table.deepcopy(data.raw[type][name])
    block.name = blockName
    block.minable.result = blockName

    return block
end

data:extend({createBlock("command-block", "constant-combinator", "constant-combinator")})
data:extend({createBlockItem("command-block")})
data:extend({createBlockRecipe("command-block")})