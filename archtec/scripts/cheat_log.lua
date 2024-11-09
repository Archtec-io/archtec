local function round(x)
	return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

-- https://stackoverflow.com/a/50082540
local function short(number, decimals)
	local power = 10^decimals
	return math.floor(number * power) / power
end

local times = {}
local pd_cache = {}

local function get_pd(name)
	local t = os.time()
	if pd_cache[name] and times[name] and times[name] > t - 2 then -- get info all 2 sec
		return pd_cache[name]
	else
		local info = core.get_player_information(name)
		times[name] = t
		pd_cache[name] = info
		return info
	end
end

local function handle_cheat(player, cheat)
	local name = player:get_player_name()
	local speed = player:get_velocity()
	local lag = short(core.get_server_max_lag(), 2)
	local pos = player:get_pos()
	for i, x in pairs(speed) do
		speed[i] = round(x)
	end
	for i, x in pairs(pos) do
		pos[i] = round(x)
	end
	local info = get_pd(name)
	archtec.notify_team("[archtec] Anticheat: player '" .. name .. "' ('" .. cheat.type .. "') speed: " .. tostring(speed) .. " pos: " .. tostring(pos) .. " lag: " .. lag .. " jitter: " .. short(info.avg_jitter, 7) .. " rtt: " .. short(info.avg_rtt, 5), false)
end

core.register_on_cheat(function(player, cheat)
	if not player:is_player() then return end
	if cheat.type == "dug_unbreakable" or cheat.type == "finished_unknown_dig" then return end
	if cheat.type == "moved_too_fast" then
		handle_cheat(player, cheat)
	else
		archtec.notify_team("[archtec] Anticheat: player '" .. player:get_player_name() .. "' ('" .. cheat.type .. "')", false)
	end
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	times[name] = nil
	pd_cache[name] = nil
end)
