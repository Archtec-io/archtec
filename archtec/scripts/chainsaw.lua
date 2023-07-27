if not minetest.get_modpath("choppy") then return end

local S = archtec.S
local api = choppy.api

-- disable is_enabled() since we don't use the initialized function
choppy.api.is_enabled = function(...) return true end

local function conditions(name)
	local playtime = archtec_playerdata.get(name, "playtime")
	local nodes_dug = archtec_playerdata.get(name, "nodes_dug")
	local nodes_placed = archtec_playerdata.get(name, "nodes_placed")
	local timestap = archtec_playerdata.get(name, "first_join")
	if timestap > (os.time() - 604800) or playtime < 86400 or nodes_dug < 20000 or nodes_placed < 10000 then -- joined 7 days ago; 24h playtime
		return false
	end
	return true
end

archtec.chainsaw_conditions = conditions

local function grant_priv(name, priv)
	archtec.grant_priv(name, priv)
	minetest.chat_send_player(name, minetest.colorize("#00BD00", S("Congratulations! You have been granted the '@1' privilege", "archtec_chainsaw")))
	notifyTeam("[chainsaw] Granted '" .. name .. "' the 'archtec_chainsaw' priv")
end

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
		local name = digger:get_player_name()
		if not minetest.get_player_privs(name).archtec_chainsaw then
			if conditions(name) then
				grant_priv(name, "archtec_chainsaw")
			else
				minetest.chat_send_player(name, minetest.colorize("#FF0000", S("[chainsaw] You don't satisfy all conditions to use a chainsaw. Needed conditions: 20k nodes dug, 10k nodes placed, 24h playtime, 7 days or older account")))
				return
			end
		end

		if pointed_thing.type ~= "node" then
			return
		end

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

		if api.is_enabled(digger) then
			local treetop = api.find_treetop(pos, oldnode, digger)
			api.start_process(digger, pos, treetop or pos, oldnode.name)
		end
	end,
})

minetest.unregister_chatcommand("toggle_choppy")

anvil.make_unrepairable("technic:chainsaw")
choppy.api.registered_axes = {}
choppy.api.register_axe("technic:chainsaw")

minetest.register_craft({
	output = "technic:chainsaw",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:diamond"},
		{"basic_materials:copper_wire", "basic_materials:motor", "default:diamond"},
		{"", "dye:red", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "technic:chainsaw",
	recipe = {
		{"techage:ta3_canister_gasoline", "technic:chainsaw"}
	},
	replacements = {{"techage:ta3_canister_gasoline", "techage:ta3_canister_empty"}}
})

minetest.register_craft({
	type = "shapeless",
	output = "technic:chainsaw",
	recipe = {
		"biofuel:fuel_can", "technic:chainsaw",
		"biofuel:fuel_can", "biofuel:fuel_can",
	}
})
