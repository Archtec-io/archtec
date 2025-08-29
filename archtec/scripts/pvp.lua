local S = archtec.S
local C = core.colorize
local data = {}

local function get_data(name)
	return data[name] or {}
end

local function pvp_enable(name, player, init)
	data[name].pvp = true

	if not init then
		player:hud_remove(data[name].pvp_bg_off)
		player:hud_remove(data[name].pvp_icon_off)
		data[name].pvp_bg_off = nil
		data[name].pvp_icon_off = nil

		core.chat_send_player(name, S("Your PvP has been enabled."))
	end

	data[name].pvp_bg_on = player:hud_add({
		type = "image",
		position = {x = 1, y = 1},
		scale = {x = 1, y = 1},
		offset = {x= -30, y = -30},
		text = "ui_formbg_9_sliced.png^[colorize:#FF0000:60",
	})

	data[name].pvp_icon_on = player:hud_add({
		type = "image",
		position = {x = 1, y = 1},
		scale = {x = 3, y = 3},
		offset = {x = -30, y = -30},
		text = "archtec_pvp_on.png",
	})
end

local function pvp_disable(name, player, init)
	data[name].pvp = false

	if not init then
		player:hud_remove(data[name].pvp_bg_on)
		player:hud_remove(data[name].pvp_icon_on)
		data[name].pvp_bg_on = nil
		data[name].pvp_icon_on = nil

		core.chat_send_player(name, S("Your PvP has been disabled."))
	end

	data[name].pvp_bg_off = player:hud_add({
		type = "image",
		position = {x = 1, y = 1},
		scale = {x = 1, y = 1},
		offset = {x= -30, y = -30},
		text = "ui_formbg_9_sliced.png^[colorize:#00BD00:60",
	})

	data[name].pvp_icon_off = player:hud_add({
		type = "image",
		position = {x = 1, y = 1},
		scale = {x = 3, y = 3},
		offset = {x = -30, y = -30},
		text = "archtec_pvp_off.png",
	})
end

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	data[name] = {}
	pvp_disable(name, player, true)
end)

core.register_on_leaveplayer(function(player)
	data[player:get_player_name()] = nil
end)

core.register_on_punchplayer(function(player, hitter)
	if not hitter or not hitter:is_player() then
		return false
	end

	local name = player:get_player_name()  -- Attacked (passive)
	local name_hitter = hitter:get_player_name() -- Hitter (active)

	if name == name_hitter then
		return false
	end

	if not get_data(name_hitter).pvp then
		core.chat_send_player(name_hitter, C("#FF0000", S("You can't hit @1 because your PvP is disabled!", name)))
		return true
	end
	if not get_data(name).pvp then
		core.chat_send_player(name_hitter, C("#FF0000", S("You can't hit @1 because their PvP is disabled!", name)))
		return true
	end

	if archtec.ignore_check(name, name_hitter) then
		archtec.ignore_msg(nil, name_hitter, name) -- message should go to hitter
		return true
	end

	return false
end)

local old_calculate_knockback = core.calculate_knockback
function core.calculate_knockback(player, hitter, ...)
	if not get_data(player:get_player_name()).pvp or not get_data(hitter:get_player_name()).pvp then
		return 0
	end
	return old_calculate_knockback(player, hitter, ...)
end

-- Integration for players
if core.get_modpath("unified_inventory") then
	unified_inventory.register_button("pvp", {
		type = "image",
		image = "archtec_pvp_on.png",
		tooltip = "PvP",
		action = function(player)
			local name = player:get_player_name()
			if get_data(name).pvp then
				pvp_disable(name, player)
			else
				pvp_enable(name, player)
			end
		end
	})
end

core.register_chatcommand("pvp", {
	description = "Toggle PvP of other player",
	params = "<name> <on/off>",
	privs = {staff = true},
	func = function(name, param)
		core.log("action", "[/pvp] executed by '" .. name .. "' with param '" .. param .. "'")
		local params = archtec.parse_params(param)
		local target = archtec.get_and_trim(params[1])
		local mode = archtec.get_and_trim(params[2])

		if target == "" or mode == "" then
			core.chat_send_player(name, C("#FF0000", "[pvp] No target or PvP mode provided!"))
			return
		end

		if not archtec.is_online(target) then
			core.chat_send_player(name, C("#FF0000", "[pvp] Player '" .. target .. "' isn't online!"))
			return
		end

		if mode ~= "on" and mode ~= "off" then
			core.chat_send_player(name, C("#FF0000", "[pvp] Mode must be 'on' or 'off'!"))
			return
		end

		if mode == "on" then
			if get_data(target).pvp then
				core.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already enabled!"))
				return
			end
			pvp_enable(target, core.get_player_by_name(target))
			core.chat_send_player(name, C("#00BD00", "[pvp] Enabled PvP of " .. target))
		elseif mode == "off" then
			if not get_data(target).pvp then
				core.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already disabled!"))
				return
			end
			pvp_disable(target, core.get_player_by_name(target))
			core.chat_send_player(name, C("#00BD00", "[pvp] Disabled PvP of " .. target))
		else
			core.chat_send_player(name, C("#FF0000", "[pvp] Unknown mode!"))
		end
	end
})
