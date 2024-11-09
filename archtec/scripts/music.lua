local S = archtec.S
local music = {}
local current = {}

local path = core.get_worldpath() .. "/music/"

function music.play(name, title)
	core.dynamic_add_media({filepath = path .. title .. ".ogg", ephemeral = false, to_player = name}, function(player)
		local handle = core.sound_play(title, {to_player = name, gain = 1.0})
		current[name] = handle
	end)
end

function music.stop(name)
	local handle = current[name]
	if handle then
		core.sound_stop(handle)
		current[name] = nil
		return true
	end
	return false
end

local function get_music_list()
	local files = {}
	local flist = core.get_dir_list(path, false)
	for f = 1, #flist do
		local filename = flist[f]
		local outname, _ = filename:match("(.*)(.ogg)$")
		files[#files + 1] = outname
	end
	files = table.concat(files, ", ")
	return files
end

local function file_exists(title)
	local flist = core.get_dir_list(path, false)
	return archtec.table_contains(flist, title .. ".ogg")
end

core.register_chatcommand("music_play", {
	description = "Play music to specified players",
	params = "<title> <name[s]>",
	privs = {staff = true},
	func = function(name, param)
		core.log("action", "[/music_play] executed by '" .. name .. "' with param '" .. param .. "'")
		if param:trim() == "" then
			core.chat_send_player(name, core.colorize("#FF0000", S("[music_play] No arguments provided!")))
			return
		end
		local title, playersraw
		title, playersraw = param:match("([^ ]+) *(.*)")
		if playersraw:trim() == "" then
			core.chat_send_player(name, core.colorize("#FF0000", S("[music_play] No player names provided!")))
			return
		end
		if not file_exists(title) then
			core.chat_send_player(name, core.colorize("#FF0000", S("[music_play] Unknown title!")))
			return
		end
		local players = archtec.string_to_table(playersraw)
		for _, player in pairs(players) do
			if not archtec.is_online(player) then
				core.chat_send_player(name, core.colorize("#FF0000", S("[music_play] Player @1 is not online!", player)))
				return
			end
			music.play(player, title)
			if name ~= player then
				core.chat_send_player(player, core.colorize("#00BD00", S("[music_play] Playing @1 to you (started by @2)", title, name)))
			end
		end
		core.chat_send_player(name, core.colorize("#00BD00", S("[music_play] Playing @1 to @2", title, playersraw:trim())))

	end
})

core.register_chatcommand("music_stop", {
	description = "Stop music for specified players",
	params = "<name[s]>",
	privs = {staff = true},
	func = function(name, param)
		core.log("action", "[/music_stop] executed by '" .. name .. "' with param '" .. param .. "'")
		if param:trim() == "" then
			core.chat_send_player(name, core.colorize("#FF0000", S("[music_stop] No player names provided!")))
			return
		end
		local players = archtec.string_to_table(param)
		for _, player in pairs(players) do
			if not archtec.is_online(player) then
				core.chat_send_player(name, core.colorize("#FF0000", S("[music_stop] Player @1 is not online!", player)))
				return
			end
			music.stop(player)
			if name ~= player then
				core.chat_send_player(player, core.colorize("#00BD00", S("[music_stop] @1 stopped your music", name)))
			end
		end
		core.chat_send_player(name, core.colorize("#00BD00", S("[music_stop] Stopped music for @1", param:trim())))
	end
})

core.register_chatcommand("music_list", {
	description = "Returns a list with all available songs",
	privs = {staff = true},
	func = function(name)
		core.log("action", "[/music_list] executed by '" .. name .. "'")
		core.chat_send_player(name, core.colorize("#00BD00", S("[music_list] @1", get_music_list())))
	end
})

core.register_on_leaveplayer(function(player)
	current[player:get_player_name()] = nil
end)
