-- Based on https://github.com/mt-mods/beowulf/blob/master/df_detect.lua
local mp = core.get_modpath("archtec")
local client_hashes = {}
local ip_list = {}

-- Read hashes from generated files
for _, filename in ipairs(core.get_dir_list(mp .. "/hashes")) do
	local file = io.open(mp .. "/hashes/" .. filename)
	for line in file:lines() do
		client_hashes[#client_hashes + 1] = line:sub(line:find("^([^ ]*)"))
	end
	file:close()
end

core.log("action", "[archtec] Loaded " .. #client_hashes .. " cheat client hashes")

local function check_version_string(s)
	for _, v in ipairs(client_hashes) do
		if s:find(v) then
			return v
		end
	end
end

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local info = core.get_player_information(name)
	local version = info.version_string

	if not version then
		archtec.notify_team("[login] Client detection failed!")
	else
		archtec.notify_team("[login] (3) Client info for '" .. name .. "': Client: " .. version .. " FS-V: " .. info.formspec_version)

		local client_version = check_version_string(version)
		if client_version then
			archtec.notify_team("[login] Detected use of Cheatclient (" .. client_version .. ") by '" .. name .. "' auto ban in 30 seconds.")
			core.after(30.0, function()
				xban.ban_player(name, "Server", nil, "Cheating")
				archtec.notify_team("[archtec] Auto banned '" .. name .. "' for using a cheat client.")
			end)
		end
	end

	-- Check for other players w/ the same IP
	if info.address then
		ip_list[name] = info.address
		local same_ip = {}
		for user, ip in pairs(ip_list) do
			if ip == info.address then
				same_ip[#same_ip + 1] = user
			end
		end

		if #same_ip > 1 then
			archtec.notify_team("[archtec] IP " .. info.address .. " is currently used by " .. #same_ip .. " players: " .. table.concat(same_ip, ", ") .. ".")
		end
	end
end)

core.register_on_leaveplayer(function(player)
	ip_list[player:get_player_name()] = nil
end)
