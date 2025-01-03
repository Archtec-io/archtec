if not core.get_modpath("choppy") then return end

local S = archtec.S
local api = choppy.api
local ptime_min = archtec.time.hours(24)
local days_played = archtec.time.days(7)

core.register_privilege("archtec_chainsaw", S("Allows you to use the chainsaw"))

-- disable is_enabled() since we don't use the initialized function
choppy.api.is_enabled = function(...) return true end

local function conditions(name)
	local playtime = archtec_playerdata.get(name, "playtime")
	local nodes_dug = archtec_playerdata.get(name, "nodes_dug")
	local nodes_placed = archtec_playerdata.get(name, "nodes_placed")
	local timestamp = archtec_playerdata.get(name, "first_join")
	if timestamp > (os.time() - days_played) or playtime < ptime_min or nodes_dug < 20000 or nodes_placed < 10000 then -- joined 7 days ago; 24h playtime
		return false
	end
	return true
end

archtec.chainsaw_conditions = conditions

local function grant_priv(name, priv)
	archtec.priv_grant(name, priv)
	core.chat_send_player(name, core.colorize("#00BD00", S("Congratulations! You have been granted the '@1' privilege.", "archtec_chainsaw")))
	archtec.notify_team("[chainsaw] Granted '" .. name .. "' the 'archtec_chainsaw' priv")
end

core.register_tool(":technic:chainsaw", {
	description = S("Chainsaw"),
	inventory_image = "archtec_chainsaw.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 1,
		groupcaps = {
			choppy = {times = {[1] = 2.10, [2] = 0.90, [3] = 0.50}, uses = 30, maxlevel = 3},
		},
		damage_groups = {fleshy = 7},
	},
	sound = {breaks = "default_tool_breaks"},
	on_use = function(itemstack, digger, pointed_thing)
		local name = digger:get_player_name()
		if not core.get_player_privs(name).archtec_chainsaw then
			if conditions(name) then
				grant_priv(name, "archtec_chainsaw")
			else
				core.chat_send_player(name, core.colorize("#FF0000", S("[chainsaw] You don't satisfy all conditions to use a chainsaw. Needed conditions: 20k nodes dug, 10k nodes placed, 24h playtime, 7 days or older account!")))
				return
			end
		end

		if pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local oldnode = core.get_node_or_nil(pointed_thing.under)

		if not api.is_tree_node(oldnode.name, "trunk") then
			-- not a tree trunk
			return
		end

		if api.get_process(name) then
			-- already cutting
			return
		end

		if api.is_enabled(digger) then
			local treetop = api.find_treetop(pos, oldnode, digger)
			api.start_process(digger, pos, treetop or pos, oldnode.name)
		end
	end,
})

core.unregister_chatcommand("toggle_choppy")
core.unregister_chatcommand("disable_choppy")
core.unregister_chatcommand("visualize_choppy")

anvil.make_unrepairable("technic:chainsaw")
choppy.api.registered_axes = {}
choppy.api.register_axe("technic:chainsaw")

core.register_craft({
	output = "technic:chainsaw",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:diamond"},
		{"basic_materials:copper_wire", "basic_materials:motor", "default:diamond"},
		{"", "dye:red", "default:steel_ingot"},
	}
})

core.register_craft({
	output = "technic:chainsaw",
	recipe = {
		{"techage:ta3_canister_gasoline", "technic:chainsaw"}
	},
	replacements = {{"techage:ta3_canister_gasoline", "techage:ta3_canister_empty"}}
})

core.register_craft({
	type = "shapeless",
	output = "technic:chainsaw",
	recipe = {
		"biofuel:fuel_can", "technic:chainsaw",
		"biofuel:fuel_can", "biofuel:fuel_can",
	}
})

-- Reduce impact on saturation
local uses_choppy = {}
choppy.api.register_before_chop(function(self, player, pos, node)
	uses_choppy[player:get_player_name()] = true
end)

choppy.api.register_after_chop(function(self, player, pos, node)
	uses_choppy[player:get_player_name()] = nil
end)

stamina.register_on_exhaust_player(function(player, change, cause)
	if not core.is_player(player) then
		return
	end

	if cause == "dig" then
		local name = player:get_player_name()
		if uses_choppy[name] then
			return true -- Don't exhaust player
		end
	end
end)
