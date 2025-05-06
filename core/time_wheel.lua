---@class TimeWheel
---@field buckets integer[][]
---@field safe_buckets integer[][]
---@field bucket_size integer[]
---@field num_buckets integer
---@field callbacks function[]
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

        callbacks = {},
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
    wheel.callbacks[id] = callback

    local expected = wheel.curr_tick + dt
    local new_bucket = bit32.band(expected, wheel.num_buckets - 1) + 1

    local size = wheel.bucket_size[new_bucket] + 1
    wheel.bucket_size[new_bucket] = size

    wheel.buckets[new_bucket][size] = id
    wheel.expected_ticks[id] = expected
end

---@param wheel TimeWheel
function M.reschedule(wheel, dt, id)
    local expected = wheel.curr_tick + dt
    local new_bucket = bit32.band(expected, wheel.num_buckets - 1) + 1

    local size = wheel.bucket_size[new_bucket] + 1
    wheel.bucket_size[new_bucket] = size

    wheel.buckets[new_bucket][size] = id
    wheel.expected_ticks[id] = expected
end

---@param wheel TimeWheel
function M.swap_buffers(wheel, index)
    local temp = wheel.buckets[index]
    wheel.buckets[index] = wheel.safe_buckets[index]
    wheel.safe_buckets[index] = temp
end

---@param wheel TimeWheel
function M.set_bucket_size(wheel, index, size)
    wheel.bucket_size[index] = size
end

---@param wheel TimeWheel
function M.get_bucket_size(wheel, index)
    return wheel.bucket_size[index]
end

---@param wheel TimeWheel
function M.tick(wheel)
    wheel.curr_tick = wheel.curr_tick + 1
    wheel.curr_index = bit32.band(wheel.curr_tick, wheel.num_buckets - 1) + 1
end

---@param wheel TimeWheel
function M.safe_run_tick(wheel)
    local ok, error = pcall(M.run_tick, wheel)

    if not ok then
        game.print("[SCHEDULER ERROR] " .. error)
    end
end

---@param wheel TimeWheel
function M.run_tick(wheel)
    M.tick(wheel)

    local num_buckets = wheel.num_buckets
    local tick = wheel.curr_tick
    local curr_index = wheel.curr_index

    local size = M.get_bucket_size(wheel, curr_index)
    local new_size = 0

    if size == 0 then
        return
    end

    local array = wheel.buckets[curr_index]
    local safe_array = wheel.safe_buckets[curr_index]

    local buckets = wheel.buckets
    local callbacks = wheel.callbacks
    local reuse_ids = wheel.reuse_ids
    local bucket_size = wheel.bucket_size
    local expected_ticks = wheel.expected_ticks

    for i = 1, size do -- not meant to be readable
        local id = array[i]

        if tick >= expected_ticks[id] then
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
                local new_bucket = expected % num_buckets + 1

                local size = bucket_size[new_bucket] + 1
                bucket_size[new_bucket] = size

                buckets[new_bucket][size] = id
                expected_ticks[id] = expected
            end
        else
            new_size = new_size + 1
            safe_array[new_size] = id
        end
    end

    M.swap_buffers(wheel, curr_index)
    M.set_bucket_size(wheel, curr_index, new_size)
end

return M