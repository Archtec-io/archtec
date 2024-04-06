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

-- Fix flowers. thx ethereal...
local flowers = {
	"flowers:rose",
	"flowers:tulip",
	"flowers:dandelion_yellow",
	"flowers:chrysanthemum_green",
	"flowers:geranium",
	"flowers:viola",
	"flowers:dandelion_white",
	"flowers:tulip_black",
	"flowers:mushroom_brown",
	"flowers:mushroom_red"
}

minetest.after(1, function()
	for _, flower in pairs(flowers) do
		techage.register_flower(flower)
		signs_bot.register_flower(flower)
	end
end)

-- Disable titanium drops
techage.register_ore_for_gravelsieve("titanium:titanium", 99999)

-- Biofuel support
if minetest.get_modpath("biofuel") then
	minetest.override_item("biofuel:fuel_can", {stack_max = 1, inventory_image = "archtec_biofuel_fuel_can.png"})

	minetest.register_craftitem(":biofuel:fuel_can_empty", {
		description = "Empty Canister of Biofuel",
		inventory_image = "archtec_biofuel_fuel_can_empty.png",
		stack_max = 1
	})

	techage.register_liquid("biofuel:fuel_can", "biofuel:fuel_can_empty", 1, "techage:gasoline")
end