local node_box_simple = {
	{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.5},
	{-0.5, -0.5, -0.5, -0.4375, 0.5, -0.4375},
	{0.4375, -0.5, -0.5, 0.5, 0.5, -0.4375},
	{-0.4375, 0.4375, -0.5, 0.4375, 0.5, -0.4375},
	{-0.4375, -0.5, -0.5, 0.4375, -0.4375, -0.4375},
}

local function node_tiles_front_other(front, other)
	return {other, other, other, other, other, front}
end

local function register_drawer(name, def)
	def.description = def.description or ("Wooden")
	def.drawtype = "nodebox"
	def.node_box = {type = "fixed", fixed = node_box_simple}
	def.collision_box = {type = "regular"}
	def.selection_box = {type = "fixed", fixed = node_box_simple}
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true

	-- normal drawer 1x1 = 1
	local def1 = table.copy(def)
	def1.description = "Fake Drawer"
	def1.tiles = def.tiles or def.tiles1
	minetest.register_node(name .. "1", def1)

	-- 1x2 = 2
	local def2 = table.copy(def)
	def2.description = "Fake Drawer (1x2)"
	def2.tiles = def.tiles2
	minetest.register_node(name .. "2", def2)

	-- 2x2 = 4
	local def4 = table.copy(def)
	def4.description = "Fake Drawer (2x2)"
	def4.tiles = def.tiles4
	minetest.register_node(name .. "4", def4)
end

register_drawer("archtec:acacia_wood", {
	description = ("Acacia Wood"),
	tiles1 = node_tiles_front_other("drawers_acacia_wood_front_1.png",
		"drawers_acacia_wood.png"),
	tiles2 = node_tiles_front_other("drawers_acacia_wood_front_2.png",
		"drawers_acacia_wood.png"),
	tiles4 = node_tiles_front_other("drawers_acacia_wood_front_4.png",
		"drawers_acacia_wood.png"),
	groups = {choppy = 3, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
})

register_drawer("archtec:aspen_wood", {
	description = ("Aspen Wood"),
	tiles1 = node_tiles_front_other("drawers_aspen_wood_front_1.png",
		"drawers_aspen_wood.png"),
	tiles2 = node_tiles_front_other("drawers_aspen_wood_front_2.png",
		"drawers_aspen_wood.png"),
	tiles4 = node_tiles_front_other("drawers_aspen_wood_front_4.png",
		"drawers_aspen_wood.png"),
	groups = {choppy = 3, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_wood_defaults(),
})
