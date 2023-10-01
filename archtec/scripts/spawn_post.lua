local function copy_node(name)
	if not minetest.registered_nodes[name] then
		minetest.log("error", "[archtec] copy_node '" .. name .. "' does not exist")
		return
	end
	local _, itemname = archtec.split_itemname(name)
	local def = table.copy(minetest.registered_nodes[name])
	local old_on_dig = def.on_dig or minetest.node_dig
	-- Only staff members can dig those blocks
	def.on_dig = function(pos, node, digger)
		if minetest.check_player_privs(digger, "staff") then
			return old_on_dig(pos, node, digger)
		end
		return false
	end
	def.groups["not_in_creative_inventory"] = 1
	def.mod_origin = nil
	minetest.register_node("archtec:" .. itemname, def)
end

local node_list = {
	"jonez:romantic_base",
	"jonez:romantic_shaft",
	"jonez:romantic_architrave",
	"jonez:romanic_architrave",
	"jonez:ruin_vine",
	"jonez:ruin_creeper",
	"xdecor:ivy",
	"homedecor:cardboard_box",
	"homedecor:cardboard_box_big",
}

for _, node in ipairs(node_list) do
	copy_node(node)
end

-- sign
if minetest.get_modpath("signs_lib") then
	local cbox = signs_lib.make_selection_boxes(35, 25, true, 0, 0, 0, true)
	local groups = table.copy(signs_lib.standard_steel_groups)
	groups["not_in_creative_inventory"] = 1

	signs_lib.register_sign("archtec:sign_wall_steel_white_black", {
		description = "Post Office sign",
		paramtype2 = "facedir",
		selection_box = cbox,
		mesh = "signs_lib_standard_facedir_sign_wall.obj",
		tiles = {
			"basic_signs_steel_white_black.png",
			"signs_lib_sign_wall_steel_edges.png",
			nil,
			nil,
			"default_steel_block.png"
		},
		inventory_image = "basic_signs_steel_white_black_inv.png",
		groups = groups,
		sounds = signs_lib.standard_steel_sign_sounds,
		default_color = "0",
		entity_info = {
			mesh = "signs_lib_standard_sign_entity_wall.obj",
			yaw = signs_lib.standard_yaw
		},
		allow_hanging = true,
		allow_widefont = true,
		allow_onpole = true,
		allow_onpole_horizontal = true,
		allow_yard = true,
		use_texture_alpha = "clip",
		locked = true, -- main difference
	})
end

if minetest.get_modpath("xdecor") then
	local mod = "^[multiply:#8c8c8c"
	local tiles = {}
	for k, v in pairs(minetest.registered_nodes["xdecor:mailbox"].tiles) do
		tiles[k] = v .. mod
	end
	minetest.register_node("archtec:mailbox_fake", {
		description = "Mailbox (Fake)",
		tiles = tiles,
		groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
		is_ground_content = false,
		sounds = default.node_sound_metal_defaults(),
		buildable_to = true,
		paramtype2 = "facedir",
	})
end