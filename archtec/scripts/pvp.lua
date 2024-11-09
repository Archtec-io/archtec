local S = archtec.S
local C = core.colorize
local enabled = {}

local function pvp_enable(name, player, init)
	enabled[name] = true
	archtec.modify_hud(name, 1, {bg_color = "#FF0000", icon = "archtec_pvp_on.png", icon_scale = 3})

	if not init then
		core.chat_send_player(name, S("Your PvP has been enabled."))
	end
end

local function pvp_disable(name, player, init)
	enabled[name] = false
	archtec.modify_hud(name, 1, {bg_color = "#00BD00", icon = "archtec_pvp_off.png", icon_scale = 3})

	if not init then
		core.chat_send_player(name, S("Your PvP has been disabled."))
	end
end

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	pvp_disable(name, player, true)
end)

core.register_on_leaveplayer(function(player)
	enabled[player:get_player_name()] = nil
end)

core.register_on_punchplayer(function(player, hitter)
	if not hitter or not hitter:is_player() then
		return false
	end

	local name = player:get_player_name()
	local name_hitter = hitter:get_player_name()

	if name == name_hitter then
		return false
	end

	if not enabled[name_hitter]then
		core.chat_send_player(name_hitter, C("#FF0000", S("You can't hit @1 because your PvP is disabled!", name)))
		return true
	end
	if not enabled[name] then
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
	if not enabled[player:get_player_name()] or not enabled[hitter:get_player_name()] then
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
			if enabled[name] then
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
			if enabled[target] then
				core.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already enabled!"))
				return
			end
			pvp_enable(target, core.get_player_by_name(target))
			core.chat_send_player(name, C("#00BD00", "[pvp] Enabled PvP of " .. target))
		elseif mode == "off" then
			if not enabled[target] then
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
