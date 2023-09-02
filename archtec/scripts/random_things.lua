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

archtec.discord_link = "https://discord.gg/txCMTMwBWm"

minetest.register_chatcommand("discord", {
	description = "Discord server link",
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/discord] executed by '" .. name .. "'")
		minetest.chat_send_player(name, S("Discord server link: @1", archtec.discord_link))
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
		discord.send(nil, ":anger: " .. logmsg)
		minetest.chat_send_all(minetest.colorize("#FF0", S("@1 requested a server shutdown in @2 seconds.", name, delay)))
		-- shutdown, ask for reconnect
		minetest.request_shutdown("The server is rebooting, please reconnect in about a minute.", true, tonumber(delay))
	end
})