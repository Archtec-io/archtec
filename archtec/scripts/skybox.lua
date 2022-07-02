local sky_start = tonumber(-100)
local player_list = {}
local timer = 0

local function node_ok(pos, fallback)
	fallback = fallback or "air"
	local node = minetest.get_node_or_nil(pos)

	if not node then
		return fallback
	end

	if minetest.registered_nodes[node.name] then
		return node.name
	end

	return fallback
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 12.7 then
		return
	end

	timer = 0

	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local head_node = node_ok(pos)
		local ndef = minetest.registered_nodes[head_node]
		local current = player_list[name] or ""
		pos.y = pos.y - 1.5 -- reset pos
		pos.y = pos.y + 1.5 -- head level

		if pos.y > sky_start and current ~= "surface" then
			player:set_sky({ type = "regular", clouds = true })
			player:set_sun({ visible = true, sunrise_visible = true })
			player:set_moon({ visible = true })
			player:set_stars({ visible = true })
			player_list[name] = "surface"

		elseif pos.y < sky_start and current ~= "blackness" then
			player:set_sky({ base_color = "#000000", type = "plain", clouds = false })
			player:set_sun({ visible = false, sunrise_visible = false })
			player:set_moon({ visible = false })
			player:set_stars({ visible = false })
			player_list[name] = "blackness"
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_list[name] = nil
end)