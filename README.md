From Minecraft command blocks to Factorio.

This mod adds a new block called a Command Block that allows for high performance factory scripting in Lua. Has been battletested to orchestrate 40k machines with minimal lag.

As of now, here are the core things the api gives access to:

TaskModule - Allows for dynamic tick scheduling
HookModule - Allows for hooking onto some game events and custom events.
OutModule - Allows for basic debug printing
WireModule - Allows for circuitry operations like traversing a wire system or signal stuff.
InvModule - Allows for basic inventory operations
BankModule - Allows for a virtual item storage that simplifies a lot of the complexities of scripting.
Like instead of a massive item bus, the bank module abstracts that away and allows for more cleaner item routing.

All of these modules are in the core/modules folder.

-------------------------

It also gives access to:

LuaGameScript (https://lua-api.factorio.com/latest/classes/LuaGameScript.html)

LuaPrototypes (https://lua-api.factorio.com/latest/classes/LuaPrototypes.html)

-------------------------

Future Plans:

1. More Modules
2. Actual Art
3. Better UI
