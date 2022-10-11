local MESSAGE_INTERVAL = 300
local S = minetest.get_translator("archtec")

random_messages = {
	"To check someone's playtime use /playtime <player_name>.",
	"Visit our Discord server: https://discord.gg/txCMTMwBWm",
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
