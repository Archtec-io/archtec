-- Make digiline chest more different from default chests
if core.get_modpath("digilines") then
	core.override_item("digilines:chest", {
		tiles = {
			"default_chest_top.png" and "digiline_std.png",
			"default_chest_top.png",
			"default_chest_side.png",
			"default_chest_side.png",
			"default_chest_side.png",
			"default_chest_front.png",
		},
	})
end

-- Make launcher more easily diggable
if core.get_modpath("fireworkz") then
	core.override_item("fireworkz:launcher", {
		groups = {cracky = 2},
	})
end

-- Don't spawn infinite fire particles
if core.get_modpath("fake_fire") then
	core.override_item("fake_fire:fancy_fire", {
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			return itemstack
		end,
	})
end

-- Fill hunger bar completely
if core.get_modpath("ethereal") then
	core.override_item("ethereal:golden_apple", {
		on_use = function(itemstack, user, pointed_thing)
			if user then
				user:set_hp(20)
				return core.do_item_eat(20, nil, itemstack, user, pointed_thing)
			end
		end,
	})
end

-- Remove torch damage
if core.get_modpath("3d_armor") then
	core.override_item("default:torch", {damage_per_second = 0})
	core.override_item("default:torch_wall", {damage_per_second = 0})
	core.override_item("default:torch_ceiling", {damage_per_second = 0})
end

-- Disable wardrobe skin selector
if core.get_modpath("homedecor_wardrobe") then
	core.override_item("homedecor:wardrobe", {
		on_construct = function()
		end,
		on_place = function(itemstack, placer, pointed_thing)
			return homedecor.stack_vertically(itemstack, placer, pointed_thing, itemstack:get_name(), "placeholder")
		end,
		can_dig = function(pos, player)
			local meta = core.get_meta(pos)
			return meta:get_inventory():is_empty("main")
		end,
	})
end

-- Mailbox can be dug by staff members if empty
if core.get_modpath("xdecor") then
	core.override_item("xdecor:mailbox", {
		can_dig = function(pos, player)
			local meta = core.get_meta(pos)
			local owner = meta:get_string("owner")
			local player_name = player and player:get_player_name()
			local inv = meta:get_inventory()
			if core.check_player_privs(player_name, {staff = true}) then
				return inv:is_empty("mailbox")
			end
			return inv:is_empty("mailbox") and player_name == owner
		end,
	})
end

-- Give pandas more HP
if core.get_modpath("mobs_animal") then
	local def = core.registered_entities["mobs_animal:panda"]
	def.initial_properties.hp_max = 30 -- default 24
	def.initial_properties.hp_min = 15 -- default 10
	core.registered_entities["mobs_animal:panda"] = def
end

-- Higher spawn chance for mobs
core.register_on_mods_loaded(function()
	for _, abm in ipairs(core.registered_abms) do
		local label = abm.label or ""

		if label:sub(1, 12) == "mobs_animal:" then
			abm.chance = abm.chance * 0.5
		end

		if label:sub(1, 13) == "mobs_monster:" then
			abm.chance = abm.chance * 0.5
		end
	end
end)

-- Gates w/o movement
if core.get_modpath("castle_gates") then
	local gates = {"castle_gates:steel_portcullis_bars", "castle_gates:wood_portcullis_bars"}

	for _, name in ipairs(gates) do
		local def = table.copy(core.registered_nodes[name])
		-- remove castle_gates specific groups and functions
		def.can_dig = nil
		def.on_rightclick = nil
		if def.groups.cracky then
			def.groups = {cracky = 1}
		elseif def.groups.choppy then
			def.groups = {choppy = 1}
		end
		def.description = def.description .. " (without function)"
		-- register node
		core.register_node(":" .. name .. "_lite", def)
	end

	core.register_craft({
		output = "castle_gates:wood_portcullis_bars_lite",
		recipe = {
			{"group:wood", "default:steel_ingot", "group:wood"},
			{"group:wood", "default:tin_ingot", "group:wood"},
			{"group:wood", "default:steel_ingot", "group:wood"},
		}
	})

	core.register_craft({
		output = "castle_gates:steel_portcullis_bars_lite",
		recipe = {
			{"", "default:steel_ingot", ""},
			{"default:steel_ingot", "", "default:steel_ingot"},
			{"", "default:steel_ingot", ""},
		}
	})
end

-- Undigable fence
if core.get_modpath("homedecor_fences") then
	local def = table.copy(core.registered_nodes["homedecor:fence_wrought_iron_2"])
	def.can_dig = nil
	def.groups = {cracky = 1, not_in_creative_inventory = 1}
	def.description = def.description .. " (slow dig)"
	core.register_node(":" .. def.name .. "_slow", def)
end

-- Caveralms stones drop themselves
if core.get_modpath("caverealms") then
	core.override_item("caverealms:stone_with_algae", {
		drop = nil
	})

	core.override_item("caverealms:stone_with_lichen", {
		drop = nil
	})

	core.override_item("caverealms:stone_with_moss", {
		drop = nil
	})
end

-- Faster cart
if core.get_modpath("carts") then
	carts.speed_max = 9
end

-- Higher signs_bot accu capacity
if core.get_modpath("signs_bot") then
	signs_bot.MAX_CAPA = signs_bot.MAX_CAPA * 1.5
end

-- Add empty biofuel canister
if core.get_modpath("biofuel") then
	core.override_item("biofuel:fuel_can", {stack_max = 1, inventory_image = "archtec_biofuel_fuel_can.png"})

	core.register_craftitem(":biofuel:fuel_can_empty", {
		description = "Empty Canister of Biofuel",
		inventory_image = "archtec_biofuel_fuel_can_empty.png",
		stack_max = 1
	})
end

-- Annoy cheaters
core.override_item("default:stone", {
	damage_per_second = 5
})
