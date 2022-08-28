--  Vps Blocker

local http = minetest.request_http_api()
assert(http ~= nil, "You need to add archtec_vpn_blocker to secure.http_mods")

local kick_message = "You are using a proxy, vpn or other hosting services, please disable them to play on this server."

archtec_vpn_blocker = {}
local cache = {}
local storage = minetest.get_mod_storage()

local checkers = {}

function archtec_vpn_blocker.register_checker(check)
  assert(type(check) == "table")
  check.active = true
  assert(type(check.getreq) == "function")
  --  Dummy testing function:
  local req, call = check.getreq("0.0.0.0")
  assert(type(req) == "table")
  assert(type(req.url == "string"))
  assert(type(call) == "function")
  table.insert(checkers, check)
end

--  Load checkers
dofile(minetest.get_modpath(minetest.get_current_modname()).. "/checker.lua")

--  Add the main ipcheckup function
local function check_ip(name, ip, hash)
  --  Loop throught the list of checkers and use one
  local checked = false
  for _, check in pairs(checkers) do
    if check.active then
      local req, call = check.getreq(ip)
      if req then
        local function callback(result)
          local pass, err = call(result)
          if pass then
            cache[hash] = 1
            minetest.log("action", "archtec_vpn_blocker: Passing good-ip-player "..name.." ["..ip.."]")
          elseif pass == false then
            cache[hash] = 2
            minetest.log("action", "archtec_vpn_blocker: Kicking bad-ip-player "..name.." ["..ip.."]")
          else minetest.log("error", "archtec_vpn_blocker: Callback-Error "..err.." while checking "..name.." ["..ip.."]!")
          end
        end
        http.fetch(req, callback)
        checked = true
        break
      else minetest.log("error", "archtec_vpn_blocker: Checker failed to create requests for "..name.." ["..ip.."]!")
      end
    end
  end
  --  Report error if no working was found
  if not checked then
    minetest.log("error", "archtec_vpn_blocker: No working checker found!")
  end
end

--  Add a function which handels what do do(check, kick, nth...)
function archtec_vpn_blocker.handle_player(name, ip)
  if not ip or not name then
    return
  end
  local iphash = minetest.sha1(ip)
  if not iphash then
    return
  end
  if cache[iphash] == 1 or storage:get_int(name) == 1 then
    return
  end
  if not cache[iphash] then
    check_ip(name, ip, iphash)
    return
  end
  if cache[iphash] == 2 then
    local player = minetest.get_player_by_name(name)
    if player then
      --  Kick after a server step, to prevent other on_joinplayer to crash
      minetest.after(0, function()
        minetest.kick_player(name, kick_message)
      end)
    else return kick_message
    end
  end
end

--  Do handle_player on prejoin and normal join
minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  local ip = minetest.get_player_ip(name)
  archtec_vpn_blocker.handle_player(name, ip)
end)

--  Add a command to whitelist players
minetest.register_chatcommand("vps_wl", {
  description = "Allow a player to use vps services.",
  params = "<add or remove> <name>",
  privs = {server=true},
  func = function(name, params)
    local p = string.split(params, " ")
    if p[1] == "add" then
      storage:set_int(p[2], 1)
      return true, "Added "..p[2].." to the whitelist."
    elseif p[1] == "remove" then
      storage:set_int(p[2], 0)
      return true, "Removed "..p[2].." from the whitelist."
    else return false, "Invalid Input"
    end
  end
})
