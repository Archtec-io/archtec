local waypoints = {}

local pos = minetest.setting_get_pos("static_spawnpoint")
pos.y = pos.y + 0.5

local function waypoint_add(name)
	if not waypoints[name] then
		local player = minetest.get_player_by_name(name)
		waypoints[name] = player:hud_add({
			hud_elem_type = "waypoint",
			name = "[Spawn]",
			text = "m",
			number = 0xFF0000,
			world_pos = pos
		})
	end
end

archtec.sp_add = waypoint_add

local function waypoint_remove(name)
	if waypoints[name] then
		local player = minetest.get_player_by_name(name)
		player:hud_remove(waypoints[name])
		waypoints[name] = nil
	end
end

archtec.sp_remove = waypoint_remove

local function update(name, setting, newvalue)
	if setting ~= "sp_show" then return end
	if newvalue == true then
		waypoint_add(name)
	else
		waypoint_remove(name)
	end
end

archtec.settings.add_callback(update)

minetest.register_on_leaveplayer(function(player)
	if player then
		waypoints[player:get_player_name()] = nil
	end
end)
