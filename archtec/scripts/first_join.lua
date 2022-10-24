local key = "archtec:joined"

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
            minetest.chat_send_player(player, "First join of " .. param .. ": " .. archtec.get_first_join_date(param))
        else
            minetest.chat_send_player(player, "First join of " .. player .. ": " .. archtec.get_first_join_date(player))
		end
	end
})
