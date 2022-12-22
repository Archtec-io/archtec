unused_args = false
allow_defined_top = true

ignore = {
	"431", -- Shadowing an upvalue
	"432", -- Shadowing an upvalue argument
	"411", -- Redefining a local variable
}

globals = {
	"archtec",
	"notifyTeam",
	"archtec_pvp",
	"archtec_teleport",
	"vote",
	"archtec_vpn_blocker",
	"player_api",
	"ranks",
	"biome_lib",
	"stairs"
}

read_globals = {
	"core",
	"DIR_DELIM",
	"dump",
	"dump2",
	"minetest",
	"discord",
	"xban",
	"homedecor",
	"vector",
	"mesecon",
	"unified_inventory",
	"default",
	"techage",
	"choppy",

	string = {fields = {"split"}},
	table = {fields = {"copy"}},
}

files["archtec/scripts/discord_fallback.lua"] = {
	globals = { "discord" },
}

files["archtec/scripts/status.lua"] = {
	globals = { "minetest.get_server_status" },
}

files["archtec_pvp/pvp.lua"] = {
	globals = { "minetest.calculate_knockback" },
}

files["weather/ca_effects/lightning.lua"] = {
	globals = { "lightning" },
	read_globals = { "PcgRandom" },
}

files["archtec/scripts/split_long_msg.lua"] = {
	globals = { "minetest.chat_send_all", "minetest.chat_send_player" },
}

files["archtec/scripts/privs_cache.lua"] = {
	globals = { "minetest.set_player_privs", "minetest.get_player_privs" },
}

files["archtec/scripts/item_drop.lua"] = {
	read_globals = { "ItemStack" },
}

files["stamina/init.lua"] = {
	globals = { "minetest.do_item_eat" },
}