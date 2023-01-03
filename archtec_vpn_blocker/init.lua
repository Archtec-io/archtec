local http = minetest.request_http_api()
assert(http ~= nil, "You need to add archtec_vpn_blocker to secure.http_mods")

archtec_vpn_blocker = {}
local iphub_key = minetest.settings:get("iphub_key")

--  Add the main ipcheckup function
local function check_ip(name, ip, hash)
  local request = {
    ["url"] = "https://v2.api.iphub.info/ip/" .. ip,
    ["extra_headers"] = {"X-Key: " .. iphub_key}
  }
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
            minetest.kick_player(name, "You are using a proxy, vpn or other hosting services, please disable them to play on this server.")
          end
        end)
      end
    else
      return
    end
  end)
end

function archtec_vpn_blocker.handle_player(name, ip)
  if not ip or not name then
    return
  end
  local iphash = minetest.sha1(ip)
  if not iphash then
    return
  end
  check_ip(name, ip, iphash)
end

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  local ip = minetest.get_player_ip(name)
  archtec_vpn_blocker.handle_player(name, ip)
end)
