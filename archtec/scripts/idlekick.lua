local timeout = 1800 -- kick after 30 mins
local timer = 0

local times = {}

local function now() return minetest.get_us_time() / 1000000 end
local function bumpn(player) times[player] = now() return player end

local function bump(player)
	if not (player) then return end
	return bumpn(player)
end

minetest.register_on_joinplayer(function(player) return bump(player) end)
minetest.register_on_placenode(function(_, _, player) bump(player) end)
minetest.register_on_dignode(function(_, _, player) return bump(player) end)
minetest.register_on_punchnode(function(_, _, player) return bump(player) end)
minetest.register_on_chat_message(function(player) bumpn(player) end)
minetest.register_on_craft(function(_, player) bump(player) end)
minetest.register_on_player_inventory_action(function(player) return bump(player) end)

local looks = {}
local function checkplayer(player)
	local look = player:get_look_dir()
	local old = looks[player]
	looks[player] = look
	if player:get_player_control_bits() ~= 0 then return bumpn(player) end
	if not (old and vector.equals(old, look)) then return bumpn(player) end
	return player
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 2 then
		return
	end
	timer = 0

	for _, player in pairs(minetest.get_connected_players()) do
		local pcheck = checkplayer(player)
		if times[pcheck] < now() - timeout then
			local name = player:get_player_name()
			minetest.kick_player(name, "Too long inactive")
			minetest.chat_send_all(name .. " got kicked! Reason: Too long inactive")
			discord.send(":bangbang: " .. name .. " got kicked! Reason: Too long inactive")
		end
	end
end)
