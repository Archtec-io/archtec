local modPath = minetest.get_modpath(minetest.get_current_modname())
local scriptsPath = modPath..DIR_DELIM.."scripts"..DIR_DELIM

archtec = {}

dofile(scriptsPath.."discord_fallback.lua")
dofile(scriptsPath.."notifyTeam.lua")
dofile(scriptsPath.."privs.lua")
dofile(scriptsPath.."userlimit.lua")
dofile(scriptsPath.."stats.lua")
dofile(scriptsPath.."shutdown.lua")
dofile(scriptsPath.."mapfix.lua")
dofile(scriptsPath.."prejoin.lua")
dofile(scriptsPath.."disallow_new_players.lua")
dofile(scriptsPath.."aliases.lua")
dofile(scriptsPath.."unregister.lua")
dofile(scriptsPath.."spawn.lua")
dofile(scriptsPath.."skybox.lua")
dofile(scriptsPath.."lua_mem.lua")
dofile(scriptsPath.."homedecor_wardrobe.lua")
dofile(scriptsPath.."mvps_stopper.lua")
dofile(scriptsPath.."death_messages.lua")
dofile(scriptsPath.."zipper_detect.lua")
dofile(scriptsPath.."buckets.lua")
dofile(scriptsPath.."redef.lua")
dofile(scriptsPath.."run_lua_code.lua")
dofile(scriptsPath.."idlekick.lua")
dofile(scriptsPath.."shutdown.lua")
dofile(scriptsPath.."discord.lua")
dofile(scriptsPath.."crafting.lua")
dofile(scriptsPath.."df_detect.lua")
dofile(scriptsPath.."overrides.lua")
dofile(scriptsPath.."cheat_log.lua")
dofile(scriptsPath.."playtime.lua")
dofile(scriptsPath.."join_ratelimit.lua")
dofile(scriptsPath.."status.lua")
dofile(scriptsPath.."random_messages.lua")

if minetest.get_modpath("caverealms") then
    dofile(scriptsPath.."caverealms.lua")
end

if minetest.get_modpath("techage") then
    dofile(scriptsPath.."techage.lua")
end

local http = minetest.request_http_api()
if http then
    assert(loadfile(scriptsPath.."/report_webhook.lua"))(http)
end
