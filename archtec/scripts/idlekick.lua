local S = archtec.S
local timeout = 1800 -- kick after 30 mins
local timer = 0

local times, tag, ppos = {}, {}, {}

local function now() return minetest.get_us_time() / 1000000 end
local function bumpn(name) times[name] = now() return name end

local function bump(player)
	if not player then return end
	local name = player:get_player_name()
	return bumpn(name)
end

local function get_nametag(name, player)
	if not player then return end
	local att = player:get_nametag_attributes()
	if att.text == "" or att.text == nil then
		att.text = name
	end
	return att.text
end

minetest.register_on_joinplayer(function(player)
	-- can happen when player was idle and got kicked
	local hp = player:get_hp() or 20
	if hp == 0 then
		local name = player:get_player_name()
		minetest.log("action", "[archtec] Respawned dead player '" .. name .. "' on join")
		minetest.chat_send_player(name, minetest.colorize("#00BD00", S("Server respawned you (you were dead without respawn option)")))
		player:respawn()
	end
	-- create entrie
	return bump(player)
end)

minetest.register_on_placenode(function(_, _, player) bump(player) end)
minetest.register_on_dignode(function(_, _, player) return bump(player) end)
minetest.register_on_punchnode(function(_, _, player) return bump(player) end)
minetest.register_on_chat_message(function(player) bumpn(player) end)
minetest.register_on_craft(function(_, player) bump(player) end)
minetest.register_on_player_inventory_action(function(player) return bump(player) end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 6 then
		return
	end
	timer = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local time = now()

		if pos ~= ppos[name] then
			bumpn(name)
			ppos[name] = pos
		end

		if times[name] < time - timeout then
			minetest.kick_player(name, "Too long inactive")
		end
		if times[name] < time - 300 then
			if not tag[name] then
				tag[name] = true
				local nametag = get_nametag(name, player) .. " (idle)"
				player:set_nametag_attributes({
					text = nametag
				})
			end
		elseif tag[name] == true then
			tag[name] = nil
			local nametag = get_nametag(name, player)
			nametag = string.sub(nametag, 1, #nametag - 7)
			player:set_nametag_attributes({
				text = nametag
			})
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	if not player then return end
	local name = player:get_player_name()
	times[name] = nil
	tag[name] = nil
	ppos[name] = nil
end)