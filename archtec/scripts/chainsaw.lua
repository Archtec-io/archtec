if not minetest.get_modpath("choppy") then return end

local api = choppy.api

minetest.register_tool(":technic:chainsaw", {
	description = "Chainsaw",
	inventory_image = "technic_chainsaw.png",
    tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
	sound = {breaks = "default_tool_breaks"},
	on_use = function(itemstack, digger, pointed_thing)
		local pos = pointed_thing.under
		local oldnode = minetest.get_node_or_nil(pointed_thing.under)

		if not api.is_tree_node(oldnode.name, "trunk") then
			-- not a tree trunk
			return
		end

		if not minetest.is_player(digger) then
			return
		end

		local player_name = digger:get_player_name()

		if api.get_process(player_name) then
			-- already cutting
			return
		end

		if api.is_wielding_axe(digger) and api.is_enabled(digger) then
			local treetop = api.find_treetop(pos, oldnode, player_name)
			if treetop then
				api.start_process(digger, treetop, oldnode.name)
			else
				api.start_process(digger, pos, oldnode.name)
			end
		end
	end,
})

choppy.api.registered_axes = {}

choppy.api.register_axe("technic:chainsaw")
