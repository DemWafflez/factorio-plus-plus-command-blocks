local wire_types = require("core.other.wire_types")
local wheel = require("core.time_wheel")
local auto_table = require("core.utils.auto_table")

local M = {}

local cached_circuits = auto_table.create(1)
local cached_bfs = {}
local old_wire_count = {}

---@param entity LuaEntity
---@param wire_color string
---@return LuaEntity[]
local function bfs(entity, wire_color)
    local type = wire_types[wire_color]
    assert(type ~= nil, "Wire color does not exist!")

    local q = {entity.get_wire_connector(type, true)}
    local entities = {entity}
    local visited = {[entity.unit_number] = true}

    local i = 1
    local q_size = 1

    while i <= q_size do
        local c = q[i]
        local connections = c.connections

        for j = 1, #connections do
            local c_2 = connections[j].target
            local ent = c_2.owner
            local id = ent.unit_number

            if id and not visited[id] then
                q_size = q_size + 1
                visited[id] = true

                q[q_size] = c_2
                entities[q_size] = ent
            end
        end

        i = i + 1
    end

    return entities
end

---@param entity LuaEntity
---@param wire_color string
function M.bfs_wire(entity, wire_color)
    local network = M.get_circuit(entity, wire_color)
    if not network then return {} end

    local id = network.network_id
    local bfs_result = cached_bfs[id]

    if not bfs_result then
        bfs_result = bfs(entity, wire_color)

        old_wire_count[network] = #bfs_result
        cached_bfs[id] = bfs_result
    end

    return bfs_result
end

---@param entity LuaEntity
---@param wire_color string
---@param whitelist table<string, boolean>
---@return LuaEntity[]
function M.bfs_wire_wl(entity, wire_color, whitelist)
    local bfs_result = M.bfs_wire(entity, wire_color)

    local array = {}
    local size = 0
    local n = #bfs_result

    for i = 1, n do
        local ent = bfs_result[i]

        if ent.valid and (whitelist[ent.type] or whitelist[ent.name]) then
            size = size + 1
            array[size] = ent
        end
    end

    return array
end

---@param a LuaEntity
---@param b LuaEntity
function M.is_same_circuit(a, b)
    for color in pairs(wire_types) do
        local c_a = M.get_circuit(a, color)
        local c_b = M.get_circuit(b, color)
        
        if c_a and c_b and c_a.network_id == c_b.network_id then
            return true
        end
    end

    return false
end

---@param entity LuaEntity
---@param wire_color string
---@return LuaCircuitNetwork
function M.get_circuit(entity, wire_color)
    local array = cached_circuits[entity.unit_number]
    local cached = array[wire_color]

    if cached and cached.valid then
        return cached
    end

    local type = wire_types[wire_color]
    assert(type ~= nil, "Wire color does not exist!")

    local c = entity.get_circuit_network(type)
    array[wire_color] = c

    ---@type LuaCircuitNetwork
    return c
end


wheel.schedule(__tasks, 30, function(id)
    for net, old_count in pairs(old_wire_count) do
        if net.valid then
            local new_count = net.connected_circuit_count

            if new_count ~= old_count then
                cached_bfs[net.network_id] = nil
                old_wire_count[net] = nil
            end
        else
            old_wire_count[net] = nil
        end
    end

    return 30
end)

return M