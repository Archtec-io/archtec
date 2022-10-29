local MESSAGE_INTERVAL = 600
local S = minetest.get_translator("archtec")

random_messages = {
	"To check someone's playtime use '/playtime <player_name>'",
	"Visit our Discord server: https://discord.gg/txCMTMwBWm",
	"Abusing '/vote_kick' will result in a ban for you",
	"Read our rules at the spawn",
	"If you find a bug use '/report <message>'",
	"Server staff: Niklp (Admin), LonnySophie (Mod), HomerJayS (Mod)"
}

local function display_random_message(message)
	local msg = random_messages[message] or message
	if msg then
		minetest.chat_send_all(minetest.colorize("#666", S(msg)))
	end
end

local random = math.random

local function show_random_message()
	local message = "[Info]: " .. random_messages[random(1, #random_messages)]
	display_random_message(message)
end

local function step(dtime)
	show_random_message()
	minetest.after(MESSAGE_INTERVAL, step)
end

--start function
minetest.after(MESSAGE_INTERVAL, step)
