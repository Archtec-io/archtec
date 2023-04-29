local cache = {}

function archtec.is_ignored(name, target)
    if cache[name] then
        return cache[name][target] ~= nil
    end
    local ignores = archtec_playerdata.get(name, "ignores")
    if ignores == "" then return false end
    ignores = minetest.deserialize(ignores)
    cache[name] = ignores
    return ignores[target] ~= nil
end

function archtec.ignore_player(name, target)
    local ignores = minetest.deserialize(archtec_playerdata.get(name, "ignores"))
    if not ignores then
        ignores = {}
    end
    ignores[target] = true
    archtec_playerdata.set(name, "ignores", minetest.serialize(ignores))
    -- update cache
    if not cache[name] then
        cache[name] = {}
    end
    cache[name][target] = true
end

function archtec.unignore_player(name, target)
    local ignores = archtec.string_to_table(archtec_playerdata.get(name, "ignores"))
    if not ignores then
        return
    end
    ignores[target] = nil
    archtec_playerdata.set(name, "ignores", minetest.serialize(ignores))
    -- update cache
    if not cache[name] then
        cache[name] = {} -- that should ne be possible
    else
        cache[name][target] = nil
    end
end

function archtec.list_ignored_players(name)
    local ignores = minetest.deserialize(archtec_playerdata.get(name, "ignores"))
    if ignores == "" or type(ignores) == "nil" then
        return ""
    end
    local string = ""
    for key, _ in pairs(ignores) do
        string = string .. key .. ", "
    end
    string = string:sub(1, #string - 2)
    return string
end

function archtec.count_ignored_players(name)
    local ignores = minetest.deserialize(archtec_playerdata.get(name, "ignores"))
    if ignores == nil or ignores == "" then
        return 0
    end
    return archtec.count_keys(ignores)
end

local C = minetest.colorize

minetest.register_chatcommand("ignore", {
	description = "Ignores someone",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/ignore] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
        local params = {}
        for p in string.gmatch(param, "[^%s]+") do
            table.insert(params, p)
        end
        local action = params[1]
        if action == "ignore" or action == "add" then
            local target = params[2]
            target = target:trim() -- prevent whitespace issues
            if minetest.player_exists(target) then
                if archtec.is_ignored(name, target) then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You ignore " .. target .. " already!"))
                    return
                end
                if minetest.get_player_privs(target).staff then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You can't ignore staff members!"))
                    return
                end
                if name == target then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You can't ignore yourself!"))
                    return
                end
                if archtec.count_ignored_players(name) > 10 then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You can't ignore more than 10 players!"))
                    return
                end
                archtec.ignore_player(name, target)
                minetest.chat_send_player(name, C("#00BD00", "[ignore] You are ignoring " .. target .. " now"))
                return
            else
                minetest.chat_send_player(name, C("#FF0000", "[ignore] Player " .. target .. " is not a registered player!"))
                return
            end
        elseif action == "unignore" or action == "remove" then
            local target = params[2]
            target = target:trim() -- prevent whitespace issues
            if minetest.player_exists(target) then
                if not archtec.is_ignored(name, target) then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You aren't ignoring " .. target .. "!"))
                    return
                end
                archtec.unignore_player(name, target)
                minetest.chat_send_player(name, C("#00BD00", "[ignore] You no longer ignoring " .. target))
                return
            else
                minetest.chat_send_player(name, C("#FF0000", "[ignore] Player " .. target .. " is not a registered player!"))
                return
            end
        elseif action == "" or action == nil or action == "list" then
            local list = archtec.list_ignored_players(name)
            if list == "" then
                minetest.chat_send_player(name, C("#00BD00", "[ignore] You aren't ignoring anyone"))
                return
            end
            minetest.chat_send_player(name, C("#00BD00", "List of players you ignore: " .. list))
            return
        end
        minetest.chat_send_player(name, C("#FF0000", "[ignore] Unknown subcommand!"))
	end
})