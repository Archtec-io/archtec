unused_args = false

ignore = {
	"631", -- Line is too long
}

globals = {
	"archtec",
	"archtec_chat",
	"archtec_matterbridge",
	"archtec_playerdata",
	"archtec_teleport",
	"archtec_votes",
	"mapserver",
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
	"screwdriver",
	"signs_bot",
	"signs_lib",
	"stairs",
	"stairsplus",
	"stamina",
	"techage",
	"unified_inventory",
	"unifieddyes",
	"xban",
}

files["archtec/scripts/status.lua"] = {
	globals = {"minetest.get_server_status"},
}

files["archtec/scripts/pvp.lua"] = {
	globals = {"minetest.calculate_knockback"},
}

files["archtec/scripts/privs_cache.lua"] = {
	globals = {"minetest.set_player_privs", "minetest.get_player_privs"},
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
	globals = {"core.kick_player", "core.disconnect_player", "minetest.registered_chatcommands.?.mod_origin"},
}

files["archtec/scripts/overrides.lua"] = {
	globals = {"minetest.registered_entities", "carts.speed_max", "signs_bot.MAX_CAPA"},
}

files["archtec/scripts/chainsaw.lua"] = {
	globals = {"choppy.api"},
}

files["archtec/scripts/watch.lua"] = {
	globals = {"player_api.player_attached"},
}