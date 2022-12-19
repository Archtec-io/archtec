local key = "archtec:joined"
local C = minetest.colorize

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
    if meta:get_string(key) == "" then
        local time = os.date()
	    meta:set_string(key, time)
    end
end)

function archtec.get_first_join_date(name)
	local player = minetest.get_player_by_name(name)
	if player then
		return player:get_meta():get_string(key)
	end
end

minetest.register_chatcommand("joined", {
	params = "<player>",
	description = ("See when a player first joined the server"),
	func = function(player, param)
		if minetest.get_player_by_name(param) then
			return true,
            C("#63d437", "First join of: ") .. C("#ffea00", param) .. "\n" ..
			C("#63d437", "Date: ") .. C("#ffea00", archtec.get_first_join_date(param))
        elseif minetest.get_player_by_name(player) then
			return true,
            C("#63d437", "First join of: ") .. C("#ffea00", player) .. "\n" ..
			C("#63d437", "Date: ") .. C("#ffea00", archtec.get_first_join_date(player))
		else
			return false, C("#ff0000", "This player isn't online")
		end
	end
})
