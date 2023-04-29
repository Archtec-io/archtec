local cache = {}

local function get_list(name)
    if cache[name] then
        return cache[name]
    end
    local ignores = archtec_playerdata.get(name, "ignores")
    ignores = minetest.deserialize(ignores)
    if ignores == nil then
        ignores = {}
    end
    cache[name] = ignores
    return ignores
end

local function is_ignored(name, target)
    local ignores = get_list(name)
    return ignores[target] ~= nil
end

archtec.is_ignored = is_ignored

function archtec.ignore_check(name, target)
    return is_ignored(name, target) or is_ignored(target, name)
end

local function ignore_player(name, target)
    local ignores = get_list(name)
    ignores[target] = true
    archtec_playerdata.set(name, "ignores", minetest.serialize(ignores))
    -- update cache
    if not cache[name] then
        cache[name] = {}
    end
    cache[name][target] = true
end

local function unignore_player(name, target)
    local ignores = get_list(name)
    ignores[target] = nil
    if next(ignores) ~= nil then -- do not save table if nobody is ignored
        archtec_playerdata.set(name, "ignores", minetest.serialize(ignores))
    else
        archtec_playerdata.set(name, "ignores", "") -- run's playerdata's garbage collector
    end
    -- update cache
    if not cache[name] then
        cache[name] = {}
    else
        cache[name][target] = nil
    end
end

local function list_ignored_players(name)
    local ignores = get_list(name)
    if next(ignores) == nil then
        return ""
    end
    local string = ""
    for key, _ in pairs(ignores) do
        string = string .. key .. ", "
    end
    string = string:sub(1, #string - 2)
    return string
end

local function count_ignored_players(name)
    local ignores = get_list(name)
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
                if is_ignored(name, target) then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You ignore " .. target .. " already!"))
                    return
                end
                if minetest.get_player_privs(target).staff then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You can't ignore staff members!"))
                    return
                end
                if minetest.get_player_privs(name).staff then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] Staff members can't ignore other players!"))
                    return
                end
                if name == target then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You can't ignore yourself!"))
                    return
                end
                if count_ignored_players(name) >= 10 then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You can't ignore more than 10 players!"))
                    return
                end
                ignore_player(name, target)
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
                if not is_ignored(name, target) then
                    minetest.chat_send_player(name, C("#FF0000", "[ignore] You aren't ignoring " .. target .. "!"))
                    return
                end
                unignore_player(name, target)
                minetest.chat_send_player(name, C("#00BD00", "[ignore] You no longer ignoring " .. target))
                return
            else
                minetest.chat_send_player(name, C("#FF0000", "[ignore] Player " .. target .. " is not a registered player!"))
                return
            end
        elseif action == "" or action == nil or action == "list" then
            local list = list_ignored_players(name)
            if list == "" then
                minetest.chat_send_player(name, C("#00BD00", "[ignore] You aren't ignoring anyone"))
                return
            end
            minetest.chat_send_player(name, C("#00BD00", "[ignore] List of players you ignore: " .. list))
            return
        end
        minetest.chat_send_player(name, C("#FF0000", "[ignore] Unknown subcommand!"))
	end
})

function archtec.ignore_msg(cmdname, name, target)
    if cmdname then
        cmdname = "[" .. cmdname .. "] "
    else
        cmdname = ""
    end
    if is_ignored(name, target) then
        minetest.chat_send_player(name, C("#FF0000", cmdname .. "You are ignoring " .. target .. ". You can't interact with them!"))
    else
        minetest.chat_send_player(name, C("#FF0000", cmdname .. target .. " ignores you. You can't interact with them!"))
    end
end

minetest.register_on_leaveplayer(function(player)
    if player then
        cache[player:get_player_name()] = nil
    end
end)