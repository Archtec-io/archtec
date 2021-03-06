local MP = minetest.get_modpath(minetest.get_current_modname())

local S = minetest.get_translator(minetest.get_current_modname())

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

minetest.register_chatcommand("pvp_enable", {
	params = "[<player>]",
	description = S("Enables PvP"),
	privs = {
		pvp = true
	},
	func = function(name, param)
		if param ~= "" then
			if not minetest.check_player_privs(name, "pvp_admin") then
				return false, S("You cannot change other players PvP state unless you have the pvp_admin privilege.")
			end
			name = param
		end
		if archtec_pvp.is_pvp(name) then
			return false, S("Your PvP is already enabled.")
		end
		return archtec_pvp.pvp_enable(name)
	end
})
minetest.register_chatcommand("pvp_disable", {
	params = "",
	description = S("Disables PvP"),
	privs = {
		pvp = true
	},
	func = function(name, param)
		if param ~= "" then
			if not minetest.check_player_privs(name, "pvp_admin") then
				return false, S("You cannot change other players PvP state unless you have the pvp_admin privilege.")
			end
			name = param
		end
		if not archtec_pvp.is_pvp(name) then
			return false, S("Your PvP is already disabled.")
		end
		return archtec_pvp.pvp_disable(name)
	end
})
