local sky_start = tonumber(-100)
local timer = 0
archtec.black_sky = {}

local function allow_skybox_change(name)
	local visible = auroras.player_data[name] and auroras.player_data[name].was_visible
	if visible == true then
		return false
	end
	return true
end

if not minetest.global_exists("auroras") then
	allow_skybox_change = function(name)
		return true
	end
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 6 then
		return
	end

	timer = 0

	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		if allow_skybox_change(name) then
			if pos.y > sky_start and archtec.black_sky ~= nil then
				player:set_sky({ type = "regular", clouds = true })
				player:set_sun({ visible = true, sunrise_visible = true })
				player:set_moon({ visible = true })
				player:set_stars({ visible = true })
				archtec.black_sky[name] = nil
			elseif pos.y < sky_start and archtec.black_sky ~= true then
				auroras.restore_sky(player)
				player:set_sky({ base_color = "#000000", type = "plain", clouds = false })
				player:set_sun({ visible = false, sunrise_visible = false })
				player:set_moon({ visible = false })
				player:set_stars({ visible = false })
				archtec.black_sky[name] = true
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	archtec.black_sky[name] = nil
end)