minetest.override_item("homedecor:wardrobe", {

	on_construct = function()
	end,

	on_place = function(itemstack, placer, pointed_thing)

		return homedecor.stack_vertically(itemstack, placer, pointed_thing,
				itemstack:get_name(), "placeholder")
	end,

	can_dig = function(pos,player)

		local meta = minetest.get_meta(pos)

		return meta:get_inventory():is_empty("main")
	end,
})

