# **From Minecraft command blocks to Factorio.**

This mod adds a new block called a Command Block that allows for high performance factory scripting in Lua. Has been battletested to orchestrate 40k furances/assemblers/labs with minimal lag.

---------------------------------

As of now, here are the core things the api gives access to:


  **TaskModule** - Allows for dynamic tick scheduling
  
  **HookModule** - Allows for hooking onto some game events and custom events.
  
  **OutModule** - Allows for basic debug printing
  
  **WireModule** - Allows for circuitry operations like traversing a wire system or signal stuff.
  
  **InvModule** - Allows for basic inventory operations

  **AssemblerModule** - Allows for basic assembling machine operations
  
  **BankModule** - Allows for a virtual item storage that simplifies a lot of the complexities of scripting.

[core/modules](./core/modules)

-------------------------

It also gives access to:

- [**LuaGameScript**](https://lua-api.factorio.com/latest/classes/LuaGameScript.html)  
  Full access to the global scripting interface (`game`), including player data, surfaces, and entity control.

- [**LuaPrototypes**](https://lua-api.factorio.com/latest/classes/LuaPrototypes.html)  
  Allows reading prototype definitions like items, recipes, entities, and more.

- [**serpent**](https://github.com/pkulchenko/serpent)
  In game entity debugger

-------------------------

Steps To Run Scripts:

  1. Craft a **Command Block** from the **Unsorted** category (1 Iron Plate for now).
  2. Open the GUI.
  3. Create a empty script.
  4. Paste in some code (hello_world.lua is good).
  5. Toggle the block to **ON**.
  6. Click **Select Current Script**.
  7. Click **Compile All**.
  8. Close the GUI and you should see **Hello world** on the block.

Examples:

hello_world.lua

```lua
---@param api API
---@param caller CB
local function main(api, caller)
  api.out.print(caller, "Hello world")
end

return main
```

inspect.lua

```lua
---@param api API
---@param caller CB
local function main(api, caller)
    api.task.schedule(caller, 1, function() -- 1 tick delay before ran
        api.out.print(caller, "Bank Contents:\n" .. api.bank.inspect()) -- prints contents of the bank
        return 60 -- 1 second intervals
    end)
end

return main
```

drill.lua

```lua
---@param api API
---@param caller CB
local function main(api, caller)
    local drills = api.wire.bfs_wire_wl(caller.ent, "green", {["mining-drill"] = true}) -- finds all drills in green wire
    local chests = api.wire.bfs_wire_wl(caller.ent, "red", {container = true}) -- finds all chests in red wire


    api.task.schedule(caller, 1, function()
        for _, ent in ipairs(drills) do
            local fuel = api.inv.get_inv(ent, "fuel") -- gets fuel inventory

            -- drains then sets fuel to exactly 2 coal
            api.bank.inv_drain(fuel)
            api.bank.inv_move("coal", 2, fuel)
        end

        for _, ent in ipairs(chests) do
            local chest = api.inv.get_inv(ent, "chest")
            api.bank.inv_drain(chest) -- drains mined ore from chest into bank
        end

        return 480 -- 8 second intervals
    end)
end

return main
```

output_to_chest.lua

```lua
-- pumps out 50 iron ore from the bank into a chest
local output_ores = {"iron-ore"}
local count = 50

---@param api API
---@param caller CB
local function main(api, caller)
    local cached_ents = api.wire.bfs_wire_wl(caller.ent, "green", {container = true})

    api.task.schedule(caller, 1, function()
        for _, ent in pairs(cached_ents) do
            local chest = api.inv.get_inv(ent, "chest")

            for _, ore in pairs(output_ores) do
                api.bank.inv_move(ore, count, chest)
            end
        end

        return 240
    end)
end

return main
```

--------------------------

Future Plans:

1. **More Modules** – Expand the API with additional building blocks.
2. **Custom Art** – Add proper sprites and visual polish.
3. **Improved UI** – Enhance the in-game editor and scripting interface for better usability.
