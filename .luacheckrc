unused_args = false
allow_defined_top = true

ignore = {
	"631", -- Line is too long
}

globals = {
	-- new globals
	"archtec",
	-- deps
	"player_api",
	"biome_lib",
	"choppy",
}

read_globals = {
	-- minetest/lua
	"minetest",
	"DIR_DELIM",
	"dump",
	"dump2",
	"vector",
	"ItemStack",
	"table",
	"string",
	-- deps
	"auroras",
	"anvil",
	"choppy",
	"default",
	"font_api",
	"futil",
	"homedecor",
	"mesecon",
	"stairs",
	"stairsplus",
	"signs_bot",
	"signs_lib",
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