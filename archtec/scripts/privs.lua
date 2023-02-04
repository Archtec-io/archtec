minetest.register_privilege("staff", ("Archtec staff member priv"))
minetest.register_privilege("forceload", ("Allows you to forceload your machines"))
minetest.register_privilege("archtec_chainsaw", ("Allows you to use the chainsaw"))

local function grant_priv(player, priv)
    local privs = minetest.get_player_privs(player)
    privs[priv] = true
    minetest.set_player_privs(player, privs)
end

minetest.register_chatcommand("request_lava", {
	params = "",
	description = ("Request the lava bucket placment priv"),
	func = function(player, param)
        if minetest.check_player_privs(player, "adv_buckets") then
            minetest.chat_send_player(player, "[request_lava] You already have the 'adv_buckets' privilege")
            return
        end
        local playtime = archtec_playerdata.get(player, "playtime") or 0
        if playtime > 180000 then -- 50 h playtime
            grant_priv(player, "adv_buckets")
            minetest.chat_send_player(player, "[request_lava] Congratulations! You have been granted the 'adv_buckets' privilege")
            notifyTeam("[request_lava] Granted '" .. player .. "' the 'adv_buckets' priv")
        else
            minetest.chat_send_player(player, "[request_lava] You do not have 50 hours (or more) playtime.")
        end
	end
})

minetest.register_chatcommand("request_areas_high_limit", {
	params = "",
	description = ("Request the areas_high_limit priv"),
	func = function(player, param)
        if minetest.check_player_privs(player, "areas_high_limit") then
            minetest.chat_send_player(player, "[request_areas_high_limit] You already have the 'areas_high_limit' privilege")
            return
        end
        local playtime = archtec_playerdata.get(player, "playtime") or 0
        if playtime > 108000 then -- 30 h playtime
            grant_priv(player, "areas_high_limit")
            minetest.chat_send_player(player, "[request_areas_high_limit] Congratulations! You have been granted the 'areas_high_limit' privilege")
            notifyTeam("[request_areas_high_limit] Granted '" .. player .. "' the 'areas_high_limit' priv")
        else
            minetest.chat_send_player(player, "[request_areas_high_limit] You do not have 30 hours (or more) playtime.")
        end
	end
})