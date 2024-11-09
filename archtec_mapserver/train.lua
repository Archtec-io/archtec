local last_set_by = {}

local update_formspec = function(meta)
	local line = meta:get_string("line")
	local station = meta:get_string("station")
	local index = meta:get_string("index")
	local color = meta:get_string("color") or ""

	meta:set_string("infotext", "Train: Line=" .. line .. ", Station=" .. station)


	meta:set_string("formspec", "size[8,4;]" ..
		-- col 1
		"field[0.2,0.5;4,1;line;Line;" .. line .. "]" ..
		"button_exit[4,0.2;4,1;save;Save]" ..

		-- col 2
		"field[0.2,2;4,1;station;Station;" .. station .. "]" ..
		"field[4.3,2;4,1;index;Index;" .. index .. "]" ..

		-- col 3
		"field[0.2,3.5;4,1;color;Color;" .. color .. "]" ..
		""
	)
end

core.register_node(":mapserver:train", {
	description = "Mapserver Train",
	tiles = {
		"mapserver_train.png"
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 3, handy = 1},
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
	can_dig = mapserver.can_interact,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = core.get_meta(pos)

		local last_index = 0
		local last_line = ""
		local last_color = ""

		if core.is_player(placer) then
			local name = placer:get_player_name()
			if name ~= nil then
				if last_set_by[name] ~= nil then
					last_index = last_set_by[name].index + 5
					last_line = last_set_by[name].line
					last_color = last_set_by[name].color
				else
					last_set_by[name] = {}
				end

				last_set_by[name].index = last_index
				last_set_by[name].line = last_line
				last_set_by[name].color = last_color
			end
		end

		meta:set_string("station", "")
		meta:set_string("line", last_line)
		meta:set_int("index", last_index)
		meta:set_string("color", last_color)

		update_formspec(meta)

		return mapserver.after_place_node(pos, placer, itemstack, pointed_thing)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		if not mapserver.can_interact(pos, sender) then
			return
		end

		local meta = core.get_meta(pos)
		local name = sender:get_player_name()

		if fields.save then
			if last_set_by[name] == nil then
				last_set_by[name] = {}
			end

			local index = tonumber(fields.index) or 0

			meta:set_string("color", fields.color)
			meta:set_string("line", fields.line)
			meta:set_string("station", fields.station)
			meta:set_int("index", index)

			last_set_by[name].color = fields.color
			last_set_by[name].line = fields.line
			last_set_by[name].station = fields.station
			last_set_by[name].index = index
		end

		update_formspec(meta)
	end
})
