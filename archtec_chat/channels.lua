local channel = {}
local C = minetest.colorize

local cdef_default = {
    owner = "",
    users = {},
    invites = {},
    keep = false
}

local function get_cdef(cname)
    if not archtec_chat.channels[cname] then return nil end
    local c = table.copy(archtec_chat.channels[cname])
    local t = {}
    for k, v in pairs(cdef_default) do
        t[k] = c[k] or v
    end
    return t
end

channel.get_cdef = get_cdef

local function set_cdef(cname, cdef)
    archtec_chat.channels[cname] = cdef
end

local function is_channel_owner(cdef, name)
    if cdef.owner == name then
        return true
    end
    if string.sub(cdef.owner, 1, 5) == "priv." then
        local priv = string.sub(cdef.owner, 6, #cdef.owner)
        if minetest.get_player_privs(name)[priv] then
            return true
        end
    end
    return false
end

function channel.send(cname, message)
    -- minetest.log("action", "[archtec_chat] Send message '" .. message .. "' into channel '" .. cname .. "'")
    if message == "" then return end
    local cdef = get_cdef(cname)
    local msg = minetest.colorize("#FF8800", "#" .. cname .. " | " .. message)
    for name, _ in pairs(cdef.users) do
        minetest.chat_send_player(name, msg)
    end
end

function channel.create(cname, owner, keep)
    minetest.log("action", "[archtec_chat] Create channel '" .. cname .. "' for '" .. owner .. "'")
    local def = {owner = owner, users = {}, invites = {}, keep = false}
    if keep then
        def.keep = true
    end
    set_cdef(cname, def)
end

function channel.delete(cname, name)
    local cdef = get_cdef(cname)
    if cdef.keep then return end
    minetest.log("action", "[archtec_chat] Delete channel '" .. cname .. "' by '" .. name .. "'")
    channel.send(cname, name .. " deleted the channel.")
    archtec_chat.channels[cname] = nil
end

function channel.join(cname, name, msg)
    local cdef = get_cdef(cname)
    cdef.users[name] = true
    set_cdef(cname, cdef)
    if msg then
        channel.send(cname, msg)
    else
        channel.send(cname, name .. " joined the channel.")
    end
    archtec_chat.users[name][cname] = true
end

function channel.leave(cname, name, msg)
    local cdef = get_cdef(cname)
    if msg then
        channel.send(cname, msg)
    else
        channel.send(cname, name .. " left the channel.")
    end
    cdef.users[name] = nil
    set_cdef(cname, cdef)
    if archtec.count_keys(cdef.users) == 0 then -- channel cleanup
        channel.delete(cname, "Service")
    end
    archtec_chat.users[name][cname] = nil
end

function channel.invite_delete(cname, target, timed_out)
    local cdef = get_cdef(cname)
    if cdef.invites[target] then -- invite might already be deleted
        minetest.log("action", "[archtec_chat] Delete '" .. cname .. "' invite for '" .. target .. "'")
        if timed_out then
            minetest.chat_send_player(target, C("#FF8800", "Invite timed-out"))
        end
        cdef.invites[target] = nil
        set_cdef(cname, cdef)
    end
end

function channel.invite(cname, target, inviter)
    local cdef = get_cdef(cname)
    minetest.log("action", "[archtec_chat] '" .. inviter .. "' invited  '" .. target .. "' to channel '" .. cname .. "'")
    minetest.chat_send_player(target, C("#FF8800", inviter .. " invited you to join #" .. cname .. ". '/c j " .. cname .. "' to join. It will timeout in 60 seconds. Type '/c l main' to leave the main channel."))
    cdef.invites[target] = os.time()
    set_cdef(cname, cdef)
    minetest.after(60, function(cname, target)
        local cdef = get_cdef(cname)
        if cdef and cdef.invites[target] then
            channel.invite_delete(cname, target, true)
        end
    end, cname, target)
end

function channel.invite_accept(cname, target)
    minetest.log("action", "[archtec_chat] Invite in '" .. cname .. "' accepted by '" .. target .. "'")
    channel.invite_delete(cname, target, false)
    channel.join(cname, target)
end

local function list_table(t)
    if next(t) == nil then
        return ""
    end
    local string = ""
    for key, _ in pairs(t) do
        string = string .. key .. ", "
    end
    string = string:sub(1, #string - 2)
    return string
end

local function get_cname(c)
    if not c then return end
    if c:sub(1, 1) == "#" then
        return c:sub(2, #c)
    else
        return c
    end
end

channel.get_cname = get_cname

local help_list = {
    join = {
        name = "join",
        description = "Join a channel (# is optional)",
        param = "<channel>",
        shortcut = "j",
        usage = "/c join #mychannel"
    },
    leave = {
        name = "leave",
        description = "Leave a channel (# is optional)",
        param = "<channel>",
        shortcut = "l",
        usage = "/c leave #mychannel"
    },
    invite = {
        name = "invite",
        description = "Invite someone in a channel (# is optional)",
        param = "<channel> <name>",
        shortcut = "i",
        usage = "/c invite #mychannel Player007"
    },
    list = {
        name = "list",
        description = "List all channels",
        param = "",
        shortcut = "li",
        usage = "/c list"
    },
    find = {
        name = "find",
        description = "Finds all channels where <name> is",
        param = "<name>",
        shortcut = "f",
        usage = "/c find Player007"
    },
    kick = {
        name = "kick",
        description = "Kicks <name> from <channel>. Can be used by channelowners. (# is optional)",
        param = "<channel> <name>",
        shortcut = "k",
        usage = "/c kick #mychannel Player007"
    },
    move = {
        name = "move",
        description = "Moves <name> from <channel1> to <channel2>. Staff only command. (# is optional)",
        param = "<name> <channel1> <channel2>",
        shortcut = "m",
        usage = "/c move Player007 #mychannel #mychannel2"
    },
    help = {
        name = "help",
        description = "Sends you the help for <sub-command>",
        param = "<sub-command>",
        shortcut = "h",
        usage = "/c help join"
    }
}

local tab = "   "

local function parse_help(d)
    local s = ""
    s = s .. "----------\n"
    s = s .. d.name .. ":\n"
    s = s .. tab .. "Description: " .. d.description .. "\n"
    s = s .. tab .. "Params: " .. d.param .. "\n"
    s = s .. tab .. "Shortcut: " .. d.shortcut .. "\n"
    s = s .. tab .. "Usage: " .. d.usage .. "\n"
    return s
end

local function help_all()
    local s = "Archtec chat command reference\n"
    for cmd, d in pairs(help_list) do
        s = s .. parse_help(d)
    end
    return C("#00BD00", s)
end

minetest.register_chatcommand("c", {
    func = function(name, param)
        minetest.log("action", "[/c] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
        if param:trim() == "" or param:trim() == nil then
            minetest.chat_send_player(name, help_all())
            return
        end
        local params = {}
        for p in string.gmatch(param, "[^%s]+") do
            table.insert(params, p)
        end
        local action, p1, p2, p3 = params[1], params[2], params[3], params[4]
        if action == "join" or action == "j" then
            local c = archtec.get_and_trim(p1)
            if c == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/join] No channelname provided!"))
                return
            end
            c = get_cname(c) -- remove channel prefix
            local cdef = get_cdef(c)
            -- join if main
            if c == "main" then
                channel.join(c, name, "")
                minetest.chat_send_player(name, C("#00BD00", "[c/join] Joined #main"))
                return
            end
            -- create if not registered
            if not cdef then
                if type(c) == "string" and string.len(c) <= 30 then
                    channel.create(c, name)
                    channel.join(c, name, name .. " created the channel.")
                    return
                else
                    minetest.chat_send_player(name, C("#FF0000", "[c/join] Channelname contains forbidden characters or is too long!"))
                    return
                end
            end
            -- check if player is already in channel
            if cdef.users[name] then
                minetest.chat_send_player(name, C("#FF0000", "[c/join] You are already in this channel!"))
                return
            end
            -- is player invited?
            local is_owner = is_channel_owner(cdef, name)
            if cdef.invites[name] or is_owner then
                -- is ignored player in channel?
                local kicks = {}
                for user, _ in pairs(cdef.users) do
                    if archtec.ignore_check(name, user) then
                        if not is_channel_owner(cdef, user) and is_owner then
                            table.insert(kicks, user)
                        else
                            archtec.ignore_msg("c/join", name, user)
                            return
                        end
                    end
                end -- TODO allow owners to join, kick other players
                if cdef.invites[name] then
                    channel.invite_accept(c, name)
                else
                    channel.join(c, name)
                end
                -- kick later to prevent automatic channel deletions
                for _, user in pairs(kicks) do
                    channel.leave(c, user, name .. " (channelowner) kicked " .. user .. ". (automatic kick to allow owner join)")
                end
            else
                minetest.chat_send_player(name, C("#FF0000", "[c/join] You aren't invited!"))
                return
            end
        elseif action == "leave" or action == "l" then
            local c = archtec.get_and_trim(p1)
            if c == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/leave] No channelname provided!"))
                return
            end
            c = get_cname(c) -- remove channel prefix
            local cdef = get_cdef(c)
            -- leave if main
            if c == "main" then
                channel.leave(c, name, "")
                minetest.chat_send_player(name, C("#00BD00", "[c/leave] Left #main"))
                return
            end
            -- check if player is in channel
            if not cdef or not cdef.users[name] then
                minetest.chat_send_player(name, C("#FF0000", "[c/leave] You are not in this channel!"))
                return
            end
            channel.leave(c, name)
        elseif action == "list" or action == "li" then
            local channels = archtec_chat.channels
            if next(channels) == nil then
                minetest.chat_send_player(name, C("#FF0000", "No channels registered!"))
                return
            end
            local list = ""
            for cname, cdef in pairs(channels) do
                list = list .. cname .. " - " .. list_table(cdef.users or {}) .. "\n"
            end
            list = list:sub(1, #list - 1)
            minetest.chat_send_player(name, C("#00BD00", list))
        elseif action == "invite" or action == "i" then
            local c = archtec.get_and_trim(p1)
            local target = archtec.get_and_trim(p2)
            if c == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] No channelname provided!"))
                return
            end
            if target == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] No target provided!"))
                return
            end
            if not archtec.is_online(target) then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] " .. target .. " is not online!"))
                return
            end
            c = get_cname(c) -- remove channel prefix
            local cdef = get_cdef(c)
            if not cdef then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] Channel #" .. c .. " does not exist!"))
                return
            end
            if not is_channel_owner(cdef, name) then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] You aren't authorized to invite someone to join " .. c .. "!"))
                return
            end
            if not cdef.users[name] then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] You can't invite " .. target .. " since you aren't in #" .. c))
                return
            end
            if cdef.users[target] then
                minetest.chat_send_player(name, C("#FF0000", "[c/invite] " .. target .. " is already a member of #" .. c .. "!"))
                return
            end
            if archtec.ignore_check(name, target) then
                archtec.ignore_msg("c/invite", name, target)
                return
            end
            channel.invite(c, target, name)
            minetest.chat_send_player(name, C("#00BD00", "[c/invite] Invited " .. target .. " to join #" .. c))
        elseif action == "kick" or action == "k" then
            local c = archtec.get_and_trim(p1)
            local target = archtec.get_and_trim(p2)
            if c == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/kick] No channelname provided!"))
                return
            end
            if target == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/kick] No target provided!"))
                return
            end
            c = get_cname(c) -- remove channel prefix
            local cdef = get_cdef(c)
            if not cdef then
                minetest.chat_send_player(name, C("#FF0000", "[c/kick] Channel #" .. c .. " does not exist!"))
                return
            end
            if not is_channel_owner(cdef, name) then
                minetest.chat_send_player(name, C("#FF0000", "[c/kick] You aren't authorized to kick someone!"))
                return
            end
            if not cdef.users[target] then
                minetest.chat_send_player(name, C("#FF0000", "[c/kick] " .. target .. " is not in #" .. c .. "!"))
                return
            end
            channel.leave(c, target, name .. " kicked " .. target .. ".")
        elseif action == "move" or action == "m" then
            if not minetest.get_player_privs(name).staff then
                minetest.chat_send_player(name, C("#FF0000", "[c/move] You aren't authorized to move someone!"))
                return
            end
            local target = archtec.get_and_trim(p1)
            local c1 = archtec.get_and_trim(p2)
            local c2 = archtec.get_and_trim(p3)
            if target == "" or c1 == "" or c2 == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/move] Missing param (<target> <channel 1> <channel 2>)!"))
                return
            end
            if not archtec.is_online(target) then
                minetest.chat_send_player(name, C("#FF0000", "[c/move] " .. target .. " is not online!"))
                return
            end
            c1, c2 = get_cname(c1), get_cname(c2) -- remove channel prefixes
            local cdef1, cdef2 = get_cdef(c1), get_cdef(c2)
            if not cdef1 then
                minetest.chat_send_player(name, C("#FF0000", "[c/move] Channel #" .. c1 .. " does not exist!"))
                return
            end
            if not cdef2 then
                minetest.chat_send_player(name, C("#FF0000", "[c/move] Channel #" .. c2 .. " does not exist!"))
                return
            end
            if not cdef1.users[target] then
                minetest.chat_send_player(name, C("#FF0000", "[c/move] " .. target .. " is not in #" .. c1 .. "!"))
                return
            end
            channel.leave(c1, target, name .. " moved " .. target .. " to #" .. c2 .. ".")
            channel.join(c2, target, name .. " moved " .. target .. " from #" .. c1 .. " to here.")
            minetest.chat_send_player(name, C("#00BD00", "[c/move] Moved " .. target .. " to #" .. c2))
        elseif action == "find" or action == "f" then
            local target = archtec.get_and_trim(p1)
            if target == "" then
                minetest.chat_send_player(name, C("#FF0000", "[c/find] No target provided!"))
                return
            end
            if not archtec.is_online(target) then
                minetest.chat_send_player(name, C("#FF0000", "[c/find] " .. target .. " is not online!"))
                return
            end
            local channels = archtec_chat.users[target]
            if next(channels) == nil then
                minetest.chat_send_player(name, C("#FF0000", target .. " is in no channels!"))
                return
            end
            minetest.chat_send_player(name, C("#00BD00", list_table(channels or {})))
        elseif action == "help" or action == "h" then
            local help = archtec.get_and_trim(p1)
            if help == "" then
                minetest.chat_send_player(name, help_all())
                return
            end
            local hd = help_list[help]
            if not hd then
                minetest.chat_send_player(name, C("#FF0000", "[c/help] No help for this sub-command available!"))
                return
            end
            minetest.chat_send_player(name, C("#00BD00", parse_help(hd)))
        else
            minetest.chat_send_player(name, help_all())
        end
    end
})
return channel