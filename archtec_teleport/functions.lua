local S = minetest.get_translator(minetest.get_current_modname())

-- Placeholders
local chatmsg, source, target, name2, target_coords

local function send_message(player, message)
	minetest.chat_send_player(player, minetest.colorize("#FF8800", message))
end

-- Teleport player to a player (used in "/tpr" command).
function archtec_teleport.tpr_teleport_player()
	target_coords = source:get_pos()
	local target_sound = target:get_pos()
	target:set_pos(archtec_teleport.find_free_position_near(target_coords))
	minetest.sound_play("tpr_warp", {pos = target_coords, gain = 0.5, max_hear_distance = 10}, true)
	minetest.sound_play("tpr_warp", {pos = target_sound, gain = 0.5, max_hear_distance = 10}, true)
end

function archtec_teleport.find_free_position_near(pos)
	local tries = {
		{x=1,y=0,z=0},
		{x=-1,y=0,z=0},
		{x=0,y=0,z=1},
		{x=0,y=0,z=-1},
	}
	for _,d in pairs(tries) do
		local p = vector.add(pos, d)
		local def = minetest.registered_nodes[minetest.get_node(p).name]
		if def and not def.walkable then
			return p, true
		end
	end
	return pos, false
end

-- Teleport Request System
function archtec_teleport.tpr_send(sender, receiver)
	if receiver == "" then
		send_message(sender, S("Usage: /tpr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		return
	end

	if sender == receiver then
		send_message(sender, S("You can't teleport you to yourself"))
		return
	end

	minetest.log("action", "[archtec_teleport] " .. sender .. " is trying to teleport to " .. receiver)
	send_message(receiver, S("@1 is requesting to teleport to you. /ok to accept.", sender))
	send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", archtec_teleport.timeout_delay))

	-- Write name values to list and clear old values.
	archtec_teleport.tpr_list[receiver] = sender
	archtec_teleport.tpn_list[sender] = receiver

	-- Teleport timeout delay
	minetest.after(archtec_teleport.timeout_delay, function(sender_name, receiver_name)
		if archtec_teleport.tpr_list[receiver_name] and archtec_teleport.tpn_list[sender_name] then
			archtec_teleport.tpr_list[receiver_name] = nil

			send_message(sender_name, S("Request timed-out."))
			send_message(receiver_name, S("Request timed-out."))
			return
		end
	end, sender, receiver)
end

function archtec_teleport.tp2me_send(sender, receiver)
	if receiver == "" then
		send_message(sender, S("Usage: /tp2me <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		return
	end

	if sender == receiver then
		send_message(sender, S("You can't teleport you to yourself"))
		return
	end

	minetest.log("action", "[archtec_teleport] " .. sender .. " requested to teleport " .. receiver .. " to " .. sender)
	send_message(receiver, S("@1 is requesting that you teleport to them. /ok to accept.", sender))
	send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", archtec_teleport.timeout_delay))

	-- Write name values to list and clear old values.
	archtec_teleport.tp2me_list[receiver] = sender

	-- Teleport timeout delay

	minetest.after(archtec_teleport.timeout_delay, function(sender_name, receiver_name)
		if archtec_teleport.tp2me_list[receiver_name] and archtec_teleport.tpn_list[sender_name] then
			archtec_teleport.tp2me_list[receiver_name] = nil
			archtec_teleport.tpn_list[sender_name] = nil

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

	archtec_teleport.tpr_teleport_player()

	-- Avoid abusing with area requests
	target_coords = nil

	send_message(name, chatmsg)
	-- Immediate_teleport
	send_message(name2, S("Request Accepted!"))
end
