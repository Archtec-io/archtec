local max_users = tonumber(core.settings:get("max_users"))
local old_get_server_status = core.get_server_status

function core.get_server_status(player_name, login)
	local status = old_get_server_status(player_name, login)
	local text, game, uptime, names = status:match("^# Server: (.*) game: (.*) uptime: (.*) clients: (.*)")

	if not (text and game and names) then
		return status
	end

	return ("Archtec: %s uptime: %s clients (%i/%i): %s"):format(
		text,
		uptime,
		#core.get_connected_players(),
		max_users,
		names
	)
end
