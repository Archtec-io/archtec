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
	"discord",
	"mapserver",
	"notifyTeam",
	"player_monoids",
	"vote",
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
	"auroras",
	"choppy",
	"default",
	"font_api",
	"futil",
	"homedecor",
	"mesecon",
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
	globals = {"core.kick_player", "core.disconnect_player"},
}

files["archtec/scripts/overrides.lua"] = {
	globals = {"minetest.registered_entities"},
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