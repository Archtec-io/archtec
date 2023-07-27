local S = archtec.S
local messages = {}

-- Fall damage
messages.fall = {
	"@1 hit the ground too hard",
	"@1 jumped off a cliff",
	"@1 thought water canceled fall damage",
	"@1 fell and couldn't get back up"
}

-- Burning death messages
messages.burn = {
	"@1 burned to a crisp.",
	"@1 got a little too warm.",
	"@1 got too close to the camp fire.",
	"@1 just got roasted, hotdog style.",
	"@1 got burned up. More light that way."
}

-- Drowning
messages.drown = {
	"@1 drowned.",
	"@1 ran out of air.",
	"@1 failed at swimming lessons.",
	"@1 tried to impersonate an anchor.",
	"@1 forgot he wasn't a fish.",
	"@1 blew one too many bubbles."
}

-- Burning in lava
messages.lava = {
	"@1 melted into a ball of fire.",
	"@1 thought lava was cool.",
	"@1 melted into a ball of fire.",
	"@1 couldn't resist that warm glow of lava.",
	"@1 dug straight down.",
	"@1 didn't know lava was hot."
}

-- Killed by other player
messages.pvp = {
	"@1 was slain by @2.",
	"@1 was killed by @2.",
	"@1 was put to the sword by @2.",
	"@1 lost a PVP battle to @2."
}

-- Killed by mob
messages.mob = {
	"@1 was slain by @2.",
	"@1 was killed by @2.",
	"@1 got on @2's last nerve.",
	"@1 forgot to feed @2."
}

-- Everything else
messages.other = {
	"@1 died.",
	"@1 did something fatal.",
	"@1 gave up on life.",
	"@1 is somewhat dead now.",
	"@1 passed out -permanently."
}

local function send_death_message(cause, player, killer)
	local random_selection = messages[cause][math.random(1, #messages[cause])]
	local name = player:get_player_name()
	local death_message

	if killer then
		if killer:is_player() then
			death_message = S(random_selection, name, killer:get_player_name())
		else
			-- Get entity name, excluding mod name ("mymod:enemy" -> "enemy")
			local entity_name = killer:get_luaentity().name
			local index, _ = string.find(entity_name, ":")
			entity_name = string.sub(entity_name, index + 1)
			entity_name = string.gsub(entity_name, "_", " ") -- remove _'s from mob names
			death_message = S(random_selection, name, entity_name)
		end
	else
		death_message = S(random_selection, name)
	end

	minetest.chat_send_all(minetest.colorize("#FF0000", death_message))
	if cause == "pvp" then
		discord.send(nil, ":crossed_swords: " .. minetest.get_translated_string("en", death_message))
	else
		discord.send(nil, ":skull_and_crossbones: " .. minetest.get_translated_string("en", death_message))
	end
end

minetest.register_on_dieplayer(function(player, reason)
	if reason.object then
		if reason.object:is_player() then
			-- Player was killed by player
			send_death_message("pvp", player, reason.object)
		else
			-- Player was killed by mob
			send_death_message("mob", player, reason.object)
		end
	else
		if reason.type == "fall" then
			-- Player was killed by fall damage
			send_death_message("fall", player)
		elseif reason.type == "drown" then
			-- Player drowned
			send_death_message("drown", player)
		elseif reason.type == "node_damage" then
			if string.match(reason.node, "lava") then
				-- Player burned in lava
				send_death_message("lava", player)
			elseif string.match(reason.node, "fire") then
				-- Player burned in fire
				send_death_message("burn", player)
			else
				-- Reason not detected, send general death message
				send_death_message("other", player)
			end
		else
			send_death_message("other", player)
		end
	end
end)