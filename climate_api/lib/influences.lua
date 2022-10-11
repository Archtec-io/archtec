climate_api.register_influence("height", function(pos)
	return pos.y
end)

climate_api.register_influence("light", function(pos)
	pos = vector.add(pos, {x = 0, y = 1, z = 0})
	return minetest.get_node_light(pos) or 0
end)

climate_api.register_influence("daylight", function(pos)
	pos = vector.add(pos, {x = 0, y = 1, z = 0})
	return minetest.get_node_light(pos, 0.5) or 0
end)

climate_api.register_influence("indoors", function(pos)
    pos = vector.add(pos, {x = 0, y = 1, z = 0})
    local daylight = minetest.get_node_light(pos, 0.5) or 0
    if daylight < 15 then return true end
    local free_sight, _ = minetest.line_of_sight(pos, { x = pos.x, y = pos.y + 10, z = pos.z })
    return not free_sight
end)

climate_api.register_global_influence("time",
	minetest.get_timeofday
)