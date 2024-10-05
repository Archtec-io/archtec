if not minetest.get_modpath("techage") then return end
local S = archtec.S

local old_on_place = minetest.registered_nodes["techage:forceload"].on_place or function() end
minetest.override_item("techage:forceload", {
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()

		if not minetest.check_player_privs(name, "forceload") then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", S("[Forceload Restriction]: 'forceload' priv required to use this node!")))
			return
		else
			return old_on_place(itemstack, placer, pointed_thing)
		end
	end
})

local old_on_place2 = minetest.registered_nodes["techage:forceloadtile"].on_place or function() end
minetest.override_item("techage:forceloadtile", {
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()

		if not minetest.check_player_privs(name, "forceload") then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", S("[Forceload Restriction]: 'forceload' priv required to use this node!")))
			return
		else
			return old_on_place2(itemstack, placer, pointed_thing)
		end
	end
})

local old_on_place3 = minetest.registered_nodes["techage:ta3_drillbox_pas"].on_place or function() end
minetest.override_item("techage:ta3_drillbox_pas", {
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()

		if not minetest.check_player_privs(name, "forceload") then
			archtec.priv_grant(name, "forceload")
			minetest.chat_send_player(name, minetest.colorize("#00BD00", S("Congratulations! You have been granted the '@1' privilege.", "forceload")))
			archtec.notify_team("[techage] Granted '" .. name .. "' the 'forceload' priv")
			return old_on_place3(itemstack, placer, pointed_thing)
		else
			return old_on_place3(itemstack, placer, pointed_thing)
		end
	end
})

-- Disable titanium drops
techage.register_ore_for_gravelsieve("titanium:titanium", 99999)

-- signs_bot: Support for a few more trees
local ts = signs_bot.register_tree_saplings
ts("cherrytree:sapling", "cherrytree:sapling", 2400, 4800)
ts("mahogany:sapling", "mahogany:sapling", 2400, 4800)
