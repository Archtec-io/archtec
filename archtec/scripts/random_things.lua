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
    description = "Shows player stats",
	privs = {interact = true},
    func = function(name, param)
        local target = archtec.get_target(name, param)
		if target == name then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't thank yourself"))
			return
		end
		if not archtec.is_online(target) then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't thank someone who is offline"))
			return
		end
		archtec_playerdata.mod(target, "thank_you", 1)
		minetest.chat_send_all(minetest.colorize("#00BD00", name .. " said thank you to " .. target))
		discord.send(nil, ":wave: " .. name .. " said thank you to " .. target)
    end
})