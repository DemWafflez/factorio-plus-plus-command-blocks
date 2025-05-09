# **From Minecraft command blocks to Factorio.**

This mod adds a new block called a Command Block that allows for high performance factory scripting in Lua. Has been battletested to orchestrate 40k furances/assemblers/labs with minimal lag.

---------------------------------

As of now, here are the core things the api gives access to:


  **TaskModule** - Allows for dynamic tick scheduling
  
  **HookModule** - Allows for hooking onto some game events and custom events.
  
  **OutModule** - Allows for basic debug printing
  
  **WireModule** - Allows for circuitry operations like traversing a wire system or signal stuff.
  
  **InvModule** - Allows for basic inventory operations
  
  **BankModule** - Allows for a virtual item storage that simplifies a lot of the complexities of scripting. Like instead of a massive item bus, the bank module abstracts that away and allows for much cleaner item routing. 100% optional module. I don't want to be offending anyone.

[core/modules](./core/modules)

-------------------------

It also gives access to:

- [**LuaGameScript**](https://lua-api.factorio.com/latest/classes/LuaGameScript.html)  
  Full access to the global scripting interface (`game`), including player data, surfaces, and entity control.

- [**LuaPrototypes**](https://lua-api.factorio.com/latest/classes/LuaPrototypes.html)  
  Allows reading prototype definitions like items, recipes, entities, and more.

-------------------------

Future Plans:

1. **More Modules** – Expand the API with additional building blocks.
2. **Custom Art** – Add proper sprites and visual polish for the Command Block.
3. **Improved UI** – Enhance the in-game editor and scripting interface for better usability.
