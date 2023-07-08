local S = minetest.get_translator(minetest.get_current_modname())

archtec_teleport = {
	tpr_list = {},
	tp2me_list = {}
}

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	if archtec_teleport.tpr_list[name] then
		archtec_teleport.tpr_list[name] = nil
	end

	if archtec_teleport.tp2me_list[name] then
		archtec_teleport.tp2me_list[name] = nil
	end
end)

local timeout_delay = 60

local function send_message(name, message)
	minetest.chat_send_player(name, minetest.colorize("#FF8800", message))
end

local function find_free_position_near(pos)
	local tries = {
		{x=1,y=0,z=0},
		{x=-1,y=0,z=0},
		{x=0,y=0,z=1},
		{x=0,y=0,z=-1},
	}
	for _, d in pairs(tries) do
		local p = vector.add(pos, d)
		local def = minetest.registered_nodes[minetest.get_node(p).name]
		if def and not def.walkable then
			return p
		end
	end
end

local function tpr_teleport_player(source, target, pos)
	target:set_pos(pos)
	minetest.sound_play("tpr_warp", {pos = source:get_pos(), gain = 0.5, max_hear_distance = 10}, true)
	minetest.sound_play("tpr_warp", {pos = target:get_pos(), gain = 0.5, max_hear_distance = 10}, true)
end

-- Teleport Request System
function archtec_teleport.tpr_send(sender, receiver)
    receiver = receiver:trim()
	if receiver == "" then
		send_message(sender, S("Usage: /tpr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player with this name!"))
		return
	end

	if sender == receiver then
		send_message(sender, S("You can't teleport you to yourself!"))
		return
	end

	if archtec.ignore_check(sender, receiver) then
		if archtec.is_ignored(sender, receiver) then -- TPR uses an extra message coloring and design system
			send_message(sender, S("You are ignoring @1. You can't interact with them!", receiver))
		else
			send_message(sender, S("@1 ignores you. You can't interact with them!", receiver))
		end
		return
	end

	minetest.log("action", "[archtec_teleport] " .. sender .. " is trying to teleport to " .. receiver)
	send_message(receiver, S("@1 is requesting to teleport to you. /ok to accept.", sender))
	send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", timeout_delay))

	-- Write name values to list and clear old values.
	archtec_teleport.tpr_list[receiver] = sender

	-- Teleport timeout delay
	minetest.after(timeout_delay, function(sender_name, receiver_name)
		if archtec_teleport.tpr_list[receiver_name] then
			archtec_teleport.tpr_list[receiver_name] = nil

			send_message(sender_name, S("Request timed-out."))
			send_message(receiver_name, S("Request timed-out."))
			return
		end
	end, sender, receiver)
end

function archtec_teleport.tp2me_send(sender, receiver)
    receiver = receiver:trim()
	if receiver == "" then
		send_message(sender, S("Usage: /tp2me <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player with this name!"))
		return
	end

	if sender == receiver then
		send_message(sender, S("You can't teleport you to yourself!"))
		return
	end

	if archtec.ignore_check(sender, receiver) then
		if archtec.is_ignored(sender, receiver) then -- TPR uses an extra message coloring and design system
			send_message(sender, S("You are ignoring @1. You can't interact with them!", receiver))
		else
			send_message(sender, S("@1 ignores you. You can't interact with them!", receiver))
		end
		return
	end

	minetest.log("action", "[archtec_teleport] " .. sender .. " requested to teleport " .. receiver .. " to " .. sender)
	send_message(receiver, S("@1 is requesting that you teleport to them. /ok to accept.", sender))
	send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", timeout_delay))

	-- Write name values to list and clear old values.
	archtec_teleport.tp2me_list[receiver] = sender

	-- Teleport timeout delay
	minetest.after(timeout_delay, function(sender_name, receiver_name)
		if archtec_teleport.tp2me_list[receiver_name] then
			archtec_teleport.tp2me_list[receiver_name] = nil

			send_message(sender_name, S("Request timed-out."))
			send_message(receiver_name, S("Request timed-out."))
			return
		end
	end, sender, receiver)
end

-- Teleport Accept Systems
function archtec_teleport.tpr_accept(name)
	-- Check to prevent constant teleporting
	if not archtec_teleport.tpr_list[name] and not archtec_teleport.tp2me_list[name] then
		send_message(name, S("Usage: /ok allows you to accept teleport requests sent to you by other players."))
		return
	end
    local name2, source, target, chatmsg

	-- Teleport requests.
	if archtec_teleport.tpr_list[name] then
		name2 = archtec_teleport.tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = S("@1 is teleporting to you.", name2)
		archtec_teleport.tpr_list[name] = nil
	elseif archtec_teleport.tp2me_list[name] then
		name2 = archtec_teleport.tp2me_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = S("You are teleporting to @1.", name2)
		archtec_teleport.tp2me_list[name] = nil
	else
		return
	end

	-- Could happen if either player disconnects (or timeout); if so just abort
	if not source or not target then
		send_message(name, S("@1 is not online right now.", name2))
		archtec_teleport.tpr_list[name] = nil
		archtec_teleport.tp2me_list[name] = nil
		return
	end

    local pos = find_free_position_near(source:get_pos())
    if not pos then
        send_message(name, S("@1 is not at a safe teleport position. Ask them for move to another spot!", name2))
		send_message(name2, S("@1 tried to teleport to you but you aren't at a safe teleport position. Please move to another spot!", name))
        return
    end

	tpr_teleport_player(source, target, pos)

	send_message(name, chatmsg)
	-- Immediate_teleport
	send_message(name2, S("Request Accepted!"))
end

minetest.register_chatcommand("tpr", {
	description = S("Request teleport to another player"),
	params = "<playername>",
	privs = {interact = true},
	func = archtec_teleport.tpr_send
})

minetest.register_chatcommand("tp2me", {
	description = S("Request player to teleport to you"),
	params = "<playername>",
	privs = {interact = true},
	func = archtec_teleport.tp2me_send
})

minetest.register_chatcommand("ok", {
	description = S("Accept teleport requests from another player"),
	privs = {interact = true},
	func = archtec_teleport.tpr_accept
})