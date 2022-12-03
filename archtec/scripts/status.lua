local max_users = tonumber(minetest.settings:get("max_users"))
local old_get_server_status = minetest.get_server_status
local s_lag = 0

function minetest.get_server_status(player_name, login)
	local status = old_get_server_status(player_name, login)
	local text, game, uptime, maxlag, names = status:match("^# Server: (.*) game: (.*) uptime: (.*) max lag: (.*) clients: (.*)")

	if not (text and game and uptime and maxlag and names) then
		return status
	end

	return ("Archtec: %s uptime: %s %s clients (%i/%i): %s"):format(
		text,
		uptime,
		s_lag,
		#minetest.get_connected_players(),
		max_users,
		names
	)
end

local l_time = 0
local l_N = 2048
local l_samples = {}
local l_ctr = 0
local l_sumsq = 0
local l_sum = 0

minetest.register_globalstep(function (dtime)
	local news = os.clock() - l_time
	if l_time == 0 then
		news = 0.1
	end
	l_time = os.clock()

	local olds = l_samples[l_ctr+1] or 0
	l_sumsq = l_sumsq - olds * olds + news * news
	l_sum = l_sum - olds + news

	l_samples[l_ctr + 1] = news

	l_ctr = (l_ctr + 1) % l_N

	if l_ctr == 0 then
		-- recalculate from scratch
		l_sumsq = 0
		l_sum = 0
		for i = 1, l_N do
			local sample = l_samples[i]
			l_sumsq = l_sumsq + sample * sample
			l_sum = l_sum + sample
		end
	end

	if news < 0.09 then
		news = 0.09
	end

	local l_avg = l_sumsq / l_sum
	if l_avg < 0.09 then
		l_avg = 0.09
	end

	local max_lag = minetest.get_server_max_lag()
	s_lag = string.format("lag: %.2f avg: %.2f max: %.2f |", news, l_avg, max_lag)
end)
