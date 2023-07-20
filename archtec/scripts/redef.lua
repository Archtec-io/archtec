--based on redef/3d_ladders.lua
local ladders = {
	{'ladder_wood', 'default_ladder_wood.png', 'default_wood.png'},
	{'ladder_steel', 'default_ladder_steel.png', 'default_steel_block.png'}
}

for l,def in pairs(ladders) do
	minetest.override_item('default:'..def[1], {
		tiles = { def[2], def[2], def[3], def[3], def[3], def[3] },
		use_texture_alpha = 'clip',
		drawtype = 'nodebox',
		paramtype = 'light',
		node_box = {
			type = 'fixed',
			fixed = {
				{-0.375, -0.5, -0.5, -0.25, -0.375, 0.5}, -- strut_1
				{0.25, -0.5, -0.5, 0.375, -0.375, 0.5}, -- strut_2
				{-0.4375, -0.5, 0.3125, 0.4375, -0.375, 0.4375}, -- rung_1
				{-0.4375, -0.5, 0.0625, 0.4375, -0.375, 0.1875}, -- rung_2
				{-0.4375, -0.5, -0.1875, 0.4375, -0.375, -0.0625}, -- rung_3
				{-0.4375, -0.5, -0.4375, 0.4375, -0.375, -0.3125} -- rung_4
			}
		},
		selection_box = {
			type = 'wallmounted',
			wall_top = {-0.4375, 0.375, -0.5, 0.4375, 0.5, 0.5},
			wall_side = {-0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375},
			wall_bottom = {-0.4375, -0.5, -0.5, 0.4375, -0.375, 0.5}
		}
	})
end

--based on redef/grass_box_height.lua
local height = 2
local target = -0.5 + (tonumber(height) * 0.0625)


local grass_nodes = {
	'default:junglegrass',
	'default:dry_grass_1',
	'default:dry_grass_2',
	'default:dry_grass_3',
	'default:dry_grass_4',
	'default:dry_grass_5',
	'default:grass_1',
	'default:grass_2',
	'default:grass_3',
	'default:grass_4',
	'default:grass_5',
}

for _,grass in pairs(grass_nodes) do
	local current_box = minetest.registered_nodes[grass].selection_box.fixed
	if (current_box[5] > target) then
		minetest.override_item(grass, {
			selection_box = {
				type = 'fixed',
				fixed = {
					current_box[1],
					current_box[2],
					current_box[3],
					current_box[4],
					target,
					current_box[6]
				}
			}
		})
	end
end
