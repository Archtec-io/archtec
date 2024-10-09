local fpath = minetest.get_worldpath() .. "/news.txt"
local S = archtec.S
local FS = function(...) return minetest.formspec_escape(S(...)) end
local news = S("No news available")

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
	local fs = ""
	fs = fs .. "size[" .. fsw .. "," .. fsh .. ",true]"
	fs = fs .. "hypertext[0.3,0;" .. fsw .. "," .. fsh .. ";news;" .. minetest.formspec_escape(news) .. "]"
	fs = fs .. "button_exit[0," .. (fsh - 0.75) .. ";" .. fsw .. ",1;ok;" .. FS("Continue") .. "]"
	minetest.show_formspec(name, "archtec:news", fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:news" then return end
	if fields.news and fields.news:sub(1, 12) == "action:link_" then
		local link = fields.news:sub(13, #fields.news)
		local url = nil

		-- Some hardcoded URLs
		if link == "website" then url = archtec.links.website end
		if link == "discord" then url = archtec.links.discord end
		if link == "matrix" then url = archtec.links.matrix end

		-- Dynamic URLs
		if url == nil then
			url = link
		end

		if url ~= nil then
			local name = player:get_player_name()
			minetest.close_formspec(name, "archtec:news")
			minetest.chat_send_player(name, minetest.colorize("#FF8800", S("Ctrl + Click the link to open your browser") .. ":") .. " " .. url)
		end
	end

	return true
end)

minetest.register_on_joinplayer(function(player)
	show_formspec(player:get_player_name())
end)

minetest.register_chatcommand("news", {
	description = "Read the server news",
	privs = {interact = true},
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