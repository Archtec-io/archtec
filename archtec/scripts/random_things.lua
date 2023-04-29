-- remove building category
if minetest.get_modpath("unified_inventory") then
	unified_inventory.remove_category("building")
end

if minetest.get_modpath("biome_lib") then
	biome_lib.mapgen_elevation_limit = { ["min"] = 0, ["max"] = 48 }
end

if minetest.get_modpath("moreblocks") then
	local S = minetest.get_translator("moreblocks")
	local def = minetest.registered_nodes["moreblocks:empty_shelf"]
	stairs.register_stair_and_slab(
		"moreblocks:empty_shelf",
		"moreblocks:empty_shelf",
		def.groups,
		def.tiles,
		S("@1 Stair", def.description),
		S("@1 Slab", def.description),
		def.sounds,
		true
	)
end

minetest.register_chatcommand("thankyou", {
	params = "<name>",
	description = "Thank someone",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/thankyou] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
		local target = archtec.get_target(name, param)
		if target == name then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't thank yourself"))
			return
		end
		if not archtec.is_online(target) then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't thank someone who is offline"))
			return
		end
		if archtec.ignore_check(name, target) then
			archtec.ignore_msg("thankyou", name, target)
			return
		end
		archtec_playerdata.mod(target, "thank_you", 1)
		minetest.chat_send_all(minetest.colorize("#00BD00", name .. " said thank you to " .. target))
		discord.send(nil, ":wave: **" .. name .. "** said thank you to **" .. target .. "**")
    end
})

local abr = minetest.settings:get("active_block_range") * 16

local function remove_falling_nodes(pos)
    local c = 0
    local objects = minetest.get_objects_inside_radius(pos, abr)
    for _, object in ipairs(objects) do
        local ent = object:get_luaentity()
        if ent and ent.name == "__builtin:falling_node" then
            if object:get_velocity().y == 0 then
                local pos2 = object:get_pos()
                local nodep = vector.round(pos2)
                nodep.y = nodep.y - 1
                if minetest.get_node(nodep).name == "air" or nodep.y < -30912 then
                    minetest.log("action", "[falling_nodes_cleaner] remove falling entity at " .. minetest.pos_to_string(pos2))
                    object:remove()
                    c = c + 1
                end
            end
        end
    end
    return c
end

minetest.register_chatcommand("falling_nodes_cleanup", {
	description = "Remove stuck falling nodes",
	privs = {staff = true},
	func = function(name, param)
		minetest.log("action", "[/falling_nodes_cleanup] executed by '" .. name)
		local counter
		local player = minetest.get_player_by_name(name)
		if not player then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You are not online!"))
			return
		end
		counter = remove_falling_nodes(player:get_pos())
		minetest.chat_send_player(name, minetest.colorize("#00BD00", "Removed " .. counter .. " falling node(s)"))
    end
})