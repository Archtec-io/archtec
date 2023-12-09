local before = minetest.get_us_time()
local modpath = minetest.get_modpath("archtec")
local path = modpath .. "/scripts/"

archtec = {}
archtec.S = minetest.get_translator("archtec")
archtec.version_major = 23
archtec.version_minor = 12

dofile(path.."common.lua")
dofile(path.."notifyTeam.lua")
dofile(path.."settings.lua")
dofile(path.."ignore.lua")
dofile(path.."privs.lua")
dofile(path.."stats.lua")
dofile(path.."mapfix.lua")
dofile(path.."prejoin.lua")
dofile(path.."aliases.lua")
dofile(path.."unregister.lua")
dofile(path.."spawn.lua")
dofile(path.."skybox.lua")
dofile(path.."mvps_stopper.lua")
dofile(path.."techage.lua")
dofile(path.."death_messages.lua")
dofile(path.."buckets.lua")
dofile(path.."redef.lua")
dofile(path.."run_lua_code.lua")
dofile(path.."idlekick.lua")
dofile(path.."crafting.lua")
dofile(path.."df_detect.lua")
dofile(path.."overrides.lua")
dofile(path.."cheat_log.lua")
dofile(path.."join_ratelimit.lua")
dofile(path.."status.lua")
dofile(path.."random_things.lua")
dofile(path.."random_messages.lua")
dofile(path.."privs_cache.lua")
dofile(path.."item_drop.lua")
dofile(path.."abm.lua")
dofile(path.."watch.lua")
dofile(path.."fakedrawer.lua")
dofile(path.."count_objects.lua")
dofile(path.."instrument_mod.lua")
dofile(path.."chainsaw.lua")
dofile(path.."network_info.lua")
dofile(path.."recipe_check.lua")
dofile(path.."tool_break.lua")
dofile(path.."ranks.lua")
dofile(path.."music.lua")
dofile(path.."node_limiter.lua")
dofile(path.."news.lua")
dofile(path.."lock.lua")
dofile(path.."waypoints.lua")
dofile(path.."luac_logging.lua")
dofile(path.."faq.lua")
dofile(path.."faq_content.lua")
dofile(path.."spawn_post.lua")
dofile(path.."playerlist.lua")
dofile(path.."dummies.lua")
dofile(path.."snow.lua")

local http = minetest.request_http_api()
if http then
	assert(loadfile(path.."/report_webhook.lua"))(http)
	assert(loadfile(path.."/geoip.lua"))(http)
	assert(loadfile(path.."/vpn_blocker.lua"))(http)
end

minetest.register_on_mods_loaded(function()
	if not minetest.global_exists("archtec_matterbridge") then
		archtec_matterbridge = {}
		archtec_matterbridge.send = function(...)
			-- dummy function
		end
	end
	if not minetest.global_exists("futil") then
		futil = {table = {}}
		futil.table.pairs_by_key = function(...) return ... end
	end
	-- CI pipeline
	if minetest.settings:get("archtec.ci") then
		minetest.log("action", "Server will shutdown in a few seconds!")
		minetest.after(10, function()
			minetest.request_shutdown("CI")
		end)
	end
end)

local after = minetest.get_us_time()

minetest.log("action", "Archtec: loaded. Loading took " .. (after - before) / 1000 .. " ms")
