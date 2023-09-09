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

local tries = {}
local rad = 1

for x = -rad, rad do
	for y = -rad, rad do
		for z = -rad, rad do
			table.insert(tries, vector.new(x, y, z))
		end
	end
end

local function find_free_position_near(pos)
	local lpos = vector.new(pos.x, pos.y - 0.5, pos.z)
	for _, try in ipairs(tries) do
		local vec = vector.round(vector.add(try, lpos))
		local node = minetest.get_node_or_nil(vec)
		if node then
			local def = minetest.registered_nodes[node.name]
			if def and (def.walkable or (def.liquidtype ~= "none" and def.damage_per_second <= 0)) then
				return pos
			end
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

	minetest.log("action", "[archtec_teleport] " .. sender .. " requested to teleport " .. receiver .. " to them")
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
	local name2, source, target, chatmsg, mode

	-- Teleport requests.
	if archtec_teleport.tpr_list[name] then
		name2 = archtec_teleport.tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = S("@1 is teleporting to you.", name2)
		mode = "tpr"
	elseif archtec_teleport.tp2me_list[name] then
		name2 = archtec_teleport.tp2me_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = S("You are teleporting to @1.", name2)
		mode = "tp2me"
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
		if mode == "tpr" then
			send_message(name, S("You can't accept the teleport request because you are not at a safe spot!"))
			send_message(name2, S("@1 tried to accept the teleport request but isn't at a safe spot!", name))
		elseif mode == "tp2me" then
			send_message(name2, S("@1 tried to accept the teleport request but you aren't at a safe spot. Please move to another spot!", name))
			send_message(name, S("You can't accept the teleport request because @1 is not at a safe spot!", name2))
		end
		return
	end

	tpr_teleport_player(source, target, pos)

	send_message(name, chatmsg)
	-- Immediate_teleport
	send_message(name2, S("Request Accepted!"))
	if mode == "tpr" then
		minetest.log("action", "[archtec_teleport] " .. name .. " accepted a tpr by " .. name2)
	elseif mode == "tp2me" then
		minetest.log("action", "[archtec_teleport] " .. name .. " accepted a tp2me by " .. name2)
	end

	archtec_teleport.tpr_list[name] = nil
	archtec_teleport.tp2me_list[name] = nil
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