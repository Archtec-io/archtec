local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_button("pvp", {
		type = "image",
		image = "pvp.png",
		tooltip = "PvP",
		condition = function(player)
			return minetest.check_player_privs(player, "pvp")
		end,
		action = function(player)
			archtec_pvp.pvp_toggle(player:get_player_name())
		end
	})
end

minetest.register_chatcommand("pvp", {
	params = "<mode> <name>",
	description = S("Change the PvP mode of <name>"),
	privs = {staff = true},
	func = function(name, param)
		minetest.log("action", "[/pvp] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
		local params = archtec.parse_params(param)
		params[1] = params[1] or ""; params[2] = params[2] or ""
		local mode, target = params[1]:trim(), params[2]:trim()
		if mode == "" or target == "" then
			minetest.chat_send_player(name, C("#FF0000", "[pvp] No mode or target provided!"))
			return
		end
		local player = minetest.get_player_by_name(target)
		if not player then
			minetest.chat_send_player(name, C("#FF0000", "[pvp] Player '" .. target .. "' is not online!"))
			return
		end
		if mode == "enable" then
			if archtec_pvp.is_pvp(target) then
				minetest.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already enabled!"))
				return
			end
			archtec_pvp.pvp_enable(target)
			minetest.chat_send_player(name, C("#00BD00", "[pvp] Enabled PvP of " .. target))
		elseif mode == "disable" then
			if not archtec_pvp.is_pvp(target) then
				minetest.chat_send_player(name, C("#FF0000", "[pvp] PvP of " .. target .. " is already disabled!"))
				return
			end
			archtec_pvp.pvp_disable(target)
			minetest.chat_send_player(name, C("#00BD00", "[pvp] Disabled PvP of " .. target))
		else
			minetest.chat_send_player(name, C("#FF0000", "[pvp] Unknown mode!"))
			return
		end
	end
})