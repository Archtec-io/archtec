local modname = minetest.get_current_modname()

local timeout = 600

local times = {}

local function now() return minetest.get_us_time() / 1000000 end
local function bumpn(pname) times[pname] = now() return pname end
local function bump(player)
	if not (player and player.get_player_name) then return end
	local pname = player:get_player_name()
	if not pname then return end
	return bumpn(pname)
end

minetest.register_on_joinplayer(function(player) return bump(player) end)
minetest.register_on_placenode(function(_, _, player)
	--do not return
	bump(player)
end)
minetest.register_on_dignode(function(_, _, player) return bump(player) end)
minetest.register_on_punchnode(function(_, _, player) return bump(player) end)
minetest.register_on_chat_message(function(pname) bumpn(pname) end)
minetest.register_on_craft(function(_, player) bump(player) end)
minetest.register_on_player_inventory_action(function(player) return bump(player) end)

local looks = {}
local function checkplayer(player)
	local pname = player:get_player_name()
	local look = player:get_look_dir()
	local old = looks[pname]
	looks[pname] = look
	if player:get_player_control_bits() ~= 0 then return bumpn(pname) end
	if not (old and vector.equals(old, look)) then return bumpn(pname) end
	return pname
end

minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local pname = checkplayer(player)
		if times[pname] < now() - timeout then
			minetest.kick_player(pname, "Too long inactive")
			minetest.chat_send_all(pname.." got kicked! Reason: Too long inactive")
        	discord.send(":bangbang: "..pname.." got kicked! Reason: Too long inactive")
		end
	end
end)