-- Based on https://github.com/MT-CTF/seasonal_xmas
local spawn_snow = false

if os.date("%m") == "12" then
	spawn_snow = true
end

-- Spawns snow particles around player
local function spawn_particles(player)
	if archtec_playerdata.get(player:get_player_name(), "s_snow") == true then
		core.add_particlespawner({
			amount = 2000,
			minpos = vector.new(-25, 10, -25),
			maxpos = vector.new( 25, 25,  25),
			minvel = vector.new(-2, -7, -2),
			maxvel = vector.new(-2, -9, -2),
			time = math.random(30, 60),
			minexptime = 10,
			maxexptime = 10,
			minsize = 1,
			maxsize = 4,
			collisiondetection = true,
			collision_removal = true,
			object_collision = true,
			vertical = false,
			texture = ("[combine:7x7:%s,%s=archtec_snowflakes.png"):format(math.random(0, 3) * -7, math.random(0, 1) * -7),
			playername = player:get_player_name(),
			attached = player,
			glow = 2
		})
	end
end

local spawner_step = 8
core.register_globalstep(function(dtime)
	if spawner_step >= 10 then
		spawner_step = 0

		if spawn_snow then
			for _, player in ipairs(core.get_connected_players()) do
				spawn_particles(player)
			end
		end
	else
		spawner_step = spawner_step + dtime
	end
end)

core.register_on_joinplayer(function(player)
	if spawn_snow == true then
		spawn_particles(player)
	end
end)

core.register_chatcommand("snow", {
	params = "",
	description = "Toggles the snow mode state",
	privs = {staff = true},
	func = function(name, param)
		core.log("action", "[/snow] executed by '" .. name .. "'")

		if spawn_snow == true then
			spawn_snow = false
			core.chat_send_player(name, "Snow mode disabled.")
		elseif spawn_snow == false then
			spawn_snow = true
			core.chat_send_player(name, "Snow mode enabled.")
		end
	end
})
