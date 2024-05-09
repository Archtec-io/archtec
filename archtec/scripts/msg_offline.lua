local S = archtec.S
local C = minetest.colorize

local max_messages = 3
local max_message_length = 200
local delete_message_after = archtec.time.days(90)

--[[
	{
		created = 1700000000,
		author = "Player1",
		text = "Hello....",
	}
]]
--

archtec_playerdata.register_key("offline_msgs", "table", {})
archtec_playerdata.register_upgrade("offline_msgs", "archtec:cleanup_offline_msgs", true, function(name, msgs)
	for i, msg in ipairs(msgs) do
		if msg.created + delete_message_after > os.time() then
			msgs[i] = nil
		end
	end
	return msgs
end)

minetest.register_chatcommand("tell", {
	description = "Send private message to an offline player",
	params = "<name> <text>",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/tell] executed by '" .. name .. "' with param '" .. param .. "'")
		local target, msg = string.match(param, "([%a%d_-]+) (.+)")

		if target == nil or msg == nil then
			minetest.chat_send_player(name, C("#FF0000", S("[tell] No playername or message provided!")))
			return
		end

		if target == name then
			minetest.chat_send_player(name, C("#FF0000", S("[tell] You can't send yourself an offline message!")))
			return
		end

		if archtec.is_online(target) then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tell] @1 is online, please send a normal message to them!", target))
			)
			return
		end

		if not minetest.player_exists(target) then
			minetest.chat_send_player(name, C("#FF0000", S("[tell] Player '@1' does not exist!", target)))
			return
		end

		if archtec.ignore_check(name, target) then
			archtec.ignore_msg("tell", name, target)
			return
		end

		if #msg > max_message_length then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tell] Message too long! (max length is @1 characters)", max_message_length))
			)
			return
		end

		local msgs = archtec_playerdata.get(target, "offline_msgs")
		local messages_by_user = 0
		for _, tmsg in ipairs(msgs) do
			if tmsg.author == name then
				messages_by_user = messages_by_user + 1
			end
		end

		if messages_by_user >= max_messages then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tell] You can't send @1 more than @2 offline messages!", target, max_messages))
			)
			return
		end

		msgs[#msgs + 1] = {created = os.time(), author = name, text = msg}
		archtec_playerdata.set(target, "offline_msgs", msgs)
		minetest.chat_send_player(
			name,
			C("#00BD00", S("[tell] Message saved. @1 will see your message when they joins the next time.", target))
		)
		minetest.log("action", "[archtec] Saved offline message from " .. name .. " to " .. target .. ": " .. msg)
	end,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local msgs = archtec_playerdata.get(name, "offline_msgs")

	if #msgs > 0 then
		for i, msg in ipairs(msgs) do
			local date = os.date("!%Y-%m-%d %H:%M", msg.created) .. " UTC"
			minetest.chat_send_player(
				name,
				C("#FF0", S("[tell] @1 sent you an offline message at @2:", msg.author, date)) .. " " .. msg.text
			)
			minetest.log(
				"action",
				"[archtec] Sent offline message from "
					.. msg.author
					.. " to "
					.. name
					.. ": "
					.. msg.text
					.. " (created at "
					.. date
					.. ")"
			)
			msgs[i] = nil
		end

		archtec_playerdata.set(name, "offline_msgs", msgs)
	end
end)
