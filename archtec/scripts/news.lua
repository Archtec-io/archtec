local modname = minetest.get_current_modname()
local fpath = minetest.get_worldpath() .. "/news.txt"
local news = "No news available"

local function read_file()
	local file = io.open(fpath, "rb")
	if not file then return end
	local raw = file:read("*all")
	file:close()
	news = raw
end

local fsw = 12.5
local fsh = 10

local function show_formspec(name)
	minetest.show_formspec(name, modname,
	"size[" .. fsw .. "," .. fsh .. ",true]"
	.. "textarea[0.3,0;" .. fsw .. "," .. fsh .. ";;;"
	.. minetest.formspec_escape(news)
	.. "]button_exit[0," .. (fsh - 0.75) .. ";" .. fsw
	.. ",1;ok;" .. "Continue" .. "]")
end

minetest.register_on_joinplayer(function(player)
	if player then
		show_formspec(player:get_player_name())
	end
end)

minetest.register_chatcommand("news", {
	description = "Read the server news",
	privs = {staff = true},
	func = function(name)
		minetest.log("action", "[/news] executed by '" .. name .. "'")
		show_formspec(name)
	end
})

minetest.register_chatcommand("news_reload", {
	description = "Reload server news",
	privs = {staff = true},
	func = function(name)
		minetest.log("action", "[/news_reload] executed by '" .. name .. "'")
		read_file()
		show_formspec(name)
		minetest.chat_send_player(name, "News reloaded")
	end
})

-- Load news
read_file()