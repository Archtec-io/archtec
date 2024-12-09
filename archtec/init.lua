local before = core.get_us_time()
local modpath = core.get_modpath("archtec")
local path = modpath .. "/scripts/"

archtec = {}
archtec.S = core.get_translator("archtec")

-- Change links here
archtec.links = {}
archtec.links.website = "https://archtec.niklp.net"
archtec.links.mapserver = "https://archmap.niklp.net"
archtec.links.discord = "https://discord.gg/txCMTMwBWm"
archtec.links.matrix = "https://matrix.to/#/#archtec:matrix.org"

-- Load files which provide API stuff first
dofile(path .. "common.lua")
dofile(path .. "notify_team.lua")
dofile(path .. "namecolor.lua")
dofile(path .. "settings.lua")
dofile(path .. "ignore.lua")
dofile(path .. "hud_api.lua")
dofile(path .. "xp.lua")

-- These files aren't (mostly) in a particular order
dofile(path .. "pvp.lua")
dofile(path .. "privs.lua")
dofile(path .. "serverstats.lua")
dofile(path .. "mapfix.lua")
dofile(path .. "prejoin.lua")
dofile(path .. "aliases.lua")
dofile(path .. "unregister.lua")
dofile(path .. "spawn.lua")
dofile(path .. "skybox.lua")
dofile(path .. "mvps_stopper.lua")
dofile(path .. "techage.lua")
dofile(path .. "death_messages.lua")
dofile(path .. "buckets.lua")
dofile(path .. "redef.lua")
dofile(path .. "run_lua_code.lua")
dofile(path .. "idlekick.lua")
dofile(path .. "crafting.lua")
dofile(path .. "df_detect.lua")
dofile(path .. "overrides.lua")
dofile(path .. "cheat_log.lua")
dofile(path .. "join_ratelimit.lua")
dofile(path .. "status.lua")
dofile(path .. "random_things.lua")
dofile(path .. "random_messages.lua")
dofile(path .. "privs_cache.lua")
dofile(path .. "item_drop.lua")
dofile(path .. "watch.lua")
dofile(path .. "fakedrawer.lua")
dofile(path .. "count_objects.lua")
dofile(path .. "instrument_mod.lua")
dofile(path .. "chainsaw.lua")
dofile(path .. "network_info.lua")
dofile(path .. "recipe_check.lua")
dofile(path .. "tool_break.lua")
dofile(path .. "ranks.lua")
dofile(path .. "music.lua")
dofile(path .. "node_limiter.lua")
dofile(path .. "news.lua")
dofile(path .. "lock.lua")
dofile(path .. "waypoints.lua")
dofile(path .. "luac_logging.lua")
dofile(path .. "faq.lua")
dofile(path .. "faq_content.lua")
dofile(path .. "playerlist.lua")
dofile(path .. "dummies.lua")
dofile(path .. "snow.lua")
dofile(path .. "optimize_abm_lbm.lua")
dofile(path .. "perf_logging.lua")
dofile(path .. "playtime.lua")
dofile(path .. "msg_offline.lua")
dofile(path .. "mailbox.lua")
dofile(path .. "playerstats.lua")
dofile(path .. "teleport_mapblock.lua")
dofile(path .. "xdecor_tools.lua")

local http = core.request_http_api()
if http then
	assert(loadfile(path .. "/report_webhook.lua"))(http)
	assert(loadfile(path .. "/geoip.lua"))(http)
	assert(loadfile(path .. "/vpn_blocker.lua"))(http)
end

core.register_on_mods_loaded(function()
	if not core.global_exists("archtec_matterbridge") then
		archtec_matterbridge = {}
		archtec_matterbridge.send = function(...)
			-- dummy function
		end
	end
end)

local after = core.get_us_time()

core.log("action", "Archtec: loaded. Loading took " .. (after - before) / 1000 .. " ms")
