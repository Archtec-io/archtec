local music = {}
local current = {}

local path = minetest.get_worldpath() .. DIR_DELIM .. "music" .. DIR_DELIM

function music.play(name, title)
    minetest.dynamic_add_media({filepath = path .. title .. ".ogg", ephemeral = false, to_player = name}, function(player)
        local handle = minetest.sound_play(title, {to_player = name, gain = 1.0})
        current[name] = handle
    end)
end

function music.stop(name)
    local handle = current[name]
    if handle then
        minetest.sound_stop(handle)
        current[name] = nil
        return true
    end
    return false
end

local function get_music_list()
	local files = {}
	local flist = minetest.get_dir_list(path, false)
	for f = 1, #flist do
		local filename = flist[f]
		local outname, _ = filename:match("(.*)(.ogg)$")
        files[#files + 1] = outname
	end
    files = table.concat(files, ", ")
    return files
end

local function file_exists(title)
    local flist = minetest.get_dir_list(path, false)
    return archtec.table_contains(flist, title .. ".ogg")
end

minetest.register_chatcommand("music_play", {
	description = "Play music to specified players",
    params = "<title> <name[s]>",
	privs = {staff = true},
	func = function(name, param)
        minetest.log("action", "[/music_play] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
        if param:trim() == "" or param:trim() == nil then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "[music_play] No arguments provided!"))
            return
        end
        local title, playersraw
		title, playersraw = param:match("([^ ]+) *(.*)")
        if playersraw:trim() == "" or playersraw:trim() == nil then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "[music_play] No player names provided!"))
            return
        end
        if not file_exists(title) then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "[music_play] Unknown title!"))
            return
        end
        local players = archtec.string_to_table(playersraw)
        for _, player in pairs(players) do
            if not archtec.is_online(player) then
                minetest.chat_send_player(name, minetest.colorize("#FF0000", "[music_play] Player " .. player .. " is not online!"))
                return
            end
            music.play(player, title)
            if name ~= player then
                minetest.chat_send_player(player, minetest.colorize("#00BD00", "[music_play] Playing " .. title .. " to you (started by " .. name .. ")"))
            end
        end
        minetest.chat_send_player(name, minetest.colorize("#00BD00", "[music_play] Playing " .. title .. " to " .. playersraw:trim()))

	end
})

minetest.register_chatcommand("music_stop", {
	description = "Stop music for specified players",
    params = "<name[s]>",
	privs = {staff = true},
	func = function(name, param)
        minetest.log("action", "[/music_stop] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
        if param:trim() == "" or param:trim() == nil then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "[music_stop] No player names provided!"))
            return
        end
        local players = archtec.string_to_table(param)
        for _, player in pairs(players) do
            if not archtec.is_online(player) then
                minetest.chat_send_player(name, minetest.colorize("#FF0000", "[music_stop] Player " .. player .. " is not online!"))
                return
            end
            music.stop(player)
            if name ~= player then
                minetest.chat_send_player(player, minetest.colorize("#00BD00", "[music_stop] " .. name .. " stopped your music"))
            end
        end
        minetest.chat_send_player(name, minetest.colorize("#00BD00", "[music_stop] Stopped music for " .. param:trim()))
	end
})

minetest.register_chatcommand("music_list", {
	description = "Returns a list with all available songs",
	privs = {staff = true},
	func = function(name)
        minetest.log("action", "[/music_list] executed by '" .. name .. "'")
        minetest.chat_send_player(name, minetest.colorize("#00BD00", "[music_list] " .. get_music_list()))
	end
})

minetest.register_on_leaveplayer(function(player)
    if player then
        current[player:get_player_name()] = nil
    end
end)