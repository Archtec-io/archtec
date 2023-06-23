local MESSAGE_INTERVAL = 600
local S = minetest.get_translator("archtec")

local random_messages = {
	"To check someone's stats use '/stats <name>'",
	"Visit our Discord server: https://discord.gg/txCMTMwBWm",
	"Abusing '/vote_kick' will result in a ban for you",
	"Read our rules at the spawn",
	"If you find a bug use '/report <message>'",
	"Server staff: Niklp (Admin), LonnySophie (Mod), HomerJayS (Mod)",
	"Change the color of your name with '/namecolor <color>'",
	"Use '/request_areas_high_limit' if you need more or bigger areas",
	"You get the 'forceload' privilege automatically when you enter TA3",
	"To start vote day/night you must have 3 etherium dust in your inventory",
	"Change your PvP state with the sword symbol in your inventory",
	"Say someone thank you with '/thankyou <name>'",
	"Start a day/night vote with '/vote_day' or '/vote_night'",
	"Ask Niklp or LonnySophie to get a free shop at spawn",
	"Get a free mailbox at the spawn post",
	"Do you like christmas? Place your stocking at spawn's christmas area",
	"Diamond powder can be used to build cobble stone generators",
	"Moving is slow? Get Mithril Boots to move much faster",
}

local function show_random_message()
	local message = minetest.colorize("#666", S("[Info]: " .. random_messages[math.random(1, #random_messages)]))
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if archtec_playerdata.get(name, "s_help_msg") then
			minetest.chat_send_player(name, message)
		end
	end
	minetest.after(MESSAGE_INTERVAL, show_random_message)
end

-- start function
minetest.after(MESSAGE_INTERVAL, show_random_message)
