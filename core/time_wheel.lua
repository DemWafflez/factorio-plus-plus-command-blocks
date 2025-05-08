---@class TimeWheel
---@field buckets integer[][]
---@field num_buckets integer
---@field callbacks function[]
---@field expected_ticks integer[]
---@field total_ids integer
---@field reuse_ids integer[]
---@field last_cb_id integer
---@field curr_index integer
---@field curr_tick integer
local M = {}

---@return TimeWheel
function M.create(num_buckets)
    local buckets = {}

    for i = 1, num_buckets do
        buckets[i] = {}
    end

    return {
        num_buckets = num_buckets,
        buckets = buckets,

        callbacks = {},
        expected_ticks = {},
        reuse_ids = {},
        total_ids = 0,

        curr_index = 0,
        curr_tick = 0,
        last_cb_id = 0
    }
end

---@param wheel TimeWheel
function M.get_id(wheel)
    local n = #wheel.reuse_ids

    if n > 0 then
        local id = wheel.reuse_ids[n]
        wheel.reuse_ids[n] = nil
        return id
    end

    wheel.total_ids = wheel.total_ids + 1
    return wheel.total_ids
end

---@param wheel TimeWheel
function M.clear_id(wheel, id)
    wheel.reuse_ids[#wheel.reuse_ids + 1] = id
    wheel.callbacks[id] = nil
    wheel.expected_ticks[id] = nil
end

---@param wheel TimeWheel
---@param dt integer
---@param callback fun(id : integer) : boolean | integer
function M.schedule(wheel, dt, callback)
    local id = M.get_id(wheel)
    assert(id ~= nil, "ERROR")

    wheel.callbacks[id] = callback

    local expected = wheel.curr_tick + dt
    local new_array = wheel.buckets[expected % wheel.num_buckets + 1]

    new_array[#new_array + 1] = id
    wheel.expected_ticks[id] = expected
end

---@param wheel TimeWheel
function M.reschedule(wheel, dt, id)
    local expected = wheel.curr_tick + dt
    local new_array = wheel.buckets[expected % wheel.num_buckets + 1]

    new_array[#new_array + 1] = id
    wheel.expected_ticks[id] = expected
end

---@param wheel TimeWheel
---@param size integer
---@param total_ticks integer
---@param dt_per_tick integer
---@param callback fun(start : integer, last : integer)
function M.split_task(wheel, size, total_ticks, dt_per_tick, callback)
    local dx = math.floor(size / total_ticks)
    local i = 0

    M.schedule(wheel, dt_per_tick, function()
        if i >= total_ticks then
            return false
        end

        local start = i * dx + 1
        local last = i < total_ticks and start + dx - 1 or size

        callback(start, last)

        i = i + 1
        return dt_per_tick
    end)
end

---@param wheel TimeWheel
function M.safe_run_tick(wheel)
    local ok, error = pcall(M.run_tick, wheel)

    if not ok then
        M.clear_id(wheel, wheel.last_cb_id)
        game.print("[SCHEDULER ERROR] " .. error)
    end
end

---@param wheel TimeWheel
function M.run_tick(wheel)
    wheel.curr_tick = wheel.curr_tick + 1
    wheel.curr_index = wheel.curr_tick % wheel.num_buckets + 1

    local curr_index = wheel.curr_index
    local array = wheel.buckets[curr_index]
    local size = #array
    local new_size = 0

    if size == 0 then
        return
    end

    local num_buckets = wheel.num_buckets
    local tick = wheel.curr_tick

    local buckets = wheel.buckets
    local callbacks = wheel.callbacks
    local reuse_ids = wheel.reuse_ids
    local expected_ticks = wheel.expected_ticks

    for i = 1, size do -- not meant to be readable
        local id = array[i]

        if tick >= expected_ticks[id] then
            wheel.last_cb_id = id
            local dt = callbacks[id](id)

            if dt == false then
                reuse_ids[#reuse_ids + 1] = id
                callbacks[id] = nil
                expected_ticks[id] = nil
            else
                if not dt or dt < 1 then
                    dt = 1
                end
                
                local expected = tick + dt
                local new_array = buckets[expected % num_buckets + 1]
                
                new_array[#new_array + 1] = id
                expected_ticks[id] = expected
            end

            array[i] = nil
        else
            new_size = new_size + 1
            array[new_size] = id
        end
    end
end

return M