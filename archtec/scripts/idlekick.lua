local S = archtec.S
local timeout = archtec.time.hours(1) -- Kick after 1h
local timer = 0
local cache = {}

local function now()
	return minetest.get_us_time() / 1000000
end

local function cache_init(name, pos)
	cache[name] = {
		last_active = now(),
		nametag_edited = nil, -- Created later
		pos = pos
	}
end


local function bump_name(name)
	cache[name].last_active = now()
	return name
end

local function bump(player)
	if not player then return end
	local name = player:get_player_name()

	return bump_name(name)
end

local function get_nametag(name, player)
	local att = player:get_nametag_attributes()
	if att.text == "" or att.text == nil then
		return name
	end
	return att.text
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	-- Can happen when player was dead and got kicked
	local hp = player:get_hp()
	if hp == 0 then
		minetest.log("action", "[archtec] Respawned dead player '" .. name .. "' on join")
		minetest.chat_send_player(name, minetest.colorize("#00BD00", S("Server respawned you (you were dead without respawn option)")))
		player:respawn()
	end
	-- Create data structure
	cache_init(name, player:get_pos())
end)

-- Un-idle events
minetest.register_on_placenode(function(_, _, player) bump(player) end)
minetest.register_on_dignode(function(_, _, player) bump(player) end)
minetest.register_on_punchnode(function(_, _, player) bump(player) end)
minetest.register_on_craft(function(_, player) bump(player) end)
minetest.register_on_player_inventory_action(function(player) bump(player) end)
minetest.register_on_chat_message(function(name) bump_name(name) end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 6 then
		return
	end
	timer = 0

	local time = now()

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()

		if pos ~= cache[name].pos then
			bump_name(name)
			cache[name].pos = pos
		end

		if cache[name].last_active < time - timeout then
			archtec.kick_inactive_player(name)
		end

		if cache[name].last_active < time - 300 then
			if not cache[name].nametag_edited then
				cache[name].nametag_edited = true

				local nametag = get_nametag(name, player) .. " (idle)"
				player:set_nametag_attributes({
					text = nametag
				})
			end
		elseif cache[name].nametag_edited then
			cache[name].nametag_edited = nil

			local nametag = get_nametag(name, player)
			nametag = string.sub(nametag, 1, #nametag - 7)
			player:set_nametag_attributes({
				text = nametag
			})
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	cache[name] = nil
end)