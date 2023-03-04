minetest.register_privilege("staff", ("Archtec staff member priv"))
minetest.register_privilege("forceload", ("Allows you to forceload your machines"))
minetest.register_privilege("archtec_chainsaw", ("Allows you to use the chainsaw"))

local C = minetest.colorize

minetest.register_chatcommand("request_areas_high_limit", {
	params = "",
	description = ("Request the areas_high_limit priv"),
	func = function(name, param)
        if minetest.check_player_privs(name, "areas_high_limit") then
            minetest.chat_send_player(name, C("#00BD00", "[request_areas_high_limit] You already have the 'areas_high_limit' privilege"))
            return
        end
        local playtime = archtec_playerdata.get(name, "playtime") or 0
        if playtime > 108000 then -- 30 h playtime
            archtec.grant_priv(name, "areas_high_limit")
            minetest.chat_send_player(name, C("#00BD00", "[request_areas_high_limit] Congratulations! You have been granted the 'areas_high_limit' privilege"))
            notifyTeam("[request_areas_high_limit] Granted '" .. name .. "' the 'areas_high_limit' priv")
        else
            minetest.chat_send_player(name, C("#FF0000", "[request_areas_high_limit] You do not have 30 hours (or more) playtime."))
        end
	end
})