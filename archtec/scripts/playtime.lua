local os, math = os, math

local current = {}

local key = "archtec:playtime"

local C = minetest.colorize

function archtec.get_session_playtime(name)
	if current[name] then
		return os.time() - current[name]
	else
		return 0
	end
end

function archtec.get_total_playtime(name)
	local player = minetest.get_player_by_name(name)
	if player then
		return player:get_meta():get_int(key) + archtec.get_session_playtime(name)
	end
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	meta:set_int(key, meta:get_int(key) + archtec.get_session_playtime(name))
	current[name] = nil
end)

minetest.register_on_joinplayer(function(player)
	current[player:get_player_name()] = os.time()
end)

local function divmod(a, b) return math.floor(a / b), a % b end

local function format_duration(seconds)
	local display_hours, seconds_left = divmod(seconds, 3600)
	local display_minutes, display_seconds = divmod(seconds_left, 60)
	return ("%02d:%02d:%02d"):format(display_hours, display_minutes, display_seconds)
end

minetest.register_chatcommand("playtime", {
	params = "player",
	description = ("See playtime on this server"),
	func = function(player, param)
		if minetest.get_player_by_name(param) then
			return true,
				C("#63d437", "Total: ")..C("#ffea00", format_duration(archtec.get_total_playtime(param))).."\n"..
				C("#63d437", "Current: ")..C("#ffea00", format_duration(archtec.get_session_playtime(param)))
		else
			return false, ("This player isn't online")
		end
	end,
})
