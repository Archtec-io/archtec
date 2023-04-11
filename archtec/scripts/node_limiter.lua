local function generate_vector(pos, rad)
    return vector.new(pos.x + rad, pos.y + rad, pos.z + rad)
end

local function ov_node(node, t, rad, max)
    local old_place = minetest.registered_items[node].on_place or function() end
    minetest.override_item(node, {
        on_place = function(itemstack, placer, pointed_thing)
            local pos = pointed_thing.under
            local count = minetest.find_nodes_in_area(generate_vector(pos, tonumber(-rad)), generate_vector(pos, tonumber(rad)), t)
            if #count < max then
                return old_place(itemstack, placer, pointed_thing)
            else
                local pname = placer:get_player_name()
                minetest.log("action", "[node_limiter] " .. pname ..  " tried to place " .. node .. " at " .. minetest.pos_to_string(pos))
                local n = minetest.registered_nodes[node].description or node
                minetest.chat_send_player(pname, minetest.colorize("#FF0000", "You can't place more '" .. n .. "' in this area!"))
            end
        end,
    })
end


-- limit hoppers to 10 in a 24 radius
ov_node("hopper:hopper", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)
ov_node("hopper:hopper_side", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)
ov_node("hopper:hopper_void", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)
ov_node("minecart:hopper", {"hopper:hopper", "hopper:hopper_side", "hopper:hopper_void", "minecart:hopper"}, 24, 10)


-- limit quarrys to 3 in a 24 radius
local quarrys = {"techage:ta2_quarry_pas", "techage:ta2_quarry_act", "techage:ta3_quarry_pas", "techage:ta3_quarry_act", "techage:ta4_quarry_pas", "techage:ta4_quarry_act"}

for _, quarry in pairs(quarrys) do
    ov_node(quarry, quarrys, 24, 3)
end