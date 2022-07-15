--[[
death_messages - A Minetest mod which sends a chat message when a player dies.
Copyright (C) 2016  EvergreenTree
GNU General Public License v3
Modified by Niklp and debagos (Juri)
--]]

local messages = {}

-- Lava death messages
messages.lava = {
    " melted into a ball of fire.",
    " thought lava was cool.",
    " melted into a ball of fire.",
    " couldn't resist that warm glow of lava.",
    " dug straight down.",
    " didn't know lava was hot."
}

-- Drowning death messages
messages.water = {
    " drowned.",
    " ran out of air.",
    " failed at swimming lessons.",
    " tried to impersonate an anchor.",
    " forgot he wasn't a fish.",
    " blew one too many bubbles."
}

-- Burning death messages
messages.fire = {
    " burned to a crisp.",
    " got a little too warm.",
    " got too close to the camp fire.",
    " just got roasted, hotdog style.",
    " got burned up. More light that way."
}

-- Other death messages
messages.other = {
    " died.",
    " did something fatal.",
    " gave up on life.",
    " is somewhat dead now.",
    " passed out -permanently."
}

local function get_message(death_type)
	return messages[death_type][math.random(1, #messages[death_type])]
end

local function make_death_public(message)
	minetest.chat_send_all(message)
	if minetest.get_modpath("chatplus_discord") ~= nil then
		discord.send(":skull_crossbones: "..message)
	end
end

minetest.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	local node = minetest.registered_nodes[minetest.get_node(player:get_pos()).name]
	local msg = get_message("other")
	if node.groups.lava ~= nil then
		msg = get_message("lava")
	elseif node.name == "fire:basic_flame" then
		msg = get_message("fire")
	elseif player:get_breath() == 0 then
		msg = get_message("water")
	end
	make_death_public(player_name..msg)
end)