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
	"minetest.calculate_knockback", -- Archtec PVP
}

read_globals = {
	"core"
	"DIR_DELIM",
	"dump",
	"minetest",
	"discord",
	"xban",
	"homedecor",
	"vector",
	"mesecon",
	"unified_inventory",
	"default",
	"techage",

	string = {fields = {"split"}},
}

files["archtec/scripts/discord_fallback.lua"] = {
	globals = { "discord" },
}