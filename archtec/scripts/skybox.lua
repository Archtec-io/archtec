local sky_start = tonumber(-100)
local player_list = {}
local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 6 then
		return
	end

	timer = 0

	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local current = player_list[name] or ""

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