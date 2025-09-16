local S = archtec.S
local C = core.colorize

-- Remove building category
if core.get_modpath("unified_inventory") then
	unified_inventory.remove_category("building")
end

-- Add mtg stairs for 'moreblocks:empty_shelf'
if core.get_modpath("moreblocks") then
	local S2 = core.get_translator("moreblocks")
	local def = core.registered_nodes["moreblocks:empty_shelf"]
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
archtec_playerdata.register_key("thank_you_last_used", "number", 0)

core.register_chatcommand("thankyou", {
	params = "<name>",
	description = "Thank someone",
	privs = {interact = true},
	func = function(name, param)
		core.log("action", "[/thankyou] executed by '" .. name .. "' with param '" .. param .. "'")
		local target = archtec.get_target(name, param)
		if target == name then
			core.chat_send_player(name, core.colorize("#FF0000", S("You can't thank yourself!")))
			return
		end
		if not archtec.is_online(target) then
			core.chat_send_player(name, core.colorize("#FF0000", S("You can't thank an offline player!")))
			return
		end
		if archtec.ignore_check(name, target) then
			archtec.ignore_msg("thankyou", name, target)
			return
		end
		if archtec_playerdata.get(name, "thank_you_last_used") > os.time() - archtec.time.hours(1) then
			core.chat_send_player(name, core.colorize("#FF0000", S("You used '/thankyou' within the last hour! Try again later.")))
			return
		end
		archtec_playerdata.mod(target, "thank_you", 1)
		archtec_playerdata.set(name, "thank_you_last_used", os.time())
		core.chat_send_all(core.colorize("#00BD00", S("@1 said thank you to @2.", name, target)))
		archtec_matterbridge.send(":wave: **" .. archtec.escape_md(name) .. "** said thank you to **" .. target .. "**.")
	end
})

-- Falling nodes cleanup command
local abr = core.settings:get("active_block_range") * 16

local function remove_falling_nodes(pos)
	local c = 0
	local objects = core.get_objects_inside_radius(pos, abr)
	for _, object in ipairs(objects) do
		local ent = object:get_luaentity()
		if ent and ent.name == "__builtin:falling_node" then
			if object:get_velocity().y == 0 then
				local pos2 = object:get_pos()
				local nodep = vector.round(pos2)
				nodep.y = nodep.y - 1
				if core.get_node(nodep).name == "air" or nodep.y < -30912 then
					core.log("action", "[falling_nodes_cleaner] remove falling entity at " .. core.pos_to_string(pos2))
					object:remove()
					c = c + 1
				end
			end
		end
	end
	return c
end

core.register_chatcommand("falling_nodes_cleanup", {
	description = "Remove stuck falling nodes",
	privs = {staff = true},
	func = function(name)
		core.log("action", "[/falling_nodes_cleanup] executed by '" .. name)
		local counter
		local player = core.get_player_by_name(name)
		if not player then
			core.chat_send_player(name, core.colorize("#FF0000", "You are not online!"))
			return
		end
		counter = remove_falling_nodes(player:get_pos())
		core.chat_send_player(name, core.colorize("#00BD00", "Removed " .. counter .. " falling node(s)"))
	end
})

-- Shutdown command
core.register_chatcommand("sd", {
	description = "Shuts the server down after a 10 seconds delay.",
	privs = {staff = true},
	func = function(name, delay)
		if delay == "" or type(tonumber(delay)) ~= "number" then delay = 10 end
		-- notify all
		local logmsg = name .. " requested a server shutdown in " .. delay .. " seconds."
		core.log("warning", logmsg)
		archtec_matterbridge.send(":anger: " .. logmsg)
		core.chat_send_all(core.colorize("#FF0", S("@1 requested a server shutdown in @2 seconds.", name, delay)))
		-- shutdown, ask for reconnect
		core.request_shutdown("The server is rebooting, please reconnect in about a minute.", true, tonumber(delay))
	end
})

-- Stairsplus support for ethereal:glostone (https://github.com/Archtec-io/bugtracker/issues/143)
if core.get_modpath("stairsplus") and core.get_modpath("ethereal") then
	local def = core.registered_nodes["ethereal:glostone"]

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

-- /map command
local url = archtec.links.mapserver .. "#!/map/0/12/" -- layer/zoomlevel
local help_str = C("#FF8800", S("Ctrl + Click the link to open your browser"))

core.register_chatcommand("map", {
	description = "Gives you an URL to the Mapserver, pointing at your current position.",
	privs = {interact = true},
	func = function(name)
		core.log("action", "[/map] executed by '" .. name .. "'")
		local player = core.get_player_by_name(name)
		if player == nil then
			core.chat_send_player(name, C("#FF0000", S("[map] You must be online to use this command!")))
			return
		end

		local pos = player:get_pos()
		if pos == nil then
			core.chat_send_player(name, C("#FF0000", S("[map] You must be online to use this command!")))
			return
		else
			local x = math.floor(pos.x + 0.5)
			local z = math.floor(pos.z + 0.5)
			core.chat_send_player(name, S("[map] You are here: @1 (@2)", url .. tostring(x) .. "/" .. tostring(z), help_str))
		end
	end
})
