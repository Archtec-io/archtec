local S = archtec.S
local C = core.colorize

core.register_privilege("staff", S("Archtec staff member priv"))
core.register_privilege("forceload", S("Allows you to forceload your machines"))
core.register_privilege("builder", S("Priv for builders on Archtec"))

-- Grant 'areas_high_limit'
archtec.big_areas_playtime = archtec.time.hours(30)

function archtec.check_areas_high_limit(name, privs)
	if privs.areas_high_limit then
		return true
	end

	local playtime = archtec_playerdata.get(name, "playtime")
	if playtime > archtec.big_areas_playtime then
		archtec.priv_grant(name, "areas_high_limit")
		core.chat_send_player(name, C("#00BD00", S("Congratulations! You have been granted the '@1' privilege.", "areas_high_limit")))
		archtec.notify_team("[areas_high_limit] Granted '" .. name .. "' the 'areas_high_limit' priv")
		return true
	end
end

-- revoke unknown privs
local function auto_revoke(name)
	local privs = core.get_player_privs(name)
	local revoke = {}
	-- revoke unknown privs
	for priv, _ in pairs(privs) do
		if not core.registered_privileges[priv] then
			table.insert(revoke, priv)
			archtec.priv_revoke(name, priv)
		end
	end
	if next(revoke) ~= nil then
		local privs_string = table.concat(revoke, ", ")
		-- core.chat_send_player(name, C("#FF0", "[archtec] Updated your privs (revoked: " .. privs_string .. ")"))
		core.log("action", "[auto_revoke] updated privs of '" .. name .. "' (revoked: " .. privs_string .. ")")
	end
end

core.register_on_joinplayer(function(player)
	auto_revoke(player:get_player_name())
end)

-- error when trying to start w/ unknown privs
core.register_on_mods_loaded(function()
	local failure = false
	local default_privs = core.string_to_privs(core.settings:get("default_privs"))
	for priv, _ in pairs(default_privs) do
		if not core.registered_privileges[priv] then
			failure = true
			core.log("error", "[archtec] '" .. priv .. "' is marked as default_priv but not registered!")
		end
	end
	if failure == true then
		error("Unknown privs in 'defaults_privs', please change the server config!")
	end
end)
