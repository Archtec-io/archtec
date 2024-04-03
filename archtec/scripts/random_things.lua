local S = archtec.S
-- remove building category
if minetest.get_modpath("unified_inventory") then
	unified_inventory.remove_category("building")
end

if minetest.get_modpath("biome_lib") then
	biome_lib.mapgen_elevation_limit = { ["min"] = 0, ["max"] = 48 }
end

if minetest.get_modpath("moreblocks") then
	local S2 = minetest.get_translator("moreblocks")
	local def = minetest.registered_nodes["moreblocks:empty_shelf"]
	stairs.register_stair_and_slab(
		"moreblocks:empty_shelf",
		"moreblocks:empty_shelf",
		def.groups,
		def.tiles,
		S2("@1 Stair", def.description),
		S2("@1 Slab", def.description),
		def.sounds,
		true
	)
end

-- Thankyou command
archtec_playerdata.register_key("thank_you", "number", 0)

minetest.register_chatcommand("thankyou", {
	params = "<name>",
	description = "Thank someone",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/thankyou] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
		local target = archtec.get_target(name, param)
		if target == name then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", S("You can't thank yourself")))
			return
		end
		if not archtec.is_online(target) then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", S("You can't thank someone who is offline")))
			return
		end
		if archtec.ignore_check(name, target) then
			archtec.ignore_msg("thankyou", name, target)
			return
		end
		archtec_playerdata.mod(target, "thank_you", 1)
		minetest.chat_send_all(minetest.colorize("#00BD00", S("@1 said thank you to @2", name, target)))
		archtec_matterbridge.send(":wave: **" .. name .. "** said thank you to **" .. target .. "**")
	end
})

-- Falling nodes cleanup command
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
	func = function(name)
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

minetest.register_chatcommand("sd", {
	description = "Shuts the server down after a 10 seconds delay.",
	privs = {staff = true},
	func = function(name, delay)
		if delay == "" or type(tonumber(delay)) ~= "number" then delay = 10 end
		-- notify all
		local logmsg = name .. " requested a server shutdown in " .. delay .. " seconds."
		minetest.log("warning", logmsg)
		archtec_matterbridge.send(":anger: " .. logmsg)
		minetest.chat_send_all(minetest.colorize("#FF0", S("@1 requested a server shutdown in @2 seconds.", name, delay)))
		-- shutdown, ask for reconnect
		minetest.request_shutdown("The server is rebooting, please reconnect in about a minute.", true, tonumber(delay))
	end
})

-- Stairsplus support for ethereal:glostone (https://github.com/Archtec-io/bugtracker/issues/143)
if minetest.get_modpath("stairsplus") and minetest.get_modpath("ethereal") then
	local def = minetest.registered_nodes["ethereal:glostone"]

	stairsplus:register_all("ethereal", "glostone", "ethereal:glostone", {
		description = def.description,
		tiles = def.texture,
		groups = def.groups,
		sounds = def.sound
	})
end

-- Areas shortcommands
archtec.register_chatcommand_alias("so", "set_owner")
archtec.register_chatcommand_alias("ao", "add_owner")
archtec.register_chatcommand_alias("sa", "select_area")
archtec.register_chatcommand_alias("p1", "area_pos1")
archtec.register_chatcommand_alias("p2", "area_pos2")