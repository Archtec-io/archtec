local current = {}

local key = "archtec:playtime"

local C = minetest.colorize

local function divmod(a, b) return math.floor(a / b), a % b end

local function format_duration(seconds)
	local display_hours, seconds_left = divmod(seconds, 3600)
	local display_minutes, display_seconds = divmod(seconds_left, 60)
	return ("%02d:%02d:%02d"):format(display_hours, display_minutes, display_seconds)
end

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
		return archtec_playerdata.get(name, "playtime") + archtec.get_session_playtime(name)
	end
end

function archtec.get_total_playtime_format(name)
	return format_duration(archtec.get_total_playtime(name))
end

function archtec.playtimesave(name)
	archtec_playerdata.mod(name, "playtime", archtec.get_session_playtime(name))
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	current[name] = nil
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	current[name] = os.time()
	minetest.after(1, function()
		if player:is_player() then
			local meta = player:get_meta()
			if archtec_playerdata.get(name, "playtime") == 0 then
				archtec_playerdata.set(name, "playtime", player:get_meta():get_int(key))
				print(archtec_playerdata.get(name, "playtime"))
				meta:set_string(key, nil) -- remove playtime entry
				-- log
			end
		end
	end)
end)

minetest.register_chatcommand("playtime", {
	params = "<player>",
	description = ("See playtime on this server"),
	func = function(player, param)
		if minetest.get_player_by_name(param) then
			return true,
				C("#63d437", "Playtime of: ") .. C("#ffea00", param) .. "\n" ..
				C("#63d437", "Total: ") .. C("#ffea00", format_duration(archtec.get_total_playtime(param))) .. "\n" ..
				C("#63d437", "Current: ") .. C("#ffea00", format_duration(archtec.get_session_playtime(param)))
		elseif minetest.get_player_by_name(player) then
			return true,
				C("#63d437", "Playtime of: ") .. C("#ffea00", player) .. "\n" ..
				C("#63d437", "Total: ") .. C("#ffea00", format_duration(archtec.get_total_playtime(player))) .. "\n" ..
				C("#63d437", "Current: ") .. C("#ffea00", format_duration(archtec.get_session_playtime(player)))
		else
			return false, C("#ff0000", "This player isn't online")
		end
	end,
})
-- Support for offline players