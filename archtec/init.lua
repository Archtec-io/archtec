local before = minetest.get_us_time()
local modPath = minetest.get_modpath(minetest.get_current_modname())
local scriptsPath = modPath .. DIR_DELIM .. "scripts" .. DIR_DELIM

archtec = {}

dofile(scriptsPath.."common.lua")
dofile(scriptsPath.."notifyTeam.lua")
dofile(scriptsPath.."privs.lua")
dofile(scriptsPath.."userlimit.lua")
dofile(scriptsPath.."stats.lua")
dofile(scriptsPath.."shutdown.lua")
dofile(scriptsPath.."mapfix.lua")
dofile(scriptsPath.."prejoin.lua")
dofile(scriptsPath.."aliases.lua")
dofile(scriptsPath.."unregister.lua")
dofile(scriptsPath.."spawn.lua")
dofile(scriptsPath.."skybox.lua")
if minetest.get_modpath("mesecons") then
    dofile(scriptsPath.."mvps_stopper.lua")
end
dofile(scriptsPath.."death_messages.lua")
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
dofile(scriptsPath.."join_ratelimit.lua")
dofile(scriptsPath.."status.lua")
dofile(scriptsPath.."random_messages.lua")
dofile(scriptsPath.."split_long_msg.lua")
dofile(scriptsPath.."privs_cache.lua")
dofile(scriptsPath.."item_drop.lua")
dofile(scriptsPath.."abm.lua")
dofile(scriptsPath.."random_things.lua")
dofile(scriptsPath.."watch.lua")
dofile(scriptsPath.."fakedrawer.lua")
dofile(scriptsPath.."pairs_by_key.lua")
dofile(scriptsPath.."count_objects.lua")
dofile(scriptsPath.."instrument_mod.lua")
dofile(scriptsPath.."chainsaw.lua")
dofile(scriptsPath.."network_info.lua")
dofile(scriptsPath.."recipe_check.lua")
dofile(scriptsPath.."tool_break.lua")

if minetest.get_modpath("caverealms") then
    dofile(scriptsPath.."caverealms.lua")
end

if minetest.get_modpath("techage") then
    dofile(scriptsPath.."techage.lua")
end

local http = minetest.request_http_api()
if http then
    assert(loadfile(scriptsPath.."/report_webhook.lua"))(http)
    assert(loadfile(scriptsPath.."/geoip.lua"))(http)
end

minetest.register_on_mods_loaded(function()
    if not minetest.global_exists("discord") then
        discord = {}
        discord.send = function(...)
            -- dummy function
        end
    end
end)

local after = minetest.get_us_time()

print("Archtec: loaded. Loading took " .. (after - before) / 1000 .. " ms")
