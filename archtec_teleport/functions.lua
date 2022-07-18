local S = minetest.get_translator(minetest.get_current_modname())

-- Placeholders
local chatmsg, source, target, name2, target_coords

local band = false

local message_color = tp.message_color

local function color_string_to_number(color)
	if string.sub(color,1,1) == '#' then
		color = string.sub(color, 2)
	end
	if #color < 6 then
		local r = string.sub(color,1,1)
		local g = string.sub(color,2,2)
		local b = string.sub(color,3,3)
		color = r..r .. g..g .. b..b
	elseif #color > 6 then
		color = string.sub(color, 1, 6)
	end
	return tonumber(color, 16)
end

local message_color_number = color_string_to_number(message_color)

local function send_message(player, message)
	minetest.chat_send_player(player, minetest.colorize(message_color, message))
end

-- Teleport player to a player (used in "/tpr" command).
function tp.tpr_teleport_player()
	target_coords = source:get_pos()
	local target_sound = target:get_pos()
	target:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("tpr_warp", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	minetest.sound_play("tpr_warp", {pos = target_sound, gain = 0.5, max_hear_distance = 10})
end

function tp.find_free_position_near(pos)
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
function tp.tpr_send(sender, receiver)
	if receiver == "" then
		send_message(sender, S("Usage: /tpr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		return
	end

	send_message(receiver, S("@1 is requesting to teleport to you. /ok to accept.", sender))
	send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", tp.timeout_delay))

	-- Write name values to list and clear old values.
	tp.tpr_list[receiver] = sender
	tp.tpn_list[sender] = receiver

	-- Teleport timeout delay
	minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
		if tp.tpr_list[receiver_name] and tp.tpn_list[sender_name] then
			tp.tpr_list[receiver_name] = nil

			send_message(sender_name, S("Request timed-out."))
			send_message(receiver_name, S("Request timed-out."))
			return
		end
	end, sender, receiver)
end

function tp.tp2me_send(sender, receiver)
	if receiver == "" then
		send_message(sender, S("Usage: /tp2me <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	send_message(receiver, S("@1 is requesting that you teleport to them. /ok to accept; /tpn to deny.", sender))
	send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", tp.timeout_delay))

	-- Write name values to list and clear old values.
	tp.tp2me_list[receiver] = sender

	-- Teleport timeout delay

	minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
		if tp.tp2me_list[receiver_name] and tp.tpn_list[sender_name] then
			tp.tp2me_list[receiver_name] = nil
			tp.tpn_list[sender_name] = nil

			send_message(sender_name, S("Request timed-out."))
			send_message(receiver_name, S("Request timed-out."))
			return
		end
	end, sender, receiver)
end

-- Teleport Accept Systems
function tp.tpr_accept(name)
	-- Check to prevent constant teleporting
	if not tp.tpr_list[name] and not tp.tp2me_list[name]
	and not tp.tpc_list[name] then
		send_message(name, S("Usage: /ok allows you to accept teleport/area requests sent to you by other players."))
		return
	end

	-- Teleport requests.
	if tp.tpr_list[name] then
		name2 = tp.tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = S("@1 is teleporting to you.", name2)
		tp.tpr_list[name] = nil

	elseif tp.tp2me_list[name] then
		name2 = tp.tp2me_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = S("You are teleporting to @1.", name2)
		tp.tp2me_list[name] = nil
	else
		return
	end

	-- Could happen if either player disconnects (or timeout); if so just abort
	if not source
	or not target then
		send_message(name, S("@1 is not online right now.", name2))
		tp.tpr_list[name] = nil
		tp.tp2me_list[name] = nil
		return
	end

	tp.tpr_teleport_player()

	-- Avoid abusing with area requests
	target_coords = nil

	send_message(name, chatmsg)


	if tp.enable_immediate_teleport then return end
		send_message(name2, S("Request Accepted!"))
		return
	end
end
