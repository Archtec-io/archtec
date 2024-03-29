unused_args = false

ignore = {
	"631", -- Line is too long
}

globals = {
	"archtec",
	"archtec_chat",
	"archtec_matterbridge",
	"archtec_playerdata",
	"archtec_pvp",
	"archtec_teleport",
	"archtec_votes",
	"mapserver",
	"monitoring",
	"notifyTeam",
	"player_monoids",
}

read_globals = {
	-- minetest/lua
	"minetest",
	"dump",
	"dump2",
	"vector",
	"ItemStack",
	"table",
	"string",
	-- deps
	"anvil",
	"armor",
	"auroras",
	"choppy",
	"default",
	"font_api",
	"futil",
	"homedecor",
	"mesecon",
	"player_api",
	"signs_bot",
	"signs_lib",
	"stairs",
	"stairsplus",
	"techage",
	"unified_inventory",
	"unifieddyes",
	"xban",
}

files["archtec/scripts/status.lua"] = {
	globals = {"minetest.get_server_status"},
}

files["archtec_pvp/init.lua"] = {
	globals = {"minetest.calculate_knockback"},
}

files["archtec/scripts/privs_cache.lua"] = {
	globals = {"minetest.set_player_privs", "minetest.get_player_privs"},
}

files["stamina/init.lua"] = {
	globals = {"minetest.do_item_eat"},
}

files["archtec/scripts/mvps_stopper.lua"] = {
	globals = {"mesecon"},
}

files["archtec_matterbridge/tx.lua"] = {
	globals = {"minetest.send_join_message", "minetest.send_leave_message"},
}

files["archtec_matterbridge/rx.lua"] = {
	globals = {"minetest.chat_send_player"},
}

files["archtec/scripts/common.lua"] = {
	globals = {"core.kick_player", "core.kick_inactive_player", "core.disconnect_player", "minetest.registered_chatcommands.?.mod_origin"},
}

files["archtec/scripts/overrides.lua"] = {
	globals = {"minetest.registered_entities", "carts.speed_max", "signs_bot.MAX_CAPA"},
}

files["archtec/init.lua"] = {
	globals = {"futil"},
}

files["archtec/scripts/chainsaw.lua"] = {
	globals = {"choppy.api"},
}

files["archtec/scripts/random_things.lua"] = {
	globals = {"biome_lib"},
}

files["archtec/scripts/watch.lua"] = {
	globals = {"player_api"},
}

files["archtec_monitoring/builtin/after.lua"] = {
	globals = {"minetest.after"},
}

files["archtec_monitoring/builtin/forceload_blocks.lua"] = {
	globals = {"minetest.forceload_block", "minetest.forceload_free_block"},
}

files["archtec_monitoring/builtin/generated.lua"] = {
	globals = {"minetest.registered_on_generateds"},
}

files["archtec_monitoring/builtin/globalstep.lua"] = {
	globals = {"minetest.registered_globalsteps", "minetest.callback_origins"},
}

files["archtec_monitoring/builtin/on_joinplayer.lua"] = {
	globals = {"minetest.registered_on_joinplayers"},
}

files["archtec_monitoring/builtin/on_prejoinplayer.lua"] = {
	globals = {"minetest.registered_on_prejoinplayers"},
}

files["archtec_monitoring/mods/mesecons/functions.lua"] = {
	globals = {"mesecon.queue.execute"},
}

files["archtec_monitoring/mods/mesecons/globals.lua"] = {
	globals = {"mesecon.queue.execute"},
}

files["archtec_monitoring/mods/mesecons/luac.lua"] = {
	globals = {"minetest.registered_nodes"},
}