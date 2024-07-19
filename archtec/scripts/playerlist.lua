local playerlist = {huds = {}, controls = {}}
local max_players = minetest.settings:get("max_users")

local function hud_remove(player)
	for _, id in ipairs(playerlist.huds[player:get_player_name()]) do
		player:hud_remove(id)
	end
end

local function hud_show(player)
	local name = player:get_player_name()
	local players = minetest.get_connected_players()

	local huds = {player:hud_add({
		[minetest.features.hud_def_type_field and "type" or "hud_elem_type"] = "image",
		position = {x = 0.5, y = 0},
		offset = {x = 0, y = 20},
		text = "archtec_background.png",
		alignment = {x = 0, y = 1},
		scale = {x = 400, y = (#players + 1) * 18 + 8},
		number = 0xFFFFFF
	})}
	huds[#huds + 1] = player:hud_add({
		[minetest.features.hud_def_type_field and "type" or "hud_elem_type"] = "text",
		position = {x = 0.5, y = 0},
		offset = {x = 0, y = 23},
		text = #players .. "/" .. max_players,
		alignment = {x = 0, y = 1},
		scale = {x = 100, y = 100},
		style = 1,
		number = 0xFFFFFF
	})

	for i = 1, #players do
		local user = players[i]
		local uname = user:get_player_name()
		local ping = math.max(1, math.ceil(4 - (minetest.get_player_information(uname).avg_rtt or 0) * 50))
		huds[#huds + 1] = player:hud_add({
			[minetest.features.hud_def_type_field and "type" or "hud_elem_type"] = "text",
			position = {x = 0.5, y = 0},
			offset = {x = 0, y = 41 + (i - 1) * 18},
			text = uname,
			alignment = {x = 0, y = 1},
			scale = {x = 100, y = 100},
			number = 0xFFFFFF
		})
		huds[#huds + 1] = player:hud_add({
			[minetest.features.hud_def_type_field and "type" or "hud_elem_type"] = "image",
			position = {x = 0.5, y = 0},
			offset = {x = -195, y = 38 + (i - 1) * 18},
			text = "server_ping_" .. ping .. ".png",
			alignment = {x = 1, y = 1},
			scale = {x = 1.5, y = 1.5},
			number = 0xFFFFFF
		})
	end
	playerlist.huds[name] = huds
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	playerlist.controls[name] = nil
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 0.7 then -- 700 ms
		return
	end
	timer = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local controls = player:get_player_control()

		if not playerlist.controls[name] then
			playerlist.controls[name] = {}
		end

		-- Press
		if controls.zoom == true and playerlist.controls[name].zoom == nil then
			playerlist.controls[name].zoom = true
			hud_show(player)
		end

		-- Release
		if controls.zoom == false and playerlist.controls[name].zoom == true then
			playerlist.controls[name].zoom = nil
			hud_remove(player)
		end
	end
end)