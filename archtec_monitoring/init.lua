monitoring = {
	metrics = {},
	metrics_mapped = {}, -- metrics mapped by name as key
	settings = {
		prom_push_url = minetest.settings:get("monitoring.prometheus_push_url"),
	}
}

local http = minetest.request_http_api()
local MP = minetest.get_modpath("archtec_monitoring")

dofile(MP.."/metrictypes/gauge.lua")
dofile(MP.."/metrictypes/counter.lua")
dofile(MP.."/metrictypes/histogram.lua")

dofile(MP.."/chatcommands.lua")
dofile(MP.."/register.lua")

loadfile(MP.."/export/prometheus_push.lua")(http)

dofile(MP.."/builtin/version.lua")
dofile(MP.."/builtin/abm_calls.lua")
dofile(MP.."/builtin/api.lua")
dofile(MP.."/builtin/auth_fail.lua")
dofile(MP.."/builtin/forceload_blocks.lua")
dofile(MP.."/builtin/after.lua")
dofile(MP.."/builtin/generated.lua")
dofile(MP.."/builtin/globalstep.lua")
dofile(MP.."/builtin/jit.lua")
dofile(MP.."/builtin/join_count.lua")
dofile(MP.."/builtin/lag.lua")
dofile(MP.."/builtin/lbm_calls.lua")
dofile(MP.."/builtin/leave_count.lua")
dofile(MP.."/builtin/luamem.lua")
dofile(MP.."/builtin/nodetimer_calls.lua")
dofile(MP.."/builtin/on_joinplayer.lua")
dofile(MP.."/builtin/on_prejoinplayer.lua")
dofile(MP.."/builtin/on_step.lua")
dofile(MP.."/builtin/playercount.lua")
dofile(MP.."/builtin/registered_count.lua")
dofile(MP.."/builtin/ticks.lua")
dofile(MP.."/builtin/time.lua")
dofile(MP.."/builtin/uptime.lua")
dofile(MP.."/builtin/settings.lua")

if minetest.get_modpath("digilines") then
	minetest.log("action", "[archtec_monitoring] Enabling digilines integrations")
	dofile(MP.."/mods/digilines/init.lua")
end

if minetest.get_modpath("mesecons") then
	minetest.log("action", "[archtec_monitoring] Enabling mesecons integrations")
	dofile(MP.."/mods/mesecons/action_on.lua")
	dofile(MP.."/mods/mesecons/functions.lua")
	dofile(MP.."/mods/mesecons/globals.lua")
	dofile(MP.."/mods/mesecons/luac.lua")
	dofile(MP.."/mods/mesecons/queue.lua")
end

if monitoring.settings.prom_push_url ~= "" then
	if not http then
		error("[archtec_monitoring] No HTTP available!")
	end

	minetest.log("action", "[archtec_monitoring] Enabling prometheus push")
	monitoring.prometheus_push_init()
else
	minetest.log("warning", "[archtec_monitoring] No push URL provided, monitoring disabled!")
end
