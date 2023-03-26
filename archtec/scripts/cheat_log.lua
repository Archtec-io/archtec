local function round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

local times = {}
local pd_cache = {}

local function get_pd(player, name)
    local t = os.time()
    if pd_cache[name] and times[name] and times[name] > t - 2 then -- get info all 2 sec
        return pd_cache[name]
    else
        local info = minetest.get_player_information(name)
        times[name] = t
        pd_cache[name] = info
        return info
    end
end

local function handle_cheat(player, cheat)
    local name = player:get_player_name()
    local speed = player:get_velocity()
    local lag = minetest.get_server_max_lag()
    local pos = player:get_pos()
    for i, x in pairs(speed) do
        speed[i] = round(x)
    end
    for i, x in pairs(pos) do
        pos[i] = round(x)
    end
    local info = get_pd(player, name)
    notifyTeam("[archtec] Anticheat: player '" .. name .. "' ('" .. cheat.type .. "') speed: " .. tostring(speed) .. " pos: " .. tostring(pos) .. " lag: " .. lag .. " jitter: " .. info.avg_jitter .. " rtt: " .. info.avg_rtt)
end

minetest.register_on_cheat(function(player, cheat)
    if not player:is_player() then return end
    if cheat.type == "dug_unbreakable" or cheat.type == "finished_unknown_dig" then return end
    if cheat.type == "moved_too_fast" then
        handle_cheat(player, cheat)
    else
        notifyTeam("[archtec] Anticheat: player '" .. player:get_player_name() .. "' ('" .. cheat.type .. "')")
    end
end)

minetest.register_on_leaveplayer(function(player)
    if player then
        local name = player:get_player_name()
        times[name] = nil
        pd_cache[name] = nil
    end
end)
