--remove building category
unified_inventory.remove_category("building")

biome_lib.mapgen_elevation_limit = { ["min"] = 0, ["max"] = 48 }

local S = minetest.get_translator("moreblocks")
local def = minetest.registered_nodes["moreblocks:empty_shelf"]
stairs.register_stair_and_slab(
	"moreblocks:empty_shelf",
	"moreblocks:empty_shelf",
	def.groups,
	def.tiles,
	S("@1 Stair", def.description),
	S("@1 Slab", def.description),
	def.sounds,
	true
)