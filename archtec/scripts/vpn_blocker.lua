local http = assert(...)
local iphub_key = core.settings:get("archtec.iphub_key")

archtec_playerdata.register_key("vpn_allowed", "boolean", false)
archtec.vpn_blocker_enabled = true

if not iphub_key or iphub_key == "" then
	archtec.vpn_blocker_enabled = false
	core.log("warning", "[archtec] No IPHub key provided!")
	return
end

local cache = {}
local ttl = archtec.time.hours(4)

local function cleanup()
	local expire = os.time() - ttl
	for ip, d in pairs(cache) do
		if d.expire < expire then
			cache[ip] = nil
		end
	end
	core.after(ttl, cleanup)
end
core.after(ttl, cleanup)

local function check_ip(name, ip)
	if not cache[ip] then return end
	if cache[ip].result == 0 then
		core.log("action", "[vpn] Passing good-ip-player " .. name .. " [" .. ip .. "]")
	else
		if archtec.is_online(name) then
			if archtec_playerdata.get(name, "vpn_allowed") then
				core.log("action", "[vpn] Passing bad-ip-player " .. name .. " [" .. ip .. "] [VPN ALLOWED]")
				archtec.notify_team("[vpn] Passing bad-ip-player '" .. name .. "' (IP: " .. ip .. ") [VPN ALLOWED]")
			else
				core.log("action", "[vpn] Kicking bad-ip-player " .. name .. " [" .. ip .. "]")
				archtec.notify_team("[vpn] Kicking bad-ip-player '" .. name .. "' (IP: " .. ip .. ")")
				core.after(0.01, function()
					if core.get_player_by_name(name) then
						core.kick_player(name, "Please turn off your VPN.")
					end
				end)
			end
		else -- Player is joining right now
			if archtec_playerdata.get(name, "vpn_allowed") then
				core.log("action", "[vpn] Passing bad-ip-player " .. name .. " [" .. ip .. "] [VPN ALLOWED]")
				archtec.notify_team("[vpn] Passing bad-ip-player '" .. name .. "' (IP: " .. ip .. ") [VPN ALLOWED]")
			else
				core.log("action", "[vpn] Blocking bad-ip-player " .. name .. " [" .. ip .. "]")
				archtec.notify_team("[vpn] Blocking bad-ip-player '" .. name .. "' (IP: " .. ip .. ")")
				return true -- For prejoinplayer callback
			end
		end
	end
end

local function query_ip(name, ip)
	local request = {
		["url"] = "https://v2.api.iphub.info/ip/" .. ip,
		["extra_headers"] = {"X-Key: " .. iphub_key}
	}
	http.fetch(request, function(result)
		if result.code == 429 then
			return
		end
		local data = core.parse_json(result.data)
		if result.completed and result.succeeded and data and data.block then
			cache[ip] = {result = data.block, expire = os.time()}
			check_ip(name, ip)
		else
			return
		end
	end)
end

local function vpn_check(name, ip, query)
	if not archtec.vpn_blocker_enabled then return end -- Kill switch
	if not cache[ip] and query then
		query_ip(name, ip)
		return
	end
	return check_ip(name, ip)
end

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local ip = core.get_player_ip(name)
	if name and ip then
		vpn_check(name, ip, true)
	end
end)

core.register_on_prejoinplayer(function(name, ip) -- on_authplayer won't work
	if name and ip then
		if vpn_check(name, ip, false) then -- Don't query a http request but block if in cache
			return "Please turn off your VPN."
		end
	end
end)
