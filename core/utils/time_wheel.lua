local reg = require("core.utils.func_registry")
local funcs = reg.get()

---@class TimeWheel
---@field buckets integer[][]
---@field safe_buckets integer[][]
---@field bucket_size integer[]
---@field num_buckets integer
---@field cb_ids integer[]
---@field expected_ticks integer[]
---@field total_ids integer
---@field reuse_ids integer[]
---@field curr_index integer
---@field curr_tick integer
local M = {}

---@return TimeWheel
function M.create(num_buckets)
    local buckets = {}
    local safe_buckets = {}
    local bucket_size = {}

    for i = 1, num_buckets do
        buckets[i] = {}
        safe_buckets[i] = {}
        bucket_size[i] = 0
    end

    return {
        num_buckets = num_buckets,
        buckets = buckets,
        safe_buckets = safe_buckets,
        bucket_size = bucket_size,

        cb_ids = {},
        expected_ticks = {},
        reuse_ids = {},
        total_ids = 0,

        curr_index = 0,
        curr_tick = 0
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
function M.schedule(wheel, dt, callback)
    local id = M.get_id(wheel)
    wheel.cb_ids[id] = reg.register(callback)

    -- inline 
    local expected = wheel.curr_tick + dt
    local new_index = bit32.band(expected, wheel.num_buckets - 1) + 1

    local size = wheel.bucket_size[new_index] + 1
    wheel.bucket_size[new_index] = size

    wheel.buckets[new_index][size] = id
    wheel.expected_ticks[id] = expected
end

---@param wheel TimeWheel
function M.reschedule(wheel, dt, id)
    local expected = wheel.curr_tick + dt
    local new_index = bit32.band(expected, wheel.num_buckets - 1) + 1

    local size = wheel.bucket_size[new_index] + 1
    wheel.bucket_size[new_index] = size

    wheel.buckets[new_index][size] = id
    wheel.expected_ticks[id] = expected
end

---@param wheel TimeWheel
function M.tick(wheel)
    wheel.curr_tick = wheel.curr_tick + 1
    wheel.curr_index = bit32.band(wheel.curr_tick, wheel.num_buckets - 1) + 1
end

---@param wheel TimeWheel
function M.run_tick(wheel)
    M.tick(wheel)

    local funcs = funcs

    local curr_index = wheel.curr_index
    local n = wheel.bucket_size[curr_index]

    local array = wheel.buckets[curr_index]
    local safe_array = wheel.safe_buckets[curr_index]
    local tick = wheel.curr_tick

    local safe_size = 0
    local i = 1

    while i <= n do -- all inlined
        local id = array[i]

        if tick >= wheel.expected_ticks[id] then
            local dt = funcs[wheel.cb_ids[id]](id)

            if dt and dt > 0 then -- inline
                local expected = tick + dt
                local new_index = bit32.band(expected, wheel.num_buckets - 1) + 1

                local size = wheel.bucket_size[new_index] + 1
                wheel.bucket_size[new_index] = size

                wheel.buckets[new_index][size] = id
                wheel.expected_ticks[id] = expected
            else
                wheel.reuse_ids[#wheel.reuse_ids + 1] = id
            end

        else
            safe_size = safe_size + 1
            safe_array[safe_size] = id
        end

        i = i + 1
    end

    wheel.buckets[curr_index] = safe_array
    wheel.safe_buckets[curr_index] = array
    wheel.bucket_size[curr_index] = safe_size
end

return M