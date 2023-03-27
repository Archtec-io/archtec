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

local function auto_grant_revoke(name)
    local privs = minetest.get_player_privs(name)
    -- local grant = {}
    local revoke = {}
    if privs["travelnet_attach"] then
        table.insert(revoke, "travelnet_attach")
        archtec.revoke_priv(name, "travelnet_attach")
    end
    if privs["travelnet_remove"] then
        table.insert(revoke, "travelnet_remove")
        archtec.revoke_priv(name, "travelnet_remove")
    end
    minetest.chat_send_player(name, C("#FF0", "[archtec] Updated your privs (revoked: " .. table.concat(revoke, ", ") .. ")"))
    minetest.log("action", "[auto_grant_revoke] updated privs of '" .. name ..  "' (revoked: " .. table.concat(revoke, ", ") .. ")")
end

minetest.register_on_joinplayer(function(player)
    if player then
        auto_grant_revoke(player:get_player_name())
    end
end)