local bank = require("core.modules.bank_module")
local real_bank = require("core.storage.item_bank")

local M = {}

---@param entity LuaEntity
---@param recipe string | LuaRecipe | LuaRecipePrototype
function M.set_recipe_extra_to_bank(entity, recipe)
    for _, item in pairs(entity.set_recipe(recipe)) do
        real_bank.add(item.name, item.count) -- moves old items into bank
    end
end

---@param inv LuaInventory
---@param ingredients Ingredient.base[]
---@param crafted_amount integer
--- ingredients is from entity.get_recipe().ingredients or prototypes
function M.fill_inv_ingredient(inv, ingredients, crafted_amount)
    for i = 1, #ingredients do
        local item = ingredients[i]
        bank.inv_move(item.name, item.amount * crafted_amount, inv)
    end
end

return M