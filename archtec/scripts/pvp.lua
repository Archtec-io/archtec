if not minetest.settings:get_bool("enable_pvp") then
	return
end
local S = archtec.S
local C = minetest.colorize
local data = {}

local function pvp_enable(name, player, init)
	data[name].pvp = true

	if not init then
		player:hud_remove(data[name].pvp_pic_off)
		player:hud_remove(data[name].pvp_text_off)
		data[name].pvp_pic_off = nil
		data[name].pvp_text_off = nil

		minetest.chat_send_player(name, S("Your PvP has been enabled."))
	end

	data[name].pvp_pic_on = player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 0},
		offset = {x=-210, y = 20},
		scale = {x = 1, y = 1},
		text = "archtec_pvp_on.png",
	})
	data[name].pvp_text_on = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0},
		offset = {x=-125, y = 20},
		scale = {x = 100, y = 100},
		text = S("PvP is enabled for you!"),
		number = 0xFF0000, -- Red
	})
end

local function pvp_disable(name, player, init)
	data[name].pvp = false

	if not init then
		player:hud_remove(data[name].pvp_pic_on)
		player:hud_remove(data[name].pvp_text_on)
		data[name].pvp_pic_on = nil
		data[name].pvp_text_on = nil

		minetest.chat_send_player(name, S("Your PvP has been disabled."))
	end

	data[name].pvp_pic_off = player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 0},
		offset = {x = -210, y = 20},
		scale = {x = 1, y = 1},
		text = "archtec_pvp_off.png",
	})
	data[name].pvp_text_off = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0},
		offset = {x=-125, y = 20},
		scale = {x = 100, y = 100},
		text = S("PvP is disabled for you!"),
		number = 0x7DC435,
	})
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	data[name] = {}
	pvp_disable(name, player, true)
end)

minetest.register_on_leaveplayer(function(player)
	data[player:get_player_name()] = nil
end)

minetest.register_on_punchplayer(function(player, hitter)
	if not hitter or not hitter:is_player() then
		return false
	end

	local name = player:get_player_name()
	local name_hitter = hitter:get_player_name()

	if name == name_hitter then
		return false
	end

	if not data[name_hitter].pvp then
		minetest.chat_send_player(name_hitter, C("#FF0000", S("You can't hit @1 because your PvP is disabled!", name)))
		return true
	end
	if not data[name].pvp then
		minetest.chat_send_player(name_hitter, C("#FF0000", S("You can't hit @1 because their PvP is disabled!", name)))
		return true
	end

	if archtec.ignore_check(name, name_hitter) then
		archtec.ignore_msg(nil, name_hitter, name) -- message should go to hitter
		return true
	end

	return false
end)

local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, hitter, ...)
	if not data[player:get_player_name()].pvp or not data[hitter:get_player_name()].pvp then
		return 0
	end
	return old_calculate_knockback(player, hitter, ...)
end

-- Integration for players
if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_button("pvp", {
		type = "image",
		image = "archtec_pvp_on.png",
		tooltip = "PvP",
		action = function(player)
			local name = player:get_player_name()
			if data[name].pvp then
				pvp_disable(name, player)
			else
				pvp_enable(name, player)
			end
		end
	})
end

minetest.register_chatcommand("pvp", {
	description = "Toggle PvP of other player",
	params = "<name> <on/off>",
	privs = {staff = true},
	func = function(name, param)
		minetest.log("action", "[/pvp] executed by '" .. name .. "' with param '" .. param .. "'")
		local params = archtec.parse_params(param)
		local target = archtec.get_and_trim(params[1])
		local mode = archtec.get_and_trim(params[2])

		if target == "" or mode == "" then
			minetest.chat_send_player(name, C("#FF0000", "[pvp] No target or PvP mode provided!"))
			return
		end

		if not archtec.is_online(target) then
			minetest.chat_send_player(name, C("#FF0000", "[pvp] Player '" .. target .. "' isn't online!"))
			return
		end

		if mode ~= "on" and mode ~= "off" then
			minetest.chat_send_player(name, C("#FF0000", "[pvp] Mode must be 'on' or 'off'!"))
			return
		end

		if mode == "on" then
			if data[target].pvp then
				minetest.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already enabled!"))
				return
			end
			pvp_enable(target, minetest.get_player_by_name(target))
			minetest.chat_send_player(name, C("#00BD00", "[pvp] Enabled PvP of " .. target))
		elseif mode == "off" then
			if not data[target].pvp then
				minetest.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already disabled!"))
				return
			end
			pvp_disable(target, minetest.get_player_by_name(target))
			minetest.chat_send_player(name, C("#00BD00", "[pvp] Disabled PvP of " .. target))
		else
			minetest.chat_send_player(name, C("#FF0000", "[pvp] Unknown mode!"))
		end
	end
})