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
	params = "<name>",
	description = S("Enables PvP"),
	privs = {staff = true},
	func = function(name, param)
		local target = param:trim()
		if archtec_pvp.is_pvp(target) then
			minetest.chat_send_player(name, "PvP of " .. target .. " is already enabled")
			return
		end
		archtec_pvp.pvp_enable(target)
		minetest.chat_send_player(name, "Enabled PvP of " .. target)
	end
})

minetest.register_chatcommand("pvp_disable", {
	params = "<name>",
	description = S("Disables PvP"),
	privs = {staff = true},
	func = function(name, param)
		local target = param:trim()
		if not archtec_pvp.is_pvp(target) then
			minetest.chat_send_player(name, "PvP of " .. target .. " is already disabled")
			return
		end
		archtec_pvp.pvp_disable(target)
		minetest.chat_send_player(name, "Disabled PvP of " .. target)
	end
})
