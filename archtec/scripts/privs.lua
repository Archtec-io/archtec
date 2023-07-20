local S = archtec.S

minetest.register_privilege("staff", (S("Archtec staff member priv")))
minetest.register_privilege("forceload", (S("Allows you to forceload your machines")))
minetest.register_privilege("archtec_chainsaw", (S("Allows you to use the chainsaw")))

local C = minetest.colorize
archtec.big_areas_playtime = 108000 -- 30h playtime

minetest.register_chatcommand("request_areas_high_limit", {
	params = "",
	description = ("Request the areas_high_limit priv"),
	func = function(name)
		minetest.log("action", "[/request_areas_high_limit] executed by '" .. name .. "'")
		if minetest.check_player_privs(name, "areas_high_limit") then
			minetest.chat_send_player(name, C("#00BD00", S("[request_areas_high_limit] You already have the 'areas_high_limit' privilege")))
			return
		end
		local playtime = archtec_playerdata.get(name, "playtime") or 0
		if playtime > archtec.big_areas_playtime then
			archtec.grant_priv(name, "areas_high_limit")
			minetest.chat_send_player(name, C("#00BD00", S("[request_areas_high_limit] Congratulations! You have been granted the 'areas_high_limit' privilege")))
			notifyTeam("[request_areas_high_limit] Granted '" .. name .. "' the 'areas_high_limit' priv")
		else
			minetest.chat_send_player(name, C("#FF0000", S("[request_areas_high_limit] You do not have 30 hours (or more) playtime.")))
		end
	end
})

-- revoke unknown privs
local reg_privs = minetest.registered_privileges

local function auto_revoke(name)
	local privs = minetest.get_player_privs(name)
	local revoke = {}
	-- revoke unknown privs
	for priv, _ in pairs(privs) do
		if not reg_privs[priv] then
			table.insert(revoke, priv)
			archtec.revoke_priv(name, priv)
		end
	end
	if next(revoke) ~= nil then
		local privs_string = table.concat(revoke, ", ")
		minetest.chat_send_player(name, C("#FF0", "[archtec] Updated your privs (revoked: " .. privs_string .. ")"))
		minetest.log("action", "[auto_revoke] updated privs of '" .. name ..  "' (revoked: " .. privs_string .. ")")
	end
end

minetest.register_on_joinplayer(function(player)
	if player then
		auto_revoke(player:get_player_name())
	end
end)

-- error when trying to start w/ unknown privs
minetest.register_on_mods_loaded(function()
	local errors = {}
	local default_privs = minetest.string_to_privs(minetest.settings:get("default_privs"))
	for priv, _ in pairs(default_privs) do
		if not reg_privs[priv] then
			table.insert(errors, "[archtec] '" .. priv .. "' is marked as 'default_priv' but not registered!")
		end
	end
	if next(errors) ~= nil then
		for _, msg in ipairs(errors) do
			minetest.log("error", msg)
		end
		error("Please change the server config!")
	end
end)