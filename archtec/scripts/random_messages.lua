local MESSAGE_INTERVAL = 600
local S = minetest.get_translator("archtec")

random_messages = {
	"To check someone's stats use '/stats <player_name>'",
	"Visit our Discord server: https://discord.gg/txCMTMwBWm",
	"Abusing '/vote_kick' will result in a ban for you",
	"Read our rules at the spawn",
	"If you find a bug use '/report <message>'",
	"Server staff: Niklp (Admin), LonnySophie (Mod), HomerJayS (Mod)",
	"Change the color of you name with '/namecolor <color>'",
	"Use '/request_lava' if you want to place lava buckets",
	"Use '/request_areas_high_limit' if you need more or bigger areas",
	"You get the 'forceload' privilege automatically when you enter TA3",
	"To start vote day/night you must have 3 etherium dust in your inventory",
	"Change your PvP state with the sword symbol in your inventory",
}

local function display_random_message(message)
	local msg = random_messages[message] or message
	if msg then
		minetest.chat_send_all(minetest.colorize("#666", S(msg)))
	end
end

local function show_random_message()
	local message = "[Info]: " .. random_messages[math.random(1, #random_messages)]
	display_random_message(message)
end

local function step(dtime)
	show_random_message()
	minetest.after(MESSAGE_INTERVAL, step)
end

-- start function
minetest.after(MESSAGE_INTERVAL, step)
