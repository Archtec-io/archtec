local S = archtec.S
local NS = function(s) return s end -- fake function for i18n.py

local messages = {
	fall = {
		NS("@1 hit the ground too hard"),
		NS("@1 jumped off a cliff"),
		NS("@1 thought water canceled fall damage"),
		NS("@1 fell and couldn't get back up"),
	},
	burn = {
		NS("@1 burned to a crisp."),
		NS("@1 got a little too warm."),
		NS("@1 got too close to the camp fire."),
		NS("@1 just got roasted, hotdog style."),
		NS("@1 got burned up. More light that way."),
	},
	drown = {
		NS("@1 drowned."),
		NS("@1 ran out of air."),
		NS("@1 failed at swimming lessons."),
		NS("@1 tried to impersonate an anchor."),
		NS("@1 forgot he wasn't a fish."),
		NS("@1 blew one too many bubbles."),
	},
	lava = {
		NS("@1 melted into a ball of fire."),
		NS("@1 thought lava was cool."),
		NS("@1 melted into a ball of fire."),
		NS("@1 couldn't resist that warm glow of lava."),
		NS("@1 dug straight down."),
		NS("@1 didn't know lava was hot."),
	},
	pvp = {
		NS("@1 was slain by @2."),
		NS("@1 was killed by @2."),
		NS("@1 was put to the sword by @2."),
		NS("@1 lost a PVP battle to @2."),
	},
	mob = {
		NS("@1 was slain by @2."),
		NS("@1 was killed by @2."),
		NS("@1 got on @2's last nerve."),
		NS("@1 forgot to feed @2."),
	},
	other = {
		NS("@1 died."),
		NS("@1 did something fatal."),
		NS("@1 gave up on life."),
		NS("@1 is somewhat dead now."),
		NS("@1 passed out -permanently."),
	},
}

local function get_mob_name(entity_name)
	local index, _ = string.find(entity_name, ":")
	entity_name = entity_name:sub(index + 1):gsub("_", " ")
	return (entity_name:gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end))
end

local function send_death_message(cause, player, killer)
	local random_message = messages[cause][math.random(1, #messages[cause])]
	local name = player:get_player_name()
	local death_message

	if killer then
		if killer:is_player() then
			death_message = S(random_message, name, killer:get_player_name())
		else
			local mob_name = get_mob_name(killer:get_luaentity().name)
			death_message = S(random_message, name, mob_name)
		end
	else
		death_message = S(random_message, name)
	end

	core.chat_send_all(core.colorize("#FF0000", death_message))
	if cause == "pvp" then
		archtec_matterbridge.send(":crossed_swords: " .. archtec.escape_md(core.get_translated_string("en", death_message)))
	else
		archtec_matterbridge.send(":skull_and_crossbones: " .. archtec.escape_md(core.get_translated_string("en", death_message)))
	end
end

core.register_on_dieplayer(function(player, reason)
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
