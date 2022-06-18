--[[
death_messages - A Minetest mod which sends a chat message when a player dies.
Copyright (C) 2016  EvergreenTree
GNU General Public License v3
Modified by Niklp
--]]

local messages = {}
local msg

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

function get_message(mtype)
    return messages[mtype][math.random(1, #messages[mtype])]
end

minetest.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    local node = minetest.registered_nodes[
        minetest.get_node(player:get_pos()).name
    ]
    -- Death by lava
    if node.groups.lava ~= nil then
        msg = player_name .. get_message("lava")
        minetest.chat_send_all(msg)
        discord.send(':skull_crossbones: '..msg)
    -- Death by drowning
    elseif player:get_breath() == 0 then
        msg = player_name .. get_message("water")
        minetest.chat_send_all(msg)
        discord.send(':skull_crossbones: '..msg)
    -- Death by fire
    elseif node.name == "fire:basic_flame" then
        msg = player_name .. get_message("fire")
        minetest.chat_send_all(msg)
        discord.send(':skull_crossbones: '..msg)
    -- Death by something else
    else
        msg = player_name .. get_message("other")
        minetest.chat_send_all(msg)
        discord.send(':skull_crossbones: '..msg)
    end

end)
