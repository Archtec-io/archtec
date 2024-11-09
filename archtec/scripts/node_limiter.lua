local S = archtec.S
local function generate_vector(pos, rad)
	return vector.new(pos.x + rad, pos.y + rad, pos.z + rad)
end

local function ov_node(node, check_nodes, rad, max)
	local old_place = core.registered_items[node].on_place or function() end
	core.override_item(node, {
		on_place = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.above

			-- handle on_rightclick of pointed_things correctly
			if pointed_thing.type == "node" and placer and not placer:get_player_control().sneak then
				local nn = core.get_node(pointed_thing.under).name
				if core.registered_nodes[nn] and core.registered_nodes[nn].on_rightclick then
					return old_place(itemstack, placer, pointed_thing)
				end
			end

			if check_nodes then -- nodes check
				local count = core.find_nodes_in_area(generate_vector(pos, tonumber(-rad)), generate_vector(pos, tonumber(rad)), check_nodes)
				if #count < max then
					return old_place(itemstack, placer, pointed_thing)
				else
					local pname = placer:get_player_name()
					core.log("action", "[node_limiter] " .. pname .. " tried to place " .. node .. " at " .. core.pos_to_string(pos))
					local n = core.registered_nodes[node].description or node
					core.chat_send_player(pname, core.colorize("#FF0000", S("You can't place more '@1' in this area!", n)))
				end
			else -- entity check
				local p1, p2 = archtec.get_block_bounds(pos)
				local objs = core.get_objects_in_area(p1, p2)
				if #objs > max then
					local pname = placer:get_player_name()
					core.log("action", "[node_limiter] " .. pname .. " tried to place " .. node .. " at " .. core.pos_to_string(pos))
					core.chat_send_player(pname, core.colorize("#FF0000", S("You can't place more '@1' in this area! (Too many entities)", "Drawers")))
				else
					return old_place(itemstack, placer, pointed_thing)
				end
			end
		end,
	})
	mesecon.register_mvps_stopper(node)
end


-- limit hoppers to 10 in a 24 node radius
ov_node("hopper:hopper", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)
ov_node("hopper:hopper_side", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)
ov_node("hopper:hopper_void", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)
ov_node("minecart:hopper", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)


-- limit quarrys to 3 in a 24 node radius
local quarrys = {"techage:ta2_quarry_pas", "techage:ta2_quarry_act", "techage:ta3_quarry_pas", "techage:ta3_quarry_act", "techage:ta4_quarry_pas", "techage:ta4_quarry_act"}

for _, quarry in pairs(quarrys) do
	ov_node(quarry, quarrys, 24, 3)
end

-- limit signs_bots to 10 in a 16 node radius
ov_node("signs_bot:box", {"signs_bot:box"}, 16, 10)

for _, ndef in pairs(core.registered_nodes) do
	if ndef and ndef.name and string.match(ndef.name, "drawers:") then
		if ndef.name ~= "drawers:trim" and ndef.name ~= "drawers:controller" then
			ov_node(ndef.name, nil, nil, 70)
		end
	end
end
