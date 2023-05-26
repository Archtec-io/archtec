local http = minetest.request_http_api()
local iphub_key = minetest.settings:get("iphub_key")
assert(http ~= nil, "You need to add archtec_vpn_blocker to secure.http_mods")

local cache, ttl = {}, 14400 -- 4 h

local function cleanup()
    local expire = os.time() - ttl
    for ip, d in pairs(cache) do
        if d.expire < expire then
            cache[ip] = nil
        end
    end
    minetest.after(ttl, cleanup)
end
minetest.after(ttl, cleanup)

--  Add the main ipcheckup function
local function check_ip(name, ip)
    local request = {
        ["url"] = "https://v2.api.iphub.info/ip/" .. ip,
        ["extra_headers"] = {"X-Key: " .. iphub_key}
    }
    if cache[ip] then
        return cache[ip].result
    end
    http.fetch(request, function(result)
        if result.code == 429 then
            return
        end
        local data = minetest.parse_json(result.data)
        if result.completed and result.succeeded and data and data.block then
            if data.block == 0 then
                minetest.log("action", "archtec_vpn_blocker: Passing good-ip-player " .. name .. " [" .. ip .. "]")
            else
                minetest.log("action", "archtec_vpn_blocker: Kicking bad-ip-player " .. name .. " [" .. ip .. "]")
                notifyTeam("[archtec_vpn_blocker] Kicking bad-ip-player ".. name .."' (IP: " .. ip .. ")")
                minetest.after(0.01, function()
                    if minetest.get_player_by_name(name) then
                        minetest.log("action", "[archtec_vpn_blocker] kicked '" .. name .. "'")
                        minetest.kick_player(name, "Please turn off your VPN.")
                    end
                end)
            end
            cache[ip] = {}
            cache[ip].result = data.block
            cache[ip].expire = os.time()
        else
			return
        end
    end)
end

local function handle_player(name, ip)
	if not ip or not name then
		return
	end
	check_ip(name, ip)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local ip = minetest.get_player_ip(name)
	handle_player(name, ip)
end)
