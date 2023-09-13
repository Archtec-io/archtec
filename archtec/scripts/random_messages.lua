local MESSAGE_INTERVAL = 600
local S = archtec.S
local discord_link = "https://discord.gg/txCMTMwBWm"
local matrix_link = "https://matrix.to/#/#archtec:matrix.org"

local random_messages = {
	S("To check someone's stats use '/stats <name>'"),
	S("Visit our Discord server: @1", discord_link),
	S("Visit our Matrix space: @1", matrix_link),
	S("Abusing '/vote_kick' will result in a ban for you"),
	S("Read our rules at the spawn"),
	S("If you find a bug use '/report <message>'"),
	S("Server staff: Niklp (Admin), LonnySophie (Mod), HomerJayS (Mod)"),
	S("Change the color of your name with '/namecolor <color>'"),
	S("You get the 'forceload' privilege automatically when you enter TA3"),
	S("To start vote day/night you must have 3 etherium dust in your inventory"),
	S("Change your PvP state with the sword symbol in your inventory"),
	S("Say someone thank you with '/thankyou <name>'"),
	S("Start a day/night vote with '/vote_day' or '/vote_night'"),
	S("Ask Niklp or LonnySophie to get a free shop at spawn"),
	S("Get a mailbox for 20MG at the spawn post"),
	S("Do you like christmas? Place your stocking at spawn's christmas area"),
	S("Diamond powder can be used to build cobble stone generators"),
	S("Moving is slow? Get Mithril Boots to move much faster"),
	S("Any questions? Take a look at our FAQ/Wiki using '/faq'"),
}

local function show_random_message()
	local message = minetest.colorize("#999", S("[Info]:") .. " " .. random_messages[math.random(1, #random_messages)])
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
