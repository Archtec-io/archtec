if minetest.get_modpath("digilines") then
	minetest.override_item("digilines:chest", {
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

if minetest.get_modpath("fireworkz") then
	minetest.override_item("fireworkz:launcher", {
		groups = {cracky = 2},
	})
end

if minetest.get_modpath("fake_fire") then
	minetest.override_item("fake_fire:fancy_fire", {
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			return itemstack
		end,
	})
end

if minetest.get_modpath("ethereal") then
	minetest.override_item("ethereal:golden_apple", {
		on_use = function(itemstack, user, pointed_thing)
			if user then
				user:set_hp(20)
				return minetest.do_item_eat(20, nil, itemstack, user, pointed_thing)
			end
		end,
	})
end

-- remove torch damage
if minetest.get_modpath("3d_armor") then
	minetest.override_item("default:torch", {damage_per_second = 0})
	minetest.override_item("default:torch_wall", {damage_per_second = 0})
	minetest.override_item("default:torch_ceiling", {damage_per_second = 0})
end

if minetest.get_modpath("homedecor_wardrobe") then
	minetest.override_item("homedecor:wardrobe", {
		on_construct = function()
		end,
		on_place = function(itemstack, placer, pointed_thing)
			return homedecor.stack_vertically(itemstack, placer, pointed_thing, itemstack:get_name(), "placeholder")
		end,
		can_dig = function(pos, player)
			local meta = minetest.get_meta(pos)
			return meta:get_inventory():is_empty("main")
		end,
	})
end

if minetest.get_modpath("xdecor") then
	minetest.override_item("xdecor:mailbox", {
		can_dig = function(pos, player)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local player_name = player and player:get_player_name()
			local inv = meta:get_inventory()
			if minetest.check_player_privs(player_name, {staff = true}) then
				return inv:is_empty("mailbox")
			end
			return inv:is_empty("mailbox") and player_name == owner
		end,
	})
end

-- Give pandas more HP
if minetest.get_modpath("mobs_animal") then
	local def = minetest.registered_entities["mobs_animal:panda"]
	def.hp_max = 30 -- default 24
	def.hp_min = 15 -- default 10
	minetest.registered_entities["mobs_animal:panda"] = def
end

-- Higher spawn chance for mobs
minetest.register_on_mods_loaded(function()
	for _, abm in ipairs(minetest.registered_abms) do
		local label = abm.label or ""

		-- Modify spawn chances of mobs
		if label:sub(1, 12) == "mobs_animal:" then
			abm.chance = abm.chance * 0.75
		end

		if label:sub(1, 13) == "mobs_monster:" then
			abm.chance = abm.chance * 0.5
		end
	end
end)

local gates = {"castle_gates:steel_portcullis_bars", "castle_gates:wood_portcullis_bars"}

if minetest.get_modpath("castle_gates") then
	for _, name in ipairs(gates) do
		local def = table.copy(minetest.registered_nodes[name]) -- table.copy prevents LC warnings
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
		minetest.register_node(":" .. name .. "_lite", def)
	end

	minetest.register_craft({
		output = "castle_gates:wood_portcullis_bars_lite",
		recipe = {
			{"group:wood", "default:steel_ingot", "group:wood"},
			{"group:wood", "default:tin_ingot", "group:wood"},
			{"group:wood", "default:steel_ingot", "group:wood"},
		}
	})

	minetest.register_craft({
		output = "castle_gates:steel_portcullis_bars_lite",
		recipe = {
			{"", "default:steel_ingot", ""},
			{"default:steel_ingot", "", "default:steel_ingot"},
			{"", "default:steel_ingot", ""},
		}
	})
end

if minetest.get_modpath("homedecor_fences") then
	local def = table.copy(minetest.registered_nodes["homedecor:fence_wrought_iron_2"])
	def.can_dig = nil
	def.groups = {cracky = 1, not_in_creative_inventory = 1}
	def.description = def.description .. " (slow dig)"
	minetest.register_node(":" .. def.name .. "_slow", def)
end

if minetest.get_modpath("caverealms") then
	minetest.override_item("caverealms:stone_with_algae", {
		drop = "caverealms:stone_with_algae"
	})

	minetest.override_item("caverealms:stone_with_lichen", {
		drop = "caverealms:stone_with_lichen"
	})

	minetest.override_item("caverealms:stone_with_moss", {
		drop = "caverealms:stone_with_moss"
	})
end

if minetest.get_modpath("carts") then
	carts.speed_max = 8
end