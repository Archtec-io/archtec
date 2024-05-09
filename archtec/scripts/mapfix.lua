local function mapfix(minp, maxp)
	local vm = minetest.get_voxel_manip(minp, maxp)
	vm:update_liquids()
	vm:write_to_map()
	vm:update_map()
end

local default_size = 24

minetest.register_chatcommand("mapfix", {
	privs = {staff = true},
	params = "<size> (max radius 32)",
	description = "Recalculate the flowing liquids and the light of a chunk",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):get_pos())
		local size = tonumber(param) or default_size

		if size >= 33 then
			return false, "Radius is too big"
		end

		minetest.log(
			"action",
			name .. " uses mapfix at " .. minetest.pos_to_string(vector.round(pos)) .. " with radius " .. size
		)

		size = math.max(math.floor(size - 8), 0) -- When passed to get_voxel_manip, positions are rounded up, to a multiple of 16 nodes in each direction. By subtracting 8 it's rounded to the nearest chunk border. max is used to avoid negative radius.

		local minp = vector.subtract(pos, size)
		local maxp = vector.add(pos, size)

		mapfix(minp, maxp)
		return true, "Done."
	end,
})
