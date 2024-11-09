local waypoints = {}

local pos = core.setting_get_pos("static_spawnpoint") or vector.new(0, 0, 0)
pos.y = pos.y + 0.5

local function waypoint_add(name)
	if not waypoints[name] then
		local player = core.get_player_by_name(name)
		waypoints[name] = player:hud_add({
			[core.features.hud_def_type_field and "type" or "hud_elem_type"] = "waypoint",
			name = "[Spawn]",
			text = "m",
			number = 0xFF0000,
			world_pos = pos
		})
	end
end

local function waypoint_remove(name)
	if waypoints[name] then
		local player = core.get_player_by_name(name)
		player:hud_remove(waypoints[name])
		waypoints[name] = nil
	end
end

archtec.settings.add_callback(function(name, setting, newvalue)
	if setting ~= "sp_show" then return end
	if newvalue == true then
		waypoint_add(name)
	else
		waypoint_remove(name)
	end
end)

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if archtec_playerdata.get(name, "s_sp_show") then
		waypoint_add(name)
	end
end)

core.register_on_leaveplayer(function(player)
	waypoints[player:get_player_name()] = nil
end)
