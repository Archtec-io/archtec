-- possible icons: https://fontawesome.com/icons?d=gallery&s=brands,regular,solid&m=free
-- default: "home"

local update_formspec = function(meta)
	local name = meta:get_string("name")
	local icon = meta:get_string("icon") or "home"
	local url = meta:get_string("url") or ""

	meta:set_string("infotext", "POI, name:" .. name .. ", icon:" .. icon)

	meta:set_string("formspec", "size[8,4;]" ..
		-- col 1
		"field[0.2,0.5;4,1;name;Name;" .. name .. "]" ..
		"field[4.2,0.5;4,1;icon;Icon;" .. icon .. "]" ..

		-- col 2
		"field[0.2,1.5;8,1;url;URL;" .. url .. "]" ..

		-- col 3
		"button_exit[-0.1,2.5;8,1;save;Save]" ..
	"")
end

local on_receive_fields = function(pos, formname, fields, sender)
	if not mapserver.can_interact(pos, sender) then
		return
	end

	local meta = core.get_meta(pos)

	if fields.save then
		meta:set_string("name", fields.name)
		meta:set_string("url", fields.url)
		meta:set_string("icon", fields.icon or "home")
	end

	update_formspec(meta)
end

local register_poi = function(color, dye)
	core.register_node(":mapserver:poi_" .. color, {
		description = "Mapserver POI (" .. color .. ")",
		tiles = {
			"[combine:16x16:0,0=default_gold_block.png:3,2=mapserver_poi_" .. color .. ".png"
		},
		groups = {cracky = 3, oddly_breakable_by_hand = 3},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
		can_dig = mapserver.can_interact,
		after_place_node = mapserver.after_place_node,

		on_construct = function(pos)
			local meta = core.get_meta(pos)

			meta:set_string("name", "<unconfigured>")
			meta:set_string("icon", "home")
			meta:set_string("url", "")

			update_formspec(meta)
		end,

		on_receive_fields = on_receive_fields
	})
end

register_poi("blue", "blue")
register_poi("green", "green")
register_poi("orange", "orange")
register_poi("red", "red")
register_poi("purple", "violet")
