if not minetest.get_modpath("choppy") then return end

local api = choppy.api

local function joined(name)
	local timestap = archtec_playerdata.get(name, "first_join")
	if timestap < (os.time() - 604800) then -- one week ago
		return true
	else
		return false
	end
end

local function conditions(name)
	local playtime = archtec_playerdata.get(name, "playtime") or 0
	local nodes_dug = archtec_playerdata.get(name, "nodes_dug") or 0
	local nodes_placed = archtec_playerdata.get(name, "nodes_placed") or 0
	local old_enough = joined(name)
	if old_enough ~= true then
		return false
	end
	if playtime < 86400 then -- 24h playtime
		return false
	end
	if nodes_dug < 20000 then
		return false
	end
	if nodes_placed < 10000 then
		return false
	end
	return true
end

local function grant_priv(name, priv)
    local privs = minetest.get_player_privs(name)
    privs[priv] = true
    minetest.set_player_privs(name, privs)
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
		if not minetest.check_player_privs(digger, "archtec_chainsaw") then
			local name = digger:get_player_name()
			if conditions(name) then
				grant_priv(name, "archtec_chainsaw")
			else
				minetest.chat_send_player(name, minetest.colorize("#FF0000", "[chainsaw]: You don't satisfy all conditions to use a chainsaw. See /stats"))
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

minetest.register_craft({
	output = "technic:chainsaw",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:diamond"},
		{"basic_materials:copper_wire", "basic_materials:motor", "default:diamond"},
		{"", "dye:red", "default:steel_ingot"},
	}
})
