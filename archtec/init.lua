local modPath = minetest.get_modpath(minetest.get_current_modname())
local scriptsPath = modPath..DIR_DELIM.."scripts"..DIR_DELIM

dofile(scriptsPath.."notifyTeam.lua")
dofile(scriptsPath.."userlimit.lua")
dofile(scriptsPath.."stats.lua")
dofile(scriptsPath.."shutdown.lua")
dofile(scriptsPath.."mapfix.lua")
dofile(scriptsPath.."prejoin.lua")
dofile(scriptsPath.."disallow_new_players.lua")
dofile(scriptsPath.."aliases.lua")
dofile(scriptsPath.."unregister.lua")
dofile(scriptsPath.."spawn.lua")
dofile(scriptsPath.."caverealms.lua")
dofile(scriptsPath.."skybox.lua")
dofile(scriptsPath.."lua_mem.lua")

local http = minetest.request_http_api()
if http then
    assert(loadfile(scriptsPath.."/report_webhook.lua"))(http)
end

if minetest.get_modpath("chatplus_discord") then
    dofile(scriptsPath.."death_messages.lua")
    dofile(scriptsPath.."idlekick.lua")
    dofile(scriptsPath.."shutdown.lua")
end

if minetest.get_modpath("homedecor_wardrobe") then
    dofile(scriptsPath.."homedecor_wardrobe.lua")
end